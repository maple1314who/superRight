import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Shared

/// 配置界面根视图。
///
/// 负责承载侧边栏和各功能设置页，所有配置写入统一委托给
/// `MenuManagementViewModel`，避免 SwiftUI 页面直接操作 App Group 存储。
public struct RootConfigurationView: View {
    @StateObject private var viewModel: MenuManagementViewModel
    @State private var selectedSection: SidebarSection = .newFile

    public init(
        store: ConfigurationStore = UserDefaultsConfigurationStore()
    ) {
        _viewModel = StateObject(wrappedValue: MenuManagementViewModel(store: store))
    }

    public var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedSection: $selectedSection)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 800, minHeight: 625)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedSection {
        case .newFile:
            NewFileSettingsView(
                viewModel: viewModel
            )
        case .sendTo:
            SendToSettingsView(
                viewModel: viewModel
            )
        case .favorites:
            FavoriteDirectoriesView(
                viewModel: viewModel
            )
        case .fileIcon:
            FileIconSettingsView(
                viewModel: viewModel
            )
        case .toolbox:
            ToolboxSettingsView(
                viewModel: viewModel
            )
        case .general:
            GeneralSettingsView(
                viewModel: viewModel
            )
        }
    }
}

#Preview {
    RootConfigurationView(store: InMemoryConfigurationStore())
}

private enum AppVersionInfo {
    static let displayName = "右键增强"

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "3.9.2"
    }

    static var sidebarTitle: String {
        "\(displayName) \(version)"
    }
}

private enum RootConfigurationLayout {
    /// 内容区顶部统一留白。
    ///
    /// 主窗口使用 full-size content view，系统红黄绿按钮浮在内容上方；
    /// 表格页统一下移，保持和旧版“超级右键”一致的顶部呼吸区。
    static let contentTopPadding: CGFloat = 90

    /// 短配置列表的固定视口高度。
    ///
    /// “发送文件到...”和“常用目录”采用上方列表、下方操作区的两段式布局；
    /// 列表区域固定为 5 行视口，更多数据在内部通过 `LazyVStack` 滚动，避免
    /// 添加/删除项目时底部按钮和开关跟随列表高度抖动。
    static let compactListViewportHeight: CGFloat = 29 + 32 * 5
}

private enum SidebarSection: String, Identifiable {
    case newFile = "新建文件"
    case sendTo = "发送文件到..."
    case favorites = "常用目录"
    case fileIcon = "文件(夹)图标"
    case toolbox = "工具箱"
    case general = "通用设置"

    static let allCases: [SidebarSection] = [
        .newFile,
        .sendTo,
        .favorites,
        .fileIcon,
        .toolbox,
        .general
    ]

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .newFile:
            return "doc.badge.plus"
        case .sendTo:
            return "square.and.arrow.up"
        case .favorites:
            return "heart.fill"
        case .fileIcon:
            return "folder.badge.gearshape"
        case .toolbox:
            return "square.grid.2x2.fill"
        case .general:
            return "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .newFile:
            return .cyan
        case .sendTo:
            return .green
        case .favorites:
            return .red
        case .fileIcon:
            return .orange
        case .toolbox:
            return .yellow
        case .general:
            return .blue
        }
    }
}

