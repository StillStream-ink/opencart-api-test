from locust import HttpUser, task, between

class OpenCartWebUser(HttpUser):
    # 虚拟用户思考等待时间：1‑3秒随机
    wait_time = between(1, 3)

    def on_start(self):
        """每个虚拟用户启动：执行网页表单登录"""
        login_form = {
            "email": "test@test.com",
            "password": "123456"
        }
        # data=代表表单提交，不是json！网页登录接口地址
        self.client.post("/index.php?route=account/login", data=login_form, name="网页账号登录")

    @task(3)
    def browse_category(self):
        """浏览笔记本商品分类，权重3，访问更频繁"""
        self.client.get("/index.php?route=product/category&path=20", name="浏览笔记本分类页")

    @task(2)
    def view_goods_detail(self):
        """打开商品详情，权重2"""
        self.client.get("/index.php?route=product/product&product_id=42", name="查看商品详情id42")