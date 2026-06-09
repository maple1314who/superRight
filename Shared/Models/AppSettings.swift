import Foundation

/// 全局应用设置。
///
/// 这些开关同时影响配置界面、Finder 监听目录、菜单生成和主 App 显示方式。
/// 新增开关时必须在解码逻辑中提供默认值，保证历史配置可直接升级。
/// Finder Sync 只有在 `monitoredDirectoryPaths` 覆盖的目录中才会加载右键扩展，
/// 因此默认监听用户 Home，而不是只监听桌面。
public struct AppSettings: Codable, Equatable, Sendable {
    public var groupMenuByCategory: Bool
    public var hideUnavailableApplications: Bool
    public var launchAtLogin: Bool
    public var hideMenuBarIcon: Bool
    public var showNewFileIcons: Bool
    public var showSendToIcons: Bool
    public var enableCopyTo: Bool
    public var enableMoveTo: Bool
    public var showFavoriteDirectoryIcons: Bool
    public var enableFavoriteDirectories: Bool
    public var showFileIconPresetIcons: Bool
    public var enableFileIconPresets: Bool
    public var showToolboxIcons: Bool
    public var enableToolbox: Bool
    public var openNewFileAfterCreate: Bool
    public var playSoundAfterCreate: Bool
    public var monitoredDirectoryPaths: [String]

    public init(
        groupMenuByCategory: Bool,
        hideUnavailableApplications: Bool,
        launchAtLogin: Bool,
        hideMenuBarIcon: Bool,
        showNewFileIcons: Bool,
        showSendToIcons: Bool,
        enableCopyTo: Bool,
        enableMoveTo: Bool,
        showFavoriteDirectoryIcons: Bool,
        enableFavoriteDirectories: Bool,
        showFileIconPresetIcons: Bool,
        enableFileIconPresets: Bool,
        showToolboxIcons: Bool,
        enableToolbox: Bool,
        openNewFileAfterCreate: Bool,
        playSoundAfterCreate: Bool,
        monitoredDirectoryPaths: [String]
    ) {
        self.groupMenuByCategory = groupMenuByCategory
        self.hideUnavailableApplications = hideUnavailableApplications
        self.launchAtLogin = launchAtLogin
        self.hideMenuBarIcon = hideMenuBarIcon
        self.showNewFileIcons = showNewFileIcons
        self.showSendToIcons = showSendToIcons
        self.enableCopyTo = enableCopyTo
        self.enableMoveTo = enableMoveTo
        self.showFavoriteDirectoryIcons = showFavoriteDirectoryIcons
        self.enableFavoriteDirectories = enableFavoriteDirectories
        self.showFileIconPresetIcons = showFileIconPresetIcons
        self.enableFileIconPresets = enableFileIconPresets
        self.showToolboxIcons = showToolboxIcons
        self.enableToolbox = enableToolbox
        self.openNewFileAfterCreate = openNewFileAfterCreate
        self.playSoundAfterCreate = playSoundAfterCreate
        self.monitoredDirectoryPaths = monitoredDirectoryPaths
    }

    enum CodingKeys: String, CodingKey {
        case groupMenuByCategory
        case hideUnavailableApplications
        case launchAtLogin
        case hideMenuBarIcon
        case showNewFileIcons
        case showSendToIcons
        case enableCopyTo
        case enableMoveTo
        case showFavoriteDirectoryIcons
        case enableFavoriteDirectories
        case showFileIconPresetIcons
        case enableFileIconPresets
        case showToolboxIcons
        case enableToolbox
        case openNewFileAfterCreate
        case playSoundAfterCreate
        case monitoredDirectoryPaths
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.groupMenuByCategory = try container.decodeIfPresent(Bool.self, forKey: .groupMenuByCategory) ?? true
        self.hideUnavailableApplications = try container.decodeIfPresent(Bool.self, forKey: .hideUnavailableApplications) ?? true
        self.launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        self.hideMenuBarIcon = try container.decodeIfPresent(Bool.self, forKey: .hideMenuBarIcon) ?? true
        self.showNewFileIcons = try container.decodeIfPresent(Bool.self, forKey: .showNewFileIcons) ?? true
        self.showSendToIcons = try container.decodeIfPresent(Bool.self, forKey: .showSendToIcons) ?? true
        self.enableCopyTo = try container.decodeIfPresent(Bool.self, forKey: .enableCopyTo) ?? true
        self.enableMoveTo = try container.decodeIfPresent(Bool.self, forKey: .enableMoveTo) ?? false
        self.showFavoriteDirectoryIcons = try container.decodeIfPresent(Bool.self, forKey: .showFavoriteDirectoryIcons) ?? true
        self.enableFavoriteDirectories = try container.decodeIfPresent(Bool.self, forKey: .enableFavoriteDirectories) ?? true
        self.showFileIconPresetIcons = try container.decodeIfPresent(Bool.self, forKey: .showFileIconPresetIcons) ?? true
        self.enableFileIconPresets = try container.decodeIfPresent(Bool.self, forKey: .enableFileIconPresets) ?? true
        self.showToolboxIcons = try container.decodeIfPresent(Bool.self, forKey: .showToolboxIcons) ?? true
        self.enableToolbox = try container.decodeIfPresent(Bool.self, forKey: .enableToolbox) ?? true
        self.openNewFileAfterCreate = try container.decodeIfPresent(Bool.self, forKey: .openNewFileAfterCreate) ?? false
        self.playSoundAfterCreate = try container.decodeIfPresent(Bool.self, forKey: .playSoundAfterCreate) ?? true
        self.monitoredDirectoryPaths = try container.decodeIfPresent([String].self, forKey: .monitoredDirectoryPaths)
            ?? Self.defaultMonitoredDirectoryPaths
    }

    public static let `default` = AppSettings(
        groupMenuByCategory: true,
        hideUnavailableApplications: true,
        launchAtLogin: false,
        hideMenuBarIcon: true,
        showNewFileIcons: true,
        showSendToIcons: true,
        enableCopyTo: true,
        enableMoveTo: false,
        showFavoriteDirectoryIcons: true,
        enableFavoriteDirectories: true,
        showFileIconPresetIcons: true,
        enableFileIconPresets: true,
        showToolboxIcons: true,
        enableToolbox: true,
        openNewFileAfterCreate: false,
        playSoundAfterCreate: true,
        monitoredDirectoryPaths: defaultMonitoredDirectoryPaths
    )

    public static var defaultMonitoredDirectoryPaths: [String] {
        [defaultHomePath]
    }

    public static var defaultHomePath: String {
        NSHomeDirectory()
    }

    public static var legacyDesktopPath: String {
        NSHomeDirectory().appending("/Desktop")
    }
}
