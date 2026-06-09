# CHANGELOG

## V4.0.25 - 2026-06-09

### 重构
- `AppExecutionPermanentDeleteAdapter` 接管彻底删除的 Finder 选中项解析、URL 去重、二次确认和删除执行。
- `AppExecutionRequestHandler` 的彻底删除动作改为只保留策略入口并委托永久删除适配器。
- 主 App 与 Finder Extension 版本升级为 `4.0.25 / 2026060949`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.25 / 2026060949`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.25)`；最近 5 分钟未发现新崩溃报告。

## V4.0.24 - 2026-06-09

### 重构
- 新增主 App `AppExecutionCutAdapter`，集中处理剪切动作的选中项解析、URL 去重和剪贴板 move 语义写入。
- `AppExecutionRequestHandler` 的剪切动作改为只保留策略入口并委托剪切适配器。
- 主 App 与 Finder Extension 版本升级为 `4.0.24 / 2026060948`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.24 / 2026060948`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.24)`；最近 5 分钟未发现新崩溃报告。

## V4.0.23 - 2026-06-09

### 重构
- 新增主 App `AppExecutionTransferAdapter`，集中处理“发送文件到/移动文件到”的业务编排、日志和完成提示音。
- 传输动作执行前会规范化并去重 Finder 选中路径，降低同一请求内重复路径导致复制出多个重名文件的风险。
- `AppExecutionRequestHandler` 的传输动作改为只保留策略入口并委托传输适配器。
- 主 App 与 Finder Extension 版本升级为 `4.0.23 / 2026060947`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.23 / 2026060947`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.23)`；最近 5 分钟未发现新崩溃报告。

## V4.0.22 - 2026-06-09

### 重构
- 新增主 App `AppExecutionDirectoryOpeningAdapter`，集中处理常用目录目标校验和 `NSWorkspace.open` 调用。
- `AppExecutionRequestHandler` 的打开目录动作改为只保留策略入口并委托目录打开适配器。
- 主 App 与 Finder Extension 版本升级为 `4.0.22 / 2026060946`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.22 / 2026060946`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.22)`；最近 5 分钟未发现新崩溃报告。

## V4.0.21 - 2026-06-09

### 重构
- 新增主 App `AppExecutionApplicationOpeningAdapter`，集中处理外部应用和工具箱应用的 `NSWorkspace` 打开执行。
- `AppExecutionRequestHandler` 的打开应用动作改为只保留策略入口，并委托打开执行适配器；应用 Bundle 解析仍由 `AppExecutionApplicationAdapter` 负责。
- 主 App 与 Finder Extension 版本升级为 `4.0.21 / 2026060945`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.21 / 2026060945`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.21)`；最近 5 分钟未发现新崩溃报告。

## V4.0.20 - 2026-06-09

### 重构
- 新增主 App `AppExecutionCreationAdapter`，集中处理新建文件夹、新建文件、模板写入、创建后提示音和自动打开。
- `AppExecutionRequestHandler` 的新建动作改为只负责策略入口并委托创建适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.20 / 2026060944`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.20 / 2026060944`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.20)`；最近 5 分钟未发现新崩溃报告。

## V4.0.19 - 2026-06-09

### 重构
- 新增主 App `AppExecutionLogFileAdapter`，集中处理执行日志文件路径解析、文件创建和追加写入。
- `AppExecutionRequestHandler` 的日志入口保留 `NSLog` 和适配器调用，移除内联文件写入细节。
- 主 App 与 Finder Extension 版本升级为 `4.0.19 / 2026060943`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.19 / 2026060943`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.19)`；最近 5 分钟未发现新崩溃报告。

## V4.0.18 - 2026-06-09

### 重构
- 新增主 App `AppExecutionRequestQueueAdapter`，集中处理 App Group 请求队列目录定位、请求文件保存、按文件名排序读取和消费清理。
- `AppExecutionRequestHandler` 保留通知入口、去重和策略执行，把队列文件读写委托给适配器。
- 主 App 与 Finder Extension 版本升级为 `4.0.18 / 2026060942`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.18 / 2026060942`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.18)`；最近 5 分钟未发现新崩溃报告。

## V4.0.17 - 2026-06-09

### 重构
- 新增主 App `AppExecutionFolderNameAdapter`，集中处理按选中项名称创建同名文件夹的目标解析、冲突命名和目录创建。
- `AppExecutionRequestHandler` 的“按文件名创建文件夹”动作改为只负责策略入口并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.17 / 2026060941`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.17 / 2026060941`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.17)`；最近 5 分钟未发现新崩溃报告。

