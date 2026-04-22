public struct SceneVisibility: Codable, Equatable, Sendable {
    public var blankSpace: Bool
    public var file: Bool
    public var folder: Bool

    public init(blankSpace: Bool, file: Bool, folder: Bool) {
        self.blankSpace = blankSpace
        self.file = file
        self.folder = folder
    }

    public func isVisible(in scene: RightClickScene) -> Bool {
        switch scene {
        case .blankSpace:
            return blankSpace
        case .file:
            return file
        case .folder:
            return folder
        }
    }
}
