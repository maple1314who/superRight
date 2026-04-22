import Combine
import Foundation
import Shared

@MainActor
public final class MenuManagementViewModel: ObservableObject {
    @Published public private(set) var configuration: SharedConfiguration
    private let store: ConfigurationStore

    public init(store: ConfigurationStore) {
        self.store = store
        self.configuration = (try? store.load()) ?? .default
        logConfiguration(prefix: "App init")
    }

    public var sortedMenuItems: [MenuItemConfiguration] {
        configuration.sortedMenuItems()
    }

    public func menuItems(in group: MenuGroup) -> [MenuItemConfiguration] {
        sortedMenuItems.filter { $0.group == group }
    }

    public func load() throws {
        configuration = try store.load()
        logConfiguration(prefix: "App load")
    }

    public func save() throws {
        try store.save(configuration)
        logConfiguration(prefix: "App save")
    }

    public func setEnabled(id: String, isEnabled: Bool) {
        guard let index = configuration.menuItems.firstIndex(where: { $0.id == id }) else {
            return
        }
        configuration.menuItems[index].isEnabled = isEnabled
        persistIfPossible()
    }

    public func setVisibility(id: String, scene: RightClickScene, isVisible: Bool) {
        guard let index = configuration.menuItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        switch scene {
        case .blankSpace:
            configuration.menuItems[index].visibility.blankSpace = isVisible
        case .file:
            configuration.menuItems[index].visibility.file = isVisible
        case .folder:
            configuration.menuItems[index].visibility.folder = isVisible
        }
        persistIfPossible()
    }

    public func moveItems(fromOffsets: IndexSet, toOffset: Int) {
        var sorted = configuration.sortedMenuItems()
        sorted.move(fromOffsets: fromOffsets, toOffset: toOffset)
        for index in sorted.indices {
            sorted[index].order = index
        }
        configuration.menuItems = sorted
        persistIfPossible()
    }

    public func moveItem(id: String, offset: Int) {
        var sorted = configuration.sortedMenuItems()
        guard let currentIndex = sorted.firstIndex(where: { $0.id == id }) else {
            return
        }

        let destination = currentIndex + offset
        guard destination >= 0, destination < sorted.count else {
            return
        }

        let item = sorted.remove(at: currentIndex)
        sorted.insert(item, at: destination)
        for index in sorted.indices {
            sorted[index].order = index
        }
        configuration.menuItems = sorted
        persistIfPossible()
    }

    public func updateAppSettingGroupMenu(_ enabled: Bool) {
        configuration.appSettings.groupMenuByCategory = enabled
        persistIfPossible()
    }

    public func updateAppSettingHideUnavailable(_ enabled: Bool) {
        configuration.appSettings.hideUnavailableApplications = enabled
        persistIfPossible()
    }

    public func setApplicationPath(_ path: String, for application: ExternalApplication) {
        configuration.applicationPaths[application] = path
        persistIfPossible()
    }

    public func item(id: String) -> MenuItemConfiguration? {
        configuration.menuItems.first { $0.id == id }
    }

    public func canMoveUp(id: String) -> Bool {
        guard let index = sortedMenuItems.firstIndex(where: { $0.id == id }) else {
            return false
        }
        return index > 0
    }

    public func canMoveDown(id: String) -> Bool {
        guard let index = sortedMenuItems.firstIndex(where: { $0.id == id }) else {
            return false
        }
        return index < sortedMenuItems.count - 1
    }

    private func persistIfPossible() {
        try? store.save(configuration)
        logConfiguration(prefix: "App autosave")
    }

    private func logConfiguration(prefix: String) {
        if let defaultsStore = store as? UserDefaultsConfigurationStore {
            NSLog("%@", defaultsStore.debugSummary(prefix: prefix))
        } else {
            NSLog("%@ store=%@", prefix, String(describing: type(of: store)))
        }

        let items = configuration.sortedMenuItems()
        let status = items.map { "\($0.id)=\($0.isEnabled ? "on" : "off")" }
            .joined(separator: ", ")
        NSLog("%@ menuItems.count=%ld items=[%@]",
              prefix,
              items.count,
              status
        )
    }
}
