# Codex 执行说明 V2.0.0

## 1. 文档目的
本文档用于指导 Codex 在本地继续开发 macOS 访达右键增强工具的 V2 版本。
目标是在现有可运行基础上，完成正式架构接入、配置联动、动作联调与回归验证。

## 2. 工程路径
### 2.1 Xcode 主工程路径
`/Users/maple/Documents/Project/Swift/右键增强`

### 2.2 Swift Package 逻辑工程路径
`/Users/maple/Documents/Project/Swift/SuperRight`

## 3. 当前项目状态
以下状态已经确认：
1. 主 App 已经可以在 Xcode 中运行。
2. 主 App 已经能显示配置界面，入口为 `RootConfigurationView`。
3. Finder Extension 已创建成功，并已能运行。
4. 访达右键菜单已经能显示自定义菜单项。
5. 右键菜单点击链路已验证成功，测试菜单曾成功打开 Calculator。
6. 说明以下链路已经打通：
   - Finder Extension 被系统加载
   - menu(for:) 被调用
   - selector/action 被触发
   - 点击行为可以执行可见动作

当前开发重点已经不是系统接入，而是把临时测试代码收敛为正式架构。

## 4. V2 版本目标
V2 目标是把项目整理为一个完整可配置右键菜单 MVP（带 UI 配置）。

### 4.1 功能目标
V2 MVP 仅保证以下 5 个动作可用：
1. 新建文件夹
2. 在终端中打开
3. 在 iTerm 中打开
4. 用 VS Code 打开
5. 复制路径

### 4.2 产品目标
实现以下 4 个产品能力：
1. 主 App 中可以配置菜单项显示/隐藏
2. Finder 右键菜单根据配置动态变化
3. 点击菜单项可以执行真实动作
4. 改配置后重新打开右键菜单可看到变化

## 5. 正式架构要求
项目应收敛为以下结构：

```text
主 App（AppCore）
  - 配置界面
  - 修改配置
  - 保存配置

Shared
  - 配置模型
  - UserDefaultsConfigurationStore
  - 默认配置
  - 场景 / 动作 / 应用配置

ExtensionCore
  - FinderSelectionContext
  - MenuBuilder
  - MenuDisplayItem
  - ActionDispatcher

Finder Extension
  - 从 Finder 获取上下文
  - 读取配置
  - 调用 MenuBuilder
  - 转换为 NSMenu
  - 点击后调用 ActionDispatcher
```

### 5.1 设计原则
- FinderSync.swift 不承载业务规则，只做桥接。
- 菜单规则、过滤逻辑、动作执行逻辑应尽量复用 `SuperRight` 中现有代码。
- 尽量最小改动，不重写现有 Shared / AppCore / ExtensionCore。
- 保持中文菜单文案。
- 使用 `NSLog` 记录 Finder Extension 行为，不要依赖 `print` 作为唯一判断依据。

## 6. 已知目录结构（重点）
以 Swift Package 为准，重点目录如下：
- `/Users/maple/Documents/Project/Swift/SuperRight/Shared`
- `/Users/maple/Documents/Project/Swift/SuperRight/App`
- `/Users/maple/Documents/Project/Swift/SuperRight/Extension`
- `/Users/maple/Documents/Project/Swift/SuperRight/Tests`

重点文件方向如下：
- `Shared/Storage/UserDefaultsConfigurationStore.swift`
- `App/ViewModels/MenuManagementViewModel.swift`
- `Extension/MenuBuilder/MenuBuilder.swift`
- `Extension/MenuBuilder/MenuDisplayItem.swift`
- `Extension/FinderSync/FinderSelectionContext.swift`
- `Extension/ActionDispatcher/ActionDispatcher.swift`
- Xcode 主工程中的 `FinderSync.swift`

## 7. 必做任务

### 任务 1：检查并修复共享配置存储
检查 `UserDefaultsConfigurationStore` 是否具备以下能力：
- `load() throws -> SharedConfiguration`
- `save(_ configuration: SharedConfiguration) throws`

如果 `save` 不存在，请补齐。
如果已有 `save`，请确认主 App 与 Finder Extension 能读取到同一份配置。

要求：
- 优先沿用当前实现
- 不要重构 Shared 模型
- 优先先完成可运行 MVP
- 若当前未配置 App Group，可先基于当前运行方式完成 V2，但必须在结果说明中指出风险和后续建议

### 任务 2：让主 App 配置界面真正写入配置
检查以下内容：
- `RootConfigurationView`
- `MenuManagementViewModel`
- 相关 SwiftUI 视图

