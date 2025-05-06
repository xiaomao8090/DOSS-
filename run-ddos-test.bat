@echo off
chcp 65001 >nul
REM 使用UTF-8编码以正确显示中文

REM DDoS模拟测试工具启动脚本
REM 仅用于教育目的和授权测试
echo ===== DDoS模拟测试工具 =====
echo 注意：未经授权对网站进行DDoS攻击是违法的
echo.
if not exist node_modules (
    echo 正在安装依赖...
    call npm install
    echo.
)
:menu
cls
echo 请选择要执行的操作:
echo 1. 启动测试服务器
echo 2. 运行基本测试
echo 3. 生成测试场景
echo 4. 自定义测试
echo 5. 退出
echo.
set /p choice=请输入选项 (1-5): 
if "%choice%"=="1" goto start_server
if "%choice%"=="2" goto basic_test
if "%choice%"=="3" goto generate_test
if "%choice%"=="4" goto custom_test
if "%choice%"=="5" goto end
echo 无效选项，请重新选择
timeout /t 2 >nul
goto menu
:start_server
cls
echo 正在启动测试服务器...
echo 请在新的命令行窗口中运行测试
echo 按Ctrl+C停止服务器
echo.
start cmd /k "npm run test-server"
timeout /t 3 >nul
goto menu
:basic_test
cls
echo 正在运行基本测试...
echo.
echo 目标: http://localhost:3000
echo 并发连接: 10
echo 请求数: 100
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul
node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100
echo.
echo 测试完成
echo 按任意键返回主菜单...
pause >nul
goto menu
:generate_test
cls
echo 生成测试场景
echo.
echo 可用场景:
echo - basic: 基本测试
echo - increasing: 递增负载测试
echo - spike: 突发负载测试
echo - long: 长时间负载测试
echo.
set /p scenario=请输入场景类型: 
set /p testname=请输入测试名称: 
set /p target=请输入目标URL [http://localhost:3000]: 
if "%target%"=="" set target=http://localhost:3000
echo.
echo 正在生成测试场景...
node generate-load-test.js -s %scenario% -n %testname% -t %target%
echo.
echo 按任意键返回主菜单...
pause >nul
goto menu
:custom_test
cls
echo 自定义测试
echo.
set /p target=请输入目标URL: 
set /p conn=请输入并发连接数 [100]: 
set /p req=请输入每个连接的请求数 [100]: 
set /p delay=请输入请求间隔(ms) [10]: 
set /p method=请输入请求方法 [GET]: 
if "%conn%"=="" set conn=100
if "%req%"=="" set req=100
if "%delay%"=="" set delay=10
if "%method%"=="" set method=GET
echo.
echo 测试配置:
echo - 目标: %target%
echo - 并发连接: %conn%
echo - 请求数: %req%
echo - 延迟: %delay%ms
echo - 方法: %method%
echo.
echo 按任意键开始测试，或关闭此窗口取消...
pause >nul
node ddos-simulator.js -u %target% -c %conn% -r %req% -d %delay% -m %method%
echo.
echo 测试完成
echo 按任意键返回主菜单...
pause >nul
goto menu
:end
echo 感谢使用DDoS模拟测试工具
timeout /t 3 >nul
exit 
