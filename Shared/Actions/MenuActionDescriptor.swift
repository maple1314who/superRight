public struct MenuActionDescriptor: Equatable, Sendable {
    public var id: String
    public var title: String
    public var actionType: MenuActionType

    public init(id: String, title: String, actionType: MenuActionType) {
        self.id = id
        self.title = title
        self.actionType = actionType
    }
}
