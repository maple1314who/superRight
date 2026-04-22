public final class InMemoryConfigurationStore: ConfigurationStore {
    private var configuration: SharedConfiguration

    public init(configuration: SharedConfiguration = .default) {
        self.configuration = configuration
    }

    public func load() throws -> SharedConfiguration {
        configuration
    }

    public func save(_ configuration: SharedConfiguration) throws {
        self.configuration = configuration
    }
}
