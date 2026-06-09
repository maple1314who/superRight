import Foundation

public struct FileDestinationConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var directoryPath: String
    public var order: Int
    public var systemImageName: String
    public var iconColorName: String

    public init(
        id: String,
        title: String,
        directoryPath: String,
        order: Int,
        systemImageName: String,
        iconColorName: String
    ) {
        self.id = id
        self.title = title
        self.directoryPath = directoryPath
        self.order = order
        self.systemImageName = systemImageName
        self.iconColorName = iconColorName
    }

    public var normalizedDirectoryPath: String {
        URL(fileURLWithPath: (directoryPath as NSString).expandingTildeInPath, isDirectory: true)
            .standardizedFileURL
            .path
    }

    public static let defaultSendDestinations: [FileDestinationConfiguration] = [
        .init(id: "downloads", title: "下载", directoryPath: "~/Downloads", order: 0, systemImageName: "tray.and.arrow.down.fill", iconColorName: "cyan"),
        .init(id: "pictures", title: "图片", directoryPath: "~/Pictures", order: 1, systemImageName: "photo.fill", iconColorName: "cyan"),
        .init(id: "music", title: "音乐", directoryPath: "~/Music", order: 2, systemImageName: "music.note", iconColorName: "cyan"),
        .init(id: "movies", title: "影片", directoryPath: "~/Movies", order: 3, systemImageName: "film.fill", iconColorName: "cyan"),
        .init(id: "documents", title: "文稿", directoryPath: "~/Documents", order: 4, systemImageName: "folder.fill", iconColorName: "cyan")
    ]
}
