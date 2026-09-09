-- ======================
-- 本地练习环境：自动化产生脏数据清理示例
-- 注意：仅本地测试环境使用，生产环境禁止直接执行DELETE
-- ======================

-- 1. 删除测试用户产生的购物车数据（先删关联子表）
DELETE FROM oc_cart
WHERE customer_id IN (
    SELECT customer_id FROM oc_customer
    WHERE email LIKE 'test_%@example.com'
);

-- 2. 删除测试用户产生的订单明细
DELETE FROM oc_order_product
WHERE order_id IN (
    SELECT order_id FROM oc_order
    WHERE email LIKE 'test_%@example.com'
);

-- 3. 删除测试用户的主订单
DELETE FROM oc_order
WHERE email LIKE 'test_%@example.com';

-- 4. 删除测试账号
DELETE FROM oc_customer
WHERE email LIKE 'test_%@example.com';
