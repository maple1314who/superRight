# 右键增强 4.0.32

## 修复
- 修复 Finder 扩展监听目录误写为 App 沙盒目录的问题；旧配置会自动迁移回真实用户目录。
- 升级安装前和新版本启动时主动结束旧 Finder 扩展进程，避免旧右键菜单残留。
- 清理重复扩展注册后，只保留 /Applications 中的正式安装版本。

## 验证
- `swift test`：56 tests, 0 failures。
- Debug 构建：BUILD SUCCEEDED。
- Release 构建：BUILD SUCCEEDED。
- 本机安装验证：Finder Extension 4.0.32 已启用，监听目录为 `/Users/maple`。
