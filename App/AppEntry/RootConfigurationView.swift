import SwiftUI
import AppKit
import Shared

public struct RootConfigurationView: View {
    @StateObject private var viewModel: MenuManagementViewModel
    @State private var selectedSection: SidebarSection = .newFile
    @State private var sendDestinations = FileDestination.defaultSendDestinations
    @State private var favoriteDirectories = FileDestination.defaultFavoriteDirectories
    @State private var fileIconPresets = FileIconPreset.defaultPresets
    @State private var toolboxItems = ToolboxItem.defaultItems
    @State private var showSendIcons = true
    @State private var showFavoriteIcons = true
    @State private var showFilePresetIcons = true
    @State private var showToolboxIcons = true
    @State private var enableCopyTo = true
    @State private var enableMoveTo = false
    @State private var enableFavoriteDirectories = true

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
                directories: $favoriteDirectories,
                showIcons: $showFavoriteIcons,
                isEnabled: $enableFavoriteDirectories
            )
        case .fileIcon:
            FileIconSettingsView(
                presets: $fileIconPresets,
                showIcons: $showFilePresetIcons
            )
        case .toolbox:
            ToolboxSettingsView(
                items: $toolboxItems,
                showIcons: $showToolboxIcons
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

                Text("超级右键 2.2.3")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                Button("评分") {}
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.cyan)
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

            Button("订购") {}
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.cyan)
                .padding(.bottom, 24)
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

    var body: some View {
        VStack(spacing: 12) {
            NewFileTableView(
                templates: viewModel.sortedNewFileTemplates,
                showIcons: viewModel.configuration.appSettings.showNewFileIcons,
                updateTemplate: viewModel.updateNewFileTemplate
            )
                .padding(.horizontal, 20)
                .padding(.top, 45)

            HStack(spacing: 8) {
                Button("添加模板文件") {
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

            Spacer()
        }
    }

    private func removeLastDisabledTemplate() {
        guard let template = viewModel.sortedNewFileTemplates.last(where: { !$0.isEnabled == false }) else {
            return
        }
        viewModel.removeNewFileTemplate(id: template.id)
    }
}

private struct SendToSettingsView: View {
    @ObservedObject var viewModel: MenuManagementViewModel

    var body: some View {
        VStack(spacing: 12) {
            SendToDestinationTableView(
                viewModel: viewModel,
                showIcons: viewModel.configuration.appSettings.showSendToIcons,
                emptyRowCount: 12
            )
            .padding(.horizontal, 20)
            .padding(.top, 45)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    viewModel.addSendToDestination()
                }

                SmallSquareButton(systemImage: "minus") {
                    viewModel.removeLastSendToDestination()
                }
                .disabled(viewModel.sortedSendToDestinations.isEmpty)

                Spacer()

                Button("重置") {
                    viewModel.resetSendToDestinations()
                }
            }
            .padding(.horizontal, 20)

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

            Spacer()
        }
    }
}

private struct SendToDestinationTableView: View {
    @ObservedObject var viewModel: MenuManagementViewModel
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
            ForEach(viewModel.sortedSendToDestinations.indices, id: \.self) { index in
                let destination = viewModel.sortedSendToDestinations[index]
                SendToDestinationRowView(
                    destination: destination,
                    showIcon: showIcons,
                    isOdd: index % 2 == 1,
                    update: viewModel.updateSendToDestination
                )
            }

            EmptyStripedRows(startIndex: viewModel.sortedSendToDestinations.count, count: emptyRowCount)
        }
    }
}

private struct SendToDestinationRowView: View {
    let destination: FileDestinationConfiguration
    let showIcon: Bool
    let isOdd: Bool
    let update: (FileDestinationConfiguration) -> Void

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

            TextField(
                "",
                text: Binding(
                    get: { destination.directoryPath },
                    set: { update(\.directoryPath, value: $0) }
                )
            )
            .textFieldStyle(.plain)
            .font(.system(size: 13))
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)

            TextField(
                "",
                text: Binding(
                    get: { destination.title },
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
    }

    private func update<Value>(_ keyPath: WritableKeyPath<FileDestinationConfiguration, Value>, value: Value) {
        var updated = destination
        updated[keyPath: keyPath] = value
        update(updated)
    }
}

private struct FavoriteDirectoriesView: View {
    @Binding var directories: [FileDestination]
    @Binding var showIcons: Bool
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(spacing: 12) {
            DirectoryTableView(
                destinations: $directories,
                showIcons: showIcons,
                emptyRowCount: 16
            )
            .padding(.horizontal, 20)
            .padding(.top, 45)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    directories.append(.empty)
                }

                SmallSquareButton(systemImage: "minus") {
                    if !directories.isEmpty {
                        directories.removeLast()
                    }
                }
                .disabled(directories.isEmpty)

                Spacer()

