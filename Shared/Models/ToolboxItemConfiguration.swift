/// 工具箱功能项配置。
///
/// 工具箱是从配置界面生成 Finder 右键动作的动态功能列表。模型只保存
/// 可持久化配置；具体文件操作由主 App 的 `AppExecutionRequestHandler` 执行。
public struct ToolboxItemConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var isEnabled: Bool
    public var title: String
    public var order: Int
    public var actionType: MenuActionType
    public var option: String
    public var availableOptions: [String]
    public var systemImageName: String
    public var iconColorName: String

    public init(
        id: String,
        isEnabled: Bool,
        title: String,
        order: Int,
        actionType: MenuActionType,
        option: String = "",
        availableOptions: [String] = [""],
        systemImageName: String,
        iconColorName: String
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.title = title
        self.order = order
        self.actionType = actionType
        self.option = option
        self.availableOptions = availableOptions
        self.systemImageName = systemImageName
        self.iconColorName = iconColorName
    }

    public static let defaultItems: [ToolboxItemConfiguration] = [
        .init(
            id: "show_file_info",
            isEnabled: true,
            title: "文件信息",
            order: 0,
            actionType: .showFileInfo,
            systemImageName: "info.circle.fill",
            iconColorName: "blue"
        ),
        .init(
            id: "copy_file_name",
            isEnabled: true,
            title: "拷贝文件(夹)名称",
            order: 1,
            actionType: .copyFileName,
            systemImageName: "doc.on.doc.fill",
            iconColorName: "cyan"
        ),
        .init(
            id: "create_folder_from_file_name",
            isEnabled: true,
            title: "根据文件名新建文件夹",
            order: 2,
            actionType: .createFolderFromFileName,
            systemImageName: "folder.fill",
            iconColorName: "cyan"
        ),
        .init(
            id: "send_via_airdrop",
            isEnabled: true,
            title: "隔空投送",
            order: 3,
            actionType: .sendViaAirDrop,
            systemImageName: "paperplane.fill",
            iconColorName: "blue"
        ),
        .init(
            id: "cut_items",
            isEnabled: true,
            title: "剪切",
            order: 4,
            actionType: .cutItems,
            systemImageName: "scissors",
            iconColorName: "orange"
        ),
        .init(
            id: "open_ishot",
            isEnabled: true,
            title: "iShot",
            order: 5,
            actionType: .openIShot,
            systemImageName: "camera.viewfinder",
            iconColorName: "purple"
        ),
        .init(
            id: "convert_to_icns",
            isEnabled: true,
            title: "ICNS 转换",
            order: 6,
            actionType: .convertToICNS,
            systemImageName: "app.badge",
            iconColorName: "indigo"
        ),
        // 破坏性动作默认关闭，避免升级后用户右键菜单立即出现不可恢复删除入口。
        .init(
            id: "permanently_delete",
            isEnabled: false,
            title: "彻底删除",
            order: 7,
            actionType: .permanentlyDelete,
            systemImageName: "trash.slash.fill",
            iconColorName: "red"
        ),
        .init(
            id: "hide_selected_items",
            isEnabled: true,
            title: "隐藏已选文件",
            order: 8,
            actionType: .hideSelectedItems,
            systemImageName: "eye.slash.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "unhide_selected_items",
            isEnabled: true,
            title: "取消隐藏已选文件",
            order: 9,
            actionType: .unhideSelectedItems,
            systemImageName: "eye.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "hide_directory_items",
            isEnabled: true,
            title: "隐藏全部文件",
            order: 10,
            actionType: .hideDirectoryItems,
            systemImageName: "eye.slash.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "unhide_directory_items",
            isEnabled: true,
            title: "取消隐藏全部文件",
            order: 11,
            actionType: .unhideDirectoryItems,
            systemImageName: "eye.fill",
            iconColorName: "gray"
        )
    ]
}
