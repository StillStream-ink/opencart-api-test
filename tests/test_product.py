import allure
import pytest
from api.product_api import ProductAPI


@allure.epic("OpenCart 接口测试")           # 项目级：最高层级
@allure.feature("商品浏览接口")             # 模块级：测试大类
class TestProductAPI:

    @allure.story("商品详情")               # 功能级：具体功能点
    @allure.title("TC-API-PROD-001: 查询有效商品详情")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_product_detail_success(self):
        api = ProductAPI()
        resp = api.get_product_detail(43)
        assert resp.status_code == 200
        assert "MacBook" in resp.text

    @allure.story("商品列表")
    @allure.title("TC-API-PROD-004: 查询有效分类商品列表")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_product_category_success(self):
        api = ProductAPI()
        resp = api.get_product_category(20)
        assert resp.status_code == 200
        assert "Desktops" in resp.text

    @allure.story("搜索商品")
    @allure.title("TC-API-PROD-006: 搜索有效关键词")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_search_success(self):
        api = ProductAPI()
        resp = api.search_product("Mac")
        assert resp.status_code == 200
        assert "MacBook" in resp.text