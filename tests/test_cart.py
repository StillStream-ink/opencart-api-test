import allure
from api.cart_api import CartAPI
from data.test_data import PRODUCTS


@allure.epic("OpenCart 接口测试")
@allure.feature("购物车接口")
class TestCartAPI:

    @allure.story("加购")
    @allure.title("TC-API-CART-001: 正常加购")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_add_to_cart_success(self, api_client):
        api = CartAPI(api_client)
        resp = api.add_to_cart(PRODUCTS["macbook"]["product_id"], 1)
        assert resp.status_code == 200
        assert "Success" in resp.text

    @allure.story("获取购物车")
    @allure.title("TC-API-CART-006: 获取购物车（已登录）")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_get_cart_success(self, api_client):
        api = CartAPI(api_client)
        api.add_to_cart(PRODUCTS["macbook"]["product_id"], 1)
        resp = api.get_cart()
        assert resp.status_code == 200