## V4.0.16 - 2026-06-09

### 重构
- 新增主 App `AppExecutionTextToolAdapter`，集中处理复制文件名、翻译选中文本、路径二维码等文本派生动作。
- `AppExecutionRequestHandler` 的文本工具动作改为只负责策略入口和日志记录，移除无用主线程辅助函数。
- 主 App 与 Finder Extension 版本升级为 `4.0.16 / 2026060940`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.16 / 2026060940`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.16)`；最近 5 分钟未发现新崩溃报告。

## V4.0.15 - 2026-06-09

### 重构
- 新增主 App `AppExecutionVisibilityAdapter`，集中处理选中项和当前目录直接子项的 Finder 隐藏标记业务编排。
- `AppExecutionRequestHandler` 的隐藏/取消隐藏动作改为只负责策略入口并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.15 / 2026060939`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.15 / 2026060939`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.15)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.14 - 2026-06-09

### 重构
- 新增主 App `AppExecutionIShotAdapter`，集中处理 iShot 应用解析、`NSWorkspace` 启动和主线程调用边界。
- `AppExecutionRequestHandler` 的 iShot 动作改为只负责策略入口并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.14 / 2026060938`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.14 / 2026060938`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.14)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.13 - 2026-06-09

### 重构
- 新增主 App `AppExecutionSharingAdapter`，集中处理 `NSSharingService` AirDrop 分享和主线程调用边界。
- `AppExecutionRequestHandler` 的 AirDrop 动作改为只负责解析 Finder 选中目标并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.13 / 2026060937`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.13 / 2026060937`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.13)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.12 - 2026-06-09

### 重构
- 新增主 App `AppExecutionFinderAdapter`，集中处理 Finder 信息窗口 AppleScript 调用和失败回退定位。
- `AppExecutionRequestHandler` 的查看简介动作改为只负责解析 Finder 选中目标并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.12 / 2026060936`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.12 / 2026060936`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.12)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.11 - 2026-06-09

### 重构
- 新增主 App `AppExecutionShortcutAdapter`，集中处理发送快捷方式到桌面的桌面路径、冲突命名和符号链接创建。
- `AppExecutionRequestHandler` 的快捷方式动作改为只负责解析 Finder 选中目标并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.11 / 2026060935`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.11 / 2026060935`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.11)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.10 - 2026-06-09

### 重构
- 新增主 App `AppExecutionPermanentDeleteAdapter`，集中处理彻底删除二次确认、确认文案和 `FileManager.removeItem` 调用。
- `AppExecutionRequestHandler` 的彻底删除动作改为只负责解析 Finder 选中目标并委托适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.10 / 2026060934`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.10 / 2026060934`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.10)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.9 - 2026-06-09

### 重构
- 新增主 App `AppExecutionWebAdapter`，集中处理翻译 URL 构造和系统浏览器打开逻辑。
- `AppExecutionRequestHandler` 的翻译动作改为只负责选中文本解析和执行日志记录。
- 主 App 与 Finder Extension 版本升级为 `4.0.9 / 2026060933`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.9 / 2026060933`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.9)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.8 - 2026-06-09

### 重构
- 新增主 App `AppExecutionQRCodeAdapter`，集中处理 CoreImage 二维码生成、纠错等级和图片缩放。
- `AppExecutionRequestHandler` 的二维码动作改为只负责选中路径文本、剪贴板写入和日志记录。
- 主 App 与 Finder Extension 版本升级为 `4.0.8 / 2026060932`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.8 / 2026060932`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.8)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.7 - 2026-06-09

