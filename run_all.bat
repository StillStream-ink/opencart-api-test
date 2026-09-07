@echo off
chcp 65001 >nul
title OpenCart 全量测试 (接口自动化 + 性能压测)
cd /d "%~dp0"

echo ============================================================
echo  OpenCart 全量测试启动 (接口 + Locust + JMeter)
echo  开始时间: %date% %time%
echo ============================================================

REM ---------- 第 1 步：接口自动化测试 ----------
echo.
echo [1/5] 正在执行 接口自动化测试 (Pytest) ...
pytest tests/ -v --alluredir=./allure-results
if %errorlevel% neq 0 (
    echo [警告] 接口自动化存在失败用例，但继续执行后续压测...
) else (
    echo [成功] 接口自动化全部通过！
)

REM ---------- 第 2 步：生成 Allure 报告 ----------
echo.
echo [2/5] 正在生成 Allure 报告 ...
allure generate ./allure-results -o ./allure-report --clean
echo Allure 报告已生成: allure-report/index.html

REM ---------- 第 3 步：Locust 无头压测 ----------
echo.
echo [3/5] 正在执行 Locust 压测 (15并发, 运行2分钟) ...
if not exist reports mkdir reports
locust -f locustfile.py --host=http://127.0.0.1/opencart --users 15 --spawn-rate 5 --run-time 2m --headless --csv=reports/locust_15user
echo Locust 报告已保存至: reports/locust_15user_stats.csv

REM ---------- 第 4 步：JMeter 无头压测 ----------
echo.
echo [4/5] 正在执行 JMeter 压测 (50并发) ...
D:\apache-jmeter-5.6.3\bin\jmeter -n -t jmeter/opencart_category_50vu.jmx -l jmeter/result_50vu.jtl -e -o jmeter/report_50vu -f
echo JMeter 报告已生成: jmeter/report_50vu/index.html

REM ---------- 第 5 步：推送飞书通知 ----------
echo.
echo [5/5] 正在推送飞书通知 ...
python send_feishu_report.py

REM ---------- 收尾 ----------
echo.
echo ============================================================
echo  全量测试执行完毕！
echo  结束时间: %date% %time%
echo ============================================================
echo  报告清单：
echo    1. Allure  : allure-report/index.html
echo    2. Locust  : reports/locust_15user_stats.csv
echo    3. JMeter  : jmeter/report_50vu/index.html
echo    4. 飞书通知: 已发送
echo ============================================================
pause