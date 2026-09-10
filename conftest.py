import re
import pytest
from api.client import APIClient
from data.test_data import TEST_USER, validate_test_data

# 模块加载时自动校验测试数据完整性
validate_test_data()


@pytest.fixture
def api_client():
    """登录 OpenCart 4 并返回带 customer_token 的客户端"""
    client = APIClient()

    # 1. GET 登录页，拿 login_token
    login_page = client.get("/index.php?route=account/login&language=en-gb")
    m = re.search(r'login_token=([a-f0-9]+)', login_page.text)
    assert m, "未找到 login_token，请检查登录页 HTML"
    login_token = m.group(1)

    # 2. POST 登录，拿 redirect URL
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


@pytest.fixture
def guest_client():
    """游客客户端，不登录"""
    return APIClient()