### 重构
- 新增主 App `AppExecutionImageConversionAdapter`，集中处理 `.icns`、macOS `.iconset`、iOS `AppIcon.appiconset` 三类图片转换。
- `AppExecutionRequestHandler` 的 ICNS、macOS 图标集、iOS 图标集动作改为委托图片转换适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.7 / 2026060931`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.7 / 2026060931`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.7)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.6 - 2026-06-09

### 重构
- 新增主 App `AppExecutionClipboardAdapter`，集中处理文本、Finder 文件 URL 移动语义和图片三类剪贴板写入。
- `AppExecutionRequestHandler` 的复制文件名、剪切选中项、二维码写入剪贴板动作改为委托剪贴板适配器执行。
- 主 App 与 Finder Extension 版本升级为 `4.0.6 / 2026060930`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.6 / 2026060930`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.6)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.5 - 2026-06-09

### 重构
- 新增主 App `AppExecutionIconAdapter`，集中处理 Finder 自定义图标目标解析、导入图片解码、SF Symbol 预设渲染和 `NSWorkspace.setIcon` 写入/移除。
- `AppExecutionRequestHandler` 改为只委托图标适配器执行文件/文件夹图标动作，减少主处理器中的 AppKit 图标细节。
- 主 App 与 Finder Extension 版本升级为 `4.0.5 / 2026060929`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。
- 已安装 `/Applications/右键增强.app`，主 App 和 Finder Extension 均为 `4.0.5 / 2026060929`，插件注册为 `com.maple.right.superright.RightClickFinderExtension(4.0.5)`。
- 最近 5 分钟未发现 `右键增强` 或 `RightClickFinderExtension` 新崩溃报告。

## V4.0.4 - 2026-06-09

### 重构
- 新增主 App `AppExecutionFileSystemAdapter`，集中处理 Finder 选中项解析、复制/移动、目录子项读取和隐藏标记写入。
- `AppExecutionRequestHandler` 改为通过文件系统适配器执行复制/移动和隐藏操作，移除自身的冲突命名与隐藏标记细节。
- 主 App 与 Finder Extension 版本升级为 `4.0.4 / 2026060928`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V4.0.3 - 2026-06-09

### 重构
- 新增主 App `AppExecutionApplicationAdapter`，统一解析外部应用、工具箱应用和 iShot 的 Bundle 路径。
- `AppExecutionRequestHandler` 改为通过应用适配器获取 App URL，移除自身的 Bundle ID 和安装路径解析细节。
- 主 App 与 Finder Extension 版本升级为 `4.0.3 / 2026060927`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V4.0.2 - 2026-06-09

### 重构
- 主 App `AppExecutionRequestHandler` 接入 V4 执行架构，执行入口改为策略工厂 + 策略调用。
- 新增主 App 侧 `AppExecutionStrategyContext`，用上下文适配既有 AppKit、文件系统和工具箱实现。
- 新增主 App 侧责任链 `AppExecutionPreflightLink`，在执行前校验外部应用目标、目标目录、复制/移动源文件。
- 新增主 App 侧观察者 `AppExecutionObserving`，统一记录动作开始、成功和失败。
- 主 App 与 Finder Extension 版本升级为 `4.0.2 / 2026060926`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V4.0.1 - 2026-06-09

### 重构
- 新增责任链模式 `ActionExecutionPreflightLink`，在进入策略前统一校验动作前置条件。
- 新增默认文件名、目标目录、Finder 选中项三个前置校验节点，避免具体策略重复校验。
- 明确 `ForwardedOnlyActionStrategy` 作为空对象策略处理只应转发给主 App 的动作。
- 主 App 与 Finder Extension 版本升级为 `4.0.1 / 2026060925`。

### 验证
- `swift test`：55 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V4.0.0 - 2026-06-09

### 重构
- Finder Extension 动作执行链升级为 V4 架构，引入策略、工厂、适配器、观察者四类设计模式。
- 每类菜单动作拆分为独立 `MenuActionStrategy`，移除执行入口中的大 `switch`。
- 新增 `MenuActionStrategyFactory` 统一维护 `MenuActionType -> Strategy` 映射。
- 新增 `FileSystemActionAdapter`、`ExternalApplicationActionAdapter` 隔离文件系统、外部 App 打开和系统版本差异。
- 新增 `ActionExecutionObserving`，通过观察者记录执行开始、成功和失败事件。
- 主 App 与 Finder Extension 版本升级为 `4.0.0 / 2026060924`。

### 验证
- `swift test`：53 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.5 - 2026-06-09

### 修复
- 修复主窗口背景拖拽覆盖层调用 `contentView.hitTest` 导致 SwiftUI 命中测试递归、打开后闪退的问题。
- 侧边栏、表格下方按钮区、开关区和通用设置页补充拖拽排除标记，保证控件点击不被背景拖窗覆盖层截获。
- 主 App 与 Finder Extension 版本升级为 `3.10.5 / 2026060923`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.4 - 2026-06-09

### 修复
- “发送文件到...”和“常用目录”改为固定短列表视口，底部新增/删除/重置按钮和开关区域不再随行数变化上下抖动。
- 短列表继续使用 `LazyVStack` 承载行内容，超过 5 行后在列表内部滚动，保持上下两个区域视觉分离。
- 主 App 与 Finder Extension 版本升级为 `3.10.4 / 2026060922`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.3 - 2026-06-09

### 修复
- 窗口拖拽改为全窗背景拖拽覆盖层，不再限制为顶部区域。
- 表格容器新增拖拽排除标记，避免窗口拖拽抢占行排序、滚动、Picker 和文本编辑。
- 主 App 与 Finder Extension 版本升级为 `3.10.3 / 2026060921`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.2 - 2026-06-09

### 新增
- 工具箱默认列表补齐旧版 `arrOfOthers` 功能项，共覆盖 46 个工具入口。
- 新增“发送快捷方式到桌面”“iShot 截图”“生成 macOS Icons”“生成 iOS Icons”“百度翻译”“Google 翻译”“生成二维码”。
- 新增一组外部 App 打开入口，未默认启用的编辑器/IDE 可在工具箱中手动开启。

### 改进
- Finder Extension 会把新增工具箱动作转发到主 App 执行。
- 主 App 补齐快捷方式、图标集、外部 App 打开、翻译网页和二维码剪贴板执行逻辑。
- 主 App 与 Finder Extension 版本升级为 `3.10.2 / 2026060920`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.1 - 2026-06-09

### 修复
- 关闭整窗背景拖拽，避免干扰表格行拖拽和下拉菜单选择。
- 新增只覆盖右侧内容区顶部空白区域的窗口拖拽热区。
- 主 App 与 Finder Extension 版本升级为 `3.10.1 / 2026060919`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.10.0 - 2026-06-09

### 调整
- 配置页表格顶部统一留出 `90pt` 空间，视觉结构对齐旧版“超级右键”。
- 新增 `RootConfigurationLayout` 集中管理根配置界面布局常量。
- 主 App 与 Finder Extension 版本升级为 `3.10.0 / 2026060918`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.9.9 - 2026-06-09

### 修复
- “发送文件到...”和“常用目录”短列表表格按实际行数收缩，避免大块空白区域。
- “常用目录”行改为只读点击选择，并支持稳定拖拽排序。
- 工具箱选项列过滤空选项，无真实选项的功能不再显示空 Picker。

### 改进
- 常用目录排序由 `MenuManagementViewModel` 统一重排并重新编号。
- 主 App 与 Finder Extension 版本升级为 `3.9.9 / 2026060917`。

### 验证
- `swift test`：51 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.9.8 - 2026-06-09

### 修复
- 移除主窗口顶部独立标题栏占位，让系统窗口按钮浮在左侧栏顶部。
- “发送文件到...”列表行改为只读点击选择，避免误触进入编辑。
- “发送文件到...”列表接入稳定拖拽排序，并持久化排序结果。

### 改进
- 发送目标排序由 `MenuManagementViewModel` 统一重排并重新编号。
- 主 App 与 Finder Extension 版本升级为 `3.9.8 / 2026060916`。

### 验证
- `swift test`：50 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.9.7 - 2026-06-09

### 修复
- 隐藏主窗口标题栏里重复显示的“右键增强”文字，避免和左侧栏品牌区重复。
- “新建文件”表格支持拖拽排序，拖拽描述和真实行为一致。
- 文件/文件夹图标表格拖拽改为松手后排序，避免实时重排导致列表抖动。

### 改进
- 新建文件模板排序由 `MenuManagementViewModel` 统一重排并持久化。
- 主 App 与 Finder Extension 版本升级为 `3.9.7 / 2026060915`。

### 验证
- `swift test`：49 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：BUILD SUCCEEDED。

## V3.9.6 - 2026-06-09

### 修复
- “新建文件”里的“主菜单”开关现在会真正影响 Finder 右键菜单：勾选后模板直接显示在根菜单，未勾选则保留在“新建”子菜单。

### 改进
- Finder 菜单根节点支持动态模板项与分类子菜单按 `order` 稳定混排。
- 主 App 与 Finder Extension 版本升级为 `3.9.6 / 2026060914`。

### 验证
- `swift test`：48 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.9.5 - 2026-06-09

### 修复
- “发送文件到...”新增改为选择真实目录，并自动使用目录名作为显示名称。
- “发送文件到...”删除改为优先删除选中行，并允许列表删空，不再被配置迁移逻辑自动补回默认项。
- 主 App 请求处理器按 `requestID` 去重，避免 Finder Extension 同时通过队列和分布式通知传递时同一复制/移动动作执行多次。

### 验证
- `swift test`：47 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- 本机运行态复核：Finder Extension 已切回 `/Applications/右键增强.app` 单一注册源，历史 DMG 无挂载残留，监听目录为 `/Users/maple`。

## V3.9.4 - 2026-06-09

### 修复
- 完全磁盘访问权限检测增加系统级 TCC 数据库和 TCC 目录探测，降低系统已勾选但 App 内误判未授权的概率。
- 主 App Release entitlements 移除沙盒，避免完全磁盘访问能力被 App Sandbox 继续阻断。
- Finder 扩展默认监听目录从桌面迁移到用户 Home，旧的“仅桌面默认配置”会自动升级。
- Finder Extension 读取配置失败或监听目录无效时，兜底监听 Home，不再只兜底桌面。
- Sparkle 安装更新前主动终止 Finder 扩展进程，避免更新后 Finder 继续加载旧 appex。

### 验证
- `swift test`：45 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.9.3 - 2026-06-09

### 修复
- 删除配置界面侧边栏中未实现的“评分”和“订购”入口，避免展示不可用功能。

### 新增
- Finder 右键菜单按“新建 / 打开 / 工具”分组展示为子菜单，不再把所有动作混在扁平列表中。
- 文件/文件夹图标预设支持导入本地图片，右键设置图标时优先使用导入图片。
- 文件/文件夹图标预设支持拖拽排序，排序后同步影响配置界面和右键菜单展示顺序。
- 工具箱新增“剪切”“iShot”“ICNS 转换”，旧配置会自动迁移补齐新默认项。
- “彻底删除”执行前新增主 App 二次确认弹窗，取消时不会删除任何文件。

### 已知限制
- 本机未安装 Developer ID Application 证书，且未配置 `notarytool` 凭据，Developer ID 公证暂无法真实完成。

### 验证
- `swift test`：43 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.9.2 - 2026-06-09

### 修复
- 启动后主动执行一次 Sparkle 后台更新检查，避免默认检查周期导致新版本不立即提示。
- 通用设置新增“检查更新…”按钮，隐藏 Dock 和菜单栏图标后仍可手动触发更新检查。

### 改进
- 新增 `SharedConstants.appCheckForUpdatesNotification`，让 AppCore 通过进程内通知请求主 App 统一调用 Sparkle。
- 主 App 与 Finder Extension 版本升级为 `3.9.2 / 2026060911`。

### 验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/DerivedData build`：`BUILD SUCCEEDED`。
- GitHub Release 资源已公开验证，`appcast.xml` 和 `SuperRight-3.9.2.dmg` 均返回 HTTP 200。

