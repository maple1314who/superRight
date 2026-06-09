public final class InMemoryConfigurationStore: ConfigurationStore {
    private var configuration: SharedConfiguration

    public init(configuration: SharedConfiguration = .default) {
        self.configuration = configuration.upgradedWithDefaults()
    }

    public func load() throws -> SharedConfiguration {
        configuration.upgradedWithDefaults()
    }

    public func save(_ configuration: SharedConfiguration) throws {
        self.configuration = configuration.upgradedWithDefaults()
    }
}
