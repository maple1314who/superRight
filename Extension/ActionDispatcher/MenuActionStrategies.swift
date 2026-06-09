import Foundation
import Shared

/// 菜单动作策略。
///
/// 每个策略只负责一类菜单动作的业务流程。策略通过 `ActionExecutionAdapters`
/// 使用文件系统、剪贴板和外部应用能力，避免直接依赖具体 macOS API。
public protocol MenuActionStrategy {
    var supportedActionTypes: Set<MenuActionType> { get }

    @discardableResult
    func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL?
}

public struct CreateFolderActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType> = [.createFolder]

    public init() {}

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        try adapters.fileSystem.createFolder(in: request.finderContext.currentDirectoryURL)
    }
}

public struct CreateFileActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType> = [.createFile]

    public init() {}

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        try adapters.fileSystem.createFile(
            item: request.item,
            in: request.finderContext.currentDirectoryURL
        )
    }
}

public struct OpenExternalApplicationActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType> = [
        .openTerminal,
        .openITerm,
        .openVSCode,
        .openCursor,
        .openIdea
    ]

    public init() {}

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        guard let application = request.item.actionType.externalApplication else {
            throw ActionDispatchError.commandFailed(-1)
        }
        return try adapters.externalApplications.openApplication(
            application,
            context: request.finderContext,
            configuration: request.configuration
        )
    }
}

public struct CopyPathActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType> = [.copyPath]

    public init() {}

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        let targetURL = request.finderContext.primarySelectedURL ?? request.finderContext.currentDirectoryURL
        try adapters.clipboardWriter.copy(text: targetURL.path)
        return targetURL
    }
}

public struct TransferItemsActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType>
    private let shouldMove: Bool

    public init(actionType: MenuActionType, shouldMove: Bool) {
        self.supportedActionTypes = [actionType]
        self.shouldMove = shouldMove
    }

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        try adapters.fileSystem.transferSelectedItems(
            item: request.item,
            context: request.finderContext,
            shouldMove: shouldMove
        )
    }
}

public struct OpenDirectoryActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType> = [.openDirectory]

    public init() {}

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        try adapters.fileSystem.openDirectory(item: request.item)
    }
}

/// 只转发给主 App 的动作策略。
///
/// Finder Extension 进程不适合直接做弹窗、权限敏感、图标写入、删除等操作。
/// 对这些菜单动作返回 `nil`，由 `FinderSync` 转发到主 App 的执行链处理。
public struct ForwardedOnlyActionStrategy: MenuActionStrategy {
    public let supportedActionTypes: Set<MenuActionType>

    public init(actionTypes: Set<MenuActionType>) {
        self.supportedActionTypes = actionTypes
    }

    public func execute(
        request: ActionExecutionRequestContext,
        adapters: ActionExecutionAdapters
    ) throws -> URL? {
        NSLog(
            "ActionDispatcher.execute forwarded-only type=%@",
            request.item.actionType.rawValue
        )
        return nil
    }
}

private extension MenuActionType {
    var externalApplication: ExternalApplication? {
        switch self {
        case .openTerminal:
            return .terminal
        case .openITerm:
            return .iTerm
        case .openVSCode:
            return .vsCode
        case .openCursor:
            return .cursor
        case .openIdea:
            return .idea
        default:
            return nil
        }
    }
}
