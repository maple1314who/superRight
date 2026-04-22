import XCTest
@testable import ExtensionCore

final class FinderSelectionContextTests: XCTestCase {
    func testResolveCurrentDirectoryForFolderSelection() throws {
        let temp = try TemporaryDirectory()
        defer { temp.remove() }
        let folderURL = temp.url.appendingPathComponent("FolderA")
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let result = FinderSelectionContext.resolveCurrentDirectoryURL(
            targetedURL: temp.url,
            selectedItemURLs: [folderURL]
        )

        XCTAssertEqual(result, folderURL)
    }

    func testResolveCurrentDirectoryForFileSelection() throws {
        let temp = try TemporaryDirectory()
        defer { temp.remove() }
        let fileURL = temp.url.appendingPathComponent("a.txt")
        try "x".data(using: .utf8)?.write(to: fileURL)

        let result = FinderSelectionContext.resolveCurrentDirectoryURL(
            targetedURL: temp.url,
            selectedItemURLs: [fileURL]
        )

        XCTAssertEqual(result?.standardizedFileURL.path, temp.url.standardizedFileURL.path)
    }

    func testResolveCurrentDirectoryForBlankSelection() throws {
        let temp = try TemporaryDirectory()
        defer { temp.remove() }

        let result = FinderSelectionContext.resolveCurrentDirectoryURL(
            targetedURL: temp.url,
            selectedItemURLs: []
        )

        XCTAssertEqual(result, temp.url)
    }
}
