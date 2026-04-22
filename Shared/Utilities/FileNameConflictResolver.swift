import Foundation

public enum FileNameConflictResolver {
    public static func nextAvailableURL(
        in directoryURL: URL,
        baseName: String,
        pathExtension: String?,
        fileManager: FileManager = .default
    ) -> URL {
        let normalizedExtension = (pathExtension ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))

        var index = 1
        while true {
            let numberedName = index == 1 ? baseName : "\(baseName) \(index)"
            let fileName: String
            if normalizedExtension.isEmpty {
                fileName = numberedName
            } else {
                fileName = "\(numberedName).\(normalizedExtension)"
            }

            let candidateURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
            if !fileManager.fileExists(atPath: candidateURL.path) {
                return candidateURL
            }
            index += 1
        }
    }
}
