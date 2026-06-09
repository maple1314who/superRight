import Foundation
import Shared

/// 文件系统动作适配器。
///
/// 负责封装 Finder Extension 内可直接执行的文件系统操作，包括安全作用域访问、
/// 冲突命名、Finder AppleScript 兜底创建文件夹等平台细节。策略层只表达“创建”
/// 或“移动”，不关心这些 macOS 具体实现。
public final class FileSystemActionAdapter {
    private let fileManager: FileManager
    private let commandRunner: CommandRunning

    public init(
        fileManager: FileManager = .default,
        commandRunner: CommandRunning = ProcessCommandRunner()
    ) {
        self.fileManager = fileManager
        self.commandRunner = commandRunner
    }

    public func createFolder(in directoryURL: URL) throws -> URL {
        try withSecurityScopedAccess(to: directoryURL) {
            try ensureDirectoryExists(directoryURL)

            let destinationURL = FileNameConflictResolver.nextAvailableURL(
                in: directoryURL,
                baseName: "新建文件夹",
                pathExtension: nil,
                fileManager: fileManager
            )
            do {
                try fileManager.createDirectory(
                    at: destinationURL,
                    withIntermediateDirectories: false
                )
                return destinationURL
            } catch {
                if isPermissionDenied(error),
                   let fallbackURL = try createFolderViaFinder(directoryURL: directoryURL) {
                    NSLog("ActionDispatcher.createFolder fallbackByFinder success path=%@",
                          fallbackURL.path
                    )
                    return fallbackURL
                }
                throw error
            }
        }
    }

    public func createFile(item: MenuDisplayItem, in directoryURL: URL) throws -> URL {
        try withSecurityScopedAccess(to: directoryURL) {
            try ensureDirectoryExists(directoryURL)

            guard let defaultFileName = item.defaultFileName else {
                throw ActionDispatchError.missingFileNameConfiguration
            }

            let explicitExtension = item.fileExtension?.trimmingCharacters(
                in: CharacterSet(charactersIn: ".")
            )
            let extensionFromName = URL(filePath: defaultFileName).pathExtension
            let fileExtension = (explicitExtension?.isEmpty == false ? explicitExtension : extensionFromName)
            let defaultBaseName = URL(filePath: defaultFileName)
                .deletingPathExtension()
                .lastPathComponent

            let destinationURL = FileNameConflictResolver.nextAvailableURL(
                in: directoryURL,
                baseName: defaultBaseName.isEmpty ? "Untitled" : defaultBaseName,
                pathExtension: fileExtension,
                fileManager: fileManager
            )

            if let templateData = item.templateData {
                try templateData.write(to: destinationURL)
            } else {
                let content = item.templateContent ?? ""
                try content.data(using: .utf8)?.write(to: destinationURL)
            }
            return destinationURL
        }
    }

    public func transferSelectedItems(
        item: MenuDisplayItem,
        context: FinderSelectionContext,
        shouldMove: Bool
    ) throws -> URL {
        guard let destinationPath = item.destinationPath,
              !destinationPath.isEmpty else {
            throw ActionDispatchError.missingDestinationPath
        }
        guard !context.selectedItemURLs.isEmpty else {
            throw ActionDispatchError.missingSelectedItems
        }

        let destinationDirectoryURL = URL(fileURLWithPath: destinationPath, isDirectory: true)
        try withSecurityScopedAccess(to: destinationDirectoryURL) {
            try ensureDirectoryExists(destinationDirectoryURL)
            for sourceURL in context.selectedItemURLs {
                let destinationURL = availableTransferDestination(
                    sourceURL: sourceURL,
                    destinationDirectoryURL: destinationDirectoryURL
                )
                if shouldMove {
                    try fileManager.moveItem(at: sourceURL, to: destinationURL)
                } else {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                }
            }
        }
        return destinationDirectoryURL
    }

    public func openDirectory(item: MenuDisplayItem) throws -> URL {
        guard let destinationPath = item.destinationPath,
              !destinationPath.isEmpty else {
            throw ActionDispatchError.missingDestinationPath
        }

        let directoryURL = URL(fileURLWithPath: destinationPath, isDirectory: true)
        try ensureDirectoryExists(directoryURL)
        let status = try commandRunner.run(
            executable: "/usr/bin/open",
            arguments: [directoryURL.path]
        )
        if status != 0 {
            throw ActionDispatchError.commandFailed(status)
        }
        return directoryURL
    }

    private func availableTransferDestination(
        sourceURL: URL,
        destinationDirectoryURL: URL
    ) -> URL {
        FileNameConflictResolver.nextAvailableURL(
            in: destinationDirectoryURL,
            baseName: sourceURL.deletingPathExtension().lastPathComponent,
            pathExtension: sourceURL.pathExtension.isEmpty ? nil : sourceURL.pathExtension,
            fileManager: fileManager
        )
    }

