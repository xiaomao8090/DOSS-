@echo off
chcp 65001 >nul
REM 设置控制台编码为UTF-8
REM 解决中文显示乱码问题

echo ===== DDoS模拟测试工具编码修复工具 =====
echo 此工具将修复批处理文件中文显示乱码问题
echo.

set "FILES_TO_FIX=run-ddos-test.bat run-advanced-test.bat run-test-suite.bat"

for %%f in (%FILES_TO_FIX%) do (
    if exist %%f (
        echo 处理文件: %%f
        
        REM 创建临时文件
        type %%f > %%f.tmp
        
        REM 在文件开头添加编码设置
        echo @echo off> %%f
        echo chcp 65001 ^>nul>> %%f
        echo REM 使用UTF-8编码以正确显示中文>> %%f
        echo.>> %%f
        
        REM 添加原文件内容（第2行开始，跳过原有的@echo off）
        for /f "skip=1 delims=" %%i in (%%f.tmp) do (
            echo %%i>> %%f
        )
        
        REM 删除临时文件
        del %%f.tmp
        
        echo [完成] 已修复 %%f
    ) else (
        echo [警告] 文件不存在: %%f
    )
)

echo.
echo 处理完成！现在你的批处理文件应该能正确显示中文了。
echo 如果你创建新的批处理文件，请在文件开头添加以下内容：
echo @echo off
echo chcp 65001 ^>nul
echo.
echo 按任意键退出...
pause >nul
exit 