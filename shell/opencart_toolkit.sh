#!/bin/bash
# ============================================
# OpenCart 自动化运维工具包
# 版本: 1.0
# 功能: 健康检查 | 日志分析 | 数据库备份 | 一键报告
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# 配置 → 改成你本机真实环境
# ============================================
OPENCART_DIR="/d/phpstudy_pro/WWW/opencart"
LOG_DIR="$OPENCART_DIR/system/storage/logs"
BACKUP_DIR="$OPENCART_DIR/backups"
REPORT_DIR="$OPENCART_DIR/reports"
DB_USER="root"
DB_PASSWORD=""
DB_NAME="opencart_db"

# 创建必要目录
mkdir -p "$BACKUP_DIR" "$REPORT_DIR"

# ============================================
# 函数定义
# ============================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

show_menu() {
    clear
    echo "=========================================="
    echo "  OpenCart 自动化运维工具包 v1.0"
    echo "=========================================="
    echo ""
    echo "  1. 健康检查（快速）"
    echo "  2. 完整健康检查 + 报告生成"
    echo "  3. 查看错误日志（最近 20 条）"
    echo "  4. 日志分析统计"
    echo "  5. 备份数据库"
    echo "  6. 清理旧备份（保留 7 天）"
    echo "  7. 查看系统状态"
    echo "  8. 生成综合报告"
    echo "  9. 一键执行全部（检查+备份+报告）"
    echo "  0. 退出"
    echo ""
    echo -n "请选择 [0-9]: "
}

quick_check() {
    echo ""
    echo "=========================================="
    echo "  快速健康检查"
    echo "=========================================="

    if ps aux | grep -v grep | grep -E "httpd|apache" > /dev/null 2>&1; then
        print_success "Web 服务正在运行"
    else
        print_error "Web 服务未运行"
    fi

    if mysql -u "$DB_USER" -e "SELECT 1;" > /dev/null 2>&1; then
        print_success "MySQL 连接正常"
    else
        print_error "MySQL 连接失败"
    fi

    if curl -s -o /dev/null -w "%{http_code}" "http://localhost/opencart" | grep -q "200"; then
        print_success "OpenCart 前台可访问"
    else
        print_error "OpenCart 前台不可访问"
    fi

    LOG_FILE="$LOG_DIR/error.log"
    if [ -f "$LOG_FILE" ]; then
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
        if [ "$ERROR_COUNT" -eq 0 ]; then
            print_success "无错误日志"
        else
            print_warning "发现 $ERROR_COUNT 条错误"
        fi
    else
        print_warning "日志文件不存在"
    fi

    echo ""
    read -p "按 Enter 键继续..."
}