private struct SidebarView: View {
    @Binding var selectedSection: SidebarSection

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.18), radius: 4, y: 1)

                    Text("R")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text(AppVersionInfo.sidebarTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(height: 208)

            VStack(spacing: 0) {
                ForEach(SidebarSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        SidebarRow(
                            section: section,
                            isSelected: section == selectedSection
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .frame(width: 180)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.28, blue: 0.28),
                    Color(red: 0.12, green: 0.25, blue: 0.30),
                    Color(red: 0.22, green: 0.23, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(WindowDragExclusionMarker())
    }
}

private struct SidebarRow: View {
    let section: SidebarSection
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(section.tint)
                    .frame(width: 20, height: 20)

                Image(systemName: section.systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(section.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 39)
        .background(isSelected ? Color.white.opacity(0.18) : Color.clear)
    }
}

private struct NewFileSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    @State private var importErrorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            NewFileTableView(
                templates: viewModel.sortedNewFileTemplates,
                showIcons: viewModel.configuration.appSettings.showNewFileIcons,
                updateTemplate: viewModel.updateNewFileTemplate,
                moveTemplate: viewModel.moveNewFileTemplate
            )
                .padding(.horizontal, 20)
                .padding(.top, RootConfigurationLayout.contentTopPadding)

            HStack(spacing: 8) {
                Button("添加模板文件") {
                    importTemplateFile()
                }

                Button("添加空白模板") {
                    viewModel.addNewFileTemplate()
                }

                Button {
                    removeLastDisabledTemplate()
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 18)
                }
                .disabled(!viewModel.sortedNewFileTemplates.contains { !$0.isEnabled == false })

                Button {} label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button("重置") {
                    viewModel.resetNewFileTemplates()
                }
            }
            .padding(.horizontal, 20)
            .background(WindowDragExclusionMarker())

            if let importErrorMessage {
                Text(importErrorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle(
                        "显示图标",
                        isOn: Binding(
                            get: { viewModel.configuration.appSettings.showNewFileIcons },
                            set: { viewModel.updateShowNewFileIcons($0) }
                        )
                    )
                    Toggle(
                        "新建文件后自动打开",
                        isOn: Binding(
                            get: { viewModel.configuration.appSettings.openNewFileAfterCreate },
                            set: { viewModel.updateOpenNewFileAfterCreate($0) }
                        )
                    )
                }

                Spacer()

                Toggle(
                    "开启提示音",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.playSoundAfterCreate },
                        set: { viewModel.updatePlaySoundAfterCreate($0) }
                    )
                )
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)
            .background(WindowDragExclusionMarker())

            Spacer()
        }
    }

    private func removeLastDisabledTemplate() {
        guard let template = viewModel.sortedNewFileTemplates.last(where: { !$0.isEnabled == false }) else {
            return
        }
        viewModel.removeNewFileTemplate(id: template.id)
    }

    private func importTemplateFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = "导入"
        panel.message = "选择一个文件作为新建文件模板，原始内容会被保存到配置中。"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                return
            }

            do {
                try viewModel.importNewFileTemplate(from: url)
                importErrorMessage = nil
            } catch {
                importErrorMessage = "导入失败：\(error.localizedDescription)"
            }
        }
    }
}

private struct SendToSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    @State private var selectedDestinationID: String?

    var body: some View {
        VStack(spacing: 12) {
            SendToDestinationTableView(
                viewModel: viewModel,
                showIcons: viewModel.configuration.appSettings.showSendToIcons,
                selectedDestinationID: $selectedDestinationID,
                moveDestination: viewModel.moveSendToDestination
            )
            .padding(.horizontal, 20)
            .padding(.top, RootConfigurationLayout.contentTopPadding)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    addSendToDestination()
                }

                SmallSquareButton(systemImage: "minus") {
                    removeSelectedSendToDestination()
                }
                .disabled(viewModel.sortedSendToDestinations.isEmpty)

                Spacer()

                Button("重置") {
                    viewModel.resetSendToDestinations()
                }
            }
            .padding(.horizontal, 20)
            .background(WindowDragExclusionMarker())

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle(
                        "显示图标",
                        isOn: Binding(
                            get: { viewModel.configuration.appSettings.showSendToIcons },
                            set: { viewModel.updateShowSendToIcons($0) }
                        )
                    )
                    Toggle(
                        "启用复制文件到...",
                        isOn: Binding(
                            get: { viewModel.configuration.appSettings.enableCopyTo },
                            set: { viewModel.updateEnableCopyTo($0) }
                        )
                    )
                }

                Spacer()

                Toggle(
                    "启用移动文件到...",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.enableMoveTo },
                        set: { viewModel.updateEnableMoveTo($0) }
                    )
                )
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)
            .background(WindowDragExclusionMarker())

            Spacer()
        }
    }

    private func addSendToDestination() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "添加"
        panel.message = "选择一个目录加入“发送文件到”。"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                return
            }

            selectedDestinationID = viewModel.addSendToDestination(directoryURL: url)
        }
    }

    private func removeSelectedSendToDestination() {
        if let selectedDestinationID,
           viewModel.sortedSendToDestinations.contains(where: { $0.id == selectedDestinationID }) {
            viewModel.removeSendToDestination(id: selectedDestinationID)
        } else {
            viewModel.removeLastSendToDestination()
        }
        selectedDestinationID = viewModel.sortedSendToDestinations.last?.id
    }
}

