import XCTest
@testable import ExtensionCore
@testable import Shared

private struct MockAvailabilityChecker: ApplicationAvailabilityChecking {
    let unavailableApps: Set<ExternalApplication>

    func isInstalled(application: ExternalApplication, configuredPath: String?) -> Bool {
        !unavailableApps.contains(application)
    }
}

final class MenuBuilderTests: XCTestCase {
    func testBlankSpaceSceneFiltersMenuItems() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let configuration = SharedConfiguration.default
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let ids = Set(menu.map(\.id))

        XCTAssertTrue(ids.contains("new_folder"))
        XCTAssertTrue(ids.contains("open_terminal"))
        XCTAssertTrue(ids.contains("open_iterm"))
        XCTAssertTrue(ids.contains("open_vscode"))
        XCTAssertTrue(ids.contains("open_idea"))
        XCTAssertTrue(ids.contains("copy_path"))
        XCTAssertFalse(ids.contains("open_cursor"))
        XCTAssertFalse(ids.contains("new_markdown"))
    }

    func testFileSceneOnlyShowsAllowedItems() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: .default)
        let ids = Set(menu.map(\.id))

        XCTAssertTrue(ids.contains("open_vscode"))
        XCTAssertTrue(ids.contains("open_idea"))
        XCTAssertTrue(ids.contains("copy_path"))
        XCTAssertFalse(ids.contains("new_folder"))
        XCTAssertFalse(ids.contains("open_terminal"))
        XCTAssertFalse(ids.contains("open_iterm"))
    }

    func testFolderSceneShowsTerminalAction() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let selectedFolder = tempDirectory.url.appendingPathComponent("Project")
        try FileManager.default.createDirectory(at: selectedFolder, withIntermediateDirectories: true)

        let context = FinderSelectionContext(
            selectedItemURLs: [selectedFolder],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: .default)
        let ids = Set(menu.map(\.id))

        XCTAssertTrue(ids.contains("open_terminal"))
        XCTAssertTrue(ids.contains("open_iterm"))
        XCTAssertTrue(ids.contains("open_vscode"))
        XCTAssertTrue(ids.contains("open_idea"))
        XCTAssertTrue(ids.contains("copy_path"))
        XCTAssertFalse(ids.contains("new_json"))
    }

    func testUnavailableApplicationIsHiddenWhenConfigured() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [.iTerm, .vsCode, .idea])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        var configuration = SharedConfiguration.default
        configuration.appSettings.hideUnavailableApplications = true

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let ids = Set(menu.map(\.id))

        XCTAssertFalse(ids.contains("open_iterm"))
        XCTAssertFalse(ids.contains("open_vscode"))
        XCTAssertFalse(ids.contains("open_idea"))
        XCTAssertTrue(ids.contains("open_terminal"))
    }

    func testEnabledNewFileTemplatesAreAddedToCreateMenu() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        var configuration = SharedConfiguration.default
        configuration.newFileTemplates = [
            NewFileTemplateConfiguration(
                id: "json",
                isEnabled: true,
                title: "JSON",
                fileExtension: "json",
                showInMainMenu: false,
                order: 0,
                defaultFileName: "Untitled.json",
                templateContent: "{}\n",
                systemImageName: "curlybraces",
                iconColorName: "blue"
            ),
            NewFileTemplateConfiguration(
                id: "disabled",
                isEnabled: false,
                title: "Disabled",
                fileExtension: "disabled",
                showInMainMenu: false,
                order: 1,
                defaultFileName: "Untitled.disabled",
                systemImageName: "doc",
                iconColorName: "gray"
            )
        ]

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let jsonItem = try XCTUnwrap(menu.first { $0.id == "new_file_template_json" })
        let ids = Set(menu.map(\.id))

        XCTAssertEqual(jsonItem.actionType, .createFile)
        XCTAssertEqual(jsonItem.fileExtension, "json")
        XCTAssertEqual(jsonItem.defaultFileName, "Untitled.json")
        XCTAssertEqual(jsonItem.templateContent, "{}\n")
        XCTAssertFalse(ids.contains("new_file_template_disabled"))
    }

    func testNewFileTemplatesAreHiddenForFileSelection() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: .default)
        XCTAssertFalse(menu.contains { $0.id.hasPrefix("new_file_template_") })
    }

    func testSendToDestinationsAreAddedForFileSelection() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let destinationDirectory = try TemporaryDirectory()
        defer { destinationDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        var configuration = SharedConfiguration.default
        configuration.sendToDestinations = [
            FileDestinationConfiguration(
                id: "target",
                title: "目标",
                directoryPath: destinationDirectory.url.path,
                order: 0,
                systemImageName: "folder.fill",
                iconColorName: "cyan"
            )
        ]
        configuration.appSettings.enableCopyTo = true
        configuration.appSettings.enableMoveTo = true

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let copyItem = try XCTUnwrap(menu.first { $0.id == "copy_to_target" })
        let moveItem = try XCTUnwrap(menu.first { $0.id == "move_to_target" })

        XCTAssertEqual(copyItem.actionType, .copyToDirectory)
        XCTAssertEqual(moveItem.actionType, .moveToDirectory)
        XCTAssertEqual(copyItem.destinationPath, destinationDirectory.url.path)
    }

    func testSendToDestinationsAreHiddenForBlankSpace() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: .default)
        XCTAssertFalse(menu.contains { $0.id.hasPrefix("copy_to_") })
        XCTAssertFalse(menu.contains { $0.id.hasPrefix("move_to_") })
    }

    func testFileIconPresetsAreAddedForSelectedItems() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        var configuration = SharedConfiguration.default
        configuration.fileIconPresets = [
            FileIconConfiguration(
                id: "blue-doc",
                isEnabled: true,
                title: "蓝色文档",
                order: 0,
                systemImageName: "doc.fill",
                iconColorName: "blue",
                sizeDescription: "128 x 128"
            ),
            FileIconConfiguration(
                id: "disabled",
                isEnabled: false,
                title: "隐藏",
                order: 1,
                systemImageName: "xmark",
                iconColorName: "red",
                sizeDescription: "128 x 128"
            )
        ]

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let applyItem = try XCTUnwrap(menu.first { $0.id == "apply_file_icon_blue-doc" })

        XCTAssertEqual(applyItem.title, "设置图标：蓝色文档")
        XCTAssertEqual(applyItem.actionType, .applyFileIcon)
        XCTAssertEqual(applyItem.iconSystemImageName, "doc.fill")
        XCTAssertEqual(applyItem.iconColorName, "blue")
        XCTAssertTrue(menu.contains { $0.id == "remove_custom_icon" && $0.actionType == .removeCustomIcon })
        XCTAssertFalse(menu.contains { $0.id == "apply_file_icon_disabled" })
    }

    func testFileIconPresetsAreHiddenForBlankSpaceOrDisabledSetting() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        let blankContext = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )
        XCTAssertFalse(
            builder.buildMenu(context: blankContext, configuration: .default)
                .contains { $0.actionType == .applyFileIcon || $0.actionType == .removeCustomIcon }
        )

        var configuration = SharedConfiguration.default
        configuration.appSettings.enableFileIconPresets = false
        let fileContext = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )
        XCTAssertFalse(
            builder.buildMenu(context: fileContext, configuration: configuration)
                .contains { $0.actionType == .applyFileIcon || $0.actionType == .removeCustomIcon }
        )
    }

    func testToolboxItemsAreAddedForFileSelection() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        var configuration = SharedConfiguration.default
        configuration.toolboxItems = [
            ToolboxItemConfiguration(
                id: "copy_name",
                isEnabled: true,
                title: "拷贝名称",
                order: 0,
                actionType: .copyFileName,
                systemImageName: "doc.on.doc.fill",
                iconColorName: "cyan"
            ),
            ToolboxItemConfiguration(
                id: "disabled",
                isEnabled: false,
                title: "隐藏",
                order: 1,
                actionType: .hideSelectedItems,
                systemImageName: "eye.slash.fill",
                iconColorName: "gray"
            )
        ]

        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let item = try XCTUnwrap(menu.first { $0.id == "toolbox_copy_name" })

        XCTAssertEqual(item.actionType, .copyFileName)
        XCTAssertEqual(item.iconSystemImageName, "doc.on.doc.fill")
        XCTAssertEqual(item.iconColorName, "cyan")
        XCTAssertFalse(menu.contains { $0.id == "toolbox_disabled" })
    }

    func testToolboxDirectoryItemsAreAvailableForBlankSpace() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: .default)
        let actionTypes = Set(menu.map(\.actionType))

        XCTAssertTrue(actionTypes.contains(.hideDirectoryItems))
        XCTAssertTrue(actionTypes.contains(.unhideDirectoryItems))
        XCTAssertFalse(actionTypes.contains(.copyFileName))
    }

    func testToolboxCanBeDisabled() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }
        let fileURL = tempDirectory.url.appendingPathComponent("sample.txt")
        try "hello".data(using: .utf8)?.write(to: fileURL)

        var configuration = SharedConfiguration.default
        configuration.appSettings.enableToolbox = false
        let context = FinderSelectionContext(
            selectedItemURLs: [fileURL],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        XCTAssertFalse(menu.contains { $0.id.hasPrefix("toolbox_") })
    }

    func testFavoriteDirectoriesAreAddedForAllScenes() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        var configuration = SharedConfiguration.default
        configuration.favoriteDirectories = [
            FileDestinationConfiguration(
                id: "workspace",
                title: "工作区",
                directoryPath: tempDirectory.url.path,
                order: 0,
                systemImageName: "folder.fill",
                iconColorName: "cyan"
            )
        ]
        configuration.appSettings.enableFavoriteDirectories = true

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        let favoriteItem = try XCTUnwrap(menu.first { $0.id == "favorite_directory_workspace" })

        XCTAssertEqual(favoriteItem.title, "打开 工作区")
        XCTAssertEqual(favoriteItem.actionType, .openDirectory)
        XCTAssertEqual(favoriteItem.destinationPath, tempDirectory.url.path)
    }

    func testFavoriteDirectoriesCanBeDisabled() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [])
        )
        let tempDirectory = try TemporaryDirectory()
        defer { tempDirectory.remove() }

        var configuration = SharedConfiguration.default
        configuration.appSettings.enableFavoriteDirectories = false

        let context = FinderSelectionContext(
            selectedItemURLs: [],
            currentDirectoryURL: tempDirectory.url
        )

        let menu = builder.buildMenu(context: context, configuration: configuration)
        XCTAssertFalse(menu.contains { $0.id.hasPrefix("favorite_directory_") })
    }
}
