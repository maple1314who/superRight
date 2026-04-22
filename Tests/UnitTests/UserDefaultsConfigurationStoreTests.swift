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
}
