public enum ConfigurationStoreError: Error, Equatable {
    case unavailableStorage
    case encodeFailed
    case decodeFailed
}

public protocol ConfigurationStore {
    func load() throws -> SharedConfiguration
    func save(_ configuration: SharedConfiguration) throws
}
