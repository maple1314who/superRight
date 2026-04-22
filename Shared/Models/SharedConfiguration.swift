public struct SharedConfiguration: Codable, Equatable, Sendable {
    public var menuItems: [MenuItemConfiguration]
    public var appSettings: AppSettings
    public var applicationPaths: [ExternalApplication: String]

    public init(
        menuItems: [MenuItemConfiguration],
        appSettings: AppSettings,
        applicationPaths: [ExternalApplication: String]
    ) {
        self.menuItems = menuItems
        self.appSettings = appSettings
        self.applicationPaths = applicationPaths
    }

    public mutating func normalizeOrder() {
        menuItems = menuItems
            .sorted { $0.order < $1.order }
            .enumerated()
            .map { index, item in
                var next = item
                next.order = index
                return next
            }
    }

    public func sortedMenuItems() -> [MenuItemConfiguration] {
        menuItems.sorted { $0.order < $1.order }
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
                id: "copy_path",
                title: "复制路径",
                isEnabled: true,
                order: 4,
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
            .cursor: ExternalApplication.cursor.defaultBundlePath
        ]
    )
}
