#!/bin/bash

echo "========================================"
echo "HarmonyOS 应用打包脚本"
echo "========================================"
echo ""

# 检查是否在项目根目录
if [ ! -f "hvigorfile.ts" ]; then
    echo "错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "请选择构建模式："
echo "1. Debug 模式（开发测试用）"
echo "2. Release 模式（正式发布用）"
echo ""
read -p "请输入选项 (1 或 2): " mode

if [ "$mode" == "1" ]; then
    echo ""
    echo "正在构建 Debug 版本..."
    ./hvigorw assembleHap --mode module -p product=default --analyze
    if [ $? -eq 0 ]; then
        echo ""
        echo "========================================"
        echo "Debug 版本构建成功！"
        echo "输出位置: entry/build/default/outputs/default/entry-default-debug.hap"
        echo "========================================"
    else
        echo ""
        echo "构建失败，请检查错误信息"
        exit 1
    fi
elif [ "$mode" == "2" ]; then
    echo ""
    echo "正在构建 Release 版本..."
    ./hvigorw assembleHap --mode module -p product=default --analyze -p buildMode=release
    if [ $? -eq 0 ]; then
        echo ""
        echo "========================================"
        echo "Release 版本构建成功！"
        echo "输出位置: entry/build/default/outputs/default/entry-default-release.hap"
        echo "========================================"
        echo ""
        echo "注意：Release 版本需要配置签名才能安装到设备"
        echo "请参考 README.md 中的签名配置说明"
    else
        echo ""
        echo "构建失败，请检查错误信息"
        exit 1
    fi
else
    echo "无效的选项"
    exit 1
fi


