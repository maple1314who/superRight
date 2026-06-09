import Foundation

/// 完全磁盘访问权限状态探测。
///
/// macOS 没有公开 API 能直接读取“完全磁盘访问权限”开关状态，只能通过读取
/// TCC 保护的数据库或用户数据目录做能力探测。这里覆盖系统级 TCC 数据库
/// 和多个常见用户隐私目录，避免单个目录不存在导致授权后仍显示未授权。
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
            "/Library/Application Support/com.apple.TCC/TCC.db",
            NSHomeDirectory().appending("/Library/Application Support/com.apple.TCC/TCC.db"),
            NSHomeDirectory().appending("/Library/Application Support/com.apple.TCC/MDMOverrides.plist")
        ]
    }

    private static var protectedReadableDirectories: [String] {
        [
            "/Library/Application Support/com.apple.TCC",
            NSHomeDirectory().appending("/Library/Application Support/com.apple.TCC"),
            NSHomeDirectory().appending("/Library/Mail"),
            NSHomeDirectory().appending("/Library/Messages"),
            NSHomeDirectory().appending("/Library/Safari"),
            NSHomeDirectory().appending("/Library/Calendars")
        ]
    }
}
