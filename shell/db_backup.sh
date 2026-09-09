#!/bin/bash
# OpenCart数据库自动备份脚本

# -------------------------- 新增日志配置 --------------------------
# 脚本运行日志文件
LOG_FILE="./backup_run.log"
# ----------------------------------------------------------------

# 数据库配置
DB_USER="root"
DB_PASS="你的mysql密码"
DB_NAME="opencart"
# 备份存放目录
BACKUP_DIR="./db_backup"
# 获取当前时间作为备份文件名后缀
DATE=$(date +%Y%m%d_%H%M%S)

# 如果备份文件夹不存在就自动创建
if [ ! -d "$BACKUP_DIR" ];then
    mkdir -p $BACKUP_DIR
fi

# 打印日志，tee实现屏幕输出同时写入日志文件
echo "[$(date '+%Y‑%m‑%d %H:%M:%S')] ====== 开始执行数据库备份 ======" | tee -a ${LOG_FILE}

# mysqldump导出数据库
mysqldump -h192.168.111.169 -u$DB_USER -p$DB_PASS $DB_NAME > ${BACKUP_DIR}/opencart_${DATE}.sql

# ========== 新增：判断备份命令是否执行成功 ==========
if [ $? -ne 0 ]; then
    echo "[$(date '+%Y‑%m‑%d %H:%M:%S')] ❌ 数据库备份执行失败！" | tee -a ${LOG_FILE}
    exit 1
fi

# 删除7天以前的旧备份，防止磁盘占满
find $BACKUP_DIR -name "opencart_*.sql" -mtime +7 -delete

echo "[$(date '+%Y‑%m‑%d %H:%M:%S')] ✅数据库备份完成，文件：${BACKUP_DIR}/opencart_${DATE}.sql" | tee -a ${LOG_FILE}
echo "[$(date '+%Y‑%m‑%d %H:%M:%S')] ====== 备份任务结束 ======" | tee -a ${LOG_FILE}
