import Foundation
import Shared

/// V4 菜单动作执行上下文。
///
/// 策略层只读取该上下文，不直接访问 Finder 或存储系统。这样同一个策略可以被
/// Finder Extension、主 App 转发前校验、以及单元测试复用。
public struct ActionExecutionRequestContext {
    public let item: MenuDisplayItem
    public let finderContext: FinderSelectionContext
    public let configuration: SharedConfiguration

    public init(
        item: MenuDisplayItem,
        finderContext: FinderSelectionContext,
        configuration: SharedConfiguration
    ) {
        self.item = item
        self.finderContext = finderContext
        self.configuration = configuration
    }
}

/// 策略运行时依赖集合。
///
/// 工厂负责选择策略，适配器负责隔离系统 API、文件系统和外部命令。策略只协调
/// 业务流程，不直接创建 `Process`、访问剪贴板或处理 macOS 版本差异。
public struct ActionExecutionAdapters {
    let fileSystem: FileSystemActionAdapter
    let externalApplications: ExternalApplicationActionAdapter
    let clipboardWriter: ClipboardWriting

    public init(
        fileSystem: FileSystemActionAdapter,
        externalApplications: ExternalApplicationActionAdapter,
        clipboardWriter: ClipboardWriting
    ) {
        self.fileSystem = fileSystem
        self.externalApplications = externalApplications
        self.clipboardWriter = clipboardWriter
    }
}
