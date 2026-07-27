import pytest
from api.client import APIClient


@pytest.fixture
def api_client():
    """提供 API 客户端 fixture"""
    client = APIClient()
    # 登录
    client.post(
        "/index.php?route=account/login.login",
        data={"email": "testuser01@demo.local", "password": "Test@123456"}
    )
    return client


@pytest.fixture
def guest_client():
    """未登录客户端"""
    return APIClient()