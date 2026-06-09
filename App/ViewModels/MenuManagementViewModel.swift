import Combine
import Foundation
import Shared

/// 配置界面的状态管理入口。
///
/// SwiftUI 视图只通过该 ViewModel 读写共享配置，避免多个页面直接操作
/// `ConfigurationStore` 导致状态不同步。
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

    public var monitoredDirectoryPaths: [String] {
        configuration.appSettings.monitoredDirectoryPaths
    }

    public var sortedNewFileTemplates: [NewFileTemplateConfiguration] {
        configuration.sortedNewFileTemplates()
    }

    public var sortedSendToDestinations: [FileDestinationConfiguration] {
        configuration.sortedSendToDestinations()
    }

    public var sortedFavoriteDirectories: [FileDestinationConfiguration] {
        configuration.sortedFavoriteDirectories()
    }

    public var sortedFileIconPresets: [FileIconConfiguration] {
        configuration.sortedFileIconPresets()
    }

    public var sortedToolboxItems: [ToolboxItemConfiguration] {
        configuration.sortedToolboxItems()
    }

    public func menuItems(in group: MenuGroup) -> [MenuItemConfiguration] {
        sortedMenuItems.filter { $0.group == group }
    }

    public func load() throws {
        configuration = try store.load()
        logConfiguration(prefix: "App load")
    }

    /// 将当前内存配置写回 App Group，并输出调试摘要。
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

    public func updateAppSettingHideMenuBarIcon(_ enabled: Bool) {
        configuration.appSettings.hideMenuBarIcon = enabled
        persistIfPossible()
        NotificationCenter.default.post(
            name: Notification.Name(SharedConstants.appSettingsDidChangeNotification),
            object: nil
        )
    }

    public func updateShowNewFileIcons(_ enabled: Bool) {
        configuration.appSettings.showNewFileIcons = enabled
        persistIfPossible()
    }

    public func updateOpenNewFileAfterCreate(_ enabled: Bool) {
        configuration.appSettings.openNewFileAfterCreate = enabled
        persistIfPossible()
    }

    public func updatePlaySoundAfterCreate(_ enabled: Bool) {
        configuration.appSettings.playSoundAfterCreate = enabled
        persistIfPossible()
    }

    public func updateShowSendToIcons(_ enabled: Bool) {
        configuration.appSettings.showSendToIcons = enabled
        persistIfPossible()
    }

    public func updateEnableCopyTo(_ enabled: Bool) {
        configuration.appSettings.enableCopyTo = enabled
        persistIfPossible()
    }

    public func updateEnableMoveTo(_ enabled: Bool) {
        configuration.appSettings.enableMoveTo = enabled
        persistIfPossible()
    }

    public func updateShowFavoriteDirectoryIcons(_ enabled: Bool) {
        configuration.appSettings.showFavoriteDirectoryIcons = enabled
        persistIfPossible()
    }

    public func updateEnableFavoriteDirectories(_ enabled: Bool) {
        configuration.appSettings.enableFavoriteDirectories = enabled
        persistIfPossible()
    }

    public func updateShowFileIconPresetIcons(_ enabled: Bool) {
        configuration.appSettings.showFileIconPresetIcons = enabled
        persistIfPossible()
    }

    public func updateEnableFileIconPresets(_ enabled: Bool) {
        configuration.appSettings.enableFileIconPresets = enabled
        persistIfPossible()
    }

    public func updateShowToolboxIcons(_ enabled: Bool) {
        configuration.appSettings.showToolboxIcons = enabled
        persistIfPossible()
    }

    public func updateEnableToolbox(_ enabled: Bool) {
        configuration.appSettings.enableToolbox = enabled
        persistIfPossible()
    }

    public func updateNewFileTemplate(_ template: NewFileTemplateConfiguration) {
        guard let index = configuration.newFileTemplates.firstIndex(where: { $0.id == template.id }) else {
            return
        }
        configuration.newFileTemplates[index] = template
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func addNewFileTemplate() {
        let nextIndex = (configuration.newFileTemplates.map(\.order).max() ?? -1) + 1
        let nextID = "custom_\(UUID().uuidString)"
        let template = NewFileTemplateConfiguration(
            id: nextID,
            isEnabled: true,
            title: "新模板",
            fileExtension: "txt",
            showInMainMenu: false,
            order: nextIndex,
            defaultFileName: "Untitled.txt",
            systemImageName: "doc",
            iconColorName: "gray"
        )
        configuration.newFileTemplates.append(template)
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func removeNewFileTemplate(id: String) {
        configuration.newFileTemplates.removeAll { $0.id == id }
        if configuration.newFileTemplates.isEmpty {
            configuration.newFileTemplates = NewFileTemplateConfiguration.defaultTemplates
        }
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func resetNewFileTemplates() {
        configuration.newFileTemplates = NewFileTemplateConfiguration.defaultTemplates
        persistIfPossible()
    }

    public func updateSendToDestination(_ destination: FileDestinationConfiguration) {
        guard let index = configuration.sendToDestinations.firstIndex(where: { $0.id == destination.id }) else {
            return
        }
        configuration.sendToDestinations[index] = destination
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func addSendToDestination() {
        let nextIndex = (configuration.sendToDestinations.map(\.order).max() ?? -1) + 1
        let destination = FileDestinationConfiguration(
            id: "custom_\(UUID().uuidString)",
            title: "新目录",
            directoryPath: NSHomeDirectory(),
            order: nextIndex,
            systemImageName: "folder.fill",
            iconColorName: "cyan"
        )
        configuration.sendToDestinations.append(destination)
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func removeLastSendToDestination() {
        guard !configuration.sendToDestinations.isEmpty else {
            return
        }
        configuration.sendToDestinations.sort { $0.order < $1.order }
        configuration.sendToDestinations.removeLast()
        if configuration.sendToDestinations.isEmpty {
            configuration.sendToDestinations = FileDestinationConfiguration.defaultSendDestinations
        }
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func resetSendToDestinations() {
        configuration.sendToDestinations = FileDestinationConfiguration.defaultSendDestinations
        persistIfPossible()
    }

    public func updateFavoriteDirectory(_ directory: FileDestinationConfiguration) {
        guard let index = configuration.favoriteDirectories.firstIndex(where: { $0.id == directory.id }) else {
            return
        }
        configuration.favoriteDirectories[index] = directory
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func addFavoriteDirectory() {
        let nextIndex = (configuration.favoriteDirectories.map(\.order).max() ?? -1) + 1
        let directory = FileDestinationConfiguration(
            id: "custom_\(UUID().uuidString)",
            title: "新目录",
            directoryPath: NSHomeDirectory(),
            order: nextIndex,
            systemImageName: "folder.fill",
            iconColorName: "cyan"
        )
        configuration.favoriteDirectories.append(directory)
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func removeLastFavoriteDirectory() {
        guard !configuration.favoriteDirectories.isEmpty else {
            return
        }
        configuration.favoriteDirectories.sort { $0.order < $1.order }
        configuration.favoriteDirectories.removeLast()
        if configuration.favoriteDirectories.isEmpty {
            configuration.favoriteDirectories = FileDestinationConfiguration.defaultFavoriteDirectories
        }
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func resetFavoriteDirectories() {
        configuration.favoriteDirectories = FileDestinationConfiguration.defaultFavoriteDirectories
        persistIfPossible()
    }

    public func updateFileIconPreset(_ preset: FileIconConfiguration) {
        guard let index = configuration.fileIconPresets.firstIndex(where: { $0.id == preset.id }) else {
            return
        }
        configuration.fileIconPresets[index] = preset
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func addFileIconPreset() {
        let nextIndex = (configuration.fileIconPresets.map(\.order).max() ?? -1) + 1
        let preset = FileIconConfiguration(
            id: "custom_\(UUID().uuidString)",
            isEnabled: true,
            title: "自定义",
            order: nextIndex,
            systemImageName: "photo.fill",
            iconColorName: "blue",
            sizeDescription: "128 x 128"
        )
        configuration.fileIconPresets.append(preset)
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func removeLastFileIconPreset() {
        guard !configuration.fileIconPresets.isEmpty else {
            return
        }
        configuration.fileIconPresets.sort { $0.order < $1.order }
        configuration.fileIconPresets.removeLast()
        if configuration.fileIconPresets.isEmpty {
            configuration.fileIconPresets = FileIconConfiguration.defaultPresets
        }
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func resetFileIconPresets() {
        configuration.fileIconPresets = FileIconConfiguration.defaultPresets
        persistIfPossible()
    }

    public func updateToolboxItem(_ item: ToolboxItemConfiguration) {
        guard let index = configuration.toolboxItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        configuration.toolboxItems[index] = item
        configuration.normalizeOrder()
        persistIfPossible()
    }

    public func resetToolboxItems() {
        configuration.toolboxItems = ToolboxItemConfiguration.defaultItems
        persistIfPossible()
    }

    public func setApplicationPath(_ path: String, for application: ExternalApplication) {
        configuration.applicationPaths[application] = path
        persistIfPossible()
    }

    public func addMonitoredDirectory(path: String) {
        let normalizedPath = normalizePath(path)
        guard !normalizedPath.isEmpty else {
            return
        }

        guard !configuration.appSettings.monitoredDirectoryPaths.contains(normalizedPath) else {
            return
        }

        configuration.appSettings.monitoredDirectoryPaths.append(normalizedPath)
        persistIfPossible()
    }

    public func removeMonitoredDirectories(atOffsets offsets: IndexSet) {
        configuration.appSettings.monitoredDirectoryPaths.remove(atOffsets: offsets)
        if configuration.appSettings.monitoredDirectoryPaths.isEmpty {
            configuration.appSettings.monitoredDirectoryPaths = [defaultDesktopPath()]
        }
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

    /// UI 修改后的统一持久化入口。
    ///
    /// 这里故意吞掉错误并写日志，避免单个开关保存失败导致配置窗口崩溃。
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
        let directories = configuration.appSettings.monitoredDirectoryPaths.joined(separator: " | ")
        NSLog("%@ monitoredDirectories.count=%ld paths=[%@]",
              prefix,
              configuration.appSettings.monitoredDirectoryPaths.count,
              directories
        )
    }

    private func normalizePath(_ path: String) -> String {
        URL(fileURLWithPath: (path as NSString).expandingTildeInPath, isDirectory: true)
            .standardizedFileURL
            .path
    }

    private func defaultDesktopPath() -> String {
        NSHomeDirectory().appending("/Desktop")
    }
}
