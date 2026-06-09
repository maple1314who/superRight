import Foundation
import XCTest
@testable import Shared

final class UserDefaultsConfigurationStoreTests: XCTestCase {
    func testLoadDefaultWhenNoStoredPayload() throws {
        let suiteName = "superright.tests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("无法创建测试用 UserDefaults")
            return
        }

        let store = UserDefaultsConfigurationStore(
            suiteName: suiteName,
            userDefaults: defaults
        )
        let loaded = try store.load()

        XCTAssertEqual(loaded, .default)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testSaveAndLoadRoundTrip() throws {
        let suiteName = "superright.tests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("无法创建测试用 UserDefaults")
            return
        }

        let store = UserDefaultsConfigurationStore(
            suiteName: suiteName,
            userDefaults: defaults
        )
        var configuration = SharedConfiguration.default
        configuration.menuItems[0].isEnabled = false
        configuration.appSettings.hideUnavailableApplications = false

        try store.save(configuration)
        let loaded = try store.load()

        XCTAssertEqual(loaded.menuItems[0].isEnabled, false)
        XCTAssertEqual(loaded.appSettings.hideUnavailableApplications, false)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testLoadLegacyPayloadWithoutMonitoredDirectories() throws {
        let suiteName = "superright.tests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("无法创建测试用 UserDefaults")
            return
        }

        let store = UserDefaultsConfigurationStore(
            suiteName: suiteName,
            userDefaults: defaults
        )

        let encodedDefault = try JSONEncoder().encode(SharedConfiguration.default)
        let rootObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encodedDefault) as? [String: Any]
        )
        var legacyObject = rootObject
        legacyObject.removeValue(forKey: "newFileTemplates")
        legacyObject.removeValue(forKey: "fileIconPresets")
        if var appSettings = legacyObject["appSettings"] as? [String: Any] {
            appSettings.removeValue(forKey: "monitoredDirectoryPaths")
            appSettings.removeValue(forKey: "hideMenuBarIcon")
            appSettings.removeValue(forKey: "showNewFileIcons")
            appSettings.removeValue(forKey: "showFileIconPresetIcons")
            appSettings.removeValue(forKey: "enableFileIconPresets")
            appSettings.removeValue(forKey: "openNewFileAfterCreate")
            appSettings.removeValue(forKey: "playSoundAfterCreate")
            legacyObject["appSettings"] = appSettings
        } else {
            XCTFail("无法构造 legacy appSettings")
            return
        }
        let legacyData = try JSONSerialization.data(withJSONObject: legacyObject)
        defaults.set(legacyData, forKey: SharedConstants.configurationStorageKey)

        let loaded = try store.load()
        XCTAssertFalse(loaded.appSettings.monitoredDirectoryPaths.isEmpty)
        XCTAssertTrue(loaded.appSettings.monitoredDirectoryPaths[0].hasSuffix("/Desktop"))
        XCTAssertTrue(loaded.appSettings.hideMenuBarIcon)
        XCTAssertFalse(loaded.newFileTemplates.isEmpty)
        XCTAssertTrue(loaded.appSettings.showNewFileIcons)
        XCTAssertFalse(loaded.fileIconPresets.isEmpty)
        XCTAssertTrue(loaded.appSettings.showFileIconPresetIcons)
        XCTAssertTrue(loaded.appSettings.enableFileIconPresets)
        XCTAssertFalse(loaded.appSettings.openNewFileAfterCreate)
        XCTAssertTrue(loaded.appSettings.playSoundAfterCreate)

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testLoadMigratesMissingMenuItemAndApplicationPath() throws {
        let suiteName = "superright.tests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("无法创建测试用 UserDefaults")
            return
        }

        let store = UserDefaultsConfigurationStore(
            suiteName: suiteName,
            userDefaults: defaults
        )

        let encodedDefault = try JSONEncoder().encode(SharedConfiguration.default)
        var rootObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encodedDefault) as? [String: Any]
        )

        if var menuItems = rootObject["menuItems"] as? [[String: Any]] {
            menuItems.removeAll { ($0["id"] as? String) == "open_idea" }
            rootObject["menuItems"] = menuItems
        } else {
            XCTFail("无法构造 legacy menuItems")
            return
        }

        if let applicationPaths = rootObject["applicationPaths"] as? [Any] {
            var rebuiltApplicationPaths: [Any] = []
            var index = 0
            while index + 1 < applicationPaths.count {
                let key = applicationPaths[index]
                let value = applicationPaths[index + 1]
                if let keyString = key as? String,
                   keyString == ExternalApplication.idea.rawValue {
                    index += 2
                    continue
                }
                rebuiltApplicationPaths.append(key)
                rebuiltApplicationPaths.append(value)
                index += 2
            }
            rootObject["applicationPaths"] = rebuiltApplicationPaths
        } else {
            XCTFail("无法构造 legacy applicationPaths")
            return
        }

        let legacyData = try JSONSerialization.data(withJSONObject: rootObject)
        defaults.set(legacyData, forKey: SharedConstants.configurationStorageKey)

        let loaded = try store.load()

        XCTAssertNotNil(loaded.menuItems.first { $0.id == "open_idea" })
        XCTAssertEqual(
            loaded.applicationPaths[.idea],
            ExternalApplication.idea.defaultBundlePath
        )

        defaults.removePersistentDomain(forName: suiteName)
    }
}
