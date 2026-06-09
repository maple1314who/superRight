# CHANGELOG

## V3.5.0 - 2026-06-09

### 新增
- “工具箱”接入真实共享配置，配置界面可启用、编辑名称、重置默认项。
- Finder 右键菜单支持工具箱基础项：文件信息、拷贝文件名、根据文件名新建文件夹、隐藏/取消隐藏选中项、隐藏/取消隐藏当前目录内容。
- 主 App 支持执行工具箱请求，覆盖剪贴板写入、目录创建、Finder 隐藏标记和文件信息入口。

### 改进
- 工具箱动作统一由 Finder Extension 转发到主 App 执行，降低扩展进程权限不稳定风险。
- 共享配置兼容旧 JSON，历史用户配置会自动补工具箱配置和相关开关。
- 主 App 与 Finder Extension 版本升级为 `3.5.0 / 2026060905`。

### 验证
- `swift test`：38 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.4.0 - 2026-06-09

### 新增
- “文件/文件夹图标”接入真实共享配置，配置界面可编辑、启用、新增、删除和恢复默认图标预设。
- Finder 右键菜单在选中文件或文件夹时生成“设置图标：...”和“还原默认图标”。
- 主 App 支持执行 `applyFileIcon` 和 `removeCustomIcon`，可写入或清除 Finder 自定义图标。

### 改进
- 图标动作通过 Finder Extension 转发到主 App 执行，携带选中路径、SF Symbol 和颜色参数。
- 共享配置兼容旧 JSON，历史用户配置会自动补图标预设和相关开关。
- 主 App 与 Finder Extension 版本升级为 `3.4.0 / 2026060904`。

### 验证
- `swift test`：34 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.3.0 - 2026-06-09

### 改进
- 应用内展示名称统一为“右键增强”。
- 侧边栏版本号改为读取 App Bundle 的 `CFBundleShortVersionString`，避免 UI 版本与实际包版本不一致。
- 主 App 与 Finder Extension 的真实版本统一为 `3.3.0 / 2026060903`。

### 文档
- 补充核心模块源码注释，覆盖 Shared、ExtensionCore、AppCore、Finder Extension 和主 App 执行链路。
- 新增模块说明文档，明确每个模块职责、关键文件、维护规则和功能接入流程。
- 新增版本管理说明，明确 `MARKETING_VERSION`、`CURRENT_PROJECT_VERSION` 和发版记录同步规则。
- 新增 Codex 工作流 Skill 文档，固化注释、文档、回归测试、Git 提交和剩余任务汇报流程。

### 验证
- `swift test`：31 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- 生成包 `Info.plist` 已确认：`CFBundleDisplayName = 右键增强`，`CFBundleShortVersionString = 3.3.0`，`CFBundleVersion = 2026060903`。

## V3.2.0 - 2026-06-09

### 新增
- “常用目录”接入真实共享配置，支持新增、删除、重置、编辑路径和显示名称。
- Finder 右键菜单会根据常用目录配置生成“打开 <目录名>”动作。
- 新增 `openDirectory` 动作，支持由 Finder Extension 转发给主 App 打开目录。

### 验证
- `swift test`：31 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.1.0 - 2026-06-09

### 新增
- 新增 IDEA 支持：配置界面、Finder 右键菜单、主 App 执行请求均支持 `openIdea`。
- 新增“新建文件”真实配置：模板列表、启用状态、扩展名、默认文件名、创建后打开、创建后播放声音均持久化。
- 新增“发送文件到...”真实功能：支持配置目标目录，右键选中文件/文件夹后复制到目标目录。
- 新增“移动文件到...”开关：默认关闭，开启后右键菜单生成移动动作。
- 新增 App 图标资源。

### 改进
- 配置界面重构为侧边栏布局，接近目标参考 UI。
- 通用设置中的“隐藏状态栏图标”升级为“隐藏 Dock 和菜单栏图标”。
- 主 App 启动和激活时会刷新完全磁盘访问权限状态。
- Finder Extension 对写文件类动作统一转发给主 App 执行，提高权限稳定性。
- App Group 请求队列继续保留，降低主 App 刚启动时丢请求的概率。

### 修复
- 修复完全磁盘权限系统已勾选但 App 内状态不刷新的问题。
- 修复 IDEA 配置存在但配置页和右键菜单不可见的问题。
- 修复新建文件模板只存在 UI 假数据、右键菜单不生效的问题。

### 验证
- `swift test`：27 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- 已将最新 Debug 包覆盖到 `/Applications/右键增强.app` 并重启 Finder Extension。

### 已知限制
- “常用目录”“文件(夹)图标”“工具箱”仍主要是 UI 占位，后续版本继续实现。
- `showInMainMenu` 当前仅持久化，尚未实现主菜单/子菜单分组语义。
- 打包产物需要在每次功能完成后重新生成，旧 `dist` 产物不代表当前代码状态。