private struct SendToDestinationTableView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    let showIcons: Bool
    @Binding var selectedDestinationID: String?
    let moveDestination: (String, String) -> Void
    @State private var draggingDestinationID: String?
    @State private var pendingDropTargetID: String?

    var body: some View {
        SettingsTableFrame(height: RootConfigurationLayout.compactListViewportHeight) {
            HStack(spacing: 0) {
                HeaderCell("图标", width: 60)
                HeaderCell("真实路径", alignment: .leading)
                HeaderCell("显示名称（点击选择/按住拖拽）", alignment: .leading)
            }
        } rows: {
            ForEach(viewModel.sortedSendToDestinations.indices, id: \.self) { index in
                let destination = viewModel.sortedSendToDestinations[index]
                SendToDestinationRowView(
                    destination: destination,
                    showIcon: showIcons,
                    isOdd: index % 2 == 1,
                    isSelected: selectedDestinationID == destination.id,
                    select: { selectedDestinationID = destination.id }
                )
                .opacity(draggingDestinationID == destination.id ? 0.55 : 1)
                .onDrag {
                    draggingDestinationID = destination.id
                    pendingDropTargetID = nil
                    return NSItemProvider(object: destination.id as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: StableReorderDropDelegate(
                        targetID: destination.id,
                        draggingID: $draggingDestinationID,
                        pendingTargetID: $pendingDropTargetID,
                        move: moveDestination
                    )
                )
            }

            EmptyStripedRows(startIndex: viewModel.sortedSendToDestinations.count, count: compactEmptyRowCount)
        }
    }
}

private struct SendToDestinationRowView: View {
    let destination: FileDestinationConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if showIcon {
                    SmallIconView(
                        systemImage: destination.systemImageName,
                        tint: destination.iconTint
                    )
                }
            }
            .frame(width: 60)

            Text(destination.directoryPath)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(destination.title)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 32)
        .contentShape(Rectangle())
        .background(rowBackground)
        .onTapGesture(perform: select)
    }

    private var rowBackground: Color {
        if isSelected {
            return Color.accentColor.opacity(0.18)
        }
        return isOdd ? Color.black.opacity(0.035) : Color.white
    }

}

private struct FavoriteDirectoriesView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    @State private var selectedDirectoryID: String?

    var body: some View {
        VStack(spacing: 12) {
            FavoriteDirectoryTableView(
                viewModel: viewModel,
                showIcons: viewModel.configuration.appSettings.showFavoriteDirectoryIcons,
                selectedDirectoryID: $selectedDirectoryID,
                moveDirectory: viewModel.moveFavoriteDirectory
            )
            .padding(.horizontal, 20)
            .padding(.top, RootConfigurationLayout.contentTopPadding)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    selectedDirectoryID = viewModel.addFavoriteDirectory()
                }

                SmallSquareButton(systemImage: "minus") {
                    removeSelectedFavoriteDirectory()
                }
                .disabled(viewModel.sortedFavoriteDirectories.isEmpty)

                Spacer()

                Button("重置") {
                    viewModel.resetFavoriteDirectories()
                }
            }
            .padding(.horizontal, 20)
            .background(WindowDragExclusionMarker())

            HStack {
                Toggle(
                    "显示图标",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.showFavoriteDirectoryIcons },
                        set: { viewModel.updateShowFavoriteDirectoryIcons($0) }
                    )
                )

                Spacer()

                Toggle(
                    "启用常用目录",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.enableFavoriteDirectories },
                        set: { viewModel.updateEnableFavoriteDirectories($0) }
                    )
                )
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)
            .background(WindowDragExclusionMarker())

            Spacer()
        }
    }

    private func removeSelectedFavoriteDirectory() {
        if let selectedDirectoryID,
           viewModel.sortedFavoriteDirectories.contains(where: { $0.id == selectedDirectoryID }) {
            viewModel.removeFavoriteDirectory(id: selectedDirectoryID)
        } else {
            viewModel.removeLastFavoriteDirectory()
        }
        selectedDirectoryID = viewModel.sortedFavoriteDirectories.last?.id
    }
}

