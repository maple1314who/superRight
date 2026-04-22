import SwiftUI
import Shared

public struct MenuItemDetailView: View {
    private let item: MenuItemConfiguration
    @ObservedObject private var viewModel: MenuManagementViewModel

    public init(item: MenuItemConfiguration, viewModel: MenuManagementViewModel) {
        self.item = item
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("基础信息") {
                LabeledContent("显示名称", value: item.title)
                LabeledContent("动作类型", value: item.actionType.rawValue)
                Toggle(
                    "启用",
                    isOn: Binding(
                        get: { viewModel.item(id: item.id)?.isEnabled ?? item.isEnabled },
                        set: { viewModel.setEnabled(id: item.id, isEnabled: $0) }
                    )
                )
            }

            Section("显示场景") {
                Toggle(
                    RightClickScene.blankSpace.rawValue,
                    isOn: Binding(
                        get: { viewModel.item(id: item.id)?.visibility.blankSpace ?? item.visibility.blankSpace },
                        set: { viewModel.setVisibility(id: item.id, scene: .blankSpace, isVisible: $0) }
                    )
                )
                Toggle(
                    RightClickScene.file.rawValue,
                    isOn: Binding(
                        get: { viewModel.item(id: item.id)?.visibility.file ?? item.visibility.file },
                        set: { viewModel.setVisibility(id: item.id, scene: .file, isVisible: $0) }
                    )
                )
                Toggle(
                    RightClickScene.folder.rawValue,
                    isOn: Binding(
                        get: { viewModel.item(id: item.id)?.visibility.folder ?? item.visibility.folder },
                        set: { viewModel.setVisibility(id: item.id, scene: .folder, isVisible: $0) }
                    )
                )
            }
        }
        .navigationTitle("功能详情")
    }
}
