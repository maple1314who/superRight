public enum ExternalApplication: String, Codable, CaseIterable, Sendable {
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case vsCode = "VSCode"
    case cursor = "Cursor"

    public var defaultBundlePath: String {
        switch self {
        case .terminal:
            return "/System/Applications/Utilities/Terminal.app"
        case .iTerm:
            return "/Applications/iTerm.app"
        case .vsCode:
            return "/Applications/Visual Studio Code.app"
        case .cursor:
            return "/Applications/Cursor.app"
        }
    }

    public var openArgument: String {
        switch self {
        case .terminal:
            return "Terminal"
        case .iTerm:
            return "iTerm"
        case .vsCode:
            return "Visual Studio Code"
        case .cursor:
            return "Cursor"
        }
    }
}
