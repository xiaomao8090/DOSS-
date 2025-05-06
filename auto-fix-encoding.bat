@echo off
chcp 65001 >nul
REM 自动修复Windows批处理文件中文显示乱码的工具

echo ------------------------------------------------
echo   Windows批处理文件中文乱码修复工具
echo   适用于DDoS模拟测试工具的批处理文件
echo ------------------------------------------------
echo.

echo [1/4] 创建备份目录...
if not exist backups mkdir backups
echo      √ 完成

echo [2/4] 检测批处理文件...
set "count=0"
for %%f in (*.bat) do (
    if not "%%f"=="auto-fix-encoding.bat" (
        if not "%%f"=="fix-encoding.bat" (
            if not "%%f"=="ddos-launcher.bat" (
                set /a count+=1
                echo      发现文件: %%f
            )
        )
    )
)
echo      √ 找到 %count% 个批处理文件

echo [3/4] 备份并修复批处理文件...
for %%f in (*.bat) do (
    if not "%%f"=="auto-fix-encoding.bat" (
        if not "%%f"=="fix-encoding.bat" (
            if not "%%f"=="ddos-launcher.bat" (
                echo      正在处理: %%f
                
                REM 备份原文件
                copy "%%f" "backups\%%f.bak" >nul
                
                REM 检查文件是否已包含chcp命令
                findstr /c:"chcp 65001" "%%f" >nul
                if errorlevel 1 (
                    echo        - 需要修复编码
                    
                    REM 创建临时文件
                    type "%%f" > "%%f.tmp"
                    
                    REM 添加编码设置
                    echo @echo off> "%%f"
                    echo chcp 65001 ^>nul>> "%%f"
                    echo REM 使用UTF-8编码，解决中文显示乱码问题>> "%%f"
                    echo.>> "%%f"
                    
                    REM 添加原文件内容（跳过第一行的@echo off）
                    for /f "skip=1 delims=" %%i in ("%%f.tmp") do (
                        echo %%i>> "%%f"
                    )
                    
                    REM 删除临时文件
                    del "%%f.tmp"
                    echo        √ 已修复
                ) else (
                    echo        √ 已包含UTF-8编码设置，无需修复
                )
            )
        )
    )
)
echo      √ 批处理文件修复完成

echo [4/4] 创建启动器...
if not exist ddos-launcher.bat (
    echo @echo off> ddos-launcher.bat
    echo chcp 65001 ^>nul>> ddos-launcher.bat
    echo title DDoS模拟测试工具启动器>> ddos-launcher.bat
    echo color 1F>> ddos-launcher.bat
    echo echo ===== DDoS模拟测试工具启动器 =====>> ddos-launcher.bat
    echo echo 请选择要执行的操作:>> ddos-launcher.bat
    echo echo 1. 启动测试服务器>> ddos-launcher.bat
    echo echo 2. 运行基本测试>> ddos-launcher.bat
    echo echo 3. 运行高级测试>> ddos-launcher.bat
    echo echo 4. 运行测试套件>> ddos-launcher.bat
    echo echo 5. 退出>> ddos-launcher.bat
    echo echo.>> ddos-launcher.bat
    echo set /p choice=请输入选项 (1-5): >> ddos-launcher.bat
    echo.>> ddos-launcher.bat
    echo if "%%choice%%"=="1" start cmd /k "title 测试服务器 ^&^& chcp 65001 ^>nul ^&^& npm run test-server">> ddos-launcher.bat
    echo if "%%choice%%"=="2" start cmd /k "title 基本测试 ^&^& chcp 65001 ^>nul ^&^& run-ddos-test.bat">> ddos-launcher.bat
    echo if "%%choice%%"=="3" start cmd /k "title 高级测试 ^&^& chcp 65001 ^>nul ^&^& run-advanced-test.bat">> ddos-launcher.bat
    echo if "%%choice%%"=="4" start cmd /k "title 测试套件 ^&^& chcp 65001 ^>nul ^&^& run-test-suite.bat">> ddos-launcher.bat
    echo if "%%choice%%"=="5" exit>> ddos-launcher.bat
    echo.>> ddos-launcher.bat
    echo goto :eof>> ddos-launcher.bat
    echo      √ 已创建简易启动器
) else (
    echo      √ 启动器已存在
)

echo.
echo ------------------------------------------------
echo   修复完成！现在您的批处理文件应该可以正确显示中文了
echo   ※ 建议使用 ddos-launcher.bat 来启动程序 ※
echo ------------------------------------------------
echo.

echo 按任意键退出...
pause >nul 