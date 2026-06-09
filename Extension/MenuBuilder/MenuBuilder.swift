import Foundation
import Shared

/// 外部应用可用性检查接口，便于单元测试注入假实现。
public protocol ApplicationAvailabilityChecking {
    func isInstalled(application: ExternalApplication, configuredPath: String?) -> Bool
}

/// 基于文件系统的外部应用检查器。
public struct FileSystemApplicationAvailabilityChecker: ApplicationAvailabilityChecking {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func isInstalled(application: ExternalApplication, configuredPath: String?) -> Bool {
        if let configuredPath, !configuredPath.isEmpty {
            return fileManager.fileExists(atPath: configuredPath)
        }
        return fileManager.fileExists(atPath: application.defaultBundlePath)
    }
}

/// Finder 右键菜单构建器。
///
/// 该模块只负责把共享配置和 Finder 上下文转换为展示菜单，不执行实际动作。
/// 动作执行由 Finder Extension 或主 App 请求处理器完成。
public struct MenuBuilder {
    private let availabilityChecker: ApplicationAvailabilityChecking

    public init(
        availabilityChecker: ApplicationAvailabilityChecking = FileSystemApplicationAvailabilityChecker()
    ) {
        self.availabilityChecker = availabilityChecker
    }

    /// 按当前场景、开关、应用可用性和动态配置生成最终菜单项。
    public func buildMenu(
        context: FinderSelectionContext,
        configuration: SharedConfiguration
    ) -> [MenuDisplayItem] {
        let configuredItems = configuration.sortedMenuItems()
            .filter { $0.isEnabled }
            .filter { $0.visibility.isVisible(in: context.scene) }
            .filter { shouldKeepMenuItem($0, configuration: configuration) }

        let templateItems = buildNewFileTemplateItems(
            context: context,
            configuration: configuration,
            startingOrder: (configuredItems.map(\.order).max() ?? -1) + 1
        )

        let sendToItems = buildSendToItems(
            context: context,
            configuration: configuration,
            startingOrder: max(
                configuredItems.map(\.order).max() ?? -1,
                templateItems.map(\.order).max() ?? -1
            ) + 1
        )

        let favoriteDirectoryItems = buildFavoriteDirectoryItems(
            configuration: configuration,
            startingOrder: max(
                configuredItems.map(\.order).max() ?? -1,
                templateItems.map(\.order).max() ?? -1,
                sendToItems.map(\.order).max() ?? -1
            ) + 1
        )

        let fileIconItems = buildFileIconItems(
            context: context,
            configuration: configuration,
            startingOrder: max(
                configuredItems.map(\.order).max() ?? -1,
                templateItems.map(\.order).max() ?? -1,
                sendToItems.map(\.order).max() ?? -1,
                favoriteDirectoryItems.map(\.order).max() ?? -1
            ) + 1
        )

        return (configuredItems + templateItems + sendToItems + favoriteDirectoryItems + fileIconItems)
            .sorted { $0.order < $1.order }
            .map(MenuDisplayItem.init(configuration:))
    }

    /// 将启用的新建文件模板转换为 Finder 菜单项。
    private func buildNewFileTemplateItems(
        context: FinderSelectionContext,
        configuration: SharedConfiguration,
        startingOrder: Int
    ) -> [MenuItemConfiguration] {
        guard context.scene != .file else {
            return []
        }

        return configuration.sortedNewFileTemplates()
            .filter { $0.isEnabled }
            .enumerated()
            .map { offset, template in
                MenuItemConfiguration(
                    id: "new_file_template_\(template.id)",
                    title: template.title,
                    isEnabled: true,
                    order: startingOrder + offset,
                    group: .create,
                    visibility: SceneVisibility(blankSpace: true, file: false, folder: true),
                    actionType: .createFile,
                    fileExtension: template.normalizedFileExtension,
                    defaultFileName: template.defaultFileName,
                    templateContent: template.templateContent
                )
            }
    }

