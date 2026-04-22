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
        XCTAssertTrue(ids.contains("copy_path"))
        XCTAssertFalse(ids.contains("new_json"))
    }

    func testUnavailableApplicationIsHiddenWhenConfigured() throws {
        let builder = MenuBuilder(
            availabilityChecker: MockAvailabilityChecker(unavailableApps: [.iTerm, .vsCode])
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
        XCTAssertTrue(ids.contains("open_terminal"))
    }
}
