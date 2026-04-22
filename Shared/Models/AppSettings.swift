public struct AppSettings: Codable, Equatable, Sendable {
    public var groupMenuByCategory: Bool
    public var hideUnavailableApplications: Bool
    public var launchAtLogin: Bool

    public init(
        groupMenuByCategory: Bool,
        hideUnavailableApplications: Bool,
        launchAtLogin: Bool
    ) {
        self.groupMenuByCategory = groupMenuByCategory
        self.hideUnavailableApplications = hideUnavailableApplications
        self.launchAtLogin = launchAtLogin
    }

    public static let `default` = AppSettings(
        groupMenuByCategory: true,
        hideUnavailableApplications: true,
        launchAtLogin: false
    )
}