private struct FavoriteDirectoryTableView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    let showIcons: Bool
    @Binding var selectedDirectoryID: String?
    let moveDirectory: (String, String) -> Void
    @State private var draggingDirectoryID: String?
    @State private var pendingDropTargetID: String?

    var body: some View {
        SettingsTableFrame(height: RootConfigurationLayout.compactListViewportHeight) {
            HStack(spacing: 0) {
                HeaderCell("图标", width: 60)
                HeaderCell("真实路径", alignment: .leading)
                HeaderCell("显示名称（点击选择/按住拖拽）", alignment: .leading)
            }
        } rows: {
            ForEach(viewModel.sortedFavoriteDirectories.indices, id: \.self) { index in
                let directory = viewModel.sortedFavoriteDirectories[index]
                FavoriteDirectoryRowView(
                    directory: directory,
                    showIcon: showIcons,
                    isOdd: index % 2 == 1,
                    isSelected: selectedDirectoryID == directory.id,
                    select: { selectedDirectoryID = directory.id }
                )
                .opacity(draggingDirectoryID == directory.id ? 0.55 : 1)
                .onDrag {
                    draggingDirectoryID = directory.id
                    pendingDropTargetID = nil
                    return NSItemProvider(object: directory.id as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: StableReorderDropDelegate(
                        targetID: directory.id,
                        draggingID: $draggingDirectoryID,
                        pendingTargetID: $pendingDropTargetID,
                        move: moveDirectory
                    )
                )
            }

            EmptyStripedRows(startIndex: viewModel.sortedFavoriteDirectories.count, count: compactEmptyRowCount)
        }
    }
}

private struct FavoriteDirectoryRowView: View {
    let directory: FileDestinationConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if showIcon {
                    SmallIconView(
                        systemImage: directory.systemImageName,
                        tint: directory.iconTint
                    )
                }
            }
            .frame(width: 60)

            Text(directory.directoryPath)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(directory.title)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 32)
        .contentShape(Rectangle())
        .background(rowBackground)
        .onTapGesture(perform: select)
    }

    private var rowBackground: Color {
        if isSelected {
            return Color.accentColor.opacity(0.18)
        }
        return isOdd ? Color.black.opacity(0.035) : Color.white
    }
}

private struct FileIconSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel

    var body: some View {
        VStack(spacing: 12) {
            FileIconTableView(
                presets: viewModel.sortedFileIconPresets,
                showIcons: viewModel.configuration.appSettings.showFileIconPresetIcons,
                update: viewModel.updateFileIconPreset,
                move: viewModel.moveFileIconPreset,
                importImage: importIconImage,
                clearImage: clearIconImage
            )
                .padding(.horizontal, 20)
                .padding(.top, RootConfigurationLayout.contentTopPadding)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    viewModel.addFileIconPreset()
                }

                SmallSquareButton(systemImage: "minus") {
                    viewModel.removeLastFileIconPreset()
                }
                .disabled(viewModel.sortedFileIconPresets.isEmpty)

                Text("*自定义图标尺寸建议小于 128 x 128（dpi = 72）")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("重置") {
                    viewModel.resetFileIconPresets()
                }
            }
            .padding(.horizontal, 20)
            .background(WindowDragExclusionMarker())

            HStack {
                Toggle(
                    "显示图标",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.showFileIconPresetIcons },
                        set: { viewModel.updateShowFileIconPresetIcons($0) }
                    )
                )

                Toggle(
                    "启用右键图标菜单",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.enableFileIconPresets },
                        set: { viewModel.updateEnableFileIconPresets($0) }
                    )
                )

                Spacer()
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)
            .background(WindowDragExclusionMarker())

            Spacer()
        }
    }

    private func importIconImage(for presetID: String) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.prompt = "导入"

        guard panel.runModal() == .OK,
              let url = panel.url,
              let image = NSImage(contentsOf: url),
              let data = try? Data(contentsOf: url) else {
            return
        }

        let width = Int(image.size.width.rounded())
        let height = Int(image.size.height.rounded())
        viewModel.updateFileIconPresetImage(
            id: presetID,
            imageData: data,
            fileName: url.lastPathComponent,
            sizeDescription: "\(width) x \(height)"
        )
    }

    private func clearIconImage(for preset: FileIconConfiguration) {
        viewModel.updateFileIconPresetImage(
            id: preset.id,
            imageData: nil,
            fileName: nil,
            sizeDescription: preset.defaultSizeDescription
        )
    }
}

