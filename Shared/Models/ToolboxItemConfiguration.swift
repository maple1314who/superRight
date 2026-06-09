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
            id: "send_shortcut_to_desktop",
            isEnabled: true,
            title: "发送快捷方式到桌面",
            order: 1,
            actionType: .sendShortcutToDesktop,
            systemImageName: "arrow.up.right.square.fill",
            iconColorName: "blue"
        ),
        .init(
            id: "send_via_airdrop",
            isEnabled: true,
            title: "隔空投送",
            order: 2,
            actionType: .sendViaAirDrop,
            systemImageName: "paperplane.fill",
            iconColorName: "blue"
        ),
        .init(
            id: "copy_file_name",
            isEnabled: true,
            title: "拷贝文件(夹)名称",
            order: 3,
            actionType: .copyFileName,
            systemImageName: "doc.on.doc.fill",
            iconColorName: "cyan"
        ),
        .init(
            id: "create_folder_from_file_name",
            isEnabled: true,
            title: "根据文件名新建文件夹",
            order: 4,
            actionType: .createFolderFromFileName,
            systemImageName: "folder.fill",
            iconColorName: "cyan"
        ),
        .init(
            id: "cut_items",
            isEnabled: true,
            title: "剪切",
            order: 5,
            actionType: .cutItems,
            systemImageName: "scissors",
            iconColorName: "orange"
        ),
        .init(
            id: "open_ishot",
            isEnabled: true,
            title: "iShot 标注/贴图",
            order: 6,
            actionType: .openIShotAnnotation,
            systemImageName: "camera.viewfinder",
            iconColorName: "purple"
        ),
        .init(
            id: "open_ishot_screenshot",
            isEnabled: true,
            title: "iShot 截图",
            order: 7,
            actionType: .openIShotScreenshot,
            systemImageName: "camera.metering.center.weighted",
            iconColorName: "purple"
        ),
        .init(
            id: "copy_path_toolbox",
            isEnabled: true,
            title: "拷贝路径",
            order: 8,
            actionType: .copyPath,
            systemImageName: "point.topleft.down.curvedto.point.bottomright.up",
            iconColorName: "cyan"
        ),
        // 破坏性动作默认关闭，避免升级后用户右键菜单立即出现不可恢复删除入口。
        .init(
            id: "permanently_delete",
            isEnabled: false,
            title: "彻底删除",
            order: 9,
            actionType: .permanentlyDelete,
            systemImageName: "trash.slash.fill",
            iconColorName: "red"
        ),
        .init(
            id: "unhide_directory_items",
            isEnabled: true,
            title: "取消隐藏全部文件",
            order: 10,
            actionType: .unhideDirectoryItems,
            systemImageName: "eye.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "hide_directory_items",
            isEnabled: true,
            title: "隐藏全部文件",
            order: 11,
            actionType: .hideDirectoryItems,
            systemImageName: "eye.slash.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "unhide_selected_items",
            isEnabled: true,
            title: "取消隐藏已选文件",
            order: 12,
            actionType: .unhideSelectedItems,
            systemImageName: "eye.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "hide_selected_items",
            isEnabled: true,
            title: "隐藏已选文件",
            order: 13,
            actionType: .hideSelectedItems,
            systemImageName: "eye.slash.fill",
            iconColorName: "gray"
        ),
        .init(
            id: "convert_to_icns",
            isEnabled: true,
            title: "ICNS 转换",
            order: 14,
            actionType: .convertToICNS,
            systemImageName: "app.badge",
            iconColorName: "indigo"
        ),
        .init(
            id: "convert_to_mac_icons",
            isEnabled: true,
            title: "生成 macOS Icons",
            order: 15,
            actionType: .convertToMacIcons,
            systemImageName: "macwindow.badge.plus",
            iconColorName: "indigo"
        ),
        .init(
            id: "convert_to_ios_icons",
            isEnabled: true,
            title: "生成 iOS Icons",
            order: 16,
            actionType: .convertToIOSIcons,
            systemImageName: "iphone.gen3.badge.play",
            iconColorName: "indigo"
        ),
        .toolboxApplication(
            id: "open_terminal_toolbox",
            title: "在 Terminal 中打开",
            order: 17,
            appName: "Terminal",
            isEnabled: true,
            systemImageName: "terminal.fill",
            iconColorName: "black"
        ),
        .toolboxApplication(id: "open_iterm_toolbox", title: "在 iTerm2 中打开", order: 18, appName: "iTerm", isEnabled: false, systemImageName: "terminal", iconColorName: "black"),
        .toolboxApplication(id: "open_vscode_toolbox", title: "在 VSCode 中打开", order: 19, appName: "Visual Studio Code", isEnabled: false, systemImageName: "chevron.left.forwardslash.chevron.right", iconColorName: "blue"),
        .toolboxApplication(id: "open_sublime_text", title: "在 Sublime Text 中打开", order: 20, appName: "Sublime Text", isEnabled: false, systemImageName: "curlybraces", iconColorName: "orange"),
        .toolboxApplication(id: "open_sublime_merge", title: "在 Sublime Merge 中打开", order: 21, appName: "Sublime Merge", isEnabled: false, systemImageName: "point.3.connected.trianglepath.dotted", iconColorName: "orange"),
        .toolboxApplication(id: "open_warp", title: "在 Warp 中打开", order: 22, appName: "Warp", isEnabled: false, systemImageName: "terminal.fill", iconColorName: "purple"),
        .toolboxApplication(id: "open_marktext", title: "在 MarkText 中打开", order: 23, appName: "MarkText", isEnabled: false, systemImageName: "text.alignleft", iconColorName: "gray"),
        .toolboxApplication(id: "open_obsidian", title: "在 Obsidian 中打开", order: 24, appName: "Obsidian", isEnabled: false, systemImageName: "note.text", iconColorName: "purple"),
        .toolboxApplication(id: "open_tabby", title: "在 Tabby 中打开", order: 25, appName: "Tabby", isEnabled: false, systemImageName: "terminal", iconColorName: "yellow"),
        .toolboxApplication(id: "open_visual_studio", title: "在 Visual Studio 中打开", order: 26, appName: "Visual Studio", isEnabled: false, systemImageName: "chevron.left.forwardslash.chevron.right", iconColorName: "purple"),
        .toolboxApplication(id: "open_hyper", title: "在 Hyper 中打开", order: 27, appName: "Hyper", isEnabled: false, systemImageName: "terminal", iconColorName: "gray"),
        .toolboxApplication(id: "open_emacs", title: "在 Emacs 中打开", order: 28, appName: "Emacs", isEnabled: false, systemImageName: "doc.plaintext", iconColorName: "purple"),
        .toolboxApplication(id: "open_clion", title: "在 CLion 中打开", order: 29, appName: "CLion", isEnabled: false, systemImageName: "hammer.fill", iconColorName: "green"),
        .toolboxApplication(id: "open_coteditor", title: "在 CotEditor 中打开", order: 30, appName: "CotEditor", isEnabled: false, systemImageName: "doc.text", iconColorName: "blue"),
        .toolboxApplication(id: "open_hbuilderx", title: "在 HBuilderX 中打开", order: 31, appName: "HBuilderX", isEnabled: false, systemImageName: "chevron.left.forwardslash.chevron.right", iconColorName: "green"),
        .toolboxApplication(id: "open_phpstorm", title: "在 PhpStorm 中打开", order: 32, appName: "PhpStorm", isEnabled: false, systemImageName: "server.rack", iconColorName: "purple"),
        .toolboxApplication(id: "open_pycharm", title: "在 PyCharm 中打开", order: 33, appName: "PyCharm", isEnabled: false, systemImageName: "chevron.left.forwardslash.chevron.right", iconColorName: "green"),
        .toolboxApplication(id: "open_typora", title: "在 Typora 中打开", order: 34, appName: "Typora", isEnabled: false, systemImageName: "textformat", iconColorName: "gray"),
        .toolboxApplication(id: "open_webstorm", title: "在 WebStorm 中打开", order: 35, appName: "WebStorm", isEnabled: false, systemImageName: "globe", iconColorName: "blue"),
        .toolboxApplication(id: "open_idea_toolbox", title: "在 IDEA 中打开", order: 36, appName: "IntelliJ IDEA", isEnabled: false, systemImageName: "lightbulb.fill", iconColorName: "orange"),
        .toolboxApplication(id: "open_android_studio", title: "在 Android Studio 中打开", order: 37, appName: "Android Studio", isEnabled: false, systemImageName: "antenna.radiowaves.left.and.right", iconColorName: "green"),
        .toolboxApplication(id: "open_appcode", title: "在 AppCode 中打开", order: 38, appName: "AppCode", isEnabled: false, systemImageName: "swift", iconColorName: "orange"),
        .toolboxApplication(id: "open_datagrip", title: "在 DataGrip 中打开", order: 39, appName: "DataGrip", isEnabled: false, systemImageName: "cylinder.split.1x2.fill", iconColorName: "green"),
        .toolboxApplication(id: "open_goland", title: "在 GoLand 中打开", order: 40, appName: "GoLand", isEnabled: false, systemImageName: "figure.run", iconColorName: "cyan"),
        .toolboxApplication(id: "open_rider", title: "在 Rider 中打开", order: 41, appName: "Rider", isEnabled: false, systemImageName: "motorcycle.fill", iconColorName: "red"),
        .toolboxApplication(id: "open_rubymine", title: "在 RubyMine 中打开", order: 42, appName: "RubyMine", isEnabled: false, systemImageName: "diamond.fill", iconColorName: "red"),
        .init(
            id: "translate_baidu",
            isEnabled: true,
            title: "百度翻译",
            order: 43,
            actionType: .translateText,
            option: "baidu",
            systemImageName: "character.book.closed.fill",
            iconColorName: "blue"
        ),
        .init(
            id: "translate_google",
            isEnabled: true,
            title: "Google 翻译",
            order: 44,
            actionType: .translateText,
            option: "google",
            systemImageName: "character.book.closed.fill",
            iconColorName: "green"
        ),
        .init(
            id: "create_qr_code",
            isEnabled: true,
            title: "生成二维码",
            order: 45,
            actionType: .createQRCode,
            systemImageName: "qrcode",
            iconColorName: "black"
        )
    ]
}

private extension ToolboxItemConfiguration {
    static func toolboxApplication(
        id: String,
        title: String,
        order: Int,
        appName: String,
        isEnabled: Bool,
        systemImageName: String,
        iconColorName: String
    ) -> ToolboxItemConfiguration {
        ToolboxItemConfiguration(
            id: id,
            isEnabled: isEnabled,
            title: title,
            order: order,
            actionType: .openToolboxApplication,
            option: appName,
            systemImageName: systemImageName,
            iconColorName: iconColorName
        )
    }
}
