# CHANGELOG

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
- 配置界面重构为接近“超级右键 2.2.3”的侧边栏布局。
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
