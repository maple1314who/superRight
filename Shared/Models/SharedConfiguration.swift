/// App 与 Finder Extension 共用的配置根对象。
///
/// 该模型会被写入 App Group 的 UserDefaults。新增字段必须通过 `init(from:)`
/// 和 `upgradedWithDefaults()` 保持向后兼容，避免旧版本配置升级后丢失菜单项
/// 或功能开关。
public struct SharedConfiguration: Codable, Equatable, Sendable {
    public var menuItems: [MenuItemConfiguration]
    public var appSettings: AppSettings
    public var applicationPaths: [ExternalApplication: String]
    public var newFileTemplates: [NewFileTemplateConfiguration]
    public var sendToDestinations: [FileDestinationConfiguration]
    public var favoriteDirectories: [FileDestinationConfiguration]

    public init(
        menuItems: [MenuItemConfiguration],
        appSettings: AppSettings,
        applicationPaths: [ExternalApplication: String],
        newFileTemplates: [NewFileTemplateConfiguration] = NewFileTemplateConfiguration.defaultTemplates,
        sendToDestinations: [FileDestinationConfiguration] = FileDestinationConfiguration.defaultSendDestinations,
        favoriteDirectories: [FileDestinationConfiguration] = FileDestinationConfiguration.defaultFavoriteDirectories
    ) {
        self.menuItems = menuItems
        self.appSettings = appSettings
        self.applicationPaths = applicationPaths
        self.newFileTemplates = newFileTemplates
        self.sendToDestinations = sendToDestinations
        self.favoriteDirectories = favoriteDirectories
    }

    enum CodingKeys: String, CodingKey {
        case menuItems
        case appSettings
        case applicationPaths
        case newFileTemplates
        case sendToDestinations
        case favoriteDirectories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.menuItems = try container.decodeIfPresent([MenuItemConfiguration].self, forKey: .menuItems)
            ?? SharedConfiguration.default.menuItems
        self.appSettings = try container.decodeIfPresent(AppSettings.self, forKey: .appSettings) ?? .default
        self.applicationPaths = try container.decodeIfPresent([ExternalApplication: String].self, forKey: .applicationPaths)
            ?? SharedConfiguration.default.applicationPaths
        self.newFileTemplates = try container.decodeIfPresent(
            [NewFileTemplateConfiguration].self,
            forKey: .newFileTemplates
        ) ?? NewFileTemplateConfiguration.defaultTemplates
        self.sendToDestinations = try container.decodeIfPresent(
            [FileDestinationConfiguration].self,
            forKey: .sendToDestinations
        ) ?? FileDestinationConfiguration.defaultSendDestinations
        self.favoriteDirectories = try container.decodeIfPresent(
            [FileDestinationConfiguration].self,
            forKey: .favoriteDirectories
        ) ?? FileDestinationConfiguration.defaultFavoriteDirectories
    }

    /// 统一修正所有可排序配置的顺序值，保证 UI、菜单构建和持久化顺序一致。
    public mutating func normalizeOrder() {
        menuItems = menuItems
            .sorted { $0.order < $1.order }
            .enumerated()
            .map { index, item in
                var next = item
                next.order = index
                return next
            }
        newFileTemplates = newFileTemplates
            .sorted { $0.order < $1.order }
            .enumerated()
            .map { index, template in
                var next = template
                next.order = index
                return next
            }
        sendToDestinations = sendToDestinations
            .sorted { $0.order < $1.order }
            .enumerated()
            .map { index, destination in
                var next = destination
                next.order = index
                return next
            }
        favoriteDirectories = favoriteDirectories
            .sorted { $0.order < $1.order }
            .enumerated()
            .map { index, directory in
                var next = directory
                next.order = index
                return next
            }
    }

    public func sortedMenuItems() -> [MenuItemConfiguration] {
        menuItems.sorted { $0.order < $1.order }
    }

    public func sortedNewFileTemplates() -> [NewFileTemplateConfiguration] {
        newFileTemplates.sorted { $0.order < $1.order }
    }

    public func sortedSendToDestinations() -> [FileDestinationConfiguration] {
        sendToDestinations.sorted { $0.order < $1.order }
    }

    public func sortedFavoriteDirectories() -> [FileDestinationConfiguration] {
        favoriteDirectories.sorted { $0.order < $1.order }
    }

