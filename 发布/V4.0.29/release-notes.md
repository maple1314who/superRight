# 右键增强 4.0.29

## 更新内容
- 完成 V4 主 App 图片转换适配器边界收敛。
- 图片转换动作统一处理 Finder 选中项解析、重复路径去重、`.icns`、macOS `.iconset` 和 iOS `AppIcon.appiconset` 输出。
- 保持 Finder Extension 分组菜单、工具箱动作和 Sparkle 自动更新链路。

## 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/PackageRelease build`：BUILD SUCCEEDED。
- Sparkle `appcast.xml` 已生成并包含 `sparkle:edSignature`。

## 说明
- 当前包使用 Apple Development 证书签名，尚未完成 Developer ID notarization。
