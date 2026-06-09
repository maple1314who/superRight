import SwiftUI
import UniformTypeIdentifiers
import Shared

public struct ApplicationSettingsView: View {
    @ObservedObject private var viewModel: MenuManagementViewModel
    @State private var isChoosingMonitorDirectory = false

    public init(viewModel: MenuManagementViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("全局设置") {
                Toggle(
                    "按分类显示菜单",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.groupMenuByCategory },
                        set: { viewModel.updateAppSettingGroupMenu($0) }
                    )
                )
                Toggle(
                    "隐藏未安装应用菜单",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.hideUnavailableApplications },
                        set: { viewModel.updateAppSettingHideUnavailable($0) }
                    )
                )
            }

            Section("外部应用路径") {
                appPathField(for: .terminal, title: "Terminal")
                appPathField(for: .iTerm, title: "iTerm")
                appPathField(for: .vsCode, title: "VS Code")
                appPathField(for: .cursor, title: "Cursor")
                appPathField(for: .idea, title: "IntelliJ IDEA")
            }

            Section("监听目录") {
                ForEach(viewModel.monitoredDirectoryPaths, id: \.self) { path in
                    Text(path)
                        .font(.callout.monospaced())
                }
                .onDelete(perform: viewModel.removeMonitoredDirectories)

                Button("添加目录…") {
                    isChoosingMonitorDirectory = true
                }

                Button("快速添加：桌面") {
                    viewModel.addMonitoredDirectory(path: NSHomeDirectory().appending("/Desktop"))
                }
                Button("快速添加：下载") {
                    viewModel.addMonitoredDirectory(path: NSHomeDirectory().appending("/Downloads"))
                }
                Button("快速添加：文稿") {
                    viewModel.addMonitoredDirectory(path: NSHomeDirectory().appending("/Documents"))
                }
            }
        }
        .navigationTitle("应用设置")
        .fileImporter(
            isPresented: $isChoosingMonitorDirectory,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    viewModel.addMonitoredDirectory(path: url.path)
                }
            case .failure(let error):
                NSLog("%@", "选择监听目录失败: \(String(describing: error))")
            }
        }
    }

    @ViewBuilder
    private func appPathField(for app: ExternalApplication, title: String) -> some View {
        TextField(
            title,
            text: Binding(
                get: { viewModel.configuration.applicationPaths[app] ?? "" },
                set: { viewModel.setApplicationPath($0, for: app) }
            )
        )
    }
}
