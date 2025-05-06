@echo off
REM 设置控制台编码为UTF-8
chcp 65001 >nul

REM 设置窗口标题
title DDoS模拟测试工具启动器

REM 设置控制台颜色 (浅蓝底白字)
color 9F

cls
echo ========================================================
echo                DDoS模拟测试工具启动器
echo ========================================================
echo  此启动器可确保程序正确显示中文，防止出现乱码问题
echo  仅用于教育目的和授权测试，请勿用于非法用途
echo ========================================================
echo.

REM 检查Node.js是否安装
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    color 4F
    echo [错误] 未检测到Node.js，请先安装Node.js
    echo 下载地址: https://nodejs.org/
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

REM 检查npm是否安装
where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    color 4F
    echo [错误] 未检测到npm，请先安装Node.js
    echo 下载地址: https://nodejs.org/
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

REM 检查依赖
if not exist node_modules (
    echo [提示] 正在安装依赖，请稍候...
    call npm install
    if %ERRORLEVEL% neq 0 (
        color 4F
        echo [错误] 安装依赖失败，请检查网络连接或手动执行 npm install
        echo.
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
    echo [成功] 依赖安装完成
    echo.
)

REM 创建日志目录
if not exist logs mkdir logs

:menu
cls
echo ========================================================
echo                DDoS模拟测试工具启动器
echo ========================================================
echo  请选择要启动的程序:
echo.
echo  [1] 基本模式 - 启动基本测试界面
echo  [2] 高级模式 - 启动高级测试界面 (彩色显示)
echo  [3] 测试套件 - 启动测试套件 (多场景测试)
echo  [4] 启动测试服务器
echo  [5] 安装/更新依赖
echo  [6] 查看帮助信息
echo  [7] 退出
echo.
echo ========================================================
echo.

set /p choice=请输入选项编号 (1-7): 

if "%choice%"=="1" goto basic_mode
if "%choice%"=="2" goto advanced_mode
if "%choice%"=="3" goto test_suite
if "%choice%"=="4" goto start_server
if "%choice%"=="5" goto update_deps
if "%choice%"=="6" goto show_help
if "%choice%"=="7" goto end

echo 无效选项，请重新选择
timeout /t 2 >nul
goto menu

:basic_mode
cls
echo 正在启动基本测试界面...
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 启动基本模式 >> logs\launcher-log.txt

REM 检查文件是否存在
if not exist run-ddos-test.bat (
    color 4F
    echo [错误] 找不到 run-ddos-test.bat 文件
    echo.
    echo 按任意键返回主菜单...
    pause >nul
    goto menu
)

REM 检查文件是否包含编码设置
findstr /c:"chcp 65001" run-ddos-test.bat >nul
if %ERRORLEVEL% neq 0 (
    echo [提示] 正在修复 run-ddos-test.bat 的编码问题...
    
    REM 创建临时文件
    type run-ddos-test.bat > run-ddos-test.bat.tmp
    
    REM 在文件开头添加编码设置
    echo @echo off> run-ddos-test.bat
    echo chcp 65001 ^>nul>> run-ddos-test.bat
    echo REM 使用UTF-8编码以正确显示中文>> run-ddos-test.bat
    echo.>> run-ddos-test.bat
    
    REM 添加原文件内容（第2行开始，跳过原有的@echo off）
    for /f "skip=1 delims=" %%i in (run-ddos-test.bat.tmp) do (
        echo %%i>> run-ddos-test.bat
    )
    
    REM 删除临时文件
    del run-ddos-test.bat.tmp
    
    echo [完成] 已修复编码问题
    timeout /t 2 >nul
)

start cmd /k "title DDoS模拟测试工具 - 基本模式 && run-ddos-test.bat"
goto menu

:advanced_mode
cls
echo 正在启动高级测试界面...
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 启动高级模式 >> logs\launcher-log.txt

REM 检查文件是否存在
if not exist run-advanced-test.bat (
    color 4F
    echo [错误] 找不到 run-advanced-test.bat 文件
    echo.
    echo 按任意键返回主菜单...
    pause >nul
    goto menu
)

REM 检查文件是否包含编码设置
findstr /c:"chcp 65001" run-advanced-test.bat >nul
if %ERRORLEVEL% neq 0 (
    echo [提示] 正在修复 run-advanced-test.bat 的编码问题...
    
    REM 创建临时文件
    type run-advanced-test.bat > run-advanced-test.bat.tmp
    
    REM 在文件开头添加编码设置
    echo @echo off> run-advanced-test.bat
    echo chcp 65001 ^>nul>> run-advanced-test.bat
    echo REM 使用UTF-8编码以正确显示中文>> run-advanced-test.bat
    echo.>> run-advanced-test.bat
    
    REM 添加原文件内容（第2行开始，跳过原有的@echo off）
    for /f "skip=1 delims=" %%i in (run-advanced-test.bat.tmp) do (
        echo %%i>> run-advanced-test.bat
    )
    
    REM 删除临时文件
    del run-advanced-test.bat.tmp
    
    echo [完成] 已修复编码问题
    timeout /t 2 >nul
)

start cmd /k "title DDoS模拟测试工具 - 高级模式 && run-advanced-test.bat"
goto menu

:test_suite
cls
echo 正在启动测试套件...
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 启动测试套件 >> logs\launcher-log.txt

REM 检查文件是否存在
if not exist run-test-suite.bat (
    color 4F
    echo [错误] 找不到 run-test-suite.bat 文件
    echo.
    echo 按任意键返回主菜单...
    pause >nul
    goto menu
)

REM 检查文件是否包含编码设置
findstr /c:"chcp 65001" run-test-suite.bat >nul
if %ERRORLEVEL% neq 0 (
    echo [提示] 正在修复 run-test-suite.bat 的编码问题...
    
    REM 创建临时文件
    type run-test-suite.bat > run-test-suite.bat.tmp
    
    REM 在文件开头添加编码设置
    echo @echo off> run-test-suite.bat
    echo chcp 65001 ^>nul>> run-test-suite.bat
    echo REM 使用UTF-8编码以正确显示中文>> run-test-suite.bat
    echo.>> run-test-suite.bat
    
    REM 添加原文件内容（第2行开始，跳过原有的@echo off）
    for /f "skip=1 delims=" %%i in (run-test-suite.bat.tmp) do (
        echo %%i>> run-test-suite.bat
    )
    
    REM 删除临时文件
    del run-test-suite.bat.tmp
    
    echo [完成] 已修复编码问题
    timeout /t 2 >nul
)

start cmd /k "title DDoS模拟测试工具 - 测试套件 && run-test-suite.bat"
goto menu

:start_server
cls
echo 正在启动测试服务器...
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 启动测试服务器 >> logs\launcher-log.txt

REM 检查服务器是否已经在运行
netstat -ano | findstr ":3000" > nul
if %ERRORLEVEL% equ 0 (
    echo [警告] 检测到端口3000已被占用，测试服务器可能已在运行
    echo.
    echo 是否仍要尝试启动服务器？(Y/N)
    set /p confirm=
    if /i not "%confirm%"=="Y" goto menu
)

start cmd /k "title DDoS测试服务器 && chcp 65001 >nul && npm run test-server"
echo [信息] 测试服务器已在新窗口中启动
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:update_deps
cls
echo 正在更新依赖...
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 更新依赖 >> logs\launcher-log.txt

call npm install
if %ERRORLEVEL% neq 0 (
    color 4F
    echo [错误] 更新依赖失败，请检查网络连接
) else (
    echo [成功] 依赖已更新
)

echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:show_help
cls
echo ========================================================
echo                  DDoS模拟测试工具帮助                   
echo ========================================================
echo.
echo  【工具说明】
echo  本工具仅用于教育目的和授权测试，使用本工具对未经授权的
echo  网站或服务进行DDoS攻击是违法的，可能导致严重的法律后果。
echo.
echo  【解决乱码问题】
echo  如果您在命令行中看到中文显示为乱码，此启动器已自动修复
echo  批处理文件的编码问题。如果仍有问题，请尝试以下方法：
echo    1. 使用此启动器运行程序
echo    2. 修改命令行属性，将代码页改为UTF-8（65001）
echo    3. 在批处理文件开头添加：chcp 65001 >nul
echo.
echo  【基本使用方法】
echo    1. 启动测试服务器（选项4）
echo    2. 根据需要选择运行基本模式、高级模式或测试套件
echo    3. 按照程序提示进行操作
echo.
echo  【注意事项】
echo    1. 仅在您拥有或已获授权的系统上使用此工具
echo    2. 从低负载开始测试，避免意外造成系统崩溃
echo    3. 测试完成后检查结果，了解系统性能瓶颈
echo.
echo ========================================================
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:end
cls
echo 感谢使用DDoS模拟测试工具！
echo.
echo 当前时间: %date% %time% > logs\launcher-log.txt
echo 程序退出 >> logs\launcher-log.txt
timeout /t 3 >nul
exit 