要求：
- 当前 UI 中对菜单项的开关、顺序、可见性修改，必须真正落到 `UserDefaultsConfigurationStore.save(...)`
- 不能只是停留在内存态
- V2 至少要保证这 5 个动作可配置：
  - 新建文件夹
  - 在终端中打开
  - 在 iTerm 中打开
  - 用 VS Code 打开
  - 复制路径

### 任务 3：让 Finder Extension 正式接入 ExtensionCore
`FinderSync.swift` 需要从测试版切换为正式版。

不允许继续保留的方式：
- 直接手写固定菜单项
- 直接在 FinderSync 中写业务判断
- 在 FinderSync 中直接堆积动作实现

正式要求：
1. 构造 `FinderSelectionContext`
2. 读取 `SharedConfiguration`
3. 调用 `MenuBuilder.buildMenu(context:configuration:)`
4. 将 `MenuDisplayItem` 转为 `NSMenuItem`
5. 点击菜单项后调用 `ActionDispatcher.execute(...)`

补充说明：
- `representedObject` 不要传 Swift tuple，建议使用 `NSObject` 包装对象
- FinderExtension 中日志统一用 `NSLog`

### 任务 4：修复 FinderSelectionContext 的目录判断
必须保证以下规则：
1. 右键文件夹时，`currentDirectoryURL` 应为该文件夹本身
2. 右键文件时，`currentDirectoryURL` 应为该文件的父目录
3. 空白区域右键时，`currentDirectoryURL` 应为当前目录

目标：
- “新建文件夹”总是在用户预期的位置创建
- “在终端中打开”总是在当前上下文目录打开

### 任务 5：完成动作联调
在 Finder 中完成以下动作联调：
1. 新建文件夹
2. 在终端中打开
3. 在 iTerm 中打开
4. 用 VS Code 打开
5. 复制路径

要求：
- `ActionDispatcher` 为统一动作入口
- FinderSync 不直接执行这些业务
- 若机器未安装 iTerm / VS Code，菜单项应根据现有配置与 `MenuBuilder` 逻辑隐藏

### 任务 6：完成回归验证
完成全部改动后，必须执行完整回归。回归标准详见《验证操作文档 V2.0.0》。

## 8. 建议开发顺序
### Step 1
检查 `UserDefaultsConfigurationStore`，确保 `load/save` 完整。

### Step 2
检查主 App 的 `MenuManagementViewModel`，确保 UI 改动会触发存储写入。

### Step 3
将 FinderSync 从测试菜单收回正式结构：
- 读取配置
- 调用 MenuBuilder
- 组装 NSMenu
- 点击后调用 ActionDispatcher

### Step 4
联调以下 2 个动作优先通过：
- 新建文件夹
- 在终端中打开

### Step 5
再联调以下动作：
- 在 iTerm 中打开
- 用 VS Code 打开
- 复制路径

### Step 6
执行完整回归验证并输出结果。

## 9. 开发要求
### 9.1 代码要求
- 尽量最小改动
- 优先复用现有结构
- 保持模块边界清晰
- 不引入新的大型依赖
- 代码必须可编译
- Finder 扩展日志统一使用 `NSLog`

### 9.2 不要做的事
- 不要重写整个项目
- 不要重建 Finder Extension
- 不要推翻现有 Shared / AppCore / ExtensionCore 拆分
- 不要增加与 V2 无关的新功能（如 AI、OCR、脚本市场等）

## 10. 输出要求
完成后请输出一份开发结果说明，至少包含以下内容：
1. 修改了哪些文件
2. 每个文件改了什么
3. 当前仍存在的已知问题
4. 本地如何运行
5. 如何验证
6. 回归测试结果
7. 是否满足 V2 MVP 目标
8. 后续建议（若有 App Group / Bookmark / 权限模型问题，请明确说明）

## 11. 最终交付判断标准
满足以下条件可视为 V2 MVP 完成：
- 主 App 可打开并展示配置界面
- 配置界面修改能真正写入配置
- Finder 右键菜单由 `MenuBuilder` 动态生成
- Finder 菜单点击由 `ActionDispatcher` 统一执行
- 这 5 个动作中，至少已完整支持并验证：
  - 新建文件夹
  - 在终端中打开
  - 在 iTerm 中打开（若安装）
  - 用 VS Code 打开（若安装）
  - 复制路径
- 根据配置调整菜单项后，Finder 再次右键可看到变化

## 12. 补充说明
当前系统接入链路已经验证通过，曾经出现过以下关键事实：
- Finder 右键菜单可以显示自定义菜单
- 点击测试菜单可成功打开 Calculator

因此，当前开发阶段不是重新验证 Finder 扩展可行性，而是完成正式架构接入 + 配置联动 + 动作联调。
