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
- 待补充。

## 线上验证
- 待上传 GitHub Release 后补充。
