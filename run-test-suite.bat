@echo off
REM DDoS模拟测试套件 - 运行多个测试场景
REM 仅用于教育目的和授权测试

echo ===== DDoS模拟测试套件 =====
echo 注意：未经授权对网站进行DDoS攻击是违法的
echo.

if not exist node_modules (
    echo 正在安装依赖...
    call npm install
    echo.
)

REM 创建结果目录
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set RESULTS=test-suite-%TIMESTAMP%
mkdir %RESULTS% 2>nul

REM 检查测试服务器是否正在运行
set SERVER_RUNNING=0
netstat -ano | findstr ":3000" > nul
if %ERRORLEVEL% equ 0 (
    set SERVER_RUNNING=1
    echo 检测到测试服务器正在运行
) else (
    echo 未检测到测试服务器，将启动新的服务器实例
    start cmd /k "title 测试服务器 && npm run test-server"
    echo 等待服务器启动...
    timeout /t 5 > nul
)

:menu
cls
echo 请选择要运行的测试套件:
echo 1. 完整测试套件 (所有场景)
echo 2. 基本测试套件 (基本GET/POST请求)
echo 3. 负载递增测试 (逐步增加负载)
echo 4. 突发流量测试 (模拟突发流量)
echo 5. 长时间测试 (持续低强度请求)
echo 6. 自定义目标测试 (对自定义URL运行测试)
echo 7. 退出
echo.

set /p choice=请输入选项 (1-7): 

if "%choice%"=="1" goto full_suite
if "%choice%"=="2" goto basic_suite
if "%choice%"=="3" goto increasing_suite
if "%choice%"=="4" goto spike_suite
if "%choice%"=="5" goto long_suite
if "%choice%"=="6" goto custom_target
if "%choice%"=="7" goto end

echo 无效选项，请重新选择
timeout /t 2 >nul
goto menu

:run_test
echo 运行测试: %~1
echo 命令: %~2
echo 配置: %~3
echo.

echo ===== 测试开始: %~1 ===== > "%RESULTS%\%~1.txt"
echo 时间: %date% %time% >> "%RESULTS%\%~1.txt"
echo 配置: %~3 >> "%RESULTS%\%~1.txt"
echo. >> "%RESULTS%\%~1.txt"

echo 正在执行测试...
%~2 >> "%RESULTS%\%~1.txt" 2>&1

if %ERRORLEVEL% neq 0 (
    echo [失败] 测试执行出错
    echo ===== 测试失败 ===== >> "%RESULTS%\%~1.txt"
) else (
    echo [成功] 测试完成
    echo ===== 测试完成 ===== >> "%RESULTS%\%~1.txt"
)

echo 结果已保存到: %RESULTS%\%~1.txt
echo.
goto :eof

:full_suite
cls
echo 运行完整测试套件
echo 这将依次运行所有测试场景
echo 预计总时间: ~10-15分钟
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul

REM 基本测试
call :run_test "01-basic-get" "node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100 -d 10" "基本GET请求"
timeout /t 10 >nul

call :run_test "02-basic-post" "node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100 -d 10 -m POST --body '{\"test\":true}' --headers '{\"Content-Type\":\"application/json\"}'" "基本POST请求"
timeout /t 10 >nul

call :run_test "03-heavy-endpoint" "node ddos-simulator.js -u http://localhost:3000/heavy -c 5 -r 50 -d 20" "CPU密集型端点"
timeout /t 10 >nul

REM 递增测试
call :run_test "04-increasing-01" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 50 -d 50" "递增测试-低负载"
timeout /t 10 >nul

call :run_test "05-increasing-02" "node ddos-simulator.js -u http://localhost:3000 -c 20 -r 50 -d 20" "递增测试-中负载"
timeout /t 10 >nul

call :run_test "06-increasing-03" "node ddos-simulator.js -u http://localhost:3000 -c 50 -r 50 -d 10" "递增测试-高负载"
timeout /t 10 >nul

REM 突发测试
call :run_test "07-spike-01" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 20 -d 100" "突发测试-预热"
timeout /t 10 >nul

call :run_test "08-spike-02" "node ddos-simulator.js -u http://localhost:3000 -c 100 -r 20 -d 1" "突发测试-突发"
timeout /t 10 >nul

call :run_test "09-spike-03" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 20 -d 100" "突发测试-恢复"
timeout /t 10 >nul

REM 长时间测试 (缩短版本)
call :run_test "10-long" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 200 -d 50" "长时间测试"

echo.
echo 完整测试套件已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:basic_suite
cls
echo 运行基本测试套件
echo 这将测试基本的GET和POST请求性能
echo 预计总时间: ~3-5分钟
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul

call :run_test "basic-get" "node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100 -d 10" "基本GET请求"
timeout /t 10 >nul

call :run_test "basic-post" "node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100 -d 10 -m POST --body '{\"test\":true}' --headers '{\"Content-Type\":\"application/json\"}'" "基本POST请求"
timeout /t 10 >nul

call :run_test "heavy-endpoint" "node ddos-simulator.js -u http://localhost:3000/heavy -c 5 -r 50 -d 20" "CPU密集型端点"

