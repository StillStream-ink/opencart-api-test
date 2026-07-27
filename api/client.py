import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class APIClient:
    """OpenCart API 统一客户端，管理 Session 和 Cookie"""

    BASE_URL = "http://127.0.0.1/opencart"

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "application/json, text/javascript, */*; q=0.01",
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type": "application/x-www-form-urlencoded"
        })
        # 设置重试策略
        retry = Retry(total=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)

    def get(self, path: str, params=None, **kwargs):
        url = f"{self.BASE_URL}{path}"
        return self.session.get(url, params=params, **kwargs)

    def post(self, path: str, data=None, **kwargs):
        url = f"{self.BASE_URL}{path}"
        return self.session.post(url, data=data, **kwargs)

    def set_cookie(self, name: str, value: str):
        """设置 Cookie"""
        self.session.cookies.set(name, value)

    def get_cookie(self, name: str):
        """获取 Cookie"""
        return self.session.cookies.get(name)

    def clear_cookies(self):
        """清除所有 Cookie"""
        self.session.cookies.clear()