    private func ensureDirectoryExists(_ url: URL) throws {
        if !SelectionSceneResolver.isDirectory(url, fileManager: fileManager) {
            throw ActionDispatchError.invalidDirectory
        }
    }

    private func withSecurityScopedAccess<T>(to url: URL, _ body: () throws -> T) throws -> T {
        let didStart = url.startAccessingSecurityScopedResource()
        if didStart {
            NSLog("ActionDispatcher.securityScope start path=%@", url.path)
        } else {
            NSLog("ActionDispatcher.securityScope start skipped path=%@", url.path)
        }

        defer {
            if didStart {
                url.stopAccessingSecurityScopedResource()
                NSLog("ActionDispatcher.securityScope stop path=%@", url.path)
            }
        }

        return try body()
    }

    private func isPermissionDenied(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileWriteNoPermissionError {
            return true
        }
        if nsError.domain == NSPOSIXErrorDomain && nsError.code == Int(EPERM) {
            return true
        }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            if underlying.domain == NSPOSIXErrorDomain && underlying.code == Int(EPERM) {
                return true
            }
        }
        return false
    }

    private func createFolderViaFinder(directoryURL: URL) throws -> URL? {
        let baseName = "新建文件夹"
        for index in 0..<20 {
            let folderName = index == 0 ? baseName : "\(baseName) \(index + 1)"
            let candidateURL = directoryURL.appendingPathComponent(folderName, isDirectory: true)
            if fileManager.fileExists(atPath: candidateURL.path) {
                continue
            }

            let script = """
            tell application "Finder"
                set targetFolder to POSIX file "\(escapeAppleScript(directoryURL.path))" as alias
                make new folder at targetFolder with properties {name:"\(escapeAppleScript(folderName))"}
            end tell
            """
            let status = try commandRunner.run(
                executable: "/usr/bin/osascript",
                arguments: ["-e", script]
            )
            NSLog("ActionDispatcher.createFolder fallbackByFinder name=%@ status=%d",
                  folderName,
                  status
            )
            if status == 0 {
                return candidateURL
            }
        }
        return nil
    }

    private func escapeAppleScript(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

/// 外部 App 打开适配器。
///
/// 该适配器是系统版本差异的隔离层。当前 Finder Extension 统一使用 `/usr/bin/open`
/// 兼容旧 macOS；后续如果某些系统版本需要切到 LaunchServices、`NSWorkspace`
/// 或 App 专用 URL Scheme，只需要替换这里的实现。
public final class ExternalApplicationActionAdapter {
    private let commandRunner: CommandRunning
    private let fileManager: FileManager
    private let systemVersionProvider: SystemVersionProviding

    public init(
        commandRunner: CommandRunning = ProcessCommandRunner(),
        fileManager: FileManager = .default,
        systemVersionProvider: SystemVersionProviding = ProcessInfoSystemVersionProvider()
    ) {
        self.commandRunner = commandRunner
        self.fileManager = fileManager
        self.systemVersionProvider = systemVersionProvider
    }

    public func openApplication(
        _ application: ExternalApplication,
        context: FinderSelectionContext,
        configuration: SharedConfiguration
    ) throws -> URL {
        let targetURL = targetURLForOpen(actionType: application, context: context)
        let configuredPath = configuration.applicationPaths[application]
        let appArgument: String

        if let configuredPath, !configuredPath.isEmpty, fileManager.fileExists(atPath: configuredPath) {
            appArgument = configuredPath
        } else {
            appArgument = application.openArgument
        }

        let status = try commandRunner.run(
            executable: "/usr/bin/open",
            arguments: ["-a", appArgument, targetURL.path]
        )
        let osVersion = systemVersionProvider.operatingSystemVersion
        NSLog("ActionDispatcher.openApplication app=%@ arg=%@ target=%@ status=%d os=%ld.%ld.%ld",
              application.rawValue,
              appArgument,
              targetURL.path,
              status,
              osVersion.majorVersion,
              osVersion.minorVersion,
              osVersion.patchVersion
        )

        if status != 0 {
            throw ActionDispatchError.commandFailed(status)
        }
        return targetURL
    }

    private func targetURLForOpen(
        actionType: ExternalApplication,
        context: FinderSelectionContext
    ) -> URL {
        switch actionType {
        case .terminal, .iTerm:
            if context.scene == .folder, let selected = context.primarySelectedURL {
                return selected
            }
            return context.currentDirectoryURL
        case .vsCode, .cursor, .idea:
            return context.primarySelectedURL ?? context.currentDirectoryURL
        }
    }
}
