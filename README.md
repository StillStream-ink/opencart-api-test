# OpenCart API 接口自动化测试

## 📌 项目简介

基于 Python + requests + pytest + Allure 实现的 OpenCart 电商系统全栈测试工程实践项目，覆盖**接口自动化、UI 自动化、性能压测、Shell 运维工具包**四大模块，并集成 JMeter + Locust 双工具性能压测与飞书自动通知能力。

- **接口自动化**：采用 **数据驱动 + API 层封装 + Fixture 依赖注入** 的分层架构，覆盖商品浏览、购物车等核心业务接口
- **UI 自动化**：基于 Playwright + POM 四层分层架构，用例执行失败自动截图，提升问题定位效率
- **性能压测**：Locust + JMeter 双工具梯度并发压测，采集响应时间、TPS、失败率等核心指标
- **Shell 运维工具包**：WSL2 环境下编写，包含独立功能脚本（巡检/数据库定时备份/日志轮转）与交互式一体化菜单工具 `opencart_toolkit.sh`

> **测试环境**：OpenCart 4.x（本地 XAMPP 部署，Apache + MariaDB）
> **测试地址**：http://127.0.0.1/opencart
> **Shell 运行环境**：WSL2（Ubuntu）

---

## 📁 项目结构

```text
opencart_api_test/
├── api/                    # API 业务封装层
│   ├── __init__.py         # Python包标识，空文件，用于模块import导入
│   ├── client.py           # 统一 HTTP 客户端（Session/customer_token/重试/超时/5xx校验）
│   ├── product_api.py      # 商品接口（详情/列表/搜索）
│   └── cart_api.py         # 购物车接口（加购/查看）
├── tests/                  # 测试用例层（只做断言，不直接发请求）
│   ├── test_product.py     # 商品浏览接口测试
│   ├── test_cart.py        # 购物车接口测试
│   └── test_checkout.py    # 结算接口测试（已跳过，由 UI 覆盖）
├── data/                   # 测试数据中心
│   └── test_data.py        # 商品/分类/账号等测试数据 + 完整性校验
├── shell/                  # Shell 运维脚本（WSL2 环境）
│   ├── db_backup/          # 数据库备份产物目录【git忽略，运行自动生成，存放*.sql备份】
│   ├── backup_opencart.sh  # 数据库备份脚本（远程备份Windows MariaDB，带执行结果判断）
│   ├── db_backup.sh        # 旧版备份脚本
│   ├── daily_check.sh      # 日常巡检脚本
│   ├── rotate_logs.sh      # 日志轮转脚本
│   ├── opencart_toolkit.sh # 一体化交互式运维工具包
│   └── backup_run.log      # 备份执行日志【git忽略，运行自动生成】
├── docs/                   # 项目文档与截图
│   ├── images/             # 全部项目运行截图
│   ├── database_analysis_report.md  # 数据库业务数据分析报告
│   └── project_report.md   # 项目完整综合报告
├── jmeter/                 # JMeter 压测脚本
│   ├── opencart_category_50vu.jmx
│   └── opencart_category_100vu.jmx
├── reports/                # 压测与测试报告存放目录
│   ├── locust_*_stats.csv  # Locust 压测数据【保留，作为压测证据】
│   ├── allure-*/           # Allure 报告【git忽略】
│   └── report.html         # pytest-html 报告【git忽略】
├── conftest.py             # Pytest 全局 Fixture（OpenCart 4 三步登录）
├── locustfile.py           # Locust 压测脚本
├── send_feishu_report.py   # 飞书通知推送脚本
├── pytest.ini              # Pytest 配置文件
├── requirements.txt        # Python 依赖清单
├── run_tests.bat           # 仅运行接口自动化
├── run_jmeter_auto.bat     # 一键运行 JMeter 梯度压测
├── run_all.bat             # 全家桶：接口 + Locust + JMeter + 飞书推送
├── .gitignore              # git忽略配置（备份sql、日志、运行产物等）
└── README.md
```

### 📝 目录说明

 1. **纳入版本管理（提交 Git）**：py 源码、sh 脚本、jmx 压测脚本、md 文档、bat 启动脚本、**Locust 压测 CSV 数据**；
2. **运行自动生成，Git 忽略不上传**：`shell/db_backup/*.sql`、`shell/*.log`、`reports/` 下的 Allure 报告与 pytest-html 报告，属于执行产物，每次运行会发生变化，不提交仓库；
3. `api/__init__.py` 为空文件，作用是把 api 文件夹声明为 Python 包，保障模块 import 导入兼容性。

