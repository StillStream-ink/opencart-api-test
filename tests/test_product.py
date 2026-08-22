import allure
from api.product_api import ProductAPI
from data.test_data import PRODUCTS, CATEGORIES


@allure.epic("OpenCart 接口测试")
@allure.feature("商品浏览接口")
class TestProductAPI:

    @allure.story("商品详情")
    @allure.title("TC-API-PROD-001: 查询有效商品详情")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_product_detail_success(self):
        api = ProductAPI()
        resp = api.get_product_detail(PRODUCTS["macbook"]["product_id"])
        assert resp.status_code == 200
        assert PRODUCTS["macbook"]["name"] in resp.text

    @allure.story("商品列表")
    @allure.title("TC-API-PROD-004: 查询有效分类商品列表")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_product_category_success(self):
        api = ProductAPI()
        resp = api.get_product_category(CATEGORIES["desktops"])
        assert resp.status_code == 200
        assert "Desktops" in resp.text

    @allure.story("搜索商品")
    @allure.title("TC-API-PROD-006: 搜索有效关键词")
    @allure.severity(allure.severity_level.CRITICAL)
    def test_search_success(self):
        api = ProductAPI()
        resp = api.search_product("Mac")
        assert resp.status_code == 200
        assert PRODUCTS["macbook"]["name"] in resp.text