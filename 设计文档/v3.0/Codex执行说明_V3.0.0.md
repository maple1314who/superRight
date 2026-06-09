# Codex 执行说明 V3.0.0

## 1. 文档目的
本文档用于指导 Codex 在现有 V2 基础上继续推进 macOS 访达右键增强工具的 V3 版本开发。
V3 的目标不是“继续堆功能”，而是把当前项目从“能跑的原型”提升为“可长期自用的稳定工具”。

## 2. 工程路径
### 2.1 Xcode 主工程
`/Users/maple/Documents/Project/Swift/右键增强`

### 2.2 Swift Package 逻辑工程
`/Users/maple/Documents/Project/Swift/SuperRight`

## 3. 当前基线（承接 V2）
当前已知能力：
1. 主 App 可以运行并展示配置界面。
2. Finder Extension 已创建成功并可运行。
3. 主 App 菜单开关变更已能影响 Finder 菜单显示。
4. Finder 菜单点击链路已打通。
5. “新建文件夹”已改为由主 App 执行，并已形成闭环。
6. Finder Extension 已具备日志链路。
7. 主 App 与 Finder Extension 已使用 App Group 共享配置与请求队列。

## 4. V3 总目标
V3 的目标是将项目整理为一个稳定、可长期使用、可扩展的右键增强工具。

### 4.1 P0（必须完成）
1. 完成基础动作的真实 Finder 联调：
   - 新建文件夹
   - 在终端中打开
   - 在 iTerm 中打开
   - 用 VS Code 打开
   - 复制路径
2. Extension / 主 App 边界清晰
3. 所有动作都有稳定日志
4. 主 App 与 Finder Extension 配置联动稳定

### 4.2 P1（产品化）
1. 不再只监听桌面，支持多个可配置目录
2. 主 App 提供目录配置界面
3. Finder Extension 动态读取监听目录
4. 主 App 启动后能恢复监听配置
5. 错误有可见反馈或日志落盘可追踪

### 4.3 P2（稳定性与长期自用）
1. 支持主 App 自启动或常驻
2. 请求不丢失
3. 动作执行失败可追踪
4. 保持 Debug / Release 行为边界清晰
5. 给出可长期自用的运行方式说明

## 5. V3 重点设计原则
### 5.1 职责分层必须明确
#### Finder Extension
只负责：
- 读取 Finder 上下文
- 构造 `FinderSelectionContext`
- 读取共享配置
- 调用 `MenuBuilder`
- 转成 `NSMenu`
- 处理点击并分发动作
- 对于受限动作，转发请求给主 App

#### 主 App
负责：
- 配置界面
- 保存配置
- 执行需要更高权限或更适合前台处理的动作
- 管理目录配置
- 持有请求监听器

#### Shared
负责：
- 配置模型
- App Group 常量
- IPC 请求模型
- 配置读写 Store

#### ExtensionCore
负责：
- 菜单构建
- 场景判断
- 动作调度
- 应用可用性判断
- 上下文解析

## 6. V3 动作执行边界
### 6.1 必须由主 App 执行
以下动作默认由主 App 执行：
- 新建文件夹
- 新建文件
- 模板写入类动作
- 后续所有直接写文件系统的动作

### 6.2 可继续由 Extension 执行
以下动作可继续在 Extension 内执行，但必须真实验证：
- 在终端中打开
- 在 iTerm 中打开
- 用 VS Code 打开
- 复制路径

### 6.3 若 Extension 内执行不稳定
若以下动作在真实 Finder 环境中表现不稳定：
- 在终端中打开
- 在 iTerm 中打开
- 用 VS Code 打开

则允许迁移为由主 App 执行，但必须说明迁移原因。

## 7. V3 功能范围
### 7.1 必做功能
1. 菜单显示/隐藏配置
2. 菜单排序
3. 多目录监听配置
4. 新建文件夹
5. 在终端中打开
6. 在 iTerm 中打开
7. 用 VS Code 打开
8. 复制路径

