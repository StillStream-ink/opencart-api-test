@echo off
chcp 65001 >nul
echo ========================================
echo OpenCart 性能压测自动执行 (JMeter)
echo ========================================

cd /d "%~dp0jmeter"

echo [1/3] 正在执行 50 并发压测...
D:\apache-jmeter-5.6.3\bin\jmeter -n -t opencart_category_50vu.jmx -l result_50vu.jtl -e -o report_50vu -f

echo [2/3] 正在执行 100 并发压测...
D:\apache-jmeter-5.6.3\bin\jmeter -n -t opencart_category_100vu.jmx -l result_100vu.jtl -e -o report_100vu -f

echo [3/3] 压测完成！报告已生成：
echo 50并发报告: %~dp0jmeter\report_50vu\index.html
echo 100并发报告: %~dp0jmeter\report_100vu\index.html

REM 保持窗口打开，等待用户按任意键
pause