## V3.9.1 - 2026-06-09

### 新增
- 发布 Sparkle 测试更新版本，用于从 `3.9.0` 客户端验证在线更新提示。

### 改进
- 主 App 与 Finder Extension 版本升级为 `3.9.1 / 2026060910`。
- Release 资产使用 ASCII 文件名 `SuperRight-3.9.1.dmg`，避免 GitHub 对中文资产名做兼容转换。

### 验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/DerivedData build`：`BUILD SUCCEEDED`。
- Sparkle Appcast 已生成并包含 `sparkle:edSignature`。
- GitHub Release 资源已公开验证，`appcast.xml` 和 `SuperRight-3.9.1.dmg` 均返回 HTTP 200。

## V3.9.0 - 2026-06-09

### 新增
- 主 App 集成 Sparkle `2.9.3`，支持自动检查更新和菜单栏手动“检查更新…”。
- 新增 Sparkle Appcast 配置，更新源指向 GitHub Release 的 `appcast.xml`。
- 主 App entitlements 增加网络访问和 Sparkle sandbox XPC mach lookup 例外。

### 改进
- 发版流程增加 Sparkle EdDSA 公钥、DMG 包和 Appcast 生成记录。
- 新增 GitHub Actions 发布工作流，将 `SuperRight-3.9.0.dmg` 和 `appcast.xml` 上传到 `v3.9.0` Release，供 Sparkle 在线检测更新。
- 主 App 与 Finder Extension 版本升级为 `3.9.0 / 2026060909`。