full_check() {
    echo ""
    echo "=========================================="
    echo "  完整健康检查"
    echo "  时间: $(date)"
    echo "=========================================="

    echo ""
    echo "[1] 服务状态"
    for service in mysql httpd apache; do
        if ps aux | grep -v grep | grep "$service" > /dev/null 2>&1; then
            print_success "$service 正在运行"
        else
            print_error "$service 未运行"
        fi
    done

    echo ""
    echo "[2] 端口状态"
    for port in 80 3306; do
        if netstat -ano | grep ":$port " | grep LISTEN > /dev/null 2>&1; then
            print_success "端口 $port 正在监听"
        else
            print_error "端口 $port 未监听"
        fi
    done

    echo ""
    echo "[3] 数据库状态"
    if mysql -u "$DB_USER" -e "SHOW DATABASES;" > /dev/null 2>&1; then
        print_success "MySQL 连接正常"
        TABLE_COUNT=$(mysql -u "$DB_USER" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" -s -N 2>/dev/null || echo "0")
        if [ "$TABLE_COUNT" -gt 0 ]; then
            print_success "数据库 $DB_NAME 存在，共 $TABLE_COUNT 张表"
        else
            print_error "数据库 $DB_NAME 不存在"
        fi
    else
        print_error "MySQL 连接失败"
    fi

    echo ""
    echo "[4] 磁盘空间"
    df -h /d 2>/dev/null || echo "  无法获取磁盘信息"

    echo ""
    echo "[5] 日志统计"
    LOG_FILE="$LOG_DIR/error.log"
    if [ -f "$LOG_FILE" ]; then
        TOTAL_LINES=$(wc -l < "$LOG_FILE")
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
        WARNING_COUNT=$(grep -c "Warning" "$LOG_FILE" 2>/dev/null || echo "0")
        echo "  总行数: $TOTAL_LINES"
        echo "  错误数: $ERROR_COUNT"
        echo "  警告数: $WARNING_COUNT"
    else
        echo "  日志文件不存在"
    fi

    echo ""
    print_success "完整健康检查完成"
    echo ""
    read -p "按 Enter 键继续..."
}

view_logs() {
    LOG_FILE="$LOG_DIR/error.log"
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo "=========================================="
        echo "  最近 20 条错误日志"
        echo "=========================================="
        echo ""
        grep "ERROR" "$LOG_FILE" | tail -20 | sed 's/^/  /'
        echo ""
    else
        print_error "日志文件不存在: $LOG_FILE"
    fi
    read -p "按 Enter 键继续..."
}

log_analysis() {
    LOG_FILE="$LOG_DIR/error.log"
    if [ ! -f "$LOG_FILE" ]; then
        print_error "日志文件不存在"
        read -p "按 Enter 键继续..."
        return
    fi

    echo ""
    echo "=========================================="
    echo "  日志分析统计"
    echo "=========================================="
    echo ""
    echo "错误类型统计:"
    echo "  ERROR: $(grep -c "ERROR" "$LOG_FILE")"
    echo "  Warning: $(grep -c "Warning" "$LOG_FILE")"
    echo "  Notice: $(grep -c "Notice" "$LOG_FILE")"
    echo ""
    echo "错误按小时分布（最近 24 小时）:"
    for hour in {0..23}; do
        COUNT=$(grep "$(date +%Y-%m-%d) $(printf "%02d" $hour):" "$LOG_FILE" | grep -c "ERROR" 2>/dev/null || echo "0")
        if [ "$COUNT" -gt 0 ]; then
            printf "  %02d:00 - %02d:59: %d\n" "$hour" "$hour" "$COUNT"
        fi
    done

    echo ""
    read -p "按 Enter 键继续..."
}

backup_db() {
    echo ""
    echo "=========================================="
    echo "  数据库备份"
    echo "=========================================="

    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/opencart_$DATE.sql.gz"

    echo "正在备份数据库 $DB_NAME ..."

    if mysqldump -u "$DB_USER" --password="$DB_PASSWORD" "$DB_NAME" 2>/dev/null | gzip > "$BACKUP_FILE"; then
        print_success "备份成功: $BACKUP_FILE"
        echo "文件大小: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        print_error "备份失败，请检查 MySQL 连接"
    fi

    echo ""
    read -p "按 Enter 键继续..."
}

cleanup_backups() {
    echo ""
    echo "=========================================="
    echo "  清理旧备份（保留 7 天）"
    echo "=========================================="

    DELETED=$(find "$BACKUP_DIR" -name "opencart_*.sql.gz" -mtime +7 -delete -print 2>/dev/null | wc -l)
    if [ "$DELETED" -gt 0 ]; then
        print_success "已删除 $DELETED 个旧备份"
    else
        print_success "没有需要清理的旧备份"
    fi

    echo ""
    read -p "按 Enter 键继续..."
}

show_status() {
    echo ""
    echo "=========================================="
    echo "  系统状态"
    echo "=========================================="

    echo ""
    echo "CPU 负载:"
    top -bn1 | head -5

    echo ""
    echo "内存使用:"
    free -h 2>/dev/null || echo "  无法获取内存信息"

    echo ""
    echo "磁盘使用:"
    df -h /d 2>/dev/null || echo "  无法获取磁盘信息"

    echo ""
    read -p "按 Enter 键继续..."
}

generate_report() {
    echo ""
    echo "=========================================="
    echo "  生成综合报告"
    echo "=========================================="

    REPORT_FILE="$REPORT_DIR/report_$(date +%Y%m%d).txt"

    {
        echo "=========================================="
        echo "  OpenCart 测试环境综合报告"
        echo "  生成时间: $(date)"
        echo "=========================================="
        echo ""

        echo "【服务状态】"
        for service in mysql httpd; do
            if ps aux | grep -v grep | grep "$service" > /dev/null 2>&1; then
                echo "  $service: ✅ 运行中"
            else
                echo "  $service: ❌ 未运行"
            fi
        done
        echo ""

        echo "【端口状态】"
        for port in 80 3306; do
            if netstat -ano | grep ":$port " | grep LISTEN > /dev/null 2>&1; then
                echo "  $port: ✅ 监听中"
            else
                echo "  $port: ❌ 未监听"
            fi
        done
        echo ""

        echo "【数据库状态】"
        TABLE_COUNT=$(mysql -u "$DB_USER" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" -s -N 2>/dev/null || echo "0")
        echo "  表数量: $TABLE_COUNT"
        echo ""

        echo "【日志统计】"
        LOG_FILE="$LOG_DIR/error.log"
        if [ -f "$LOG_FILE" ]; then
            TOTAL=$(wc -l < "$LOG_FILE")
            ERRORS=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
            echo "  总行数: $TOTAL"
            echo "  错误数: $ERRORS"
        else
            echo "  日志文件不存在"
        fi
        echo ""

        echo "【磁盘空间】"
        df -h /d 2>/dev/null || echo "  无法获取"
        echo ""

        echo "=========================================="
        echo "  报告结束"
        echo "=========================================="
    } > "$REPORT_FILE"

    print_success "报告已生成: $REPORT_FILE"
    echo ""
    cat "$REPORT_FILE"
    echo ""
    read -p "按 Enter 键继续..."
}

run_all() {
    echo ""
    echo "=========================================="
    echo "  一键执行全部"
    echo "=========================================="

    echo ""
    full_check
    backup_db
    cleanup_backups
    generate_report

    print_success "全部任务执行完成！"
    read -p "按 Enter 键继续..."
}

# 主循环
while true; do
    show_menu
    read choice

    case $choice in
        1) quick_check ;;
        2) full_check ;;
        3) view_logs ;;
        4) log_analysis ;;
        5) backup_db ;;
        6) cleanup_backups ;;
        7) show_status ;;
        8) generate_report ;;
        9) run_all ;;
        0)
            echo "退出工具包，再见！"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择"
            sleep 1
            ;;
    esac
done