    /// 将旧配置补齐到当前版本默认结构。
    ///
    /// 这里只追加新增默认项，不删除用户已有配置。
    public func upgradedWithDefaults() -> SharedConfiguration {
        var upgraded = self
        let defaultConfiguration = SharedConfiguration.default

        let existingMenuItemIDs = Set(upgraded.menuItems.map(\.id))
        let missingMenuItems = defaultConfiguration.menuItems.filter { !existingMenuItemIDs.contains($0.id) }
        if !missingMenuItems.isEmpty {
            var nextOrder = (upgraded.menuItems.map(\.order).max() ?? -1) + 1
            for item in missingMenuItems {
                var appended = item
                appended.order = nextOrder
                nextOrder += 1
                upgraded.menuItems.append(appended)
            }
        }

        for application in ExternalApplication.allCases where upgraded.applicationPaths[application] == nil {
            upgraded.applicationPaths[application] =
                defaultConfiguration.applicationPaths[application] ?? application.defaultBundlePath
        }

        let existingTemplateIDs = Set(upgraded.newFileTemplates.map(\.id))
        let missingTemplates = defaultConfiguration.newFileTemplates.filter { !existingTemplateIDs.contains($0.id) }
        if !missingTemplates.isEmpty {
            var nextOrder = (upgraded.newFileTemplates.map(\.order).max() ?? -1) + 1
            for template in missingTemplates {
                var appended = template
                appended.order = nextOrder
                nextOrder += 1
                upgraded.newFileTemplates.append(appended)
            }
        }

        let existingDestinationIDs = Set(upgraded.sendToDestinations.map(\.id))
        let missingDestinations = defaultConfiguration.sendToDestinations.filter { !existingDestinationIDs.contains($0.id) }
        if !missingDestinations.isEmpty {
            var nextOrder = (upgraded.sendToDestinations.map(\.order).max() ?? -1) + 1
            for destination in missingDestinations {
                var appended = destination
                appended.order = nextOrder
                nextOrder += 1
                upgraded.sendToDestinations.append(appended)
            }
        }

        let existingFavoriteIDs = Set(upgraded.favoriteDirectories.map(\.id))
        let missingFavorites = defaultConfiguration.favoriteDirectories.filter { !existingFavoriteIDs.contains($0.id) }
        if !missingFavorites.isEmpty {
            var nextOrder = (upgraded.favoriteDirectories.map(\.order).max() ?? -1) + 1
            for directory in missingFavorites {
                var appended = directory
                appended.order = nextOrder
                nextOrder += 1
                upgraded.favoriteDirectories.append(appended)
            }
        }

        upgraded.normalizeOrder()
        return upgraded
    }

    public static let `default` = SharedConfiguration(
        menuItems: [
            MenuItemConfiguration(
                id: "new_folder",
                title: "新建文件夹",
                isEnabled: true,
                order: 0,
                group: .create,
                visibility: SceneVisibility(blankSpace: true, file: false, folder: false),
                actionType: .createFolder
            ),
            MenuItemConfiguration(
                id: "open_terminal",
                title: "在终端中打开",
                isEnabled: true,
                order: 1,
                group: .open,
                visibility: SceneVisibility(blankSpace: true, file: false, folder: true),
                actionType: .openTerminal,
                targetApplication: .terminal,
                requiresInstallationCheck: false
            ),
            MenuItemConfiguration(
                id: "open_iterm",
                title: "在 iTerm 中打开",
                isEnabled: true,
                order: 2,
                group: .open,
                visibility: SceneVisibility(blankSpace: true, file: false, folder: true),
                actionType: .openITerm,
                targetApplication: .iTerm,
                requiresInstallationCheck: true
            ),
            MenuItemConfiguration(
                id: "open_vscode",
                title: "用 VS Code 打开",
                isEnabled: true,
                order: 3,
                group: .open,
                visibility: SceneVisibility(blankSpace: true, file: true, folder: true),
                actionType: .openVSCode,
                targetApplication: .vsCode,
                requiresInstallationCheck: true
            ),
            MenuItemConfiguration(
                id: "open_idea",
                title: "用 IDEA 打开",
                isEnabled: true,
                order: 4,
                group: .open,
                visibility: SceneVisibility(blankSpace: true, file: true, folder: true),
                actionType: .openIdea,
                targetApplication: .idea,
                requiresInstallationCheck: true
            ),
            MenuItemConfiguration(
                id: "copy_path",
                title: "复制路径",
                isEnabled: true,
                order: 5,
                group: .tool,
                visibility: SceneVisibility(blankSpace: true, file: true, folder: true),
                actionType: .copyPath
            )
        ],
        appSettings: .default,
        applicationPaths: [
            .terminal: ExternalApplication.terminal.defaultBundlePath,
            .iTerm: ExternalApplication.iTerm.defaultBundlePath,
            .vsCode: ExternalApplication.vsCode.defaultBundlePath,
            .cursor: ExternalApplication.cursor.defaultBundlePath,
            .idea: ExternalApplication.idea.defaultBundlePath
        ],
        newFileTemplates: NewFileTemplateConfiguration.defaultTemplates,
        sendToDestinations: FileDestinationConfiguration.defaultSendDestinations,
        favoriteDirectories: FileDestinationConfiguration.defaultFavoriteDirectories
    )
}
