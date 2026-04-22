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