echo.
echo 基本测试套件已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:increasing_suite
cls
echo 运行递增负载测试
echo 这将逐步增加负载，测试服务器的扩展能力
echo 预计总时间: ~3-5分钟
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul

call :run_test "increasing-01" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 50 -d 50" "递增测试-低负载"
timeout /t 10 >nul

call :run_test "increasing-02" "node ddos-simulator.js -u http://localhost:3000 -c 20 -r 50 -d 20" "递增测试-中负载"
timeout /t 10 >nul

call :run_test "increasing-03" "node ddos-simulator.js -u http://localhost:3000 -c 50 -r 50 -d 10" "递增测试-高负载"

echo.
echo 递增负载测试已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:spike_suite
cls
echo 运行突发流量测试
echo 这将模拟突发流量，测试服务器的响应和恢复能力
echo 预计总时间: ~3-5分钟
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul

call :run_test "spike-01" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 20 -d 100" "突发测试-预热"
timeout /t 10 >nul

call :run_test "spike-02" "node ddos-simulator.js -u http://localhost:3000 -c 100 -r 20 -d 1" "突发测试-突发"
timeout /t 10 >nul

call :run_test "spike-03" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 20 -d 100" "突发测试-恢复"

echo.
echo 突发流量测试已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:long_suite
cls
echo 运行长时间测试
echo 这将进行持续的低强度测试，检测服务器的稳定性
echo 预计总时间: ~5-10分钟
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul

call :run_test "long-01" "node ddos-simulator.js -u http://localhost:3000 -c 5 -r 200 -d 50" "长时间测试-基本端点"
timeout /t 10 >nul

call :run_test "long-02" "node ddos-simulator.js -u http://localhost:3000/heavy -c 2 -r 100 -d 100" "长时间测试-CPU密集型"
timeout /t 10 >nul

call :run_test "long-03" "node ddos-simulator.js -u http://localhost:3000/memory?size=262144 -c 3 -r 150 -d 75" "长时间测试-内存分配"

echo.
echo 长时间测试已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:custom_target
cls
echo 自定义目标测试
echo.
set /p target=请输入目标URL: 

if "%target%"=="" (
    echo 错误: 目标URL不能为空
    timeout /t 2 >nul
    goto custom_target
)

echo.
echo 请选择测试类型:
echo 1. 基本测试 (GET请求)
echo 2. 递增负载测试
echo 3. 突发流量测试
echo 4. 自定义参数测试
echo.

set /p test_type=请输入选项 (1-4): 

if "%test_type%"=="1" (
    call :run_test "custom-basic" "node ddos-simulator.js -u %target% -c 10 -r 100 -d 20" "自定义目标-基本测试"
) else if "%test_type%"=="2" (
    echo 运行递增负载测试...
    call :run_test "custom-increasing-01" "node ddos-simulator.js -u %target% -c 5 -r 50 -d 50" "自定义目标-递增低负载"
    timeout /t 10 >nul
    call :run_test "custom-increasing-02" "node ddos-simulator.js -u %target% -c 20 -r 50 -d 20" "自定义目标-递增中负载"
    timeout /t 10 >nul
    call :run_test "custom-increasing-03" "node ddos-simulator.js -u %target% -c 50 -r 50 -d 10" "自定义目标-递增高负载"
) else if "%test_type%"=="3" (
    echo 运行突发流量测试...
    call :run_test "custom-spike-01" "node ddos-simulator.js -u %target% -c 5 -r 20 -d 100" "自定义目标-突发预热"
    timeout /t 10 >nul
    call :run_test "custom-spike-02" "node ddos-simulator.js -u %target% -c 100 -r 20 -d 1" "自定义目标-突发流量"
    timeout /t 10 >nul
    call :run_test "custom-spike-03" "node ddos-simulator.js -u %target% -c 5 -r 20 -d 100" "自定义目标-突发恢复"
) else if "%test_type%"=="4" (
    echo 自定义参数测试...
    set /p conn=请输入并发连接数 [50]: 
    set /p req=请输入每个连接的请求数 [100]: 
    set /p delay=请输入请求间隔(ms) [20]: 
    set /p method=请输入请求方法 [GET]: 
    
    if "%conn%"=="" set conn=50
    if "%req%"=="" set req=100
    if "%delay%"=="" set delay=20
    if "%method%"=="" set method=GET
    
    call :run_test "custom-params" "node ddos-simulator.js -u %target% -c %conn% -r %req% -d %delay% -m %method%" "自定义目标参数测试"
) else (
    echo 无效选项，返回主菜单
    timeout /t 2 >nul
    goto menu
)

echo.
echo 自定义目标测试已完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu

:end
if %SERVER_RUNNING% equ 0 (
    echo 正在关闭测试服务器...
    taskkill /fi "WINDOWTITLE eq 测试服务器" /f >nul 2>&1
)

echo 测试套件执行完成
echo 所有结果已保存至 %RESULTS% 目录
echo.
echo 感谢使用DDoS模拟测试工具
timeout /t 3 >nul
exit 