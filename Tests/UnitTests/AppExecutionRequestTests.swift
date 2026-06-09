import XCTest
@testable import Shared

final class AppExecutionRequestTests: XCTestCase {
    func testExternalApplicationMapping() {
        XCTAssertNil(AppExecutionAction.createFolder.externalApplication)
        XCTAssertNil(AppExecutionAction.createFile.externalApplication)
        XCTAssertNil(AppExecutionAction.openDirectory.externalApplication)
        XCTAssertNil(AppExecutionAction.applyFileIcon.externalApplication)
        XCTAssertNil(AppExecutionAction.removeCustomIcon.externalApplication)
        XCTAssertNil(AppExecutionAction.showFileInfo.externalApplication)
        XCTAssertNil(AppExecutionAction.copyFileName.externalApplication)
        XCTAssertNil(AppExecutionAction.createFolderFromFileName.externalApplication)
        XCTAssertNil(AppExecutionAction.sendViaAirDrop.externalApplication)
        XCTAssertNil(AppExecutionAction.permanentlyDelete.externalApplication)
        XCTAssertNil(AppExecutionAction.hideSelectedItems.externalApplication)
        XCTAssertNil(AppExecutionAction.unhideSelectedItems.externalApplication)
        XCTAssertNil(AppExecutionAction.hideDirectoryItems.externalApplication)
        XCTAssertNil(AppExecutionAction.unhideDirectoryItems.externalApplication)
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

    func testRequestRoundTripPreservesImportedTemplateData() throws {
        let templateData = Data([0x00, 0x01, 0x02, 0xFF])
        let request = AppExecutionRequest(
            requestID: "request-template",
            action: .createFile,
            directoryPath: "/Users/maple/Desktop",
            defaultFileName: "Template.bin",
            fileExtension: "bin",
            templateContent: "fallback",
            templateData: templateData
        )

        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(AppExecutionRequest.self, from: encoded)

        XCTAssertEqual(decoded.requestID, "request-template")
        XCTAssertEqual(decoded.action, .createFile)
        XCTAssertEqual(decoded.defaultFileName, "Template.bin")
        XCTAssertEqual(decoded.templateContent, "fallback")
        XCTAssertEqual(decoded.templateData, templateData)
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

    func testRequestRoundTripPreservesToolboxFields() throws {
        let request = AppExecutionRequest(
            requestID: "request-4",
            action: .copyFileName,
            directoryPath: "/Users/maple/Desktop",
            targetPath: "/Users/maple/Desktop/a.txt",
            sourcePaths: ["/Users/maple/Desktop/a.txt"],
            toolboxOption: "option"
        )

        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(AppExecutionRequest.self, from: encoded)

        XCTAssertEqual(decoded.requestID, "request-4")
        XCTAssertEqual(decoded.action, .copyFileName)
        XCTAssertEqual(decoded.sourcePaths, ["/Users/maple/Desktop/a.txt"])
        XCTAssertEqual(decoded.toolboxOption, "option")
    }
}
