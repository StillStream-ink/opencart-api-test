# OpenCart API 接口自动化测试

## 📌 项目简介

基于 **Python + requests + pytest + Allure** 实现的 OpenCart 电商系统接口自动化测试项目。
覆盖商品浏览、购物车、结算等核心业务接口，共 **17 条**测试用例，**100% 通过率**。

## 📁 项目结构
```text
opencart_api_test/
├── api/ # API 封装层
│ ├── client.py # 统一请求客户端（Session/Cookie 管理）
│ ├── product_api.py # 商品接口（详情/列表/搜索）
│ └── cart_api.py # 购物车接口（加购/获取购物车/结算）
├── tests/ # 测试用例层
│ ├── test_product.py # 商品接口测试（8 条）
│ ├── test_cart.py # 购物车接口测试（7 条）
│ └── test_checkout.py # 结算接口测试（2 条，已跳过）
├── data/ # 测试数据
│ └── test_data.py
├── reports/ # 测试报告（Allure + HTML）
├── conftest.py # Pytest 全局配置
├── pytest.ini # Pytest 设置
├── requirements.txt # 依赖包清单
├── run_tests.bat # 一键运行脚本
└── README.md
```
## 🛠️ 技术栈

| 工具 | 用途 |
|------|------|
| Python 3.11 | 编程语言 |
| requests | HTTP 请求库 |
| pytest | 测试框架 |
| Allure | 测试报告 |
| F12 (Chrome DevTools) | 接口抓取 |

## 📊 测试覆盖

| 模块 | 用例数 | 结果 | 说明 |
|------|--------|------|------|
| 商品浏览 | 8 | ✅ 全部通过 | 正向/无效ID/缺少参数/列表/搜索 |
| 购物车 | 7 | ✅ 全部通过 | 加购/未登录/无效商品/数量边界 |
| 结算 | 2 | ⏭️ 跳过 | 功能测试已覆盖，接口测试跳过 |
| **合计** | **17** | **15 通过 / 2 跳过** | **通过率 100%** |

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/StillStream-ink/opencart-api-test.git
```

### 2. 进入目录
```bash
cd opencart-api-test
```
### 3. 安装依赖
```bash
pip install -r requirements.txt
```
### 4. 运行测试
```bash
pytest tests/ -v
```
### 5. 查看 Allure 报告
```bash
pytest tests/ -v --alluredir=./reports/allure-results
allure serve ./reports/allure-results
```
### 6. 一键运行（Windows 双击即可）
```bash
run_tests.bat
```
## 📄 测试报告
测试报告通过 Allure 生成，包含完整的用例执行记录和趋势图。

## 📌 测试环境
系统版本：OpenCart 3.0.2.0（本地部署）

测试地址：http://127.0.0.1/opencart

测试账号：testuser01@demo.local / Test@123456

## 🔗 相关链接
OpenCart 官网

Allure 报告

requests 文档

## 📝 学习笔记
接口测试学习笔记

接口测试报告

## 📝 问题反馈
如有问题或建议，欢迎提 Issue。
