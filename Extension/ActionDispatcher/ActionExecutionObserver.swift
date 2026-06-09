import Foundation

/// 菜单动作执行事件。
///
/// 观察者模式入口，用于把执行链的开始、成功和失败事件从策略本身解耦出来。
/// Finder Extension 目前使用 `NSLogActionExecutionObserver` 输出日志；后续可以接入
/// 埋点、调试面板或失败重试，而不需要修改具体菜单策略。
public protocol ActionExecutionObserving {
    func actionWillExecute(_ request: ActionExecutionRequestContext)
    func actionDidFinish(_ request: ActionExecutionRequestContext, resultURL: URL?)
    func actionDidFail(_ request: ActionExecutionRequestContext, error: Error)
}

public struct NSLogActionExecutionObserver: ActionExecutionObserving {
    public init() {}

    public func actionWillExecute(_ request: ActionExecutionRequestContext) {
        NSLog(
            "ActionDispatcher.execute start id=%@ title=%@ type=%@ scene=%@ currentDir=%@",
            request.item.id,
            request.item.title,
            request.item.actionType.rawValue,
            request.finderContext.scene.rawValue,
            request.finderContext.currentDirectoryURL.path
        )
    }

    public func actionDidFinish(_ request: ActionExecutionRequestContext, resultURL: URL?) {
        if let resultURL {
            NSLog(
                "ActionDispatcher.execute success type=%@ result=%@",
                request.item.actionType.rawValue,
                resultURL.path
            )
        } else {
            NSLog(
                "ActionDispatcher.execute success type=%@ result=nil",
                request.item.actionType.rawValue
            )
        }
    }

    public func actionDidFail(_ request: ActionExecutionRequestContext, error: Error) {
        NSLog(
            "ActionDispatcher.execute failed type=%@ error=%@",
            request.item.actionType.rawValue,
            String(describing: error)
        )
    }
}

public struct CompositeActionExecutionObserver: ActionExecutionObserving {
    private let observers: [ActionExecutionObserving]

    public init(_ observers: [ActionExecutionObserving]) {
        self.observers = observers
    }

    public func actionWillExecute(_ request: ActionExecutionRequestContext) {
        observers.forEach { $0.actionWillExecute(request) }
    }

    public func actionDidFinish(_ request: ActionExecutionRequestContext, resultURL: URL?) {
        observers.forEach { $0.actionDidFinish(request, resultURL: resultURL) }
    }

    public func actionDidFail(_ request: ActionExecutionRequestContext, error: Error) {
        observers.forEach { $0.actionDidFail(request, error: error) }
    }
}
