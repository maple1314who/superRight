import Foundation
import Shared

public struct FinderSelectionContext: Equatable, Sendable {
    public var selectedItemURLs: [URL]
    public var currentDirectoryURL: URL

    public init(selectedItemURLs: [URL], currentDirectoryURL: URL) {
        self.selectedItemURLs = selectedItemURLs
        self.currentDirectoryURL = currentDirectoryURL
    }

    public var scene: RightClickScene {
        SelectionSceneResolver.resolveScene(selectedURLs: selectedItemURLs)
    }

    public var primarySelectedURL: URL? {
        selectedItemURLs.first
    }

    public static func fromFinder(
        targetedURL: URL?,
        selectedItemURLs: [URL],
        fileManager: FileManager = .default
    ) -> FinderSelectionContext? {
        let currentDirectoryURL = resolveCurrentDirectoryURL(
            targetedURL: targetedURL,
            selectedItemURLs: selectedItemURLs,
            fileManager: fileManager
        )
        guard let currentDirectoryURL else {
            return nil
        }
        return FinderSelectionContext(
            selectedItemURLs: selectedItemURLs,
            currentDirectoryURL: currentDirectoryURL
        )
    }

    public static func resolveCurrentDirectoryURL(
        targetedURL: URL?,
        selectedItemURLs: [URL],
        fileManager: FileManager = .default
    ) -> URL? {
        if let firstSelected = selectedItemURLs.first {
            if SelectionSceneResolver.isDirectory(firstSelected, fileManager: fileManager) {
                return firstSelected
            }
            return firstSelected.deletingLastPathComponent()
        }

        if let targetedURL {
            if SelectionSceneResolver.isDirectory(targetedURL, fileManager: fileManager) {
                return targetedURL
            }
            return targetedURL.deletingLastPathComponent()
        }

        return nil
    }
}
