# 右键增强 4.0.31

## 更新内容
- 将 Sparkle 更新弹窗和更新流程的默认语言切换为中文。
- 允许应用混合加载 Sparkle 内置本地化资源，优先使用简体中文，同时保留繁体中文和英文回退。
- 不改变更新下载、签名校验和安装替换逻辑。

## 验证
- `swift test`：55 tests, 0 failures。
- Debug 构建：BUILD SUCCEEDED。
- Release 构建：BUILD SUCCEEDED。
- 已确认 Release App 元数据包含 `CFBundleDevelopmentRegion=zh_CN`、`CFBundleAllowMixedLocalizations=true` 和中文本地化列表。
