import Foundation

/// Finder Extension 转交主 App 执行的动作类型。
///
/// 涉及文件写入、打开外部应用、复制/移动文件等需要更稳定权限上下文的动作，
/// 都通过该枚举进入主 App 执行链路。
public enum AppExecutionAction: String, Codable, Equatable, Sendable {
    case createFolder
    case createFile
    case openTerminal
    case openITerm
    case openVSCode
    case openCursor
    case openIdea
    case copyToDirectory
    case moveToDirectory
    case openDirectory
    case applyFileIcon
    case removeCustomIcon
    case showFileInfo
    case copyFileName
    case createFolderFromFileName
    case hideSelectedItems
    case unhideSelectedItems
    case hideDirectoryItems
    case unhideDirectoryItems

    public var externalApplication: ExternalApplication? {
        switch self {
        case .createFolder, .createFile, .copyToDirectory, .moveToDirectory, .openDirectory,
             .applyFileIcon, .removeCustomIcon, .showFileInfo, .copyFileName,
             .createFolderFromFileName, .hideSelectedItems, .unhideSelectedItems,
             .hideDirectoryItems, .unhideDirectoryItems:
            return nil
        case .openTerminal:
            return .terminal
        case .openITerm:
            return .iTerm
        case .openVSCode:
            return .vsCode
        case .openCursor:
            return .cursor
        case .openIdea:
            return .idea
        }
    }
}

/// Finder Extension 发送给主 App 的跨进程请求。
///
/// 请求同时通过分布式通知和 App Group 队列传递。新增字段必须保持可选或提供
/// 解码默认值，避免队列里的旧 JSON 无法处理。
public struct AppExecutionRequest: Codable, Sendable {
    public var requestID: String
    public var action: AppExecutionAction
    public var directoryPath: String
    public var defaultFileName: String?
    public var fileExtension: String?
    public var templateContent: String?
    public var targetPath: String?
    public var applicationPath: String?
    public var sourcePaths: [String]
    public var destinationPath: String?
    public var iconSystemImageName: String?
    public var iconColorName: String?
    public var toolboxOption: String?
    public var openAfterCreate: Bool
    public var playSoundAfterCreate: Bool

    enum CodingKeys: String, CodingKey {
        case requestID
        case action
        case directoryPath
        case defaultFileName
        case fileExtension
        case templateContent
        case targetPath
        case applicationPath
        case sourcePaths
        case destinationPath
        case iconSystemImageName
        case iconColorName
        case toolboxOption
        case openAfterCreate
        case playSoundAfterCreate
    }

    public init(
        requestID: String = UUID().uuidString,
        action: AppExecutionAction,
        directoryPath: String,
        defaultFileName: String? = nil,
        fileExtension: String? = nil,
        templateContent: String? = nil,
        targetPath: String? = nil,
        applicationPath: String? = nil,
        sourcePaths: [String] = [],
        destinationPath: String? = nil,
        iconSystemImageName: String? = nil,
        iconColorName: String? = nil,
        toolboxOption: String? = nil,
        openAfterCreate: Bool = false,
        playSoundAfterCreate: Bool = false
    ) {
        self.requestID = requestID
        self.action = action
        self.directoryPath = directoryPath
        self.defaultFileName = defaultFileName
        self.fileExtension = fileExtension
        self.templateContent = templateContent
        self.targetPath = targetPath
        self.applicationPath = applicationPath
        self.sourcePaths = sourcePaths
        self.destinationPath = destinationPath
        self.iconSystemImageName = iconSystemImageName
        self.iconColorName = iconColorName
        self.toolboxOption = toolboxOption
        self.openAfterCreate = openAfterCreate
        self.playSoundAfterCreate = playSoundAfterCreate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestID = try container.decodeIfPresent(String.self, forKey: .requestID) ?? UUID().uuidString
        self.action = try container.decode(AppExecutionAction.self, forKey: .action)
        self.directoryPath = try container.decode(String.self, forKey: .directoryPath)
        self.defaultFileName = try container.decodeIfPresent(String.self, forKey: .defaultFileName)
        self.fileExtension = try container.decodeIfPresent(String.self, forKey: .fileExtension)
        self.templateContent = try container.decodeIfPresent(String.self, forKey: .templateContent)
        self.targetPath = try container.decodeIfPresent(String.self, forKey: .targetPath)
        self.applicationPath = try container.decodeIfPresent(String.self, forKey: .applicationPath)
        self.sourcePaths = try container.decodeIfPresent([String].self, forKey: .sourcePaths) ?? []
        self.destinationPath = try container.decodeIfPresent(String.self, forKey: .destinationPath)
        self.iconSystemImageName = try container.decodeIfPresent(String.self, forKey: .iconSystemImageName)
        self.iconColorName = try container.decodeIfPresent(String.self, forKey: .iconColorName)
        self.toolboxOption = try container.decodeIfPresent(String.self, forKey: .toolboxOption)
        self.openAfterCreate = try container.decodeIfPresent(Bool.self, forKey: .openAfterCreate) ?? false
        self.playSoundAfterCreate = try container.decodeIfPresent(Bool.self, forKey: .playSoundAfterCreate) ?? false
    }
}
