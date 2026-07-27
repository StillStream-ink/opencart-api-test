from .client import APIClient


class ProductAPI:
    def __init__(self, client: APIClient = None):
        self.client = client or APIClient()

    def get_product_detail(self, product_id: int):
        """商品详情"""
        return self.client.get(
            "/index.php?route=product/product",
            params={"product_id": product_id}
        )

    def get_product_category(self, path: int):
        """商品列表（按分类）"""
        return self.client.get(
            "/index.php?route=product/category",
            params={"path": path}
        )

    def search_product(self, keyword: str):
        """搜索商品"""
        return self.client.get(
            "/index.php?route=product/search",
            params={"search": keyword}
        )