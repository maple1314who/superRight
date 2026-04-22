import Foundation
import AppCore
import ExtensionCore
import Shared

private final class RecordingCommandRunner: CommandRunning {
    struct Invocation {
        let executable: String
        let arguments: [String]
    }

    private(set) var invocations: [Invocation] = []

    @discardableResult
    func run(executable: String, arguments: [String]) throws -> Int32 {
        invocations.append(Invocation(executable: executable, arguments: arguments))
        return 0
    }
}

private final class RecordingClipboardWriter: ClipboardWriting {
    private(set) var value: String = ""

    func copy(text: String) throws {
        value = text
    }
}

@main
struct RuntimeVerifier {
    static func main() async throws {
        let suiteName = SharedConstants.appGroupIdentifier
        let key = SharedConstants.configurationStorageKey
        UserDefaults(suiteName: suiteName)?.removeObject(forKey: key)

        let appStore = UserDefaultsConfigurationStore(suiteName: suiteName, key: key)
        let finderStore = UserDefaultsConfigurationStore(suiteName: suiteName, key: key)

        NSLog("Verifier App store: %@", appStore.debugSummary(prefix: "App"))
        NSLog("Verifier Finder store: %@", finderStore.debugSummary(prefix: "Finder"))

        await MainActor.run {
            let viewModel = MenuManagementViewModel(store: appStore)
            NSLog("Verifier 初始配置 menuItems.count=%ld", viewModel.sortedMenuItems.count)

            viewModel.setEnabled(id: "open_terminal", isEnabled: false)
            NSLog("Verifier 已关闭 open_terminal")
        }

        var finderConfig = try finderStore.load()
        logConfig("Finder 读取（关闭后）", finderConfig)

        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("superright-runtime-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let context = FinderSelectionContext(selectedItemURLs: [], currentDirectoryURL: tempRoot)
        let builder = MenuBuilder(
            availabilityChecker: FileSystemApplicationAvailabilityChecker(fileManager: .default)
        )
        let menuWhenDisabled = builder.buildMenu(context: context, configuration: finderConfig)
        NSLog("Verifier Finder 菜单（关闭后）=%@", menuWhenDisabled.map(\.id).joined(separator: ","))

        await MainActor.run {
            let viewModel = MenuManagementViewModel(store: appStore)
            viewModel.setEnabled(id: "open_terminal", isEnabled: true)
            NSLog("Verifier 已开启 open_terminal")
        }

        finderConfig = try finderStore.load()
        logConfig("Finder 读取（开启后）", finderConfig)
        let menuWhenEnabled = builder.buildMenu(context: context, configuration: finderConfig)
        NSLog("Verifier Finder 菜单（开启后）=%@", menuWhenEnabled.map(\.id).joined(separator: ","))

        let commandRunner = RecordingCommandRunner()
        let clipboardWriter = RecordingClipboardWriter()
        let dispatcher = ActionDispatcher(
            fileManager: .default,
            commandRunner: commandRunner,
            clipboardWriter: clipboardWriter
        )

        guard let newFolderItem = menuWhenEnabled.first(where: { $0.id == "new_folder" }) else {
            fatalError("未找到 new_folder 菜单项")
        }
        let createdFolder = try dispatcher.execute(item: newFolderItem, context: context, configuration: finderConfig)
        NSLog("Verifier 点击新建文件夹 result=%@", createdFolder?.path ?? "nil")

        guard let openTerminalItem = menuWhenEnabled.first(where: { $0.id == "open_terminal" }) else {
            fatalError("未找到 open_terminal 菜单项")
        }
        let openedTarget = try dispatcher.execute(item: openTerminalItem, context: context, configuration: finderConfig)
        NSLog("Verifier 点击在终端中打开 target=%@", openedTarget?.path ?? "nil")

        if let invocation = commandRunner.invocations.last {
            NSLog("Verifier open 命令 executable=%@ args=%@", invocation.executable, invocation.arguments.joined(separator: " "))
        }

        NSLog("Verifier 复制路径缓存=%@", clipboardWriter.value)
    }

    private static func logConfig(_ prefix: String, _ config: SharedConfiguration) {
        let status = config.sortedMenuItems()
            .map { "\($0.id)=\($0.isEnabled ? "on" : "off")" }
            .joined(separator: ",")
        NSLog("%@ menuItems.count=%ld items=[%@]", prefix, config.menuItems.count, status)
    }
}
