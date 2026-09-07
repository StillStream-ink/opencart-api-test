import json
import csv
import requests
import os
from datetime import datetime

# ============================================
# 自动切换到脚本所在目录
# ============================================
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# ============================================
# 飞书 Webhook 配置
# ============================================
FEISHU_WEBHOOK = "https://open.feishu.cn/open-apis/bot/v2/hook/9bdcd568-c176-4fe6-acd3-d69d4177129e"

def get_jmeter_stats(json_path):
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        total = data.get("Total", {})
        if not total:
            return None
        return {
            "sampleCount": total.get("sampleCount", 0),
            "errorCount": total.get("errorCount", 0),
            "errorPct": total.get("errorPct", 0.0),
            "meanResTime": total.get("meanResTime", 0.0),
            "minResTime": total.get("minResTime", 0.0),
            "maxResTime": total.get("maxResTime", 0.0),
            "pct1ResTime": total.get("pct1ResTime", 0.0),
            "pct2ResTime": total.get("pct2ResTime", 0.0),
            "pct3ResTime": total.get("pct3ResTime", 0.0),
            "throughput": total.get("throughput", 0.0),
        }
    except Exception as e:
        print(f"[警告] 读取 JMeter 报告失败: {e}")
        return None

def get_locust_stats(csv_path):
    """从 Locust CSV 报告提取汇总数据（自动检测编码）"""
    # 先检查文件是否存在
    if not os.path.exists(csv_path):
        return None
    
    encodings = ['utf-8', 'gbk', 'gb2312', 'latin-1']
    for enc in encodings:
        try:
            with open(csv_path, 'r', encoding=enc) as f:
                lines = f.readlines()
            for line in lines:
                if "Aggregated" in line:
                    parts = line.strip().split(',')
                    clean_parts = [p for p in parts if p.strip() != '']
                    if len(clean_parts) >= 10:
                        return {
                            "samples": int(clean_parts[1]),
                            "fails": int(clean_parts[2]),
                            "avg": float(clean_parts[4]),
                            "req_per_sec": float(clean_parts[8]),
                        }
        except UnicodeDecodeError:
            continue
    return None

