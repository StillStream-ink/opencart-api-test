#!/bin/bash

echo "=========================================="
echo "  OpenCart 日常检查"
echo "  执行时间: $(date)"
echo "=========================================="

# WSL访问Windows主机地址，用host.docker.internal
WIN_HOST="host.docker.internal"
if curl -s -I "http://${WIN_HOST}/opencart" | grep -q "200 OK"; then
    echo "✅ OpenCart前台页面访问正常"
else
    echo "❌ OpenCart前台不可访问，请确认phpstudy已启动"
fi

LOG_FILE="/mnt/d/phpstudy_pro/WWW/opencart/system/storage/logs/error.log"
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo 0)
    ERROR_COUNT=$(echo "$ERROR_COUNT" | tr -d '\r\n')
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "⚠️ 发现 ${ERROR_COUNT} 条错误，最近5条:"
        grep "ERROR" "$LOG_FILE" | tail -5
    else
        echo "✅ 日志没有ERROR错误"
    fi
fi

echo "=========================================="
echo "  检查完成"
echo "=========================================="
