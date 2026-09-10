import os

#  测试账号 
TEST_USER = {
    "email": "testuser01@demo.local",
    "password": "Test@123456",
}

# 商品数据 
PRODUCTS = {
    "macbook": {
        "product_id": 43,
        "name": "MacBook",
        "price": "$602.00",
    },
    "iphone": {
        "product_id": 40,
        "name": "iPhone",
        "price": "$123.20",
    },
}

# 分类数据 
CATEGORIES = {
    "desktops": "20",
}


# 数据完整性校验 
def validate_test_data():
    """校验测试数据完整性，避免空值导致用例误报"""
    assert TEST_USER.get("email"), "TEST_USER.email 不能为空"
    assert TEST_USER.get("password"), "TEST_USER.password 不能为空"
    assert PRODUCTS, "PRODUCTS 不能为空"
    assert CATEGORIES, "CATEGORIES 不能为空"
    for key, item in PRODUCTS.items():
        assert item.get("product_id"), f"PRODUCTS[{key}].product_id 不能为空"
        assert item.get("name"), f"PRODUCTS[{key}].name 不能为空"
    for key, value in CATEGORIES.items():
        assert value, f"CATEGORIES[{key}] 不能为空"