def send_feishu_text(jmeter_50, jmeter_100, locust_15, locust_25):
    if not FEISHU_WEBHOOK:
        print("[警告] 未配置飞书 Webhook")
        return

    lines = []
    lines.append("🔧 OpenCart 接口+性能 全量测试报告")
    lines.append(f"⏰ 执行时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"🖥️ 测试环境：本地 XAMPP (Windows 10)")
    lines.append("")

    # JMeter 50 并发
    lines.append("📊 JMeter 50 并发压测结果：")
    if jmeter_50:
        lines.append(f"  - 总请求数：{jmeter_50['sampleCount']}")
        lines.append(f"  - 失败数：{jmeter_50['errorCount']}")
        lines.append(f"  - 失败率：{jmeter_50['errorPct']:.2f}%")
        lines.append(f"  - 平均响应时间：{jmeter_50['meanResTime']:.2f} ms")
        lines.append(f"  - P95 响应时间：{jmeter_50['pct2ResTime']:.2f} ms")
        lines.append(f"  - 吞吐量 (TPS)：{jmeter_50['throughput']:.2f}")
    else:
        lines.append("  ⚠️ 未找到数据")

    lines.append("")

    # JMeter 100 并发
    lines.append("📊 JMeter 100 并发压测结果：")
    if jmeter_100:
        lines.append(f"  - 总请求数：{jmeter_100['sampleCount']}")
        lines.append(f"  - 失败数：{jmeter_100['errorCount']}")
        lines.append(f"  - 失败率：{jmeter_100['errorPct']:.2f}%")
        lines.append(f"  - 平均响应时间：{jmeter_100['meanResTime']:.2f} ms")
        lines.append(f"  - P95 响应时间：{jmeter_100['pct2ResTime']:.2f} ms")
        lines.append(f"  - 吞吐量 (TPS)：{jmeter_100['throughput']:.2f}")
    else:
        lines.append("  ⚠️ 未找到数据")

    lines.append("")

    # Locust 15 并发
    lines.append("🧪 Locust 15 并发压测结果：")
    if locust_15:
        lines.append(f"  - 总请求数：{locust_15['samples']}")
        lines.append(f"  - 失败数：{locust_15['fails']}")
        lines.append(f"  - 平均响应时间：{locust_15['avg']:.2f} ms")
        lines.append(f"  - 吞吐量 (req/s)：{locust_15['req_per_sec']:.2f}")
    else:
        lines.append("  ⚠️ 未找到数据")

    lines.append("")

    # Locust 25 并发
    lines.append("🧪 Locust 25 并发压测结果：")
    if locust_25:
        lines.append(f"  - 总请求数：{locust_25['samples']}")
        lines.append(f"  - 失败数：{locust_25['fails']}")
        lines.append(f"  - 平均响应时间：{locust_25['avg']:.2f} ms")
        lines.append(f"  - 吞吐量 (req/s)：{locust_25['req_per_sec']:.2f}")
    else:
        lines.append("  ⚠️ 未找到数据")

    lines.append("")
    lines.append("📎 详细报告请查看项目 allure-report/ 和 jmeter/report_*/")

    text_content = "\n".join(lines)
    payload = {"msg_type": "text", "content": {"text": text_content}}

    try:
        resp = requests.post(FEISHU_WEBHOOK, json=payload, timeout=10)
        if resp.status_code == 200 and resp.json().get("code") == 0:
            print("[通知] 飞书消息发送成功 ✅")
        else:
            print(f"[通知] 飞书消息发送失败: {resp.text}")
    except Exception as e:
        print(f"[通知] 飞书消息发送异常: {e}")

if __name__ == "__main__":
    print("=" * 50)
    print("开始收集压测结果并推送飞书通知...")
    print("=" * 50)

    # 1. JMeter 50 并发
    jmeter_50 = get_jmeter_stats("jmeter/report_50vu/statistics.json")
    if jmeter_50:
        print(f"JMeter 50 数据读取成功: 总请求 {jmeter_50['sampleCount']}, 失败率 {jmeter_50['errorPct']:.2f}%")
    else:
        print("JMeter 50 数据读取失败，请确认 report_50vu/statistics.json 是否存在")

    # 2. JMeter 100 并发
    jmeter_100 = get_jmeter_stats("jmeter/report_100vu/statistics.json")
    if jmeter_100:
        print(f"JMeter 100 数据读取成功: 总请求 {jmeter_100['sampleCount']}, 失败率 {jmeter_100['errorPct']:.2f}%")
    else:
        print("JMeter 100 数据读取失败，请确认 report_100vu/statistics.json 是否存在")

    # 3. Locust 15 并发
    locust_15 = None
    for csv_name in ["reports/locust_15user_stats.csv", "reports/.locust_15user_stats.csv"]:
        locust_15 = get_locust_stats(csv_name)
        if locust_15:
            print(f"Locust 15 数据读取成功: 总请求 {locust_15['samples']}, 平均响应 {locust_15['avg']:.2f}ms")
            break
    if not locust_15:
        print("Locust 15 数据读取失败，请确认 reports/locust_15user_stats.csv 是否存在")

    # 4. Locust 25 并发
    locust_25 = None
    for csv_name in ["reports/locust_25user_stats.csv", "reports/.locust_25user_stats.csv"]:
        locust_25 = get_locust_stats(csv_name)
        if locust_25:
            print(f"Locust 25 数据读取成功: 总请求 {locust_25['samples']}, 平均响应 {locust_25['avg']:.2f}ms")
            break
    if not locust_25:
        print("Locust 25 数据读取失败，请确认 reports/locust_25user_stats.csv 是否存在")

    # 5. 发送飞书
    send_feishu_text(jmeter_50, jmeter_100, locust_15, locust_25)