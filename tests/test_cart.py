import allure
import pytest
from api.cart_api import CartAPI
from api.client import APIClient


@allure.epic("OpenCart 接口测试")
@allure.feature("购物车接口")
class TestCartAPI:

    @allure.story("加购")
    @allure.title("TC-API-CART-001: 正常加购")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_add_to_cart_success(self):
        client = APIClient()
        client.post(
            "/index.php?route=account/login.login",
            data={"email": "testuser01@demo.local", "password": "Test@123456"}
        )
        api = CartAPI(client)
        resp = api.add_to_cart(43, 1)
        assert resp.status_code == 200
        assert "Success" in resp.text

    @allure.story("获取购物车")
    @allure.title("TC-API-CART-006: 获取购物车（已登录）")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_get_cart_success(self):
        client = APIClient()
        client.post(
            "/index.php?route=account/login.login",
            data={"email": "testuser01@demo.local", "password": "Test@123456"}
        )
        api = CartAPI(client)
        api.add_to_cart(43, 1)
        resp = api.get_cart()
        assert resp.status_code == 200