                Button("重置") {
                    directories = FileDestination.defaultFavoriteDirectories
                }
            }
            .padding(.horizontal, 20)

            HStack {
                Toggle("显示图标", isOn: $showIcons)

                Spacer()

                Toggle("启用常用目录", isOn: $isEnabled)
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)

            Spacer()
        }
    }
}

private struct FileIconSettingsView: View {
    @Binding var presets: [FileIconPreset]
    @Binding var showIcons: Bool

    var body: some View {
        VStack(spacing: 12) {
            FileIconTableView(presets: $presets, showIcons: showIcons)
                .padding(.horizontal, 20)
                .padding(.top, 45)

            HStack(spacing: 8) {
                SmallSquareButton(systemImage: "plus") {
                    presets.append(.empty)
                }

                SmallSquareButton(systemImage: "minus") {
                    if !presets.isEmpty {
                        presets.removeLast()
                    }
                }
                .disabled(presets.isEmpty)

                Text("*自定义图标尺寸建议小于 128 x 128（dpi = 72）")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("重置") {
                    presets = FileIconPreset.defaultPresets
                }
            }
            .padding(.horizontal, 20)

            HStack {
                Toggle("显示图标", isOn: $showIcons)

                Spacer()

                Button("更多图标素材>>") {}
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)

            Spacer()
        }
    }
}

private struct ToolboxSettingsView: View {
    @Binding var items: [ToolboxItem]
    @Binding var showIcons: Bool

