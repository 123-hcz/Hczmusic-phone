# 构建配置文件

## 版本信息
version: 1.0.0+1

## 构建类型
- debug: 用于开发和测试
- release: 用于发布

## 目标平台
- android: 生成APK和AAB文件
- ios: 生成IPA文件（预留）
- web: 生成Web版本（预留）

## 构建输出
- APK: build/app/outputs/flutter-apk/app-release.apk
- AAB: build/app/outputs/bundle/release/app-release.aab
- 构建产物将通过GitHub Actions自动上传为artifacts

## 环境要求
- Flutter SDK: 3.0.0+
- Java: OpenJDK 11+
- Android SDK: API level 30+
- 构建工具: build-tools;30.0.3+

## 构建流程
1. 设置构建环境
2. 获取依赖项
3. 代码分析
4. 运行测试
5. 构建APK/AAB
6. 上传构建产物

## 环境变量
- FLUTTER_VERSION: 3.24.0
- JAVA_VERSION: 11
- ANDROID_SDK_VERSION: 30