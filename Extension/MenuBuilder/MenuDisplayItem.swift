import Shared

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

    public init(
        id: String,
        title: String,
        order: Int,
        group: MenuGroup,
        actionType: MenuActionType,
        targetApplication: ExternalApplication?,
        fileExtension: String?,
        defaultFileName: String?,
        templateContent: String?
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
    }
}