private struct ToolboxSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel

    var body: some View {
        VStack(spacing: 12) {
            ToolboxTableView(
                items: viewModel.sortedToolboxItems,
                showIcons: viewModel.configuration.appSettings.showToolboxIcons,
                update: viewModel.updateToolboxItem
            )
                .padding(.horizontal, 20)
                .padding(.top, RootConfigurationLayout.contentTopPadding)

            HStack(spacing: 8) {
                Button("申请其他功能") {}

                Spacer()

                Button("重置") {
                    viewModel.resetToolboxItems()
                }
            }
            .padding(.horizontal, 20)
            .background(WindowDragExclusionMarker())

            HStack {
                Toggle(
                    "显示图标",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.showToolboxIcons },
                        set: { viewModel.updateShowToolboxIcons($0) }
                    )
                )

                Toggle(
                    "在 Finder 右键菜单启用工具箱",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.enableToolbox },
                        set: { viewModel.updateEnableToolbox($0) }
                    )
                )

                Spacer()
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)
            .background(WindowDragExclusionMarker())

            Spacer()
        }
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
    @State private var hasFullDiskAccess = FullDiskAccessPermission.isGranted

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            SettingsGroup(title: "权限") {
                Toggle(
                    "授予整个磁盘的读写权限",
                    isOn: Binding(
                        get: { hasFullDiskAccess },
                        set: { _ in openFullDiskAccessSettings() }
                    )
                )

                Text("你也许还需要在 系统偏好设置>安全性与隐私 中设置更多权限")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                Button("点击查看>>") {
                    openFullDiskAccessSettings()
                }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .font(.system(size: 13))
            }

            Divider()

            SettingsGroup(title: "菜单栏") {
                Toggle(
                    "隐藏 Dock 和菜单栏图标",
                    isOn: Binding(
                        get: { viewModel.configuration.appSettings.hideMenuBarIcon },
                        set: { viewModel.updateAppSettingHideMenuBarIcon($0) }
                    )
                )
            }

            Divider()

            SettingsGroup(title: "软件更新") {
                Text("如果隐藏 Dock 和菜单栏图标，也可以在这里手动检查更新。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                Button("检查更新…") {
                    requestCheckForUpdates()
                }
                    .buttonStyle(.borderedProminent)
            }

            Divider()

            SettingsGroup(title: "注意事项") {
                Text("右键增强是一个访达扩展，由系统调度。为了增加稳定性，有时有多个进程是正常的。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .toggleStyle(.checkbox)
        .padding(.top, 92)
        .padding(.horizontal, 58)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(WindowDragExclusionMarker())
        .onAppear {
            refreshFullDiskAccessStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshFullDiskAccessStatus()
        }
        .onReceive(Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()) { _ in
            refreshFullDiskAccessStatus()
        }
    }

    private func refreshFullDiskAccessStatus() {
        hasFullDiskAccess = FullDiskAccessPermission.isGranted
    }

    private func requestCheckForUpdates() {
        // AppCore 不直接依赖 Sparkle；检查更新请求通过通知交给主 App 的 AppDelegate。
        NotificationCenter.default.post(
            name: Notification.Name(SharedConstants.appCheckForUpdatesNotification),
            object: nil
        )
    }

    private func openFullDiskAccessSettings() {
        let urls = [
            URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"),
            URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles")
        ]

        for url in urls.compactMap({ $0 }) where NSWorkspace.shared.open(url) {
            return
        }
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))

            content
        }
    }
}

private struct DirectoryTableView: View {
    @Binding var destinations: [FileDestination]
    let showIcons: Bool
    let emptyRowCount: Int

    var body: some View {
        SettingsTableFrame {
            HStack(spacing: 0) {
                HeaderCell("图标", width: 60)
                HeaderCell("真实路径", alignment: .leading)
                HeaderCell("显示名称（点击编辑/按住拖拽）", alignment: .leading)
            }
        } rows: {
            ForEach(destinations.indices, id: \.self) { index in
                DirectoryRowView(
                    destination: $destinations[index],
                    showIcon: showIcons,
                    isOdd: index % 2 == 1
                )
            }

            EmptyStripedRows(startIndex: destinations.count, count: emptyRowCount)
        }
    }
}

private struct DirectoryRowView: View {
    @Binding var destination: FileDestination
    let showIcon: Bool
    let isOdd: Bool

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if showIcon {
                    SmallIconView(
                        systemImage: destination.systemImage,
                        tint: destination.iconTint
                    )
                }
            }
            .frame(width: 60)

            TextField("", text: $destination.path)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("", text: $destination.name)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
    }
}

private struct FileIconTableView: View {
    let presets: [FileIconConfiguration]
    let showIcons: Bool
    let update: (FileIconConfiguration) -> Void
    let move: (String, String) -> Void
    let importImage: (String) -> Void
    let clearImage: (FileIconConfiguration) -> Void
    @State private var draggingPresetID: String?
    @State private var pendingDropTargetID: String?

