import XCTest
@testable import Shared

final class AppExecutionRequestTests: XCTestCase {
    func testExternalApplicationMapping() {
        XCTAssertNil(AppExecutionAction.createFolder.externalApplication)
        XCTAssertNil(AppExecutionAction.createFile.externalApplication)
        XCTAssertNil(AppExecutionAction.openDirectory.externalApplication)
        XCTAssertNil(AppExecutionAction.applyFileIcon.externalApplication)
        XCTAssertNil(AppExecutionAction.removeCustomIcon.externalApplication)
        XCTAssertEqual(AppExecutionAction.openTerminal.externalApplication, .terminal)
        XCTAssertEqual(AppExecutionAction.openITerm.externalApplication, .iTerm)
        XCTAssertEqual(AppExecutionAction.openVSCode.externalApplication, .vsCode)
        XCTAssertEqual(AppExecutionAction.openCursor.externalApplication, .cursor)
        XCTAssertEqual(AppExecutionAction.openIdea.externalApplication, .idea)
    }

    func testRequestRoundTripPreservesForwardedApplicationFields() throws {
        let request = AppExecutionRequest(
            requestID: "request-1",
            action: .openTerminal,
            directoryPath: "/Users/maple/Desktop",
            targetPath: "/Users/maple/Desktop",
            applicationPath: "/System/Applications/Utilities/Terminal.app"
        )

        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(AppExecutionRequest.self, from: encoded)

        XCTAssertEqual(decoded.requestID, "request-1")
        XCTAssertEqual(decoded.action, .openTerminal)
        XCTAssertEqual(decoded.directoryPath, "/Users/maple/Desktop")
        XCTAssertEqual(decoded.targetPath, "/Users/maple/Desktop")
        XCTAssertEqual(
            decoded.applicationPath,
            "/System/Applications/Utilities/Terminal.app"
        )
    }

    func testRequestRoundTripPreservesDirectoryTransferFields() throws {
        let request = AppExecutionRequest(
            requestID: "request-2",
            action: .copyToDirectory,
            directoryPath: "/Users/maple/Desktop",
            sourcePaths: ["/Users/maple/Desktop/a.txt"],
            destinationPath: "/Users/maple/Downloads"
        )

        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(AppExecutionRequest.self, from: encoded)

        XCTAssertEqual(decoded.requestID, "request-2")
        XCTAssertEqual(decoded.action, .copyToDirectory)
        XCTAssertEqual(decoded.sourcePaths, ["/Users/maple/Desktop/a.txt"])
        XCTAssertEqual(decoded.destinationPath, "/Users/maple/Downloads")
    }

    func testRequestRoundTripPreservesFileIconFields() throws {
        let request = AppExecutionRequest(
            requestID: "request-3",
            action: .applyFileIcon,
            directoryPath: "/Users/maple/Desktop",
            targetPath: "/Users/maple/Desktop/a.txt",
            sourcePaths: ["/Users/maple/Desktop/a.txt"],
            iconSystemImageName: "doc.fill",
            iconColorName: "blue"
        )

        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(AppExecutionRequest.self, from: encoded)

        XCTAssertEqual(decoded.requestID, "request-3")
        XCTAssertEqual(decoded.action, .applyFileIcon)
        XCTAssertEqual(decoded.targetPath, "/Users/maple/Desktop/a.txt")
        XCTAssertEqual(decoded.sourcePaths, ["/Users/maple/Desktop/a.txt"])
        XCTAssertEqual(decoded.iconSystemImageName, "doc.fill")
        XCTAssertEqual(decoded.iconColorName, "blue")
    }
}
