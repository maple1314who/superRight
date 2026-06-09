import Foundation
import Shared

/// 菜单动作策略工厂。
///
/// 工厂模式集中维护 `MenuActionType -> MenuActionStrategy` 的映射，避免执行入口
/// 继续膨胀成大 `switch`。新增菜单动作时，优先新增策略并在工厂注册。
public final class MenuActionStrategyFactory {
    private let strategiesByActionType: [MenuActionType: MenuActionStrategy]

    public init(strategies: [MenuActionStrategy] = MenuActionStrategyFactory.defaultStrategies()) {
        var mappedStrategies: [MenuActionType: MenuActionStrategy] = [:]
        for strategy in strategies {
            for actionType in strategy.supportedActionTypes {
                mappedStrategies[actionType] = strategy
            }
        }
        self.strategiesByActionType = mappedStrategies
    }

    public func makeStrategy(for actionType: MenuActionType) -> MenuActionStrategy {
        strategiesByActionType[actionType] ?? ForwardedOnlyActionStrategy(actionTypes: [actionType])
    }

    public static func defaultStrategies() -> [MenuActionStrategy] {
        [
            CreateFolderActionStrategy(),
            CreateFileActionStrategy(),
            OpenExternalApplicationActionStrategy(),
            CopyPathActionStrategy(),
            TransferItemsActionStrategy(actionType: .copyToDirectory, shouldMove: false),
            TransferItemsActionStrategy(actionType: .moveToDirectory, shouldMove: true),
            OpenDirectoryActionStrategy(),
            ForwardedOnlyActionStrategy(
                actionTypes: [
                    .applyFileIcon,
                    .removeCustomIcon,
                    .showFileInfo,
                    .sendShortcutToDesktop,
                    .copyFileName,
                    .createFolderFromFileName,
                    .sendViaAirDrop,
                    .cutItems,
                    .openIShot,
                    .openIShotAnnotation,
                    .openIShotScreenshot,
                    .convertToICNS,
                    .convertToMacIcons,
                    .convertToIOSIcons,
                    .permanentlyDelete,
                    .hideSelectedItems,
                    .unhideSelectedItems,
                    .hideDirectoryItems,
                    .unhideDirectoryItems,
                    .openToolboxApplication,
                    .translateText,
                    .createQRCode
                ]
            )
        ]
    }
}
