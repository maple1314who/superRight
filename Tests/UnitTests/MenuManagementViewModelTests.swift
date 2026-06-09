import XCTest
@testable import AppCore
@testable import Shared

private final class RecordingConfigurationStore: ConfigurationStore {
    var configuration: SharedConfiguration
    var saveCount = 0

    init(configuration: SharedConfiguration = .default) {
        self.configuration = configuration
    }

    func load() throws -> SharedConfiguration {
        configuration
    }

    func save(_ configuration: SharedConfiguration) throws {
        saveCount += 1
        self.configuration = configuration
    }
}

@MainActor
final class MenuManagementViewModelTests: XCTestCase {
    func testToggleAndVisibilityUpdate() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)

        viewModel.setEnabled(id: "new_folder", isEnabled: false)
        viewModel.setVisibility(id: "new_folder", scene: .file, isVisible: true)

        let item = viewModel.item(id: "new_folder")
        XCTAssertEqual(item?.isEnabled, false)
        XCTAssertEqual(item?.visibility.file, true)
    }

    func testMoveItemsReordersAndReindexes() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)
        let originalFirst = viewModel.sortedMenuItems[0]

        viewModel.moveItems(fromOffsets: IndexSet(integer: 0), toOffset: 3)
        let sorted = viewModel.sortedMenuItems

        XCTAssertNotEqual(sorted[0].id, originalFirst.id)
        XCTAssertEqual(sorted[2].id, originalFirst.id)
        XCTAssertEqual(Set(sorted.map(\.order)), Set(0..<sorted.count))
    }

    func testNewFileTemplateReorderPersists() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)
        let firstID = viewModel.sortedNewFileTemplates[0].id
        let fourthID = viewModel.sortedNewFileTemplates[3].id

        viewModel.moveNewFileTemplate(draggedID: firstID, targetID: fourthID)

        let sorted = viewModel.sortedNewFileTemplates

        XCTAssertEqual(sorted[3].id, firstID)
        XCTAssertEqual(Set(sorted.map(\.order)), Set(0..<sorted.count))
    }

    func testSendToDestinationReorderPersists() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)
        let firstID = viewModel.sortedSendToDestinations[0].id
        let thirdID = viewModel.sortedSendToDestinations[2].id

        viewModel.moveSendToDestination(draggedID: firstID, targetID: thirdID)

        let sorted = viewModel.sortedSendToDestinations

        XCTAssertEqual(sorted[2].id, firstID)
        XCTAssertEqual(Set(sorted.map(\.order)), Set(0..<sorted.count))
    }

    func testFavoriteDirectoryReorderPersists() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)
        let firstID = viewModel.sortedFavoriteDirectories[0].id
        let thirdID = viewModel.sortedFavoriteDirectories[2].id

        viewModel.moveFavoriteDirectory(draggedID: firstID, targetID: thirdID)

        let sorted = viewModel.sortedFavoriteDirectories

        XCTAssertEqual(sorted[2].id, firstID)
        XCTAssertEqual(Set(sorted.map(\.order)), Set(0..<sorted.count))
    }

    func testFileIconImageImportAndReorderPersists() throws {
        let store = InMemoryConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)
        let firstID = viewModel.sortedFileIconPresets[0].id
        let thirdID = viewModel.sortedFileIconPresets[2].id
        let imageData = Data([0x01, 0x02, 0x03])

        viewModel.updateFileIconPresetImage(
            id: firstID,
            imageData: imageData,
            fileName: "local.png",
            sizeDescription: "64 x 64"
        )
        viewModel.moveFileIconPreset(draggedID: firstID, targetID: thirdID)

        let sorted = viewModel.sortedFileIconPresets
        let movedPreset = try XCTUnwrap(sorted.first { $0.id == firstID })

        XCTAssertEqual(movedPreset.importedImageData, imageData)
        XCTAssertEqual(movedPreset.importedImageFileName, "local.png")
        XCTAssertEqual(movedPreset.sizeDescription, "64 x 64")
        XCTAssertEqual(sorted[2].id, firstID)
        XCTAssertEqual(Set(sorted.map(\.order)), Set(0..<sorted.count))
    }

    func testAddAndRemoveSendToDestinationUsesSelectedDirectory() throws {
        var configuration = SharedConfiguration.default
        configuration.sendToDestinations = []
        let store = InMemoryConfigurationStore(configuration: configuration)
        let viewModel = MenuManagementViewModel(store: store)
        let directoryURL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("Downloads", isDirectory: true)

        let id = viewModel.addSendToDestination(directoryURL: directoryURL)
        let added = try XCTUnwrap(viewModel.sortedSendToDestinations.first)

        XCTAssertEqual(added.id, id)
        XCTAssertEqual(added.directoryPath, directoryURL.path)
        XCTAssertEqual(added.title, "Downloads")

        viewModel.removeSendToDestination(id: id)

        XCTAssertTrue(viewModel.sortedSendToDestinations.isEmpty)
    }

    func testRemoveLastSendToDestinationCanLeaveEmptyList() throws {
        var configuration = SharedConfiguration.default
        configuration.sendToDestinations = [
            FileDestinationConfiguration(
                id: "only",
                title: "Only",
                directoryPath: NSHomeDirectory(),
                order: 0,
                systemImageName: "folder.fill",
                iconColorName: "cyan"
            )
        ]
        let store = InMemoryConfigurationStore(configuration: configuration)
        let viewModel = MenuManagementViewModel(store: store)

        viewModel.removeLastSendToDestination()

        XCTAssertTrue(viewModel.sortedSendToDestinations.isEmpty)
    }

    func testMutationTriggersAutomaticSave() throws {
        let store = RecordingConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)

        viewModel.setEnabled(id: "open_terminal", isEnabled: false)
        viewModel.updateAppSettingHideUnavailable(false)
        viewModel.moveItem(id: "copy_path", offset: -1)

        XCTAssertGreaterThanOrEqual(store.saveCount, 3)
    }
}
