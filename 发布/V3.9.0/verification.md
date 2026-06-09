# V3.9.0 Sparkle 发布验证

## 日期
- 2026-06-09

## 已完成
- 已生成 `右键增强-3.9.0.dmg`。
- 已生成 `appcast.xml`，并包含 Sparkle EdDSA 签名。
- 已添加 GitHub Actions 工作流，用于把 DMG 和 Appcast 上传到 `v3.9.0` Release。
- 已推送到 `git@github.com:maple1314who/superRight.git`。

## 回归测试
- `swift test`：42 tests, 0 failures。

## 线上验证结果
- `https://github.com/maple1314who/superRight` 匿名访问返回 404。
- `https://github.com/maple1314who/SuperRightExtral` 匿名访问返回 404。
- `https://github.com/maple1314who/superRight/releases/latest/download/appcast.xml` 返回 404。
- `https://github.com/maple1314who/superRight/releases/latest/download/右键增强-3.9.0.dmg` 返回 404。

## 当前阻塞
Sparkle 客户端不会携带 GitHub 登录态或私有仓库凭证。如果更新源所在 GitHub 仓库是私有仓库，即使 Release 资源上传成功，用户机器上的 Sparkle 也无法匿名下载 `appcast.xml` 和 DMG，因此无法检测更新。

## 下一步
- 将用于 Sparkle 更新的仓库改为公开仓库；或
- 改用公开托管地址，例如 GitHub Pages、对象存储、官网 CDN；然后同步修改 App 内 `SUFeedURL`。

## 测试更新提示说明
当前 App 版本已经是 `3.9.0`。Sparkle 不会提示同版本更新。要测试弹出更新提示，需要安装低于 `3.9.0` 的旧版本，或发布 `3.9.1`。
