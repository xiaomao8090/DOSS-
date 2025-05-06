@echo off
chcp 65001 >nul
REM 使用UTF-8编码以正确显示中文

setlocal enabledelayedexpansion
REM 高级DDoS模拟测试工具启动脚本
REM 仅用于教育目的和授权测试
title DDoS模拟测试工具 - 高级版
REM 设置颜色代码
set "RED=31"
set "GREEN=32"
set "YELLOW=33"
set "BLUE=34"
set "MAGENTA=35"
set "CYAN=36"
set "WHITE=37"
REM 定义彩色输出函数
call :define_color_function
call %color% %CYAN% "======================================================"
call %color% %CYAN% "              DDoS模拟测试工具 - 高级版               "
call %color% %CYAN% "======================================================"
call %color% %RED% "警告：未经授权对网站进行DDoS攻击是违法的"
call %color% %WHITE% ""
REM 检查依赖
call %color% %BLUE% "正在检查环境..."
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    call %color% %RED% "错误: 未找到Node.js，请安装Node.js后再运行此脚本"
    call %color% %YELLOW% "下载地址: https://nodejs.org/"
    pause
    exit /b 1
)
if not exist node_modules (
    call %color% %YELLOW% "正在安装依赖..."
    call npm install
    if %ERRORLEVEL% neq 0 (
        call %color% %RED% "错误: 安装依赖失败"
        pause
        exit /b 1
    )
    call %color% %GREEN% "依赖安装完成"
    timeout /t 2 >nul
)
REM 测试配置
set RESULTS_DIR=test-results
if not exist %RESULTS_DIR% mkdir %RESULTS_DIR%
REM 创建日志文件
set LOG_FILE=%RESULTS_DIR%\test-log-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt
set LOG_FILE=%LOG_FILE: =0%
REM 记录系统信息
echo DDoS模拟测试工具 - 高级版 > %LOG_FILE%
echo 运行时间: %date% %time% >> %LOG_FILE%
echo ---------------------------------------- >> %LOG_FILE%
echo 系统信息: >> %LOG_FILE%
systeminfo | findstr /B /C:"OS" /C:"OS 版本" /C:"系统类型" >> %LOG_FILE%
echo ---------------------------------------- >> %LOG_FILE%
echo Node.js版本: >> %LOG_FILE%
node -v >> %LOG_FILE%
echo ---------------------------------------- >> %LOG_FILE%
:menu
cls
call %color% %CYAN% "======================================================"
call %color% %CYAN% "                 DDoS模拟测试工具菜单                 "
call %color% %CYAN% "======================================================"
echo.
call %color% %WHITE% "[1] 启动测试服务器"
call %color% %WHITE% "[2] 运行基本测试"
call %color% %WHITE% "[3] 运行多目标测试"
call %color% %WHITE% "[4] 生成测试场景"
call %color% %WHITE% "[5] 自定义测试"
call %color% %WHITE% "[6] 查看测试结果"
call %color% %WHITE% "[7] 退出"
echo.
set /p choice=请输入选项 (1-7): 
if "%choice%"=="1" goto start_server
if "%choice%"=="2" goto basic_test
if "%choice%"=="3" goto multi_target_test
if "%choice%"=="4" goto generate_test
if "%choice%"=="5" goto custom_test
if "%choice%"=="6" goto view_results
if "%choice%"=="7" goto end
call %color% %RED% "无效选项，请重新选择"
timeout /t 2 >nul
goto menu
:start_server
cls
call %color% %GREEN% "正在启动测试服务器..."
call %color% %YELLOW% "请在新的命令行窗口中运行测试"
call %color% %YELLOW% "按Ctrl+C停止服务器"
echo.
start cmd /k "title 测试服务器 && npm run test-server"
echo 启动测试服务器 >> %LOG_FILE%
timeout /t 3 >nul
goto menu
:basic_test
cls
call %color% %GREEN% "运行基本测试"
echo.
call %color% %WHITE% "目标: http://localhost:3000"
call %color% %WHITE% "并发连接: 10"
call %color% %WHITE% "请求数: 100"
echo.
call %color% %YELLOW% "按任意键开始测试，或关闭此窗口取消..."
pause >nul
call %color% %GREEN% "正在执行测试..."
echo 执行基本测试: http://localhost:3000 >> %LOG_FILE%
REM 保存输出到结果文件
set RESULT_FILE=%RESULTS_DIR%\basic-test-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt
set RESULT_FILE=%RESULT_FILE: =0%
node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100 > %RESULT_FILE% 2>&1
if %ERRORLEVEL% neq 0 (
    call %color% %RED% "测试执行过程中发生错误，请查看结果文件"
) else (
    call %color% %GREEN% "测试完成"
    call %color% %WHITE% "结果已保存到: %RESULT_FILE%"
)
echo 测试结果保存到: %RESULT_FILE% >> %LOG_FILE%
echo.
call %color% %WHITE% "按任意键返回主菜单..."
pause >nul
goto menu
:multi_target_test
cls
call %color% %GREEN% "多目标测试"
echo.
call %color% %WHITE% "此选项将对多个目标运行相同的测试配置"
echo.
REM 临时目标文件
set TARGETS_FILE=%TEMP%\ddos_targets.txt
REM 默认目标
echo http://localhost:3000> %TARGETS_FILE%
echo http://localhost:3000/heavy>> %TARGETS_FILE%
echo http://localhost:3000/memory?size=512000>> %TARGETS_FILE%
call %color% %WHITE% "当前目标列表:"
type %TARGETS_FILE% | findstr /n "^"
echo.
:target_menu
call %color% %WHITE% "目标管理选项:"
call %color% %WHITE% "[1] 使用当前目标列表"
call %color% %WHITE% "[2] 添加目标"
call %color% %WHITE% "[3] 删除目标"
call %color% %WHITE% "[4] 清空目标列表"
call %color% %WHITE% "[5] 返回主菜单"
echo.
set /p target_choice=请选择 (1-5): 
if "%target_choice%"=="1" goto run_multi_target
if "%target_choice%"=="2" goto add_target
if "%target_choice%"=="3" goto delete_target
if "%target_choice%"=="4" goto clear_targets
if "%target_choice%"=="5" goto menu
call %color% %RED% "无效选项，请重新选择"
timeout /t 2 >nul
goto target_menu
:add_target
set /p new_target=请输入新目标URL: 
echo %new_target%>> %TARGETS_FILE%
call %color% %GREEN% "已添加新目标"
goto multi_target_test
:delete_target
set /p del_num=请输入要删除的目标编号: 
set /a del_num=%del_num%
if %del_num% leq 0 (
    call %color% %RED% "无效编号"
    timeout /t 2 >nul
    goto multi_target_test
)
REM 创建新的临时文件
set TEMP_TARGETS=%TEMP%\ddos_targets_temp.txt
set line_num=1
for /f "tokens=*" %%a in (%TARGETS_FILE%) do (
    if !line_num! neq %del_num% (
        echo %%a>> %TEMP_TARGETS%
    )
    set /a line_num+=1
)
REM 替换原始文件
copy /y %TEMP_TARGETS% %TARGETS_FILE% >nul
del %TEMP_TARGETS%
call %color% %GREEN% "已删除目标"
timeout /t 1 >nul
goto multi_target_test
:clear_targets
echo.> %TARGETS_FILE%
call %color% %GREEN% "已清空目标列表"
timeout /t 1 >nul
goto multi_target_test
:run_multi_target
cls
call %color% %GREEN% "运行多目标测试"
echo.
set /p conn=请输入并发连接数 [10]: 
set /p req=请输入每个连接的请求数 [50]: 
set /p delay=请输入请求间隔(ms) [20]: 
if "%conn%"=="" set conn=10
if "%req%"=="" set req=50
if "%delay%"=="" set delay=20
echo.
call %color% %WHITE% "测试配置:"
call %color% %WHITE% "- 并发连接: %conn%"
call %color% %WHITE% "- 请求数: %req%"
call %color% %WHITE% "- 延迟: %delay%ms"
echo.
call %color% %YELLOW% "按任意键开始测试，或关闭此窗口取消..."
pause >nul
REM 创建多目标测试结果目录
set MULTI_TEST_DIR=%RESULTS_DIR%\multi-test-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set MULTI_TEST_DIR=%MULTI_TEST_DIR: =0%
mkdir %MULTI_TEST_DIR%
echo 执行多目标测试 >> %LOG_FILE%
echo 时间: %date% %time% >> %LOG_FILE%
echo 配置: 连接数=%conn%, 请求数=%req%, 延迟=%delay%ms >> %LOG_FILE%
set target_count=0
for /f "tokens=*" %%a in (%TARGETS_FILE%) do (
    set /a target_count+=1
)
set current_target=0
for /f "tokens=*" %%a in (%TARGETS_FILE%) do (
    set /a current_target+=1
    set target=%%a
ECHO is off.
    call %color% %YELLOW% "[!current_target!/!target_count!] 测试目标: !target!"
ECHO is off.
    set TARGET_RESULT=%MULTI_TEST_DIR%\target-!current_target!.txt
    echo 目标URL: !target! > !TARGET_RESULT!
    echo 时间: %date% %time% >> !TARGET_RESULT!
    echo ---------------------------------- >> !TARGET_RESULT!
ECHO is off.
    call %color% %GREEN% "开始测试..."
    echo 测试目标: !target! >> %LOG_FILE%
ECHO is off.
    node ddos-simulator.js -u !target! -c %conn% -r %req% -d %delay% >> !TARGET_RESULT! 2>&1
ECHO is off.
    if %ERRORLEVEL% neq 0 (
        call %color% %RED% "测试执行过程中发生错误"
        echo 错误: 测试失败 >> !TARGET_RESULT!
        echo 失败: !target! >> %LOG_FILE%
    ) else (
        call %color% %GREEN% "测试完成"
        echo 成功: !target! >> %LOG_FILE%
    )
ECHO is off.
    echo.
    if !current_target! lss !target_count! (
        call %color% %YELLOW% "等待30秒后测试下一个目标..."
        timeout /t 30 >nul
    )
)
call %color% %GREEN% "所有目标测试完成"
call %color% %WHITE% "结果已保存到: %MULTI_TEST_DIR%"
echo 多目标测试结果保存到: %MULTI_TEST_DIR% >> %LOG_FILE%
echo.
call %color% %WHITE% "按任意键返回主菜单..."
pause >nul
goto menu
:generate_test
cls
call %color% %GREEN% "生成测试场景"
echo.
call %color% %WHITE% "可用场景:"
call %color% %WHITE% "- basic: 基本测试"
call %color% %WHITE% "- increasing: 递增负载测试"
call %color% %WHITE% "- spike: 突发负载测试"
call %color% %WHITE% "- long: 长时间负载测试"
echo.
set /p scenario=请输入场景类型: 
REM 验证场景类型
set valid_scenario=0
for %%s in (basic increasing spike long) do (
    if /i "!scenario!"=="%%s" set valid_scenario=1
)
if !valid_scenario! equ 0 (
    call %color% %RED% "无效的场景类型，使用默认场景 'basic'"
    set scenario=basic
    timeout /t 2 >nul
)
set /p testname=请输入测试名称: 
set /p target=请输入目标URL [http://localhost:3000]: 
if "%target%"=="" set target=http://localhost:3000
if "%testname%"=="" set testname=test-%date:~0,4%%date:~5,2%%date:~8,2%
echo.
call %color% %GREEN% "正在生成测试场景..."
echo 生成测试场景: 类型=%scenario%, 名称=%testname%, 目标=%target% >> %LOG_FILE%
node generate-load-test.js -s %scenario% -n %testname% -t %target% -o %RESULTS_DIR%\scenarios
if %ERRORLEVEL% neq 0 (
    call %color% %RED% "生成测试场景时发生错误"
) else (
    call %color% %GREEN% "测试场景已生成"
)
echo.
call %color% %WHITE% "按任意键返回主菜单..."
pause >nul
goto menu
:custom_test
cls
call %color% %GREEN% "自定义测试"
echo.
set /p target=请输入目标URL: 
if "%target%"=="" (
    call %color% %RED% "错误: 目标URL不能为空"
    timeout /t 2 >nul
    goto custom_test
)
set /p conn=请输入并发连接数 [100]: 
set /p req=请输入每个连接的请求数 [100]: 
set /p delay=请输入请求间隔(ms) [10]: 
set /p method=请输入请求方法 [GET]: 
set /p workers=请输入工作进程数 [%NUMBER_OF_PROCESSORS%]: 
set /p timeout=请输入请求超时(ms) [5000]: 
if "%conn%"=="" set conn=100
if "%req%"=="" set req=100
if "%delay%"=="" set delay=10
if "%method%"=="" set method=GET
if "%workers%"=="" set workers=%NUMBER_OF_PROCESSORS%
if "%timeout%"=="" set timeout=5000
set /p use_body=是否添加请求体? (y/n) [n]: 
set body_param=
if /i "%use_body%"=="y" (
    set /p body=请输入请求体 (JSON格式): 
    set body_param=--body "%body%"
)
set /p use_headers=是否添加自定义请求头? (y/n) [n]: 
set headers_param=
if /i "%use_headers%"=="y" (
    set /p headers=请输入请求头 (JSON格式): 
    set headers_param=--headers "%headers%"
)
echo.
call %color% %WHITE% "测试配置:"
call %color% %WHITE% "- 目标: %target%"
call %color% %WHITE% "- 并发连接: %conn%"
call %color% %WHITE% "- 请求数: %req%"
call %color% %WHITE% "- 延迟: %delay%ms"
call %color% %WHITE% "- 方法: %method%"
call %color% %WHITE% "- 工作进程: %workers%"
call %color% %WHITE% "- 超时: %timeout%ms"
if defined body_param call %color% %WHITE% "- 请求体: %body%"
if defined headers_param call %color% %WHITE% "- 请求头: %headers%"
echo.
call %color% %YELLOW% "按任意键开始测试，或关闭此窗口取消..."
pause >nul
call %color% %GREEN% "正在执行测试..."
set CUSTOM_RESULT=%RESULTS_DIR%\custom-test-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt
set CUSTOM_RESULT=%CUSTOM_RESULT: =0%
echo 执行自定义测试: %target% >> %LOG_FILE%
echo 配置: 连接数=%conn%, 请求数=%req%, 延迟=%delay%ms, 方法=%method%, 工作进程=%workers%, 超时=%timeout%ms >> %LOG_FILE%
node ddos-simulator.js -u %target% -c %conn% -r %req% -d %delay% -m %method% -w %workers% -t %timeout% %body_param% %headers_param% > %CUSTOM_RESULT% 2>&1
