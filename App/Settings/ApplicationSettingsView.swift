import SwiftUI
import Shared

public struct ApplicationSettingsView: View {
    @ObservedObject private var viewModel: MenuManagementViewModel

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
            }
        }
        .navigationTitle("应用设置")
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
