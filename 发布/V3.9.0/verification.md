# V3.9.0 Sparkle 发布验证

## 日期
- 2026-06-09

## 已完成
- 已生成 `SuperRight-3.9.0.dmg`。
- 已生成 `appcast.xml`，并包含 Sparkle EdDSA 签名。
- 已添加 GitHub Actions 工作流，用于把 DMG 和 Appcast 上传到 `v3.9.0` Release。
- 已将 `superRight` 设置为公开仓库，作为 Sparkle 更新下载源。
- 已将主程序源码仓库 `SuperRightExtral` 恢复为私有仓库，避免公开主程序源码。

## 回归测试
- `swift test`：42 tests, 0 failures。

## 线上验证结果
- `https://github.com/maple1314who/superRight`：HTTP 200，公开可访问。
- `https://github.com/maple1314who/SuperRightExtral`：HTTP 404，匿名不可访问，保持私有。
- `https://github.com/maple1314who/superRight/releases/latest/download/appcast.xml`：HTTP 200，大小 895 bytes。
- `https://github.com/maple1314who/superRight/releases/latest/download/SuperRight-3.9.0.dmg`：HTTP 200，大小 4084170 bytes。

## 发布资产
- Appcast：`appcast.xml`。
- DMG：`SuperRight-3.9.0.dmg`。
- DMG SHA256：`7fc472a834de19a6d9d1bfb6bb32a16caa25e7b097ec163ed4473f645482232f`。
- Appcast enclosure 指向 `SuperRight-3.9.0.dmg`，并保留原 Sparkle EdDSA 签名。

## 安全边界
公开更新仓库会暴露 DMG 和 Appcast，任何人拿到链接都可以下载安装包；但 Sparkle 更新安全依赖 EdDSA 私钥签名，外部人员不能只靠公开仓库伪造可被客户端接受的更新。

## 测试更新提示说明
当前 App 版本已经是 `3.9.0`。Sparkle 不会提示同版本更新。要测试弹出更新提示，需要安装低于 `3.9.0` 的旧版本，或发布 `3.9.1`。