    var body: some View {
        SettingsTableFrame {
            HStack(spacing: 0) {
                HeaderCell(width: 58) {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundStyle(.blue)
                }
                HeaderCell("图标", width: 82)
                HeaderCell("尺寸", width: 128)
                HeaderCell("来源", width: 148)
                HeaderCell("显示名称（单击编辑/按住拖拽）", alignment: .leading)
            }
        } rows: {
            ForEach(Array(presets.enumerated()), id: \.element.id) { index, preset in
                FileIconPresetRowView(
                    preset: preset,
                    showIcon: showIcons,
                    isOdd: index % 2 == 1,
                    update: update,
                    importImage: importImage,
                    clearImage: clearImage
                )
                .onDrag {
                    draggingPresetID = preset.id
                    pendingDropTargetID = nil
                    return NSItemProvider(object: preset.id as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: StableReorderDropDelegate(
                        targetID: preset.id,
                        draggingID: $draggingPresetID,
                        pendingTargetID: $pendingDropTargetID,
                        move: move
                    )
                )
            }
        }
    }
}

/// 稳定拖拽排序代理。
///
/// 不在 `dropEntered` 中立即移动数组，只记录当前悬停目标并在松手时移动一次。
/// 这样可避免 SwiftUI 行位置变化后重复触发进入事件，导致列表拖拽时来回抖动。
private struct StableReorderDropDelegate: DropDelegate {
    let targetID: String
    @Binding var draggingID: String?
    @Binding var pendingTargetID: String?
    let move: (String, String) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggingID, draggingID != targetID else {
            return
        }
        pendingTargetID = targetID
    }

    func performDrop(info: DropInfo) -> Bool {
        if let draggingID,
           let pendingTargetID,
           draggingID != pendingTargetID {
            move(draggingID, pendingTargetID)
        }
        draggingID = nil
        pendingTargetID = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct FileIconPresetRowView: View {
    let preset: FileIconConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let update: (FileIconConfiguration) -> Void
    let importImage: (String) -> Void
    let clearImage: (FileIconConfiguration) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Toggle(
                "",
                isOn: Binding(
                    get: { preset.isEnabled },
                    set: { update(\.isEnabled, value: $0) }
                )
            )
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 58)

            ZStack {
                if showIcon {
                    if let importedIconImage = preset.importedIconImage {
                        Image(nsImage: importedIconImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        SmallIconView(
                            systemImage: preset.systemImageName,
                            tint: preset.iconTint
                        )
                    }
                }
            }
            .frame(width: 82)

            Text(preset.sizeDescription)
                .font(.system(size: 13))
                .frame(width: 128, alignment: .center)

            HStack(spacing: 6) {
                Button(preset.importedImageData == nil ? "导入" : "更换") {
                    importImage(preset.id)
                }
                .buttonStyle(.borderless)

                if preset.importedImageData != nil {
                    Button("清除") {
                        clearImage(preset)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .font(.system(size: 12))
            .frame(width: 148, alignment: .center)

            TextField(
                "",
                text: Binding(
                    get: { preset.title },
                    set: { update(\.title, value: $0) }
                )
            )
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
        .contentShape(Rectangle())
    }

    private func update<Value>(_ keyPath: WritableKeyPath<FileIconConfiguration, Value>, value: Value) {
        var updated = preset
        updated[keyPath: keyPath] = value
        update(updated)
    }
}

private struct ToolboxTableView: View {
    let items: [ToolboxItemConfiguration]
    let showIcons: Bool
    let update: (ToolboxItemConfiguration) -> Void

    var body: some View {
        SettingsTableFrame {
            HStack(spacing: 0) {
                HeaderCell(width: 58) {
                    Image(systemName: "square")
                        .foregroundStyle(.secondary)
                }
                HeaderCell("图标", width: 74)
                HeaderCell("显示名称（单击编辑/按住拖拽）", alignment: .leading)
                HeaderCell("选项", width: 260)
            }
        } rows: {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                ToolboxRowView(
                    item: item,
                    showIcon: showIcons,
                    isOdd: index % 2 == 1,
                    update: update
                )
            }
        }
    }
}

private struct ToolboxRowView: View {
    let item: ToolboxItemConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let update: (ToolboxItemConfiguration) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Toggle(
                "",
                isOn: Binding(
                    get: { item.isEnabled },
                    set: { update(\.isEnabled, value: $0) }
                )
            )
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 58)

            ZStack {
                if showIcon {
                    SmallIconView(systemImage: item.systemImageName, tint: item.iconTint)
                }
            }
            .frame(width: 74)

            TextField(
                "",
                text: Binding(
                    get: { item.title },
                    set: { update(\.title, value: $0) }
                )
            )
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if item.selectableOptions.isEmpty {
                    Color.clear
                } else if item.selectableOptions.count == 1,
                          let option = item.selectableOptions.first {
                    Text(option)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Picker(
                        "",
                        selection: Binding(
                            get: { item.option },
                            set: { update(\.option, value: $0) }
                        )
                    ) {
                        ForEach(item.selectableOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .labelsHidden()
                }
            }
            .frame(width: 238)
            .padding(.trailing, 22)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
    }

    private func update<Value>(_ keyPath: WritableKeyPath<ToolboxItemConfiguration, Value>, value: Value) {
        var updated = item
        updated[keyPath: keyPath] = value
        update(updated)
    }
}

private struct SettingsTableFrame<Header: View, Rows: View>: View {
    let height: CGFloat
    let header: Header
    let rows: Rows

    init(
        height: CGFloat = 455,
        @ViewBuilder header: () -> Header,
        @ViewBuilder rows: () -> Rows
    ) {
        self.height = height
        self.header = header()
        self.rows = rows()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .frame(height: 28)
                .font(.system(size: 12, weight: .medium))
                .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    rows
                }
            }
        }
        .frame(height: height)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
        .background(WindowDragExclusionMarker())
    }
}

