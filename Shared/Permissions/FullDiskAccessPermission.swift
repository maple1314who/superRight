import Foundation

public enum FullDiskAccessPermission {
    public static var isGranted: Bool {
        canReadProtectedTCCDatabase || canReadProtectedUserData
    }

    private static var canReadProtectedTCCDatabase: Bool {
        protectedReadableFiles.contains { path in
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: url.path) else {
                return false
            }
            guard let handle = try? FileHandle(forReadingFrom: url) else {
                return false
            }
            defer {
                try? handle.close()
            }
            return (try? handle.read(upToCount: 1)) != nil
        }
    }

    private static var canReadProtectedUserData: Bool {
        protectedReadableDirectories.contains { path in
            let url = URL(fileURLWithPath: path, isDirectory: true)
            guard FileManager.default.fileExists(atPath: url.path) else {
                return false
            }
            return (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil
        }
    }

    private static var protectedReadableFiles: [String] {
        [
            NSHomeDirectory().appending("/Library/Application Support/com.apple.TCC/TCC.db"),
            NSHomeDirectory().appending("/Library/Application Support/com.apple.TCC/MDMOverrides.plist")
        ]
    }

    private static var protectedReadableDirectories: [String] {
        [
            NSHomeDirectory().appending("/Library/Mail"),
            NSHomeDirectory().appending("/Library/Messages"),
            NSHomeDirectory().appending("/Library/Safari"),
            NSHomeDirectory().appending("/Library/Calendars")
        ]
    }
}
