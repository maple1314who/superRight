import Foundation
import Shared

/// Finder Extension 侧动作执行错误。
///
/// 当前主路径已尽量转交主 App 执行，该错误仍用于可在扩展内安全完成的动作
/// 和单元测试覆盖。
public enum ActionDispatchError: Error, Equatable {
    case missingFileNameConfiguration
    case missingDestinationPath
    case missingSelectedItems
    case commandFailed(Int32)
    case clipboardWriteFailed
    case invalidDirectory
}

/// Finder Extension 内的动作执行器。
///
/// 只处理扩展进程可以稳定完成的动作；涉及沙盒权限或用户交互的动作优先
/// 由主 App 通过 `AppExecutionRequest` 执行。
public final class ActionDispatcher {
    private let fileManager: FileManager
    private let commandRunner: CommandRunning
    private let clipboardWriter: ClipboardWriting

    public init(
        fileManager: FileManager = .default,
        commandRunner: CommandRunning = ProcessCommandRunner(),
        clipboardWriter: ClipboardWriting = NSPasteboardWriter()
    ) {
        self.fileManager = fileManager
        self.commandRunner = commandRunner
        self.clipboardWriter = clipboardWriter
    }

    /// 执行一个菜单动作，并返回被创建、打开或处理的目标 URL。
    @discardableResult
    public func execute(
        item: MenuDisplayItem,
        context: FinderSelectionContext,
        configuration: SharedConfiguration
    ) throws -> URL? {
        NSLog("ActionDispatcher.execute start id=%@ title=%@ type=%@ scene=%@ currentDir=%@",
              item.id,
              item.title,
              item.actionType.rawValue,
              context.scene.rawValue,
              context.currentDirectoryURL.path
        )
        switch item.actionType {
        case .createFolder:
            let created = try createFolder(in: context.currentDirectoryURL)
            NSLog("ActionDispatcher.execute createFolder result=%@", created.path)
            return created
        case .createFile:
            let created = try createFile(item: item, in: context.currentDirectoryURL)
            NSLog("ActionDispatcher.execute createFile result=%@", created.path)
            return created
        case .openTerminal:
            let opened = try openApplication(.terminal, context: context, configuration: configuration)
            NSLog("ActionDispatcher.execute openTerminal target=%@", opened.path)
            return opened
        case .openITerm:
            let opened = try openApplication(.iTerm, context: context, configuration: configuration)
            NSLog("ActionDispatcher.execute openITerm target=%@", opened.path)
            return opened
        case .openVSCode:
            let opened = try openApplication(.vsCode, context: context, configuration: configuration)
            NSLog("ActionDispatcher.execute openVSCode target=%@", opened.path)
            return opened
        case .openCursor:
            let opened = try openApplication(.cursor, context: context, configuration: configuration)
            NSLog("ActionDispatcher.execute openCursor target=%@", opened.path)
            return opened
        case .openIdea:
            let opened = try openApplication(.idea, context: context, configuration: configuration)
            NSLog("ActionDispatcher.execute openIdea target=%@", opened.path)
            return opened
        case .copyPath:
            let targetURL = targetURLForCopy(context: context)
            try clipboardWriter.copy(text: targetURL.path)
            NSLog("ActionDispatcher.execute copyPath target=%@", targetURL.path)
            return targetURL
        case .copyToDirectory:
            let destinationURL = try transferSelectedItems(item: item, context: context, shouldMove: false)
            NSLog("ActionDispatcher.execute copyToDirectory destination=%@", destinationURL.path)
            return destinationURL
        case .moveToDirectory:
            let destinationURL = try transferSelectedItems(item: item, context: context, shouldMove: true)
            NSLog("ActionDispatcher.execute moveToDirectory destination=%@", destinationURL.path)
            return destinationURL
        case .openDirectory:
            let directoryURL = try openDirectory(item: item)
            NSLog("ActionDispatcher.execute openDirectory destination=%@", directoryURL.path)
            return directoryURL
        case .applyFileIcon, .removeCustomIcon:
            NSLog("ActionDispatcher.execute file icon action forwarded-only type=%@", item.actionType.rawValue)
            return nil
        case .showFileInfo, .copyFileName, .createFolderFromFileName,
             .hideSelectedItems, .unhideSelectedItems, .hideDirectoryItems, .unhideDirectoryItems:
            NSLog("ActionDispatcher.execute toolbox action forwarded-only type=%@", item.actionType.rawValue)
            return nil
        }
    }

    private func createFolder(in directoryURL: URL) throws -> URL {
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

    private func createFile(item: MenuDisplayItem, in directoryURL: URL) throws -> URL {
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

            let content = item.templateContent ?? ""
            try content.data(using: .utf8)?.write(to: destinationURL)
            return destinationURL
        }
    }

    private func openApplication(
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
        NSLog("ActionDispatcher.openApplication app=%@ arg=%@ target=%@ status=%d",
              application.rawValue,
              appArgument,
              targetURL.path,
              status
        )

        if status != 0 {
            throw ActionDispatchError.commandFailed(status)
        }
        return targetURL
    }

    private func targetURLForCopy(context: FinderSelectionContext) -> URL {
        context.primarySelectedURL ?? context.currentDirectoryURL
    }

    private func transferSelectedItems(
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

    private func openDirectory(item: MenuDisplayItem) throws -> URL {
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
