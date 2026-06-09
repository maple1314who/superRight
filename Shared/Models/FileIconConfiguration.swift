/// 文件/文件夹自定义图标预设。
///
/// 配置界面负责维护该模型；Finder 右键菜单会把启用的预设转换成“设置图标”
/// 动作，主 App 再根据 `systemImageName` 和 `iconColorName` 渲染实际 Finder 图标。
public struct FileIconConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var isEnabled: Bool
    public var title: String
    public var order: Int
    public var systemImageName: String
    public var iconColorName: String
    public var sizeDescription: String

    public init(
        id: String,
        isEnabled: Bool,
        title: String,
        order: Int,
        systemImageName: String,
        iconColorName: String,
        sizeDescription: String
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.title = title
        self.order = order
        self.systemImageName = systemImageName
        self.iconColorName = iconColorName
        self.sizeDescription = sizeDescription
    }

    public static let defaultPresets: [FileIconConfiguration] = [
        .init(id: "app", isEnabled: true, title: "App", order: 0, systemImageName: "app.fill", iconColorName: "blue", sizeDescription: "128 x 128"),
        .init(id: "apple", isEnabled: true, title: "Apple", order: 1, systemImageName: "apple.logo", iconColorName: "black", sizeDescription: "128 x 128"),
        .init(id: "book", isEnabled: true, title: "书本", order: 2, systemImageName: "book.closed.fill", iconColorName: "orange", sizeDescription: "128 x 128"),
        .init(id: "calendar", isEnabled: true, title: "日历", order: 3, systemImageName: "calendar", iconColorName: "red", sizeDescription: "128 x 128"),
        .init(id: "cloud", isEnabled: true, title: "云端", order: 4, systemImageName: "cloud.fill", iconColorName: "blue", sizeDescription: "128 x 128"),
        .init(id: "excel", isEnabled: true, title: "Excel", order: 5, systemImageName: "x.square.fill", iconColorName: "green", sizeDescription: "128 x 128"),
        .init(id: "file", isEnabled: true, title: "文件", order: 6, systemImageName: "doc.fill", iconColorName: "blue", sizeDescription: "128 x 128"),
        .init(id: "globe", isEnabled: true, title: "谷歌", order: 7, systemImageName: "globe", iconColorName: "blue", sizeDescription: "128 x 128"),
        .init(id: "desktop", isEnabled: true, title: "Mac OS1", order: 8, systemImageName: "desktopcomputer", iconColorName: "indigo", sizeDescription: "128 x 128"),
        .init(id: "macwindow", isEnabled: true, title: "Mac OS2", order: 9, systemImageName: "macwindow", iconColorName: "indigo", sizeDescription: "128 x 128"),
        .init(id: "laptop", isEnabled: true, title: "Mac", order: 10, systemImageName: "laptopcomputer", iconColorName: "brown", sizeDescription: "64 x 64"),
        .init(id: "mail", isEnabled: true, title: "邮件", order: 11, systemImageName: "envelope.fill", iconColorName: "blue", sizeDescription: "128 x 128"),
        .init(id: "music", isEnabled: true, title: "音乐", order: 12, systemImageName: "music.note", iconColorName: "pink", sizeDescription: "128 x 128"),
        .init(id: "pages", isEnabled: true, title: "Pages", order: 13, systemImageName: "pencil.and.outline", iconColorName: "orange", sizeDescription: "128 x 128"),
        .init(id: "picture", isEnabled: true, title: "图片", order: 14, systemImageName: "photo.fill", iconColorName: "cyan", sizeDescription: "128 x 128")
    ]
}
