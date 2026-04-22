import Foundation

struct TemporaryDirectory {
    let url: URL

    init(prefix: String = "superright-tests") throws {
        let root = FileManager.default.temporaryDirectory
        let directoryURL = root.appendingPathComponent("\(prefix)-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        self.url = directoryURL
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
