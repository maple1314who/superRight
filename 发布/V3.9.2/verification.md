# V3.9.2 Sparkle 发布验证

## 日期
- 2026-06-09

## 修复原因
- `3.9.1` 只有 Sparkle 发布包，隐藏 Dock 和菜单栏图标后手动“检查更新…”入口不可见。
- Sparkle 默认自动检查不是启动即弹窗，测试时容易误判为没有检测更新。

## 修复内容
- App 启动后延迟执行一次 `checkForUpdatesInBackground()`。
- 通用设置新增“检查更新…”按钮。
- AppCore 使用 `SharedConstants.appCheckForUpdatesNotification` 通知主 App，由 AppDelegate 统一调用 Sparkle。

## 本地验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/DerivedData build`：`BUILD SUCCEEDED`。
- 生成 DMG：`dist/sparkle/SuperRight-3.9.2.dmg`。
- 生成 Appcast：`dist/sparkle/appcast.xml`，版本 `3.9.2 / 2026060911`，包含 `sparkle:edSignature`。

## 线上验证
- `https://github.com/maple1314who/superRight/releases/latest/download/appcast.xml`：HTTP 200，大小 895 bytes。
- `https://github.com/maple1314who/superRight/releases/latest/download/SuperRight-3.9.2.dmg`：HTTP 200，大小 4089465 bytes。
- 在线 Appcast 已确认版本 `3.9.2 / 2026060911`。
- 在线 Appcast 已确认 enclosure 指向 `SuperRight-3.9.2.dmg`，并包含 `sparkle:edSignature`。
- DMG SHA256：`89d49289573d773718d74da366676fa9d198ae22af29043da01ff40b70deb1e7`。
