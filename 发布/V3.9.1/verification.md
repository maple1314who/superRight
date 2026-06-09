# V3.9.1 Sparkle 发布验证

## 日期
- 2026-06-09

## 目标
- 发布 `3.9.1 / 2026060910`，用于让已安装 `3.9.0` 的客户端检测到新版本。

## 发布资产
- Appcast：`appcast.xml`。
- DMG：`SuperRight-3.9.1.dmg`。
- 更新源：`https://github.com/maple1314who/superRight/releases/latest/download/appcast.xml`。

## 本地验证
- Release 构建：`xcodebuild -project 右键增强.xcodeproj -scheme 右键增强 -configuration Release -destination platform=macOS -derivedDataPath build/DerivedData build`：`BUILD SUCCEEDED`。
- 生成 DMG：`dist/sparkle/SuperRight-3.9.1.dmg`。
- 生成 Appcast：`dist/sparkle/appcast.xml`，版本 `3.9.1 / 2026060910`，包含 `sparkle:edSignature`。

## 线上验证
- `https://github.com/maple1314who/superRight/releases/latest/download/appcast.xml`：HTTP 200，大小 895 bytes。
- `https://github.com/maple1314who/superRight/releases/latest/download/SuperRight-3.9.1.dmg`：HTTP 200，大小 4084246 bytes。
- 在线 Appcast 已确认版本 `3.9.1 / 2026060910`。
- 在线 Appcast 已确认 enclosure 指向 `SuperRight-3.9.1.dmg`，并包含 `sparkle:edSignature`。
- DMG SHA256：`12dcd434d879e1f6a789c5978f200ec8ce78f8856fb67f533daf395d8d0dae8e`。
