import Foundation

public enum SelectionSceneResolver {
    public static func resolveScene(
        selectedURLs: [URL],
        fileManager: FileManager = .default
    ) -> RightClickScene {
        guard !selectedURLs.isEmpty else {
            return .blankSpace
        }

        let selectedDirectories = selectedURLs.filter {
            isDirectory($0, fileManager: fileManager)
        }

        if selectedDirectories.count == selectedURLs.count {
            return .folder
        }
        return .file
    }

    public static func isDirectory(_ url: URL, fileManager: FileManager = .default) -> Bool {
        var isDirectory = ObjCBool(false)
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
