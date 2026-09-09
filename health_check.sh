#!/bin/bash

# ============================================
# OpenCart 服务健康检查脚本
# 检查: 服务状态、端口、日志、磁盘空间
# ============================================

echo "=========================================="
echo "  OpenCart 服务健康检查"
echo "  执行时间: $(date)"
echo "=========================================="

# 1. 检查 MySQL 服务
echo ""
echo "[1] MySQL 服务状态"
if ps aux | grep -v grep | grep mysql > /dev/null; then
    echo "  ✅ MySQL 正在运行"
else
    echo "  ❌ MySQL 未运行"
fi

# 2. 检查 MySQL 端口 3306
echo ""
echo "[2] MySQL 端口 3306"
if netstat -ano | grep :3306 | grep LISTEN > /dev/null 2>&1; then
    echo "  ✅ 端口 3306 正在监听"
else
    echo "  ❌ 端口 3306 未监听"
fi

# 3. 检查 Apache/Web 服务
echo ""
echo "[3] Web 服务状态"
if ps aux | grep -v grep | grep -E "httpd|apache" > /dev/null; then
    echo "  ✅ Web 服务正在运行"
else
    echo "  ❌ Web 服务未运行"
fi

# 4. 检查 Web 端口 80
echo ""
echo "[4] Web 端口 80"
if netstat -ano | grep :80 | grep LISTEN > /dev/null 2>&1; then
    echo "  ✅ 端口 80 正在监听"
else
    echo "  ❌ 端口 80 未监听"
fi

# 5. 检查 OpenCart 日志
echo ""
echo "[5] OpenCart 错误日志"
LOG_FILE="/d/phpstudy_pro/WWW/opencart/system/storage/logs/error.log"
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "  ✅ 日志文件存在"
    echo "  文件大小: $(du -h "$LOG_FILE" | cut -f1 2>/dev/null || echo "未知")"
    echo "  错误总数: $ERROR_COUNT"
    if [[ "$ERROR_COUNT" -gt 0 ]]; then
        echo "  最近3条错误:"
        grep "ERROR" "$LOG_FILE" | tail -3 | sed 's/^/    /'
    fi
else
    echo "  ❌ 日志文件不存在"
fi

# 6. 检查磁盘空间
echo ""
echo "[6] 磁盘空间"
df -h /d 2>/dev/null || echo "  无法获取磁盘信息"

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
