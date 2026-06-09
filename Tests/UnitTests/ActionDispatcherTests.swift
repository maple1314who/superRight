import XCTest
@testable import ExtensionCore
@testable import Shared

private final class MockCommandRunner: CommandRunning {
    struct Invocation: Equatable {
        let executable: String
        let arguments: [String]
    }

    var invocations: [Invocation] = []
    var nextStatus: Int32 = 0

    @discardableResult
    func run(executable: String, arguments: [String]) throws -> Int32 {
        invocations.append(Invocation(executable: executable, arguments: arguments))
        return nextStatus
    }
}

private final class MockClipboardWriter: ClipboardWriting {
    private(set) var copiedText: String?

    func copy(text: String) throws {
        copiedText = text
    }
}

private final class SpyActionExecutionObserver: ActionExecutionObserving {
    private(set) var willExecuteActionTypes: [MenuActionType] = []
    private(set) var finishedActionTypes: [MenuActionType] = []
    private(set) var failedActionTypes: [MenuActionType] = []

    func actionWillExecute(_ request: ActionExecutionRequestContext) {
        willExecuteActionTypes.append(request.item.actionType)
    }

    func actionDidFinish(_ request: ActionExecutionRequestContext, resultURL: URL?) {
        finishedActionTypes.append(request.item.actionType)
    }

    func actionDidFail(_ request: ActionExecutionRequestContext, error: Error) {
        failedActionTypes.append(request.item.actionType)
    }
}

