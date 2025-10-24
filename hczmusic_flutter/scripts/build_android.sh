#!/bin/bash

# HCZ Music Flutter 构建脚本
# 用于构建Android APK和AAB文件

set -e  # 出错时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_message() {
    case $1 in
        "info") echo -e "${GREEN}[INFO]${NC} $2" ;;
        "warn") echo -e "${YELLOW}[WARN]${NC} $2" ;;
        "error") echo -e "${RED}[ERROR]${NC} $2" ;;
    esac
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message "error" "$1 is not installed"
        exit 1
    fi
}

# 函数：检查Flutter环境
check_flutter_env() {
    print_message "info" "检查Flutter环境..."
    
    check_command "flutter"
    check_command "java"
    check_command "adb"
    
    flutter --version
    java -version
}

# 函数：获取依赖
get_dependencies() {
    print_message "info" "获取依赖项..."
    flutter pub get
    if [ $? -ne 0 ]; then
        print_message "error" "获取依赖失败"
        exit 1
    fi
}

# 函数：分析代码
analyze_code() {
    print_message "info" "分析代码..."
    flutter analyze
    if [ $? -ne 0 ]; then
        print_message "warn" "代码分析发现问题，继续构建"
    fi
}

# 函数：运行测试
run_tests() {
    print_message "info" "运行测试..."
    flutter test
    if [ $? -ne 0 ]; then
        print_message "warn" "测试失败，继续构建"
    fi
}

# 函数：构建APK
build_apk() {
    print_message "info" "构建APK..."
    flutter build apk --release
    if [ $? -eq 0 ]; then
        print_message "info" "APK构建成功: build/app/outputs/flutter-apk/app-release.apk"
    else
        print_message "error" "APK构建失败"
        exit 1
    fi
}

# 函数：构建AAB
build_aab() {
    print_message "info" "构建AAB..."
    flutter build appbundle --release
    if [ $? -eq 0 ]; then
        print_message "info" "AAB构建成功: build/app/outputs/bundle/release/app-release.aab"
    else
        print_message "error" "AAB构建失败"
        exit 1
    fi
}

# 函数：生成构建信息
generate_build_info() {
    print_message "info" "生成构建信息..."
    BUILD_DATE=$(date)
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    
    cat > build_info.json << EOF
{
  "build_date": "$BUILD_DATE",
  "flutter_version": "$FLUTTER_VERSION",
  "app_version": "$(grep 'version:' pubspec.yaml | cut -d' ' -f2)",
  "build_type": "release",
  "platform": "android"
}
EOF
    
    print_message "info" "构建信息已生成: build_info.json"
}

# 主函数
main() {
    print_message "info" "开始构建HCZ Music Android应用..."
    
    check_flutter_env
    get_dependencies
    analyze_code
    run_tests
    build_apk
    build_aab
    generate_build_info
    
    print_message "info" "构建完成！"
    print_message "info" "APK位置: build/app/outputs/flutter-apk/app-release.apk"
    print_message "info" "AAB位置: build/app/outputs/bundle/release/app-release.aab"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $0 in
        build_android.sh)
            case $1 in
                --apk-only)
                    build_apk
                    exit 0
                    ;;
                --aab-only)
                    build_aab
                    exit 0
                    ;;
                --help)
                    echo "用法: $0 [选项]"
                    echo "选项:"
                    echo "  --apk-only    只构建APK"
                    echo "  --aab-only    只构建AAB"
                    echo "  --help        显示帮助信息"
                    exit 0
                    ;;
                *)
                    print_message "error" "未知选项: $1"
                    exit 1
                    ;;
            esac
            shift
            ;;
    esac
done

# 执行主函数
main