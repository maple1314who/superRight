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

    func testMutationTriggersAutomaticSave() throws {
        let store = RecordingConfigurationStore(configuration: .default)
        let viewModel = MenuManagementViewModel(store: store)

        viewModel.setEnabled(id: "open_terminal", isEnabled: false)
        viewModel.updateAppSettingHideUnavailable(false)
        viewModel.moveItem(id: "copy_path", offset: -1)

        XCTAssertGreaterThanOrEqual(store.saveCount, 3)
    }
}
