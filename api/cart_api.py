from .client import APIClient


class CartAPI:
    def __init__(self, client: APIClient = None):
        self.client = client or APIClient()

    def add_to_cart(self, product_id: int, quantity: int = 1):
        """加购"""
        return self.client.post(
            "/index.php?route=checkout/cart.add",
            data={"product_id": product_id, "quantity": quantity}
        )

    def get_cart(self):
        """获取购物车"""
        return self.client.get("/index.php?route=checkout/cart")

    def confirm_order(self, payload: dict):
        """确认订单"""
        return self.client.post(
            "/index.php?route=checkout/confirm",
            data=payload
        )