/// 窗口拖拽排除标记。
///
/// 主 App 的全窗拖拽覆盖层会递归查找该 AppKit 标记视图；命中标记区域时，
/// 覆盖层不处理鼠标事件，保证表格行排序、滚动、Picker 和文本编辑不被拖窗抢占。
public final class WindowDragExclusionMarkerView: NSView {
    public override var mouseDownCanMoveWindow: Bool {
        false
    }
}

private struct WindowDragExclusionMarker: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        WindowDragExclusionMarkerView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private let compactEmptyRowCount = 0

private struct EmptyStripedRows: View {
    let startIndex: Int
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { index in
            Rectangle()
                .fill((startIndex + index) % 2 == 1 ? Color.black.opacity(0.035) : Color.white)
                .frame(height: 32)
        }
    }
}

private struct SmallSquareButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 18)
        }
    }
}

private struct NewFileTableView: View {
    let templates: [NewFileTemplateConfiguration]
    let showIcons: Bool
    let updateTemplate: (NewFileTemplateConfiguration) -> Void
    let moveTemplate: (String, String) -> Void
    @State private var draggingTemplateID: String?
    @State private var pendingDropTargetID: String?

    var body: some View {
        VStack(spacing: 0) {
            TableHeaderView()

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(templates.enumerated()), id: \.element.id) { index, template in
                        TemplateRowView(
                            template: template,
                            showIcon: showIcons,
                            isOdd: index % 2 == 1,
                            updateTemplate: updateTemplate
                        )
                        .opacity(draggingTemplateID == template.id ? 0.55 : 1)
                        .onDrag {
                            draggingTemplateID = template.id
                            pendingDropTargetID = nil
                            return NSItemProvider(object: template.id as NSString)
                        }
                        .onDrop(
                            of: [UTType.text],
                            delegate: StableReorderDropDelegate(
                                targetID: template.id,
                                draggingID: $draggingTemplateID,
                                pendingTargetID: $pendingDropTargetID,
                                move: moveTemplate
                            )
                        )
                    }
                }
            }
        }
        .frame(height: 445)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
        .background(WindowDragExclusionMarker())
    }
}

private struct TableHeaderView: View {
    var body: some View {
        HStack(spacing: 0) {
            HeaderCell(width: 58) {
                Image(systemName: "square")
                    .foregroundStyle(.secondary)
            }
            HeaderCell("图标", width: 58)
            HeaderCell("显示名称（单击编辑/按住拖拽）", alignment: .leading)
            HeaderCell("后缀", width: 105)
            HeaderCell("主菜单", width: 90)
        }
        .frame(height: 28)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.primary)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct HeaderCell<Content: View>: View {
    private let width: CGFloat?
    private let alignment: Alignment
    private let content: Content

    init(
        width: CGFloat? = nil,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        Group {
            if let width {
                content
                    .padding(.horizontal, 8)
                    .frame(width: width, alignment: alignment)
            } else {
                content
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: alignment)
            }
        }
        .frame(height: 28)
        .overlay(alignment: .trailing) {
            Divider()
        }
    }
}

private extension HeaderCell where Content == Text {
    init(_ title: String, width: CGFloat? = nil, alignment: Alignment = .center) {
        self.init(width: width, alignment: alignment) {
            Text(title)
        }
    }
}

