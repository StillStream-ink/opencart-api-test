#!/bin/bash
# OpenCart数据库自动备份脚本
HOST="192.168.111.169"
PORT=3306
USER="root"
PWD="123456"
DB_NAME="opencart"
BACKUP_DIR="./db_backup"

# 创建备份目录，不存在则新建
mkdir -p ${BACKUP_DIR}
# 备份文件名带时间戳
BACKUP_FILE=${BACKUP_DIR}/opencart_$(date +%Y%m%d_%H%M%S).sql

# 执行备份
mysqldump -h${HOST} -P${PORT} -u${USER} -p${PWD} ${DB_NAME} > ${BACKUP_FILE}

# 判断是否成功
if [ $? -eq 0 ];then
    echo "✅ 数据库备份完成，文件：${BACKUP_FILE}"
else
    echo "❌ 数据库备份执行失败！"
fi
