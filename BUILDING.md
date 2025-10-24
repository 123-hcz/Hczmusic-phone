# HCZ Music - Android 构建指南

## 自动构建 (GitHub Actions)

本项目配置了 GitHub Actions 自动构建流程，支持自动构建 Android APK 和 AAB 文件。

### 工作流配置

- **文件位置**: `.github/workflows/build_android.yml` (在项目根目录下)
- **触发条件**: 
  - 推送到 `main` 或 `master` 分支
  - Pull Request 到 `main` 或 `master` 分支
- **构建环境**: Ubuntu-latest
- **Flutter 版本**: 3.24.0
- **Java 版本**: OpenJDK 11

### 构建流程

1. **环境设置**
   - 设置 Java 环境 (Zulu OpenJDK 11)
   - 设置 Flutter 环境 (3.24.0)

2. **依赖管理**
   - 运行 `flutter pub get` 获取项目依赖

3. **代码质量检查**
   - 运行 `flutter analyze` 进行代码分析
   - 运行 `flutter test` 执行单元测试

4. **构建应用**
   - 运行 `flutter build apk --release` 生成发布版 APK
   - 运行 `flutter build appbundle --release` 生成 AAB (App Bundle)

5. **产物上传**
   - 上传 APK 文件为 `hczmusic-apk` artifacts
   - 上传 AAB 文件为 `hczmusic-bundle` artifacts

### 构建产物

- **APK 文件**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB 文件**: `build/app/outputs/bundle/release/app-release.aab`

## 本地构建

### 使用构建脚本

项目包含一个构建脚本，支持完整构建流程：

```bash
# 进入项目目录
cd hczmusic_flutter

# 运行构建脚本
./scripts/build_android.sh
```

### 仅构建特定格式

```bash
# 仅构建 APK
./scripts/build_android.sh --apk-only

# 仅构建 AAB
./scripts/build_android.sh --aab-only
```

### 手动构建

```bash
# 构建发布版 APK
flutter build apk --release

# 构建 AAB
flutter build appbundle --release

# 构建调试版 APK
flutter build apk --debug
```

## 构建配置

### 构建配置文件

- **build_config.json**: 包含应用构建相关信息
- **build_config.md**: 详细构建配置说明

### 项目版本信息

- **应用版本**: 1.0.0+1
- **最小 SDK 版本**: 21 (Android 5.0)
- **目标 SDK 版本**: 33
- **编译 SDK 版本**: 33

## 依赖项

构建过程需要以下依赖项：

- Flutter SDK (3.0.0+)
- Java JDK (11+)
- Android SDK
- Dart SDK

## 构建产物说明

### APK 文件 (Android Package)

- 格式: `.apk`
- 用途: 直接安装到 Android 设备
- 位置: `build/app/outputs/flutter-apk/app-release.apk`

### AAB 文件 (Android App Bundle)

- 格式: `.aab`
- 用途: 提交到 Google Play Store
- 位置: `build/app/outputs/bundle/release/app-release.aab`

## 注意事项

1. **签名**: 发布版 APK/AAB 默认使用 debug key 进行签名。正式发布前需配置 release keystore。

2. **构建时间**: 首次构建可能需要较长时间，因为需要下载依赖项。

3. **存储空间**: 构建过程需要足够的磁盘空间。

4. **网络**: 构建过程需要互联网连接以下载依赖项。

## 故障排除

### 常见问题

1. **构建失败**: 检查 Flutter 和 Android 环境配置
2. **依赖问题**: 运行 `flutter clean` 然后重新构建
3. **内存不足**: 确保有足够的内存和磁盘空间

### 调试构建

在本地运行以下命令以调试构建问题：

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release -v
```

## CI/CD 集成

GitHub Actions 工作流会在每次提交时自动运行，确保代码质量并生成构建产物。构建产物可以作为 artifacts 下载使用。