### 7.2 本阶段不做
- AI 功能
- OCR
- 全局划词
- 自动化脚本商店
- 复杂插件市场
- App Store 上架适配
- 云同步

## 8. V3 核心任务
### 任务 1：完成剩余 4 个基础动作真实联调
在真实 Finder GUI 中完成以下动作：
1. 在终端中打开
2. 在 iTerm 中打开
3. 用 VS Code 打开
4. 复制路径

要求：
- 不能只给 `swift test`
- 不能只给 `xcodebuild`
- 必须给出真实 Finder GUI 点击结果
- 必须给出日志片段

### 任务 2：完成监听目录升级
当前 Finder 仅监听桌面，这不满足长期使用目标。

V3 需要：
1. 主 App 增加“监听目录”配置能力
2. 至少支持配置 1 到 N 个目录
3. Finder Extension 从共享配置读取目录列表
4. `directoryURLs` 动态设置
5. 目录变更后重新运行 Finder Extension 可生效
6. 至少验证：
   - 桌面
   - Downloads
   - Documents
   任意两个目录

### 任务 3：主 App 配置界面升级
主 App UI 至少支持：
1. 基础菜单项开关
2. 菜单排序
3. 应用路径配置
4. 监听目录配置

如果已有界面基础可复用，优先最小改动补齐，不要重写 UI 框架。

### 任务 4：错误处理与日志升级
要求：
1. Finder Extension 全链路使用 `NSLog`
2. 主 App 请求处理写入日志文件
3. 错误必须有明确日志，不允许静默失败
4. 日志至少覆盖：
   - menu(for:)
   - buildNSMenu
   - handleMenuItem
   - payload decode
   - dispatcher.execute
   - request forward
   - main app request received
   - action success / failed

### 任务 5：长期自用运行方式整理
V3 需要给出一份清晰的运行方式说明，包括：
1. 是否必须通过 Xcode 启动
2. 是否可以直接运行 `.app`
3. Finder Extension 是否可长期启用
4. 主 App 是否需要保持运行
5. 若需要自动启动，请说明配置方式

## 9. 建议开发顺序
### Step 1
先完成“在终端中打开”的真实 Finder 联调。

### Step 2
完成“复制路径”的真实 Finder 联调。

### Step 3
完成“在 iTerm 中打开”和“用 VS Code 打开”的真实联调。

### Step 4
完成监听目录配置功能。

### Step 5
完成主 App 配置界面补齐。

### Step 6
完成完整回归。

## 10. 代码与实现要求
1. 尽量最小改动
2. 不推翻 V2 已完成结构
3. 保持模块边界清晰
4. 不引入新大型依赖
5. 真实 GUI 验证优先于单测结果
6. Finder Extension 中不使用 `print`
7. 对于 Finder 菜单点击，不依赖 Swift tuple 做 payload 传递
8. 若需要跨进程请求，继续沿用 App Group + 请求模型 + 队列补偿思路

## 11. 交付要求
请输出一份新的：
`开发验证记录_V3.0.0.md`

至少包含：
1. 修改了哪些文件
2. 每个文件改了什么
3. 真实 Finder GUI 验证结果
4. 哪些动作已经完成
5. 哪些动作仍未完成
6. 当前监听目录能力
7. 本地长期运行方式
8. 当前剩余限制
9. 后续建议

## 12. V3 验收标准
满足以下条件可视为 V3 达标：
1. 主 App 配置可影响 Finder 菜单
2. 新建文件夹在真实 Finder 中可用
3. 在终端中打开在真实 Finder 中可用
4. 复制路径在真实 Finder 中可用
5. iTerm / VS Code 若已安装，则真实可用；若未安装，则按配置隐藏或明确标记不适用
6. Finder 不再只限桌面，至少支持多个监听目录
7. 主 App 与 Finder Extension 仍保持日志可观测
8. 给出明确的长期自用运行说明
