import Foundation

public enum AppExecutionAction: String, Codable, Sendable {
    case createFolder
    case createFile
}

public struct AppExecutionRequest: Codable, Sendable {
    public var requestID: String
    public var action: AppExecutionAction
    public var directoryPath: String
    public var defaultFileName: String?
    public var fileExtension: String?
    public var templateContent: String?

    public init(
        requestID: String = UUID().uuidString,
        action: AppExecutionAction,
        directoryPath: String,
        defaultFileName: String? = nil,
        fileExtension: String? = nil,
        templateContent: String? = nil
    ) {
        self.requestID = requestID
        self.action = action
        self.directoryPath = directoryPath
        self.defaultFileName = defaultFileName
        self.fileExtension = fileExtension
        self.templateContent = templateContent
    }
}
