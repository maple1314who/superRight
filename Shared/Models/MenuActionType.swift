public enum MenuActionType: String, Codable, Sendable {
    case createFolder
    case createFile
    case openTerminal
    case openITerm
    case openVSCode
    case openCursor
    case openIdea
    case copyPath
    case copyToDirectory
    case moveToDirectory
    case openDirectory
    case applyFileIcon
    case removeCustomIcon
}
