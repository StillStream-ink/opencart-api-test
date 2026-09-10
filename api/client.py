import requests
import os
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class APIClient:
    """OpenCart API 统一客户端，管理 Session 和 Cookie"""

    BASE_URL = os.getenv("OPENCART_BASE_URL", "http://127.0.0.1/opencart")
    DEFAULT_TIMEOUT = 10  # 超时设置

    def __init__(self):
        self.session = requests.Session()
        self.customer_token = None  # 登录后保存，后续请求自动附加
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "application/json, text/javascript, */*; q=0.01",
            "Content-Type": "application/x-www-form-urlencoded"
        })
        # 设置重试策略：5xx 状态码自动重试 3 次
        retry = Retry(total=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)

    def _attach_token(self, path: str) -> str:
        """已登录时自动附加 customer_token"""
        if self.customer_token:
            sep = "&" if "?" in path else "?"
            return f"{path}{sep}customer_token={self.customer_token}"
        return path

    def _check_status(self, resp):
        """对 5xx 响应显式抛异常，避免用例拿到错误响应体后才失败"""
        if resp.status_code >= 500:
            raise requests.HTTPError(
                f"服务端错误 {resp.status_code}: {resp.url}\n响应体前 200 字: {resp.text[:200]}"
            )
        return resp

    def get(self, path: str, params=None, **kwargs):
        path = self._attach_token(path)
        url = f"{self.BASE_URL}{path}"
        kwargs.setdefault("timeout", self.DEFAULT_TIMEOUT)
        resp = self.session.get(url, params=params, **kwargs)
        return self._check_status(resp)

    def post(self, path: str, data=None, **kwargs):
        path = self._attach_token(path)
        url = f"{self.BASE_URL}{path}"
        kwargs.setdefault("timeout", self.DEFAULT_TIMEOUT)
        resp = self.session.post(url, data=data, **kwargs)
        return self._check_status(resp)

    def set_cookie(self, name: str, value: str):
        """设置 Cookie"""
        self.session.cookies.set(name, value)

    def get_cookie(self, name: str):
        """获取 Cookie"""
        return self.session.cookies.get(name)

    def clear_cookies(self):
        """清除所有 Cookie"""
        self.session.cookies.clear()