    var body: some View {
        VStack(spacing: 12) {
            ToolboxTableView(items: $items, showIcons: showIcons)
                .padding(.horizontal, 20)
                .padding(.top, 45)

            HStack(spacing: 8) {
                Button("申请其他功能") {}

                Spacer()

                Button("重置") {
                    items = ToolboxItem.defaultItems
                }
            }
            .padding(.horizontal, 20)

            HStack {
                Toggle("显示图标", isOn: $showIcons)

                Spacer()
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .padding(.horizontal, 58)
            .padding(.top, 10)

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

            SettingsGroup(title: "注意事项") {
                Text("超级右键是一个访达扩展，由系统调度。为了增加稳定性，有时有多个进程是正常的。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .toggleStyle(.checkbox)
        .padding(.top, 92)
        .padding(.horizontal, 58)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
    @Binding var presets: [FileIconPreset]
    let showIcons: Bool

    var body: some View {
        SettingsTableFrame {
            HStack(spacing: 0) {
                HeaderCell(width: 58) {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundStyle(.blue)
                }
                HeaderCell("图标", width: 82)
                HeaderCell("尺寸", width: 128)
                HeaderCell("显示名称（单击编辑/按住拖拽）", alignment: .leading)
            }
        } rows: {
            ForEach(presets.indices, id: \.self) { index in
                FileIconPresetRowView(
                    preset: $presets[index],
                    showIcon: showIcons,
                    isOdd: index % 2 == 1
                )
            }
        }
    }
}

private struct FileIconPresetRowView: View {
    @Binding var preset: FileIconPreset
    let showIcon: Bool
    let isOdd: Bool

    var body: some View {
        HStack(spacing: 0) {
            Toggle("", isOn: $preset.enabled)
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 58)

            ZStack {
                if showIcon {
                    SmallIconView(
                        systemImage: preset.systemImage,
                        tint: preset.iconTint
                    )
                }
            }
            .frame(width: 82)

            Text(preset.size)
                .font(.system(size: 13))
                .frame(width: 128, alignment: .center)

            TextField("", text: $preset.name)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
    }
}

private struct ToolboxTableView: View {
    @Binding var items: [ToolboxItem]
    let showIcons: Bool

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
            ForEach(items.indices, id: \.self) { index in
                ToolboxRowView(
                    item: $items[index],
                    showIcon: showIcons,
                    isOdd: index % 2 == 1
                )
            }
        }
    }
}

private struct ToolboxRowView: View {
    @Binding var item: ToolboxItem
    let showIcon: Bool
    let isOdd: Bool

    var body: some View {
        HStack(spacing: 0) {
            Toggle("", isOn: $item.enabled)
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 58)

            ZStack {
                if showIcon {
                    SmallIconView(systemImage: item.systemImage, tint: item.iconTint)
                }
            }
            .frame(width: 74)

            TextField("", text: $item.name)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker("", selection: $item.option) {
                ForEach(item.availableOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .labelsHidden()
            .frame(width: 238)
            .padding(.trailing, 22)
        }
        .frame(height: 32)
        .background(isOdd ? Color.black.opacity(0.035) : Color.white)
    }
}

private struct SettingsTableFrame<Header: View, Rows: View>: View {
    let header: Header
    let rows: Rows

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder rows: () -> Rows
    ) {
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
        .frame(height: 455)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
    }
}

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

private struct FileIconPreset: Identifiable {
    let id = UUID()
    var enabled: Bool
    var name: String
    var size: String
    let systemImage: String
    let iconTint: Color

    static let empty = FileIconPreset(
        enabled: true,
        name: "自定义",
        size: "128 x 128",
        systemImage: "photo.fill",
        iconTint: .blue
    )

    static let defaultPresets: [FileIconPreset] = [
        .init(enabled: true, name: "App", size: "128 x 128", systemImage: "app.fill", iconTint: .blue),
        .init(enabled: true, name: "Apple", size: "128 x 128", systemImage: "apple.logo", iconTint: .black),
        .init(enabled: true, name: "书本", size: "128 x 128", systemImage: "book.closed.fill", iconTint: .orange),
        .init(enabled: true, name: "日历", size: "128 x 128", systemImage: "calendar", iconTint: .red),
        .init(enabled: true, name: "云端", size: "128 x 128", systemImage: "cloud.fill", iconTint: .blue),
        .init(enabled: true, name: "Excel", size: "128 x 128", systemImage: "x.square.fill", iconTint: .green),
        .init(enabled: true, name: "文件", size: "128 x 128", systemImage: "doc.fill", iconTint: .blue),
        .init(enabled: true, name: "谷歌", size: "128 x 128", systemImage: "globe", iconTint: .blue),
        .init(enabled: true, name: "Mac OS1", size: "128 x 128", systemImage: "desktopcomputer", iconTint: .indigo),
        .init(enabled: true, name: "Mac OS2", size: "128 x 128", systemImage: "macwindow", iconTint: .indigo),
        .init(enabled: true, name: "Mac", size: "64 x 64", systemImage: "laptopcomputer", iconTint: .brown),
        .init(enabled: true, name: "邮件", size: "128 x 128", systemImage: "envelope.fill", iconTint: .blue),
        .init(enabled: true, name: "音乐", size: "128 x 128", systemImage: "music.note", iconTint: .pink),
        .init(enabled: true, name: "Pages", size: "128 x 128", systemImage: "pencil.and.outline", iconTint: .orange),
        .init(enabled: true, name: "图片", size: "128 x 128", systemImage: "photo.fill", iconTint: .cyan)
    ]
}

private struct ToolboxItem: Identifiable {
    let id = UUID()
    var enabled: Bool
    var name: String
    var option: String
    let availableOptions: [String]
    let systemImage: String
    let iconTint: Color

    static let defaultItems: [ToolboxItem] = [
        .init(enabled: true, name: "文件信息", option: "", availableOptions: [""], systemImage: "info.circle.fill", iconTint: .blue),
        .init(enabled: true, name: "发送快捷方式到桌面", option: "", availableOptions: [""], systemImage: "arrow.up.right.square.fill", iconTint: .gray),
        .init(enabled: true, name: "隔空投送", option: "", availableOptions: [""], systemImage: "airplayaudio", iconTint: .blue),
        .init(enabled: true, name: "拷贝文件(夹)名称", option: "", availableOptions: [""], systemImage: "doc.on.doc.fill", iconTint: .cyan),
        .init(enabled: true, name: "根据文件名新建文件夹", option: "", availableOptions: [""], systemImage: "folder.fill", iconTint: .cyan),
        .init(enabled: true, name: "剪切", option: "剪切时不隐藏选中的文件", availableOptions: ["剪切时不隐藏选中的文件", "剪切时隐藏选中的文件"], systemImage: "scissors", iconTint: .blue),
        .init(enabled: true, name: "iShot贴图、标注", option: "", availableOptions: [""], systemImage: "photo.fill", iconTint: .green),
        .init(enabled: true, name: "iShot 截图", option: "", availableOptions: [""], systemImage: "photo.fill", iconTint: .green),
        .init(enabled: true, name: "拷贝路径", option: "", availableOptions: [""], systemImage: "link", iconTint: .green),
        .init(enabled: true, name: "彻底删除", option: "需要再次确认", availableOptions: ["需要再次确认", "直接删除"], systemImage: "trash.fill", iconTint: .red),
        .init(enabled: true, name: "取消隐藏全部文件", option: "", availableOptions: [""], systemImage: "eye.fill", iconTint: .gray),
        .init(enabled: true, name: "隐藏全部文件", option: "", availableOptions: [""], systemImage: "eye.slash.fill", iconTint: .gray),
        .init(enabled: true, name: "取消隐藏已选文件", option: "", availableOptions: [""], systemImage: "eye.fill", iconTint: .gray),
        .init(enabled: true, name: "隐藏已选文件", option: "", availableOptions: [""], systemImage: "eye.slash.fill", iconTint: .gray),
        .init(enabled: true, name: "转为 ICNS 格式", option: "", availableOptions: [""], systemImage: "camera.filters", iconTint: .orange)
    ]
}