---

## 🛠️ 技术栈


| 工具 / 库        | 用途                                          | 版本        |
| ------------- | ------------------------------------------- | --------- |
| Python        | 编程语言                                        | 3.11+     |
| requests      | HTTP 请求库                                    | 2.31+     |
| pytest        | 测试框架                                        | 7.4+      |
| allure-pytest | 测试报告与用例分级                                   | 2.16+     |
| pytest-html   | HTML 测试报告                                   | 4.1+      |
| Locust        | 性能压测（代码化）                                   | 2.20+     |
| JMeter        | 性能压测（梯度加压）                                  | 5.6.3     |
| Playwright    | UI 自动化测试（POM 分层）                            | 1.40+     |
| Shell / WSL2  | 运维脚本（巡检 / 数据库备份 / crontab 定时任务 / 日志 / 一体化工具） | Bash 5.0+ |

---

## ✨ 设计亮点

### 1. 三层架构，职责分离

```
测试层(tests) → 业务 API 层(api) → HTTP 客户端层(client)
```

- **client.py**：
  - 统一管理 Session、Cookie、请求头、重试策略（5xx 自动重试 3 次）
  - 配置 `DEFAULT_TIMEOUT=10` 防止请求挂死
  - 对 5xx 响应显式抛异常（`_check_status`），避免用例拿到错误响应体后才失败
  - 维护 `customer_token` 并自动附加到已登录请求（`_attach_token`），适配 OpenCart 4 的登录态机制