final class ActionDispatcherTests: XCTestCase {
    func testV4PreflightChainPrioritizesDestinationPathBeforeSelection() throws {
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter(),
            observers: []
        )
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            id: "copy_to_missing_destination",
            title: "复制到缺失目标",
            order: 0,
            group: .tool,
            actionType: .copyToDirectory,
            targetApplication: nil,
            fileExtension: nil,
            defaultFileName: nil,
            templateContent: nil,
            destinationPath: nil
        )

        XCTAssertThrowsError(
            try dispatcher.execute(item: item, context: context, configuration: .default)
        ) { error in
            XCTAssertEqual(error as? ActionDispatchError, .missingDestinationPath)
        }
    }

    func testV4PreflightFailureNotifiesObserver() throws {
        let observer = SpyActionExecutionObserver()
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter(),
            observers: [observer]
        )
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            id: "new_invalid_file",
            title: "新建无效文件",
            order: 0,
            group: .create,
            actionType: .createFile,
            targetApplication: nil,
            fileExtension: nil,
            defaultFileName: nil,
            templateContent: nil
        )

        XCTAssertThrowsError(
            try dispatcher.execute(item: item, context: context, configuration: .default)
        ) { error in
            XCTAssertEqual(error as? ActionDispatchError, .missingFileNameConfiguration)
        }
        XCTAssertEqual(observer.willExecuteActionTypes, [.createFile])
        XCTAssertEqual(observer.finishedActionTypes, [])
        XCTAssertEqual(observer.failedActionTypes, [.createFile])
    }

    func testV4FactoryProvidesForwardedOnlyStrategyForAppOnlyActions() throws {
        let strategy = MenuActionStrategyFactory().makeStrategy(for: .applyFileIcon)
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let request = ActionExecutionRequestContext(
            item: MenuDisplayItem(
                id: "apply_icon",
                title: "应用图标",
                order: 0,
                group: .tool,
                actionType: .applyFileIcon,
                targetApplication: nil,
                fileExtension: nil,
                defaultFileName: nil,
                templateContent: nil
            ),
            finderContext: FinderSelectionContext(
                selectedItemURLs: [],
                currentDirectoryURL: temporaryDirectory.url
            ),
            configuration: .default
        )
        let adapters = ActionExecutionAdapters(
            fileSystem: FileSystemActionAdapter(
                fileManager: .default,
                commandRunner: MockCommandRunner()
            ),
            externalApplications: ExternalApplicationActionAdapter(
                commandRunner: MockCommandRunner()
            ),
            clipboardWriter: MockClipboardWriter()
        )

        let resultURL = try strategy.execute(request: request, adapters: adapters)

        XCTAssertNil(resultURL)
    }

    func testV4ObserverReceivesActionLifecycleEvents() throws {
        let observer = SpyActionExecutionObserver()
        let clipboardWriter = MockClipboardWriter()
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: clipboardWriter,
            observers: [observer]
        )
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            configuration: SharedConfiguration.default.menuItems.first { $0.id == "copy_path" }!
        )

        _ = try dispatcher.execute(item: item, context: context, configuration: .default)

        XCTAssertEqual(observer.willExecuteActionTypes, [.copyPath])
        XCTAssertEqual(observer.finishedActionTypes, [.copyPath])
        XCTAssertEqual(observer.failedActionTypes, [])
        XCTAssertEqual(clipboardWriter.copiedText, temporaryDirectory.url.path)
    }

    func testCreateFileWithConflictNaming() throws {
        let commandRunner = MockCommandRunner()
        let clipboardWriter = MockClipboardWriter()
        let dispatcher = ActionDispatcher(
            commandRunner: commandRunner,
            clipboardWriter: clipboardWriter
        )

        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )

        let fileItem = MenuDisplayItem(
            id: "new_text",
            title: "新建文本文件",
            order: 0,
            group: .create,
            actionType: .createFile,
            targetApplication: nil,
            fileExtension: "txt",
            defaultFileName: "Untitled.txt",
            templateContent: ""
        )

        let firstFileURL = try dispatcher.execute(
            item: fileItem,
            context: context,
            configuration: .default
        )
        let secondFileURL = try dispatcher.execute(
            item: fileItem,
            context: context,
            configuration: .default
        )

        XCTAssertEqual(firstFileURL?.lastPathComponent, "Untitled.txt")
        XCTAssertEqual(secondFileURL?.lastPathComponent, "Untitled 2.txt")
        let content = try String(contentsOf: firstFileURL!, encoding: .utf8)
        XCTAssertEqual(content, "")
    }

    func testCreateFileWritesImportedTemplateData() throws {
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter()
        )
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )
        let templateData = Data([0x00, 0x01, 0x02, 0xFF])

        let fileItem = MenuDisplayItem(
            id: "new_binary",
            title: "新建二进制模板",
            order: 0,
            group: .create,
            actionType: .createFile,
            targetApplication: nil,
            fileExtension: "bin",
            defaultFileName: "Template.bin",
            templateContent: "fallback",
            templateData: templateData
        )

        let fileURL = try dispatcher.execute(
            item: fileItem,
            context: context,
            configuration: .default
        )

        XCTAssertEqual(fileURL?.lastPathComponent, "Template.bin")
        XCTAssertEqual(try Data(contentsOf: fileURL!), templateData)
    }

    func testCreateFolderWithConflictNaming() throws {
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter()
        )
        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: temporaryDirectory.url
        )
        let folderItem = MenuDisplayItem(
            configuration: SharedConfiguration.default.menuItems.first { $0.id == "new_folder" }!
        )

        let firstFolder = try dispatcher.execute(item: folderItem, context: context, configuration: .default)
        let secondFolder = try dispatcher.execute(item: folderItem, context: context, configuration: .default)

        XCTAssertEqual(firstFolder?.lastPathComponent, "新建文件夹")
        XCTAssertEqual(secondFolder?.lastPathComponent, "新建文件夹 2")
    }

    func testCopyPathCopiesSelectedFilePath() throws {
        let clipboardWriter = MockClipboardWriter()
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: clipboardWriter
        )

        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let fileURL = temporaryDirectory.url.appendingPathComponent("README.md")
        try "text".data(using: .utf8)?.write(to: fileURL)

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            configuration: SharedConfiguration.default.menuItems.first { $0.id == "copy_path" }!
        )

        let resultURL = try dispatcher.execute(item: item, context: context, configuration: .default)

        XCTAssertEqual(resultURL, fileURL)
        XCTAssertEqual(clipboardWriter.copiedText, fileURL.path)
    }

    func testCopyToDirectoryCopiesSelectedFileWithConflictNaming() throws {
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter()
        )
        let sourceDirectory = try TemporaryDirectory()
        defer { sourceDirectory.remove() }
        let destinationDirectory = try TemporaryDirectory()
        defer { destinationDirectory.remove() }
        let sourceURL = sourceDirectory.url.appendingPathComponent("sample.txt")
        let existingURL = destinationDirectory.url.appendingPathComponent("sample.txt")
        try "source".data(using: .utf8)?.write(to: sourceURL)
        try "existing".data(using: .utf8)?.write(to: existingURL)

        let context = FinderSelectionContext(
            selectedItemURLs: [sourceURL],
            currentDirectoryURL: sourceDirectory.url
        )
        let item = MenuDisplayItem(
            id: "copy_to_target",
            title: "复制到目标",
            order: 0,
            group: .tool,
            actionType: .copyToDirectory,
            targetApplication: nil,
            fileExtension: nil,
            defaultFileName: nil,
            templateContent: nil,
            destinationPath: destinationDirectory.url.path
        )

        let resultURL = try dispatcher.execute(item: item, context: context, configuration: .default)

        XCTAssertEqual(resultURL?.path, destinationDirectory.url.path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertEqual(
            try String(contentsOf: destinationDirectory.url.appendingPathComponent("sample 2.txt"), encoding: .utf8),
            "source"
        )
    }

    func testMoveToDirectoryMovesSelectedFile() throws {
        let dispatcher = ActionDispatcher(
            commandRunner: MockCommandRunner(),
            clipboardWriter: MockClipboardWriter()
        )
        let sourceDirectory = try TemporaryDirectory()
        defer { sourceDirectory.remove() }
        let destinationDirectory = try TemporaryDirectory()
        defer { destinationDirectory.remove() }
        let sourceURL = sourceDirectory.url.appendingPathComponent("sample.txt")
        try "source".data(using: .utf8)?.write(to: sourceURL)

        let context = FinderSelectionContext(
            selectedItemURLs: [sourceURL],
            currentDirectoryURL: sourceDirectory.url
        )
        let item = MenuDisplayItem(
            id: "move_to_target",
            title: "移动到目标",
            order: 0,
            group: .tool,
            actionType: .moveToDirectory,
            targetApplication: nil,
            fileExtension: nil,
            defaultFileName: nil,
            templateContent: nil,
            destinationPath: destinationDirectory.url.path
        )

        let resultURL = try dispatcher.execute(item: item, context: context, configuration: .default)

        XCTAssertEqual(resultURL?.path, destinationDirectory.url.path)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationDirectory.url.appendingPathComponent("sample.txt").path))
    }

    func testOpenDirectoryUsesOpenCommand() throws {
        let commandRunner = MockCommandRunner()
        let dispatcher = ActionDispatcher(
            commandRunner: commandRunner,
            clipboardWriter: MockClipboardWriter()
        )
        let destinationDirectory = try TemporaryDirectory()
        defer { destinationDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: destinationDirectory.url
        )
        let item = MenuDisplayItem(
            id: "favorite_directory_workspace",
            title: "打开工作区",
            order: 0,
            group: .tool,
            actionType: .openDirectory,
            targetApplication: nil,
            fileExtension: nil,
            defaultFileName: nil,
            templateContent: nil,
            destinationPath: destinationDirectory.url.path
        )

        let resultURL = try dispatcher.execute(item: item, context: context, configuration: .default)

        XCTAssertEqual(resultURL?.path, destinationDirectory.url.path)
        XCTAssertEqual(commandRunner.invocations.count, 1)
        XCTAssertEqual(commandRunner.invocations.first?.executable, "/usr/bin/open")
        XCTAssertEqual(commandRunner.invocations.first?.arguments, [destinationDirectory.url.path])
    }

    func testOpenTerminalUsesConfiguredPathWhenInstalled() throws {
        let commandRunner = MockCommandRunner()
        let dispatcher = ActionDispatcher(
            commandRunner: commandRunner,
            clipboardWriter: MockClipboardWriter()
        )

        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let selectedFolder = temporaryDirectory.url.appendingPathComponent("Selected")
        try FileManager.default.createDirectory(at: selectedFolder, withIntermediateDirectories: true)

        let mockTerminalPath = temporaryDirectory.url.appendingPathComponent("Terminal.app")
        try FileManager.default.createDirectory(at: mockTerminalPath, withIntermediateDirectories: true)

        var configuration = SharedConfiguration.default
        configuration.applicationPaths[.terminal] = mockTerminalPath.path

        let context = FinderSelectionContext(
            selectedItemURLs: [selectedFolder],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            configuration: configuration.menuItems.first { $0.id == "open_terminal" }!
        )

        _ = try dispatcher.execute(item: item, context: context, configuration: configuration)

        XCTAssertEqual(commandRunner.invocations.count, 1)
        XCTAssertEqual(
            commandRunner.invocations.first?.arguments,
            ["-a", mockTerminalPath.path, selectedFolder.path]
        )
    }

    func testOpenIdeaUsesConfiguredPathWhenInstalled() throws {
        let commandRunner = MockCommandRunner()
        let dispatcher = ActionDispatcher(
            commandRunner: commandRunner,
            clipboardWriter: MockClipboardWriter()
        )

        let temporaryDirectory = try TemporaryDirectory()
        defer { temporaryDirectory.remove() }
        let selectedFolder = temporaryDirectory.url.appendingPathComponent("Workspace")
        try FileManager.default.createDirectory(at: selectedFolder, withIntermediateDirectories: true)

        let mockIdeaPath = temporaryDirectory.url.appendingPathComponent("IntelliJ IDEA.app")
        try FileManager.default.createDirectory(at: mockIdeaPath, withIntermediateDirectories: true)

        var configuration = SharedConfiguration.default
        configuration.applicationPaths[.idea] = mockIdeaPath.path

        let context = FinderSelectionContext(
            selectedItemURLs: [selectedFolder],
            currentDirectoryURL: temporaryDirectory.url
        )
        let item = MenuDisplayItem(
            configuration: configuration.menuItems.first { $0.id == "open_idea" }!
        )

        _ = try dispatcher.execute(item: item, context: context, configuration: configuration)

        XCTAssertEqual(commandRunner.invocations.count, 1)
        XCTAssertEqual(
            commandRunner.invocations.first?.arguments,
            ["-a", mockIdeaPath.path, selectedFolder.path]
        )
    }
}
