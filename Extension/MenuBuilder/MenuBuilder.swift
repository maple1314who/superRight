import Foundation
import Shared

public protocol ApplicationAvailabilityChecking {
    func isInstalled(application: ExternalApplication, configuredPath: String?) -> Bool
}

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

public struct MenuBuilder {
    private let availabilityChecker: ApplicationAvailabilityChecking

    public init(
        availabilityChecker: ApplicationAvailabilityChecking = FileSystemApplicationAvailabilityChecker()
    ) {
        self.availabilityChecker = availabilityChecker
    }

    public func buildMenu(
        context: FinderSelectionContext,
        configuration: SharedConfiguration
    ) -> [MenuDisplayItem] {
        configuration.sortedMenuItems()
            .filter { $0.isEnabled }
            .filter { $0.visibility.isVisible(in: context.scene) }
            .filter { shouldKeepMenuItem($0, configuration: configuration) }
            .map(MenuDisplayItem.init(configuration:))
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