    /// 根据“发送/移动到目录”配置生成复制或移动菜单项。
    private func buildSendToItems(
        context: FinderSelectionContext,
        configuration: SharedConfiguration,
        startingOrder: Int
    ) -> [MenuItemConfiguration] {
        guard context.scene != .blankSpace,
              !context.selectedItemURLs.isEmpty else {
            return []
        }

        let destinations = configuration.sortedSendToDestinations()
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .filter { !$0.directoryPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        var items: [MenuItemConfiguration] = []
        var order = startingOrder

        if configuration.appSettings.enableCopyTo {
            for destination in destinations {
                items.append(
                    MenuItemConfiguration(
                        id: "copy_to_\(destination.id)",
                        title: "复制到 \(destination.title)",
                        isEnabled: true,
                        order: order,
                        group: .tool,
                        visibility: SceneVisibility(blankSpace: false, file: true, folder: true),
                        actionType: .copyToDirectory,
                        destinationPath: destination.normalizedDirectoryPath
                    )
                )
                order += 1
            }
        }

        if configuration.appSettings.enableMoveTo {
            for destination in destinations {
                items.append(
                    MenuItemConfiguration(
                        id: "move_to_\(destination.id)",
                        title: "移动到 \(destination.title)",
                        isEnabled: true,
                        order: order,
                        group: .tool,
                        visibility: SceneVisibility(blankSpace: false, file: true, folder: true),
                        actionType: .moveToDirectory,
                        destinationPath: destination.normalizedDirectoryPath
                    )
                )
                order += 1
            }
        }

        return items
    }

    /// 根据常用目录配置生成打开目录菜单项。
    private func buildFavoriteDirectoryItems(
        configuration: SharedConfiguration,
        startingOrder: Int
    ) -> [MenuItemConfiguration] {
        guard configuration.appSettings.enableFavoriteDirectories else {
            return []
        }

        return configuration.sortedFavoriteDirectories()
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .filter { !$0.directoryPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .enumerated()
            .map { offset, directory in
                MenuItemConfiguration(
                    id: "favorite_directory_\(directory.id)",
                    title: "打开 \(directory.title)",
                    isEnabled: true,
                    order: startingOrder + offset,
                    group: .tool,
                    visibility: SceneVisibility(blankSpace: true, file: true, folder: true),
                    actionType: .openDirectory,
                    destinationPath: directory.normalizedDirectoryPath
                )
            }
    }

    /// 根据文件/文件夹图标预设生成“设置图标”和“还原图标”菜单项。
    private func buildFileIconItems(
        context: FinderSelectionContext,
        configuration: SharedConfiguration,
        startingOrder: Int
    ) -> [MenuItemConfiguration] {
        guard configuration.appSettings.enableFileIconPresets,
              context.scene != .blankSpace,
              !context.selectedItemURLs.isEmpty else {
            return []
        }

        let presets = configuration.sortedFileIconPresets()
            .filter { $0.isEnabled }
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        var items = presets.enumerated().map { offset, preset in
            MenuItemConfiguration(
                id: "apply_file_icon_\(preset.id)",
                title: "设置图标：\(preset.title)",
                isEnabled: true,
                order: startingOrder + offset,
                group: .tool,
                visibility: SceneVisibility(blankSpace: false, file: true, folder: true),
                actionType: .applyFileIcon,
                iconSystemImageName: preset.systemImageName,
                iconColorName: preset.iconColorName
            )
        }

        items.append(
            MenuItemConfiguration(
                id: "remove_custom_icon",
                title: "还原默认图标",
                isEnabled: true,
                order: startingOrder + items.count,
                group: .tool,
                visibility: SceneVisibility(blankSpace: false, file: true, folder: true),
                actionType: .removeCustomIcon
            )
        )
        return items
    }

    private func shouldKeepMenuItem(
        _ item: MenuItemConfiguration,
        configuration: SharedConfiguration
    ) -> Bool {
        guard configuration.appSettings.hideUnavailableApplications else {
            return true
        }

        guard item.requiresInstallationCheck,
              let application = item.targetApplication else {
            return true
        }

        return availabilityChecker.isInstalled(
            application: application,
            configuredPath: configuration.applicationPaths[application]
        )
    }
}
