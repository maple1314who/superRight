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
    public var destinationPath: String?
    public var iconSystemImageName: String?
    public var iconColorName: String?
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
        destinationPath: String? = nil,
        iconSystemImageName: String? = nil,
        iconColorName: String? = nil,
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
        self.destinationPath = destinationPath
        self.iconSystemImageName = iconSystemImageName
        self.iconColorName = iconColorName
        self.requiresInstallationCheck = requiresInstallationCheck
    }
}