private struct TemplateRowView: View {
    let template: NewFileTemplateConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let updateTemplate: (NewFileTemplateConfiguration) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Toggle(
                "",
                isOn: Binding(
                    get: { template.isEnabled },
                    set: { update(\.isEnabled, value: $0) }
                )
            )
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 58)

            ZStack {
                if showIcon {
                    FileTypeIcon(template: template)
                }
            }
            .frame(width: 58)

            TextField(
                "",
                text: Binding(
                    get: { template.title },
                    set: { update(\.title, value: $0) }
                )
            )
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(
                "",
                text: Binding(
                    get: { template.fileExtension },
                    set: { updateFileExtension($0) }
                )
            )
            .textFieldStyle(.plain)
            .font(.system(size: 13))
            .frame(width: 105, alignment: .leading)

            Toggle(
                "",
                isOn: Binding(
                    get: { template.showInMainMenu },
                    set: { update(\.showInMainMenu, value: $0) }
                )
            )
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 90)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
    }

    private func update<Value>(_ keyPath: WritableKeyPath<NewFileTemplateConfiguration, Value>, value: Value) {
        var next = template
        next[keyPath: keyPath] = value
        updateTemplate(next)
    }

    private func updateFileExtension(_ fileExtension: String) {
        var next = template
        let sanitized = fileExtension.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        next.fileExtension = sanitized
        next.defaultFileName = sanitized.isEmpty ? "Untitled" : "Untitled.\(sanitized)"
        updateTemplate(next)
    }
}

private struct FileTypeIcon: View {
    let template: NewFileTemplateConfiguration

    var body: some View {
        SmallIconView(systemImage: template.systemImageName, tint: template.iconTint)
    }
}

private struct SmallIconView: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(tint.opacity(0.16))
                .frame(width: 24, height: 24)

            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}

private struct PlaceholderSettingsView: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .padding(28)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private extension NewFileTemplateConfiguration {
    var iconTint: Color {
        switch iconColorName {
        case "blue":
            return .blue
        case "brown":
            return .brown
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        default:
            return .gray
        }
    }
}

private extension FileDestinationConfiguration {
    var iconTint: Color {
        switch iconColorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return .cyan
        }
    }
}

private extension FileIconConfiguration {
    var importedIconImage: NSImage? {
        guard let importedImageData else {
            return nil
        }
        return NSImage(data: importedImageData)
    }

    var defaultSizeDescription: String {
        FileIconConfiguration.defaultPresets
            .first { $0.id == id }?
            .sizeDescription ?? "128 x 128"
    }

    var iconTint: Color {
        switch iconColorName {
        case "black":
            return .black
        case "blue":
            return .blue
        case "brown":
            return .brown
        case "cyan":
            return .cyan
        case "green":
            return .green
        case "indigo":
            return .indigo
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "purple":
            return .purple
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return .blue
        }
    }
}

private extension ToolboxItemConfiguration {
    var selectableOptions: [String] {
        availableOptions.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var iconTint: Color {
        switch iconColorName {
        case "blue":
            return .blue
        case "cyan":
            return .cyan
        case "green":
            return .green
        case "gray":
            return .gray
        case "orange":
            return .orange
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return .blue
        }
    }
}

private struct FileDestination: Identifiable {
    let id = UUID()
    var path: String
    var name: String
    let systemImage: String
    let iconTint: Color

    static let empty = FileDestination(
        path: "~/",
        name: "新目录",
        systemImage: "folder.fill",
        iconTint: .cyan
    )

    static let defaultSendDestinations: [FileDestination] = [
        .init(path: "~/Downloads", name: "下载", systemImage: "tray.and.arrow.down.fill", iconTint: .cyan),
        .init(path: "~/Pictures", name: "图片", systemImage: "photo.fill", iconTint: .cyan),
        .init(path: "~/Music", name: "音乐", systemImage: "music.note", iconTint: .cyan),
        .init(path: "~/Movies", name: "影片", systemImage: "film.fill", iconTint: .cyan),
        .init(path: "~/Documents", name: "文稿", systemImage: "folder.fill", iconTint: .cyan)
    ]

    static let defaultFavoriteDirectories: [FileDestination] = [
        .init(path: "~/Music", name: "音乐", systemImage: "folder.fill", iconTint: .cyan),
        .init(path: "~/Pictures", name: "图片", systemImage: "folder.fill", iconTint: .cyan),
        .init(path: "~/Movies", name: "影片", systemImage: "folder.fill", iconTint: .cyan)
    ]
}
