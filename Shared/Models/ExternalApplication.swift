public enum ExternalApplication: String, Codable, CaseIterable, Equatable, Sendable {
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case vsCode = "VSCode"
    case cursor = "Cursor"
    case idea = "IDEA"

    public var bundleIdentifier: String {
        switch self {
        case .terminal:
            return "com.apple.Terminal"
        case .iTerm:
            return "com.googlecode.iterm2"
        case .vsCode:
            return "com.microsoft.VSCode"
        case .cursor:
            return "com.todesktop.230313mzl4w4u92"
        case .idea:
            return "com.jetbrains.intellij"
        }
    }

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
        case .idea:
            return "/Applications/IntelliJ IDEA.app"
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
        case .idea:
            return "IntelliJ IDEA"
        }
    }
}
