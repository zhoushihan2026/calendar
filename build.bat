@echo off
chcp 65001 >nul
echo ========================================
echo HarmonyOS 应用打包脚本
echo ========================================
echo.

REM 检查是否在项目根目录
if not exist "hvigorfile.ts" (
    echo 错误：请在项目根目录运行此脚本
    pause
    exit /b 1
)

echo 请选择构建模式：
echo 1. Debug 模式（开发测试用）
echo 2. Release 模式（正式发布用）
echo.
set /p mode="请输入选项 (1 或 2): "

if "%mode%"=="1" (
    echo.
    echo 正在构建 Debug 版本...
    call hvigorw.bat assembleHap --mode module -p product=default --analyze
    if %errorlevel%==0 (
        echo.
        echo ========================================
        echo Debug 版本构建成功！
        echo 输出位置: entry\build\default\outputs\default\entry-default-debug.hap
        echo ========================================
    ) else (
        echo.
        echo 构建失败，请检查错误信息
    )
) else if "%mode%"=="2" (
    echo.
    echo 正在构建 Release 版本...
    call hvigorw.bat assembleHap --mode module -p product=default --analyze -p buildMode=release
    if %errorlevel%==0 (
        echo.
        echo ========================================
        echo Release 版本构建成功！
        echo 输出位置: entry\build\default\outputs\default\entry-default-release.hap
        echo ========================================
        echo.
        echo 注意：Release 版本需要配置签名才能安装到设备
        echo 请参考 README.md 中的签名配置说明
    ) else (
        echo.
        echo 构建失败，请检查错误信息
    )
) else (
    echo 无效的选项
    pause
    exit /b 1
)

echo.
pause


