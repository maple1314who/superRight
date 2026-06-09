import Foundation
import Shared

/// Finder Extension 侧动作执行错误。
///
/// 当前主路径已尽量转交主 App 执行，该错误仍用于可在扩展内安全完成的动作
/// 和单元测试覆盖。
public enum ActionDispatchError: Error, Equatable {
    case missingFileNameConfiguration
    case missingDestinationPath
    case missingSelectedItems
    case commandFailed(Int32)
    case clipboardWriteFailed
    case invalidDirectory
}

/// V4 Finder Extension 动作执行器。
///
/// 这是策略/工厂/适配器/观察者四个模式的组合入口：
/// - 策略：`MenuActionStrategy` 执行不同菜单动作。
/// - 工厂：`MenuActionStrategyFactory` 根据 `MenuActionType` 选择策略。
/// - 适配器：`ActionExecutionAdapters` 隔离文件系统、外部 App、系统版本差异。
/// - 观察者：`ActionExecutionObserving` 记录开始、成功和失败事件。
public final class ActionDispatcher {
    private let strategyFactory: MenuActionStrategyFactory
    private let adapters: ActionExecutionAdapters
    private let observer: ActionExecutionObserving

    public init(
        fileManager: FileManager = .default,
        commandRunner: CommandRunning = ProcessCommandRunner(),
        clipboardWriter: ClipboardWriting = NSPasteboardWriter(),
        systemVersionProvider: SystemVersionProviding = ProcessInfoSystemVersionProvider(),
        strategyFactory: MenuActionStrategyFactory = MenuActionStrategyFactory(),
        observers: [ActionExecutionObserving] = [NSLogActionExecutionObserver()]
    ) {
        self.strategyFactory = strategyFactory
        self.adapters = ActionExecutionAdapters(
            fileSystem: FileSystemActionAdapter(
                fileManager: fileManager,
                commandRunner: commandRunner
            ),
            externalApplications: ExternalApplicationActionAdapter(
                commandRunner: commandRunner,
                fileManager: fileManager,
                systemVersionProvider: systemVersionProvider
            ),
            clipboardWriter: clipboardWriter
        )
        self.observer = CompositeActionExecutionObserver(observers)
    }

    /// 执行一个菜单动作，并返回被创建、打开或处理的目标 URL。
    @discardableResult
    public func execute(
        item: MenuDisplayItem,
        context: FinderSelectionContext,
        configuration: SharedConfiguration
    ) throws -> URL? {
        let request = ActionExecutionRequestContext(
            item: item,
            finderContext: context,
            configuration: configuration
        )
        observer.actionWillExecute(request)

        do {
            let strategy = strategyFactory.makeStrategy(for: item.actionType)
            let resultURL = try strategy.execute(
                request: request,
                adapters: adapters
            )
            observer.actionDidFinish(request, resultURL: resultURL)
            return resultURL
        } catch {
            observer.actionDidFail(request, error: error)
            throw error
        }
    }
}
