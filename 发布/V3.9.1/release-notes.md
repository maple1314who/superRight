# 右键增强 3.9.1

## 更新内容
- 发布 Sparkle 测试更新版本，用于从 `3.9.0` 验证在线更新链路。
- 保持功能逻辑不变，仅升级版本号与构建号。
- 更新包使用公开 `superRight` Release 承载，主程序源码仓库保持私有。

## 验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild Release build`：BUILD SUCCEEDED。
- Sparkle Appcast 包含 `sparkle:edSignature`。
