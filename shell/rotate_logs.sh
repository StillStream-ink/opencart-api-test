#!/bin/bash
LOG_DIR="/mnt/d/phpstudy_pro/WWW/opencart/system/storage/logs"
LOG_FILE="$LOG_DIR/error.log"
DATE=$(date +%Y%m%d)

if [ ! -f "$LOG_FILE" ];then
    echo "❌ 日志文件不存在 $LOG_FILE"
    exit 1
fi

FILE_SIZE=$(stat -c%s "$LOG_FILE")
if [ "$FILE_SIZE" -lt 1024 ];then
    echo "日志过小，无需分割"
    exit 0
fi

mv "$LOG_FILE" "$LOG_DIR/error_${DATE}.log"
echo "✅ 日志归档为 error_${DATE}.log"
touch "$LOG_FILE"

find "$LOG_DIR" -name "error_*.log" -mtime +7 -exec gzip {} \;
echo "日志分割完成"
