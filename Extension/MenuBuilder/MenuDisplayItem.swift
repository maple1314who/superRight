import Foundation
import Shared

/// Finder 菜单最终展示项。
///
/// 该模型是 `MenuBuilder` 输出给 Finder Extension 的轻量 DTO，只包含展示、
/// 排序和动作执行所需字段，避免扩展进程直接依赖完整配置模型。
public struct MenuDisplayItem: Equatable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var order: Int
    public var group: MenuGroup
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

    public init(
        id: String,
        title: String,
        order: Int,
        group: MenuGroup,
        actionType: MenuActionType,
        targetApplication: ExternalApplication?,
        fileExtension: String?,
        defaultFileName: String?,
        templateContent: String?,
        templateData: Data? = nil,
        destinationPath: String? = nil,
        iconSystemImageName: String? = nil,
        iconColorName: String? = nil,
        importedIconImageData: Data? = nil,
        toolboxOption: String? = nil
    ) {
        self.id = id
        self.title = title
        self.order = order
        self.group = group
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
    }

    public init(configuration: MenuItemConfiguration) {
        self.id = configuration.id
        self.title = configuration.title
        self.order = configuration.order
        self.group = configuration.group
        self.actionType = configuration.actionType
        self.targetApplication = configuration.targetApplication
        self.fileExtension = configuration.fileExtension
        self.defaultFileName = configuration.defaultFileName
        self.templateContent = configuration.templateContent
        self.templateData = configuration.templateData
        self.destinationPath = configuration.destinationPath
        self.iconSystemImageName = configuration.iconSystemImageName
        self.iconColorName = configuration.iconColorName
        self.importedIconImageData = configuration.importedIconImageData
        self.toolboxOption = configuration.toolboxOption
    }
}
