/// Finder 右键菜单的展示分组。
///
/// 该枚举只描述菜单 UI 的分类语义，不决定动作执行方式；Finder Extension
/// 会按固定 Finder 使用习惯把分组渲染为根菜单子菜单。
public enum MenuGroup: String, Codable, CaseIterable, Sendable {
    case create = "新建"
    case open = "打开"
    case sendTo = "发送到"
    case icon = "图标"
    case tool = "工具"
}
