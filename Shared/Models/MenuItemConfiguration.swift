import Foundation

/// 基础右键菜单项配置。
///
/// 该模型保存内置菜单项和动态模板项进入 `MenuBuilder` 前所需的共享字段。
/// `templateData` 用于跨 Shared、ExtensionCore 和 IPC 保留导入模板的原始字节。
public struct MenuItemConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var isEnabled: Bool
    public var order: Int
    public var group: MenuGroup
    public var visibility: SceneVisibility
    public var actionType: MenuActionType
    public var targetApplication: ExternalApplication?
    public var fileExtension: String?
    public var defaultFileName: String?
    public var templateContent: String?
    public var templateData: Data?
    public var destinationPath: String?
    public var iconSystemImageName: String?
    public var iconColorName: String?
    public var importedIconImageData: Data?
    public var toolboxOption: String?
    public var requiresInstallationCheck: Bool

    public init(
        id: String,
        title: String,
        isEnabled: Bool,
        order: Int,
        group: MenuGroup,
        visibility: SceneVisibility,
        actionType: MenuActionType,
        targetApplication: ExternalApplication? = nil,
        fileExtension: String? = nil,
        defaultFileName: String? = nil,
        templateContent: String? = nil,
        templateData: Data? = nil,
        destinationPath: String? = nil,
        iconSystemImageName: String? = nil,
        iconColorName: String? = nil,
        importedIconImageData: Data? = nil,
        toolboxOption: String? = nil,
        requiresInstallationCheck: Bool = false
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.order = order
        self.group = group
        self.visibility = visibility
        self.actionType = actionType
        self.targetApplication = targetApplication
        self.fileExtension = fileExtension
        self.defaultFileName = defaultFileName
        self.templateContent = templateContent
        self.templateData = templateData
        self.destinationPath = destinationPath
        self.iconSystemImageName = iconSystemImageName
        self.iconColorName = iconColorName
        self.importedIconImageData = importedIconImageData
        self.toolboxOption = toolboxOption
        self.requiresInstallationCheck = requiresInstallationCheck
    }
}
