import Foundation

/// “新建文件”模板配置。
///
/// 配置界面负责编辑该模型，Finder 菜单会把启用的模板转换成 `createFile` 动作。
/// `templateData` 用于保存从真实模板文件导入的原始字节；旧的 `templateContent`
/// 继续兼容纯文本模板和历史配置。
public struct NewFileTemplateConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var isEnabled: Bool
    public var title: String
    public var fileExtension: String
    public var showInMainMenu: Bool
    public var order: Int
    public var defaultFileName: String
    public var templateContent: String
    public var templateData: Data?
    public var systemImageName: String
    public var iconColorName: String

    public init(
        id: String,
        isEnabled: Bool,
        title: String,
        fileExtension: String,
        showInMainMenu: Bool,
        order: Int,
        defaultFileName: String,
        templateContent: String = "",
        templateData: Data? = nil,
        systemImageName: String,
        iconColorName: String
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.title = title
        self.fileExtension = fileExtension
        self.showInMainMenu = showInMainMenu
        self.order = order
        self.defaultFileName = defaultFileName
        self.templateContent = templateContent
        self.templateData = templateData
        self.systemImageName = systemImageName
        self.iconColorName = iconColorName
    }

    /// 去掉用户可能输入的前导点，保证文件扩展名拼接稳定。
    public var normalizedFileExtension: String {
        fileExtension.trimmingCharacters(in: CharacterSet(charactersIn: "."))
    }

    public static let defaultTemplates: [NewFileTemplateConfiguration] = [
        .init(id: "empty", isEnabled: true, title: "空白文件", fileExtension: "", showInMainMenu: false, order: 0, defaultFileName: "Untitled", systemImageName: "doc", iconColorName: "gray"),
        .init(id: "txt", isEnabled: true, title: "TXT", fileExtension: "txt", showInMainMenu: false, order: 1, defaultFileName: "Untitled.txt", systemImageName: "doc.plaintext", iconColorName: "gray"),
        .init(id: "rtf", isEnabled: true, title: "RTF", fileExtension: "rtf", showInMainMenu: false, order: 2, defaultFileName: "Untitled.rtf", systemImageName: "doc.richtext", iconColorName: "brown"),
        .init(id: "xml", isEnabled: true, title: "XML", fileExtension: "xml", showInMainMenu: false, order: 3, defaultFileName: "Untitled.xml", systemImageName: "chevron.left.forwardslash.chevron.right", iconColorName: "blue"),
        .init(id: "docx", isEnabled: true, title: "Word", fileExtension: "docx", showInMainMenu: false, order: 4, defaultFileName: "Untitled.docx", systemImageName: "w.square.fill", iconColorName: "blue"),
        .init(id: "xlsx", isEnabled: true, title: "Excel", fileExtension: "xlsx", showInMainMenu: false, order: 5, defaultFileName: "Untitled.xlsx", systemImageName: "x.square.fill", iconColorName: "green"),
        .init(id: "pptx", isEnabled: true, title: "PPT", fileExtension: "pptx", showInMainMenu: false, order: 6, defaultFileName: "Untitled.pptx", systemImageName: "p.square.fill", iconColorName: "orange"),
        .init(id: "wps", isEnabled: true, title: "WPS 文字", fileExtension: "wps", showInMainMenu: false, order: 7, defaultFileName: "Untitled.wps", systemImageName: "doc.text.fill", iconColorName: "blue"),
        .init(id: "et", isEnabled: true, title: "WPS 表格", fileExtension: "et", showInMainMenu: false, order: 8, defaultFileName: "Untitled.et", systemImageName: "tablecells.fill", iconColorName: "green"),
        .init(id: "dps", isEnabled: true, title: "WPS 演示", fileExtension: "dps", showInMainMenu: false, order: 9, defaultFileName: "Untitled.dps", systemImageName: "rectangle.on.rectangle", iconColorName: "orange"),
        .init(id: "pages", isEnabled: false, title: "Pages", fileExtension: "pages", showInMainMenu: false, order: 10, defaultFileName: "Untitled.pages", systemImageName: "pencil.and.outline", iconColorName: "orange"),
        .init(id: "numbers", isEnabled: false, title: "Numbers", fileExtension: "numbers", showInMainMenu: false, order: 11, defaultFileName: "Untitled.numbers", systemImageName: "chart.bar.fill", iconColorName: "green"),
        .init(id: "key", isEnabled: false, title: "Keynote", fileExtension: "key", showInMainMenu: false, order: 12, defaultFileName: "Untitled.key", systemImageName: "display", iconColorName: "blue"),
        .init(id: "md", isEnabled: false, title: "Markdown", fileExtension: "md", showInMainMenu: false, order: 13, defaultFileName: "Untitled.md", templateContent: "# Untitled\n", systemImageName: "m.square.fill", iconColorName: "purple")
    ]
}
