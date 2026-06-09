# 右键增强 4.0.30

## 更新内容
- iShot 工具箱动作从统一启动主应用改为按动作区分执行。
- “iShot 标注/贴图”优先把 Finder 选中文件交给 iShot 打开，没有选中文件时回退启动 iShot。
- “iShot 截图”启动 iShot 后尝试触发默认 `Option+A` 截图快捷键；如果未授予辅助功能权限，则保留启动回退并写入日志。
- Sparkle 更新源发布到 `4.0.30 / 2026060954`，用于从 `4.0.29` 检测更新。

## 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/PackageRelease build`：BUILD SUCCEEDED。
- Sparkle `appcast.xml` 已生成并包含 `sparkle:edSignature`。

## 说明
- 不执行 Developer ID 签名与公证，按当前项目约定继续使用 Apple Development 签名。