- **product_api.py / cart_api.py**：封装业务接口，支持客户端依赖注入
- **tests/**：只关注业务场景断言，不直接处理 HTTP 细节

### 2. Fixture 管理登录态（OpenCart 4 三步登录）

`conftest.py` 提供 `api_client` fixture，自动完成 **OpenCart 4 的三步登录流程**：

```python
@pytest.fixture
def api_client():
    client = APIClient()

    # 1. GET 登录页，拿一次性 login_token
    login_page = client.get("/index.php?route=account/login&language=en-gb")
    m = re.search(r'login_token=([a-f0-9]+)', login_page.text)
    assert m, "未找到 login_token，请检查登录页 HTML"
    login_token = m.group(1)

    # 2. POST 到 login.login（AJAX 接口），拿 redirect URL
    resp = client.post(
        f"/index.php?route=account/login.login&language=en-gb&login_token={login_token}",
        data=TEST_USER,
        headers={"X-Requested-With": "XMLHttpRequest"},
    )
    data = resp.json()
    assert "redirect" in data, f"登录失败，响应：{resp.text}"

    # 3. 从 redirect URL 提取 customer_token，保存到 client
    m2 = re.search(r'customer_token=([a-f0-9]+)', data["redirect"])
    assert m2, f"未找到 customer_token，redirect：{data['redirect']}"
    client.customer_token = m2.group(1)

    # 4. 验证登录成功
    verify = client.get("/index.php?route=account/account&language=en-gb")
    assert "account/login" not in verify.url, f"登录失败，被重定向到：{verify.url}"

    return client
```

**OpenCart 4 登录的关键设计**：

- **点分路由**：`account/login.login` 是 AJAX 接口，与页面路由 `account/login` 区分
- **一次性 token**：`login_token` 嵌在登录页 form 的 `action` 属性里，每次 GET 都会重新生成
- **登录态维持**：不靠 Cookie，而是靠 `customer_token` URL 参数。Client 层通过 `_attach_token()` 自动为所有已登录请求附加该参数

测试用例通过参数注入直接使用，**消除重复登录代码**；登录失败在 fixture 阶段直接报错，避免产生误导性的用例失败。

### 3. 数据与用例分离

所有测试数据集中维护在 `data/test_data.py`：

- 商品信息（ID、名称、价格）
- 分类信息（path）
- 测试账号

修改一处，全局生效，便于维护和多环境切换。模块加载时通过 `validate_test_data()` 校验数据完整性，避免空值导致用例误报。

### 4. 环境配置解耦

`BASE_URL` 支持通过环境变量注入，默认本地地址：

```
BASE_URL = os.getenv("OPENCART_BASE_URL", "http://127.0.0.1/opencart")
```

支持本地开发、CI/CD 流水线、不同测试环境无缝切换。

### 5. Allure 报告分级

采用 `@allure.epic / feature / story` 三级注解，生成结构化的测试报告：

- **epic**：项目级（OpenCart 接口测试）
- **feature**：模块级（商品浏览 / 购物车 / 结算）
- **story**：功能级（商品详情 / 加购 / 搜索）

### 6. 性能压测 + 飞书通知

- **JMeter**：50/100 并发梯度加压，生成 HTML 报告
- **Locust**：15/25 并发代码化压测，生成 CSV 数据（保留在仓库作为压测证据）
- **飞书通知**：测试完成后自动解析报告，推送结构化消息到飞书群，包含总请求数、失败率、平均响应时间、P95、吞吐量等关键指标

### 7. UI 自动化（Playwright + POM 四层架构）

- 基于 **POM（Page Object Model）** 四层分层架构，页面元素、业务行为、测试用例、公共基类彻底分离
- 用例执行失败**自动截图**，保留现场证据，提升问题定位效率
- 覆盖商品浏览、加购、结算等核心 UI 业务流程

### 8. Shell 运维工具包（WSL2）

> ✨ 数据库定时备份能力：接口、性能测试会产生脏数据，通过 mysqldump 远程备份 Windows 上 MariaDB；crontab 配置每日凌晨 2 点自动备份；数据污染后可导入 SQL 快速恢复干净测试环境。

- **独立功能脚本**：
  - `daily_check.sh`：服务巡检
  - `backup_opencart.sh`：远程备份 Windows 端 OpenCart 数据库，带成功失败判断，自动生成带时间戳备份文件至 `db_backup` 目录
  - `rotate_logs.sh`：日志轮转切割

- **crontab 定时任务示例（WSL2）**

```
# 每天凌晨 02:00 执行数据库备份，输出日志写入 backup_run.log
0 2 * * * /mnt/e/OpenCart测试项目_20260717/opencart_api_test/shell/backup_opencart.sh >> /mnt/e/OpenCart测试项目_20260717/opencart_api_test/shell/backup_run.log 2>&1
```

> ⚠️ 重要提示：WSL2 默认不会后台常驻 cron 服务，关闭 WSL 终端定时任务不会自动运行；该配置适合项目演示，部署真实 Linux 服务器启动 cron 服务后可自动执行。

- **一体化交互式工具** `opencart_toolkit.sh`：菜单式操作，支持快速 / 完整健康检查、日志查看与分析、数据库备份、旧备份自动清理（保留 7 天）、系统状态查看、一键生成综合报告、一键全套执行

> ⚠️ **环境说明**：Apache、MySQL (MariaDB) 部署在 Windows XAMPP，WSL 无法读取 Windows 系统进程，因此进程与端口检测项会显示未运行；数据库备份、日志解析、报告生成等核心功能不受影响。

---

## 📊 测试覆盖

| 模块     | 用例数   | 结果              | 说明                  |
| ------ | ----- | --------------- | ------------------- |
| 商品浏览   | 3     | ✅ 全部通过          | 详情查询、分类列表、关键词搜索     |
| 购物车    | 2     | ✅ 全部通过          | 正常加购、获取购物车（依赖登录态）   |
| 结算     | 2     | ⏭️ 跳过           | 依赖复杂前端会话，由 UI 自动化覆盖 |
| **合计** | **7** | **5 通过 / 2 跳过** | **通过率 100%**        |

### 性能压测（参考数据）

| 工具     | 并发数 | 总请求数    | 失败率   | 平均响应时间    | P95    |
| ------ | --- | ------- | ----- | --------- | ------ |
| JMeter | 50  | 103,620 | 0.00% | 25.03 ms  | 110 ms |
| JMeter | 100 | 109,068 | 0.00% | 47.69 ms  | 264 ms |
| Locust | 15  | 836     | 0     | 188.24 ms | —      |
| Locust | 25  | 1,355   | 0     | 198.46 ms | —      |

---

## 🚀 快速开始

### 前置条件

1. 本地部署 OpenCart（XAMPP）
2. 启动 Apache + MySQL (MariaDB) 服务
3. 确认可访问 <http://127.0.0.1/opencart>
4. **修改 `data/test_data.py` 中的 `TEST_USER` 为你的真实账号**

### 1. 克隆项目

```
git clone https://github.com/StillStream-ink/opencart-api-test.git
cd opencart-api-test
```

### 2. 创建虚拟环境（推荐）

```
python -m venv .venv
.venv\Scripts\activate
```

### 3. 安装依赖

```
pip install -r requirements.txt
```

### 4. 运行测试

```
# 基础运行
pytest tests/ -v

# 生成 HTML 报告
pytest tests/ -v --html=reports/report.html --self-contained-html

# 生成 Allure 报告
pytest tests/ -v --alluredir=./reports/allure-results
allure serve ./reports/allure-results
```

### 5. 一键运行（Windows）

双击 `run_tests.bat` 即可执行全部测试并生成 Allure 报告（含历史趋势）。

### 6. 运行 Locust 压测

```
locust -f locustfile.py --host=http://127.0.0.1/opencart --users 15 --spawn-rate 5 --run-time 2m --headless --csv=reports/locust_15user
```

### 7. 运行 JMeter 压测

```
jmeter -n -t jmeter/opencart_category_50vu.jmx -l jmeter/result_50vu.jtl -e -o jmeter/report_50vu -f
```

### 8. 一键运行全家桶

双击 `run_all.bat`，自动顺序执行：接口自动化 → Locust → JMeter → 飞书通知。

### 9. 运行 Shell 运维工具包（WSL2 环境）

```
cd shell
chmod +x backup_opencart.sh opencart_toolkit.sh

# 手动执行数据库备份
./backup_opencart.sh

# 打开一体化菜单工具
./opencart_toolkit.sh
```

执行后弹出交互式主菜单，输入数字 0-9 选择对应功能：

| 选项 | 功能                   |
| -- | -------------------- |
| 1  | 快速健康检查               |
| 2  | 完整健康检查 + 报告生成        |
| 3  | 查看错误日志（最近 20 条）      |
| 4  | 日志分析统计               |
| 5  | 备份数据库                |
| 6  | 清理旧备份（保留 7 天）        |
| 7  | 查看系统状态               |
| 8  | 生成综合报告               |
| 9  | 一键执行全部（检查 + 备份 + 报告） |
| 0  | 退出                   |

> ⚠️ 必须在 WSL2 终端中执行，不可在 Windows 直接双击 `.sh` 文件。💡 crontab 定时任务配置参考：`crontab -e` 编辑定时；`crontab -l` 查看已配置任务。

---

## 📄 测试报告示例

报告包含用例执行状态、耗时、历史趋势、环境信息等。Allure 与 pytest-html 报告为运行产物，不上传 Git，本地跑测试即可实时生成。

---

## 🔧 环境变量配置

| 变量名                 | 说明            | 默认值                         |
| ------------------- | ------------- | --------------------------- |
| `OPENCART_BASE_URL` | OpenCart 服务地址 | `http://127.0.0.1/opencart` |

示例：

```
# PowerShell
$env:OPENCART_BASE_URL="http://192.168.1.100:8080/opencart"
pytest tests/ -v
```

---

## 📢 飞书通知配置

1. 在飞书群聊中添加**自定义机器人**，获取 Webhook 地址
2. 修改 `send_feishu_report.py` 中的 `FEISHU_WEBHOOK` 变量
3. 运行 `python send_feishu_report.py` 测试通知是否正常发送

---

## 📝 相关链接

- [OpenCart 官网](https://www.opencart.com)
- [pytest 官方文档](https://docs.pytest.org)
- [requests 官方文档](https://docs.python-requests.org)
- [Allure Report](https://allurereport.org)
- [Locust 官方文档](https://locust.io)
- [JMeter 官方文档](https://jmeter.apache.org)

---

## 📄 系列文章

- [接口自动化测试实战（pytest + Allure + 数据驱动）](https://juejin.cn/post/7679507799504142386)
- [UI 自动化测试实战（Playwright + POM + 失败自动截图）](https://juejin.cn/post/7681688916479344686)
- [OpenCart 性能压测复盘（JMeter + Locust 双工具实操）](https://juejin.cn/post/7682603130693992494)
- [测试环境工程化（WSL Shell 运维 + 数据库备份 + MySQL 数据校验）](https://juejin.cn/post/7683416110918991918)

---

## 📌 作者

- GitHub: [@StillStream-ink](https://github.com/StillStream-ink)
- 项目地址: [opencart-api-test](https://github.com/StillStream-ink/opencart-api-test)
