import AppKit
import Foundation

public protocol CommandRunning {
    @discardableResult
    func run(executable: String, arguments: [String]) throws -> Int32
}

public struct ProcessCommandRunner: CommandRunning {
    public init() {}

    @discardableResult
    public func run(executable: String, arguments: [String]) throws -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus
    }
}

public protocol ClipboardWriting {
    func copy(text: String) throws
}

public struct NSPasteboardWriter: ClipboardWriting {
    public init() {}

    public func copy(text: String) throws {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(text, forType: .string)
        if !success {
            throw ActionDispatchError.clipboardWriteFailed
        }
    }
}

/// 系统版本提供者。
///
/// V4 执行层通过该协议隔离 `ProcessInfo`，让菜单策略可以基于 macOS 版本选择
/// 不同适配器实现，也让单元测试可以注入固定系统版本。
public protocol SystemVersionProviding {
    var operatingSystemVersion: OperatingSystemVersion { get }
}

public struct ProcessInfoSystemVersionProvider: SystemVersionProviding {
    public init() {}

    public var operatingSystemVersion: OperatingSystemVersion {
        ProcessInfo.processInfo.operatingSystemVersion
    }
}
