import SwiftUI
import Shared

public struct MenuManagementView: View {
    @ObservedObject private var viewModel: MenuManagementViewModel

    public init(viewModel: MenuManagementViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("菜单项") {
                    ForEach(MenuGroup.allCases, id: \.self) { group in
                        if !viewModel.menuItems(in: group).isEmpty {
                            Section(group.rawValue) {
                                ForEach(viewModel.menuItems(in: group)) { item in
                                    NavigationLink {
                                        MenuItemDetailView(item: item, viewModel: viewModel)
                                    } label: {
                                        row(item: item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("菜单管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("保存配置") {
                        try? viewModel.save()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(item: MenuItemConfiguration) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                Text(sceneSummary(for: item))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                Button {
                    viewModel.moveItem(id: item.id, offset: -1)
                } label: {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canMoveUp(id: item.id))

                Button {
                    viewModel.moveItem(id: item.id, offset: 1)
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canMoveDown(id: item.id))
            }

            Toggle(
                "启用",
                isOn: Binding(
                    get: { item.isEnabled },
                    set: { newValue in
                        viewModel.setEnabled(id: item.id, isEnabled: newValue)
                    }
                )
            )
            .labelsHidden()
        }
    }

    private func sceneSummary(for item: MenuItemConfiguration) -> String {
        let visibility = item.visibility
        let visibleScenes = [
            visibility.blankSpace ? RightClickScene.blankSpace.rawValue : nil,
            visibility.file ? RightClickScene.file.rawValue : nil,
            visibility.folder ? RightClickScene.folder.rawValue : nil
        ].compactMap { $0 }

        if visibleScenes.isEmpty {
            return "不在任何场景展示"
        }
        return visibleScenes.joined(separator: " / ")
    }
}
