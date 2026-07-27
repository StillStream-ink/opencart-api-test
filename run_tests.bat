@echo off
chcp 65001 > nul
echo ==========================================
echo   OpenCart API 测试 + Allure 报告生成
echo ==========================================
echo.

echo [1] 运行测试...
pytest tests/ -v --alluredir=./allure-results

echo [2] 检查历史数据...
if not exist "./allure-results/history" (
    echo 未找到历史数据，首次运行，跳过合并
    mkdir ./allure-results/history 2>nul
)

echo [3] 生成 Allure 报告...
allure generate ./allure-results -o ./allure-report --clean

echo [4] 保存历史数据...
if exist "./allure-report/history" (
    xcopy /E /Y /I ./allure-report/history ./allure-results/history > nul
    echo 历史数据已保存
) else (
    echo 未生成历史数据
)

echo.
echo ==========================================
echo   报告已生成，正在打开...
echo ==========================================

allure open ./allure-report

pause