import XCTest
@testable import Shared

final class AppExecutionRequestTests: XCTestCase {
    func testExternalApplicationMapping() {
        XCTAssertNil(AppExecutionAction.createFolder.externalApplication)
        XCTAssertNil(AppExecutionAction.createFile.externalApplication)
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
}
