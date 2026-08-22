# OpenCart API 接口自动化测试

## 📌 项目简介

基于 **Python + requests + pytest + Allure** 实现的 OpenCart 电商系统接口自动化测试项目。

采用 **数据驱动 + Page Object（API 层）+ Fixture 依赖注入** 的分层架构，覆盖商品浏览、购物车、结算等核心业务接口。

> **测试环境**：OpenCart 3.0.2.0（本地 XAMPP 部署）  
> **测试地址**：http://127.0.0.1/opencart

---

## 📁 项目结构

```text
opencart_api_test/
├── api/                    # API 业务封装层（Page Object 思想）
│   ├── client.py           # 统一 HTTP 客户端（Session/Cookie/重试）
│   ├── product_api.py      # 商品接口（详情/列表/搜索）
│   └── cart_api.py         # 购物车接口（加购/查看/结算）
├── tests/                  # 测试用例层（只做断言，不直接发请求）
│   ├── test_product.py     # 商品浏览接口测试
│   ├── test_cart.py        # 购物车接口测试
│   └── test_checkout.py    # 结算接口测试（复杂会话，已跳过）
├── data/                   # 测试数据中心（数据与用例分离）
│   └── test_data.py        # 商品/分类/账号等测试数据
├── reports/                # 测试报告输出（HTML + Allure）
├── conftest.py             # Pytest 全局 Fixture（登录态自动管理）
├── pytest.ini              # Pytest 配置文件
├── requirements.txt        # Python 依赖
├── run_tests.bat           # Windows 一键运行脚本
└── README.md
```

---

## 🛠️ 技术栈

| 工具/库 | 用途 | 版本 |
|---------|------|------|
| Python | 编程语言 | 3.11+ |
| requests | HTTP 请求库 | 2.31+ |
| pytest | 测试框架 | 7.4+ |
| allure-pytest | 测试报告与用例分级 | 2.16+ |
| pytest-html | HTML 测试报告 | 4.1+ |

---

## ✨ 设计亮点

### 1. 三层架构，职责分离
```
测试层(tests) → 业务 API 层(api) → HTTP 客户端层(client)
```
- **client.py**：统一管理 Session、Cookie、请求头、重试策略
- **product_api.py / cart_api.py**：封装业务接口，支持依赖注入
- **tests/**：只关注业务场景断言，不直接处理 HTTP 细节

### 2. Fixture 管理登录态
`conftest.py` 提供 `api_client` fixture，自动完成登录并返回带 Cookie 的客户端：
```python
@pytest.fixture
def api_client():
    client = APIClient()
    client.post("/index.php?route=account/login.login", data=TEST_USER)
    return client
```
测试用例通过参数注入直接使用，**消除重复登录代码**。

### 3. 数据与用例分离
所有测试数据集中维护在 `data/test_data.py`：
- 商品信息（ID、名称、价格）
- 分类信息（path、名称）
- 测试账号

修改一处，全局生效，便于维护和多环境切换。

### 4. 环境配置解耦
`BASE_URL` 支持通过环境变量注入，默认本地地址：
```python
BASE_URL = os.getenv("OPENCART_BASE_URL", "http://127.0.0.1/opencart")
```
支持本地开发、CI/CD 流水线、不同测试环境无缝切换。

### 5. Allure 报告分级
采用 `@allure.epic / feature / story` 三级注解，生成结构化的测试报告：
- **epic**：项目级（OpenCart 接口测试）
- **feature**：模块级（商品浏览 / 购物车 / 结算）
- **story**：功能级（商品详情 / 加购 / 搜索）

---

## 📊 测试覆盖

| 模块 | 用例数 | 结果 | 说明 |
|------|--------|------|------|
| 商品浏览 | 3 | ✅ 全部通过 | 详情查询、分类列表、关键词搜索 |
| 购物车 | 2 | ✅ 全部通过 | 正常加购、获取购物车 |
| 结算 | 2 | ⏭️ 跳过 | 依赖复杂前端会话，由 UI 自动化覆盖 |
| **合计** | **7** | **5 通过 / 2 跳过** | **通过率 100%** |

---

## 🚀 快速开始

### 前置条件
1. 本地部署 OpenCart（XAMPP/WAMP）
2. 启动 Apache + MySQL 服务
3. 确认可访问 http://127.0.0.1/opencart

### 1. 克隆项目
```bash
git clone https://github.com/你的用户名/opencart-api-test.git
cd opencart-api-test
```

### 2. 创建虚拟环境（推荐）
```bash
python -m venv .venv
.venv\Scripts\activate
```

### 3. 安装依赖
```bash
pip install -r requirements.txt
```

### 4. 运行测试
```bash
# 基础运行
pytest tests/ -v

# 生成 HTML 报告
pytest tests/ -v --html=reports/report.html

# 生成 Allure 报告
pytest tests/ -v --alluredir=./reports/allure-results
allure serve ./reports/allure-results
```

### 5. 一键运行（Windows）
双击 `run_tests.bat` 即可执行全部测试并生成 HTML 报告。

---

## 📄 测试报告示例

> 报告包含用例执行状态、耗时、错误日志、历史趋势等。

---

## 🔧 环境变量配置

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `OPENCART_BASE_URL` | OpenCart 服务地址 | `http://127.0.0.1/opencart` |

示例：
```bash
# PowerShell
$env:OPENCART_BASE_URL="http://192.168.1.100:8080/opencart"
pytest tests/ -v
```

---

## 📝 相关链接

- [OpenCart 官网](https://www.opencart.com)
- [pytest 官方文档](https://docs.pytest.org)
- [requests 官方文档](https://docs.python-requests.org)
- [Allure Report](https://allurereport.org)

---

## 📌 作者

- GitHub: [@你的用户名](https://github.com/你的用户名)
- 项目地址: [opencart-api-test](https://github.com/你的用户名/opencart-api-test)
