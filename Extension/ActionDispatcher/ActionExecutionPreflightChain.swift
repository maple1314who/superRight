import Foundation
import Shared

/// 动作执行前置校验链。
///
/// 责任链模式用于把“执行前必须满足的条件”从具体策略中抽出来，例如：
/// 新建文件必须有默认文件名、发送文件到必须有目标目录、复制/移动必须有选中文件。
/// 每个节点只处理自己关心的动作，其余动作继续向后传递，避免策略类里重复写校验。
open class ActionExecutionPreflightLink {
    private let next: ActionExecutionPreflightLink?

    public init(next: ActionExecutionPreflightLink? = nil) {
        self.next = next
    }

    open func validate(_ request: ActionExecutionRequestContext) throws {
        try next?.validate(request)
    }
}

/// 默认文件名校验节点。
///
/// `createFile` 策略依赖模板默认文件名生成目标文件；缺失时提前失败，避免进入
/// 文件系统适配器后才暴露配置错误。
public final class DefaultFileNamePreflightLink: ActionExecutionPreflightLink {
    public override func validate(_ request: ActionExecutionRequestContext) throws {
        if request.item.actionType == .createFile,
           request.item.defaultFileName?.isEmpty != false {
            throw ActionDispatchError.missingFileNameConfiguration
        }
        try super.validate(request)
    }
}

/// 目标目录校验节点。
///
/// 复制、移动、打开常用目录都需要配置目标路径。该节点只检查配置是否存在，
/// 目录是否真实可用仍交给文件系统适配器处理。
public final class DestinationPathPreflightLink: ActionExecutionPreflightLink {
    private let actionTypesRequiringDestination: Set<MenuActionType> = [
        .copyToDirectory,
        .moveToDirectory,
        .openDirectory
    ]

    public override func validate(_ request: ActionExecutionRequestContext) throws {
        if actionTypesRequiringDestination.contains(request.item.actionType),
           request.item.destinationPath?.isEmpty != false {
            throw ActionDispatchError.missingDestinationPath
        }
        try super.validate(request)
    }
}

/// Finder 选中项校验节点。
///
/// “复制到/移动到”必须基于 Finder 当前选中项执行；空白处触发时提前返回明确错误，
/// 防止后续适配器做无意义的文件系统操作。
public final class SelectedItemsPreflightLink: ActionExecutionPreflightLink {
    private let actionTypesRequiringSelection: Set<MenuActionType> = [
        .copyToDirectory,
        .moveToDirectory
    ]

    public override func validate(_ request: ActionExecutionRequestContext) throws {
        if actionTypesRequiringSelection.contains(request.item.actionType),
           request.finderContext.selectedItemURLs.isEmpty {
            throw ActionDispatchError.missingSelectedItems
        }
        try super.validate(request)
    }
}

public extension ActionExecutionPreflightLink {
    /// V4 默认前置校验链。
    ///
    /// 顺序是有业务含义的：先校验配置完整性，再校验 Finder 运行时输入，保证错误
    /// 信息优先指向最根本的问题。
    static func defaultChain() -> ActionExecutionPreflightLink {
        DefaultFileNamePreflightLink(
            next: DestinationPathPreflightLink(
                next: SelectedItemsPreflightLink()
            )
        )
    }
}
