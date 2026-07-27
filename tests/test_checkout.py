import allure
import pytest
from api.cart_api import CartAPI
from api.client import APIClient


@allure.epic("OpenCart 接口测试")
@allure.feature("结算接口")
class TestCheckoutAPI:

    @allure.story("结算")
    @allure.title("TC-API-CART-008: 正常结算")
    @allure.severity(allure.severity_level.CRITICAL)
    @pytest.mark.skip(reason="OpenCart结算接口依赖复杂会话状态，已在功能测试中覆盖")
    def test_checkout_success(self):
        pass

    @allure.story("结算")
    @allure.title("TC-API-CART-009: 地址不完整结算")
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.skip(reason="OpenCart结算接口依赖复杂会话状态，已在功能测试中覆盖")
    def test_checkout_address_incomplete(self):
        pass