### 验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/DerivedData build`：`BUILD SUCCEEDED`。
- Sparkle Appcast 已生成并包含 `sparkle:edSignature`。
- GitHub Release 资源已公开验证，`appcast.xml` 和 `SuperRight-3.9.0.dmg` 均返回 HTTP 200。

## V3.8.0 - 2026-06-09

### 新增
- 工具箱新增“彻底删除”默认项，配置界面可启用、禁用和改名。
- Finder Extension 支持将“彻底删除”转发给主 App，并携带 Finder 选中路径。
- 主 App 支持直接删除选中文件或文件夹，不经过废纸篓。

### 改进
- “彻底删除”作为破坏性动作默认关闭，旧配置迁移只补配置项，不自动出现在右键菜单。
- ExtensionCore 对“彻底删除”保持转发语义，不在 Finder Extension 进程直接删除文件。
- 主 App 与 Finder Extension 版本升级为 `3.8.0 / 2026060908`。

### 验证
- `swift test`：42 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.7.0 - 2026-06-09

### 新增
- 工具箱新增“隔空投送”默认项，选中文件或文件夹时在 Finder 右键菜单展示。
- Finder Extension 将隔空投送动作转发给主 App，并携带选中路径。
- 主 App 通过系统 `NSSharingService` 调起 AirDrop 分享面板发送选中项。

### 改进
- 旧配置会通过默认项迁移自动补齐 `send_via_airdrop`，不覆盖用户已有工具箱配置。
- ExtensionCore 对隔空投送保持转发语义，不在 Finder Extension 进程直接弹系统分享面板。
- 主 App 与 Finder Extension 版本升级为 `3.7.0 / 2026060907`。

### 验证
- `swift test`：41 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

## V3.6.0 - 2026-06-09

### 新增
- “新建文件”支持从真实文件导入模板，配置界面通过文件选择器读取模板文件。
- 导入模板会保存原始字节 `templateData`，创建文件时优先按原始字节写出，支持二进制模板和富文本模板。
- Finder Extension 转发创建文件请求时携带模板原始数据，主 App 执行链路可还原真实模板内容。

### 改进
- 保留 `templateContent` 作为纯文本模板和历史配置兼容字段。
- 导入模板会根据文件名和扩展名自动生成显示名称、默认文件名、图标和颜色。
- 主 App 与 Finder Extension 版本升级为 `3.6.0 / 2026060906`。

### 验证
- `swift test`：40 tests, 0 failures。
- `xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Debug -destination platform=macOS build`：`BUILD SUCCEEDED`。

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
