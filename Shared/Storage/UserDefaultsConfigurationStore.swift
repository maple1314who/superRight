import Foundation

public final class UserDefaultsConfigurationStore: ConfigurationStore {
    private let userDefaults: UserDefaults?
    public let suiteName: String
    public let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        suiteName: String = SharedConstants.appGroupIdentifier,
        key: String = SharedConstants.configurationStorageKey,
        userDefaults: UserDefaults? = nil
    ) {
        self.suiteName = suiteName
        self.key = key
        self.userDefaults = userDefaults ?? UserDefaults(suiteName: suiteName)
    }

    public func load() throws -> SharedConfiguration {
        guard let userDefaults else {
            throw ConfigurationStoreError.unavailableStorage
        }

        guard let payload = userDefaults.data(forKey: key) else {
            return .default
        }

        do {
            return try decoder.decode(SharedConfiguration.self, from: payload)
        } catch {
            throw ConfigurationStoreError.decodeFailed
        }
    }

    public func save(_ configuration: SharedConfiguration) throws {
        guard let userDefaults else {
            throw ConfigurationStoreError.unavailableStorage
        }

        do {
            let payload = try encoder.encode(configuration)
            userDefaults.set(payload, forKey: key)
        } catch {
            throw ConfigurationStoreError.encodeFailed
        }
    }

    public func debugSummary(prefix: String) -> String {
        let storageState = userDefaults == nil ? "unavailable" : "ok"
        return "\(prefix) suiteName=\(suiteName) key=\(key) storage=\(storageState)"
    }
}
