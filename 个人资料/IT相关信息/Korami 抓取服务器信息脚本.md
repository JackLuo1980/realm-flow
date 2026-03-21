---
id: A9699655-E82E-48F4-B5FD-34AD6584EFDF
tags:
  - _
---
- - -
### 脚本信息：
1. 实现单向同步服务器信息到notion
2. 实现增量和全量定时

```
import requests
import sqlite3
import os
import time
import re
import sys
from datetime import datetime
from collections import Counter

# 强制 UTF-8 输出
sys.stdout.reconfigure(encoding='utf-8')

# ================== ⚙️ 核心配置 ==================
NOTION_TOKEN = "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"
DATABASE_ID = "2d953511a57b800583bae6f7ff5d699b"
STATS_BLOCK_ID = "2da53511a57b802ab7c2c7b8ecb93a31"

CONTAINER_NAME = "komari"
DB_PATH_INSIDE = "/app/data/komari.db"
TEMP_DB = "/tmp/komari_v34_sorted.db"

HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28"
}

# ================== 1. Unicode 旗帜定义 (V25 原版 - 绝对稳) ==================
F_CN = "\U0001F1E8\U0001F1F3" # 🇨🇳
F_TW = "\U0001F1F9\U0001F1FC" # 🇹🇼
F_HK = "\U0001F1ED\U0001F1F0" # 🇭🇰
F_JP = "\U0001F1EF\U0001F1F5" # 🇯🇵
F_US = "\U0001F1FA\U0001F1F8" # 🇺🇸
F_SG = "\U0001F1F8\U0001F1EC" # 🇸🇬
F_DE = "\U0001F1E9\U0001F1EA" # 🇩🇪
F_LU = "\U0001F1F1\U0001F1FA" # 🇱🇺
F_KR = "\U0001F1F0\U0001F1F7" # 🇰🇷
F_UK = "\U0001F1EC\U0001F1E7" # 🇬🇧
F_NL = "\U0001F1F3\U0001F1F1" # 🇳🇱
F_IT = "\U0001F1EE\U0001F1F9" # 🇮🇹
F_RU = "\U0001F1F7\U0001F1FA" # 🇷🇺
F_FR = "\U0001F1EB\U0001F1F7" # 🇫🇷
F_CA = "\U0001F1E8\U0001F1E6" # 🇨🇦
F_AU = "\U0001F1E6\U0001F1FA" # 🇦🇺
F_IN = "\U0001F1EE\U0001F1F3" # 🇮🇳
F_TH = "\U0001F1F9\U0001F1ED" # 🇹🇭
F_VN = "\U0001F1FB\U0001F1F3" # 🇻🇳
F_BR = "\U0001F1E7\U0001F1F7" # 🇧🇷
F_TR = "\U0001F1F9\U0001F1F7" # 🇹🇷
F_SE = "\U0001F1F8\U0001F1EA" # 🇸🇪
F_CH = "\U0001F1E8\U0001F1ED" # 🇨🇭

# ================== 2. 强制名称修正规则 (V25 原版) ==================
NAME_RULES = {
    "HINET": f"{F_TW} 台湾", "TWLITE": f"{F_TW} 台湾", "TAIWAN": f"{F_TW} 台湾", 
    "台北": f"{F_TW} 台湾", "彰化": f"{F_TW} 台湾", "TW": f"{F_TW} 台湾",
    "BUYVM-LU": f"{F_LU} 卢森堡", "LUXEMBOURG": f"{F_LU} 卢森堡",
    "广东": f"{F_CN} 中国大陆", "武汉": f"{F_CN} 中国大陆", "上海": f"{F_CN} 中国大陆",
    "北京": f"{F_CN} 中国大陆", "深圳": f"{F_CN} 中国大陆", "杭州": f"{F_CN} 中国大陆",
    "云曦": f"{F_CN} 中国大陆", 
    "USA": f"{F_US} 美国", "LOS ANGELES": f"{F_US} 美国", "SJC": f"{F_US} 美国",
    "JAPAN": f"{F_JP} 日本", "TOKYO": f"{F_JP} 日本", "OSAKA": f"{F_JP} 日本",
    "HKLITE": f"{F_HK} 香港", "HONGKONG": f"{F_HK} 香港", "JPLITE": f"{F_JP} 日本",
    "GERMANY": f"{F_DE} 德国", "UK": f"{F_UK} 英国", "LONDON": f"{F_UK} 英国",
    "ITALY": f"{F_IT} 意大利", "FRANCE": f"{F_FR} 法国"
}

# ================== 3. 地区代码映射表 (V25 原版) ==================
REGION_MAP = {
    "HK": f"{F_HK} 香港", "HONGKONG": f"{F_HK} 香港", F_HK: f"{F_HK} 香港",
    "TW": f"{F_TW} 台湾", "TAIWAN": f"{F_TW} 台湾", "CN": f"{F_TW} 台湾", F_TW: f"{F_TW} 台湾",
    "MO": f"{F_HK} 澳门", "MACAO": f"{F_HK} 澳门",
    "JP": f"{F_JP} 日本", "JAPAN": f"{F_JP} 日本", F_JP: f"{F_JP} 日本",
    "US": f"{F_US} 美国", "USA": f"{F_US} 美国", "AMERICA": f"{F_US} 美国", F_US: f"{F_US} 美国",
    "CN_MAINLAND": f"{F_CN} 中国大陆", "CHINA": f"{F_CN} 中国大陆", F_CN: f"{F_CN} 中国大陆",
    "SG": f"{F_SG} 新加坡", "SINGAPORE": f"{F_SG} 新加坡", F_SG: f"{F_SG} 新加坡",
    "KR": f"{F_KR} 韩国", "KOREA": f"{F_KR} 韩国", F_KR: f"{F_KR} 韩国",
    "DE": f"{F_DE} 德国", "GERMANY": f"{F_DE} 德国", F_DE: f"{F_DE} 德国",
    "LU": f"{F_LU} 卢森堡", "LUXEMBOURG": f"{F_LU} 卢森堡", F_LU: f"{F_LU} 卢森堡",
    "NL": f"{F_NL} 荷兰", "NETHERLANDS": f"{F_NL} 荷兰", F_NL: f"{F_NL} 荷兰",
    "UK": f"{F_UK} 英国", "GB": f"{F_UK} 英国", F_UK: f"{F_UK} 英国",
    "IT": f"{F_IT} 意大利", "ITALY": f"{F_IT} 意大利", F_IT: f"{F_IT} 意大利",
    "FR": f"{F_FR} 法国", "FRANCE": f"{F_FR} 法国", F_FR: f"{F_FR} 法国",
    "RU": f"{F_RU} 俄罗斯", "RUSSIA": f"{F_RU} 俄罗斯", F_RU: f"{F_RU} 俄罗斯",
    "CH": f"{F_CH} 瑞士", "SWITZERLAND": f"{F_CH} 瑞士", F_CH: f"{F_CH} 瑞士",
    "CA": f"{F_CA} 加拿大", "CANADA": f"{F_CA} 加拿大", F_CA: f"{F_CA} 加拿大",
    "AU": f"{F_AU} 澳大利亚", "AUSTRALIA": f"{F_AU} 澳大利亚", F_AU: f"{F_AU} 澳大利亚",
    "TH": f"{F_TH} 泰国", "THAILAND": f"{F_TH} 泰国", F_TH: f"{F_TH} 泰国",
    "VN": f"{F_VN} 越南", "VIETNAM": f"{F_VN} 越南", F_VN: f"{F_VN} 越南",
    "IN": f"{F_IN} 印度", "INDIA": f"{F_IN} 印度", F_IN: f"{F_IN} 印度",
    "TR": f"{F_TR} 土耳其", "TURKEY": f"{F_TR} 土耳其", F_TR: f"{F_TR} 土耳其",
    "SE": f"{F_SE} 瑞典", "SWEDEN": f"{F_SE} 瑞典", F_SE: f"{F_SE} 瑞典",
    "BR": f"{F_BR} 巴西", "BRAZIL": f"{F_BR} 巴西", F_BR: f"{F_BR} 巴西",
}

# ================== 4. 实时汇率 ==================
def get_realtime_rates():
    print("💱 获取汇率...")
    default = {"USD": 7.25, "EUR": 7.85, "CNY": 1.0, "GBP": 9.2, "HKD": 0.93, "JPY": 0.048}
    try:
        r = requests.get("https://api.exchangerate-api.com/v4/latest/CNY", timeout=3).json()
        rates = r.get("rates", {})
        final = {}
        for k, v in rates.items():
            if v > 0: final[k] = 1 / v
        return {**default, **final}
    except:
        return default

def get_standard_region(db_region, server_name):
    # 完全采用 V25 逻辑
    raw_str = str(db_region).strip()
    upper_name = str(server_name).upper()
    upper_raw = raw_str.upper()

    for keyword, val in NAME_RULES.items():
        if keyword in upper_name: return val

    if upper_raw in REGION_MAP: return REGION_MAP[upper_raw]
    
    clean_code = re.sub(r"[^A-Z]", "", upper_raw)
    if clean_code in REGION_MAP: return REGION_MAP[clean_code]
    
    for key, val in REGION_MAP.items():
        if key in upper_raw and len(key) > 1: return val

    if not raw_str or raw_str.lower() == "unknown": return "🏳️ 未知"
    return raw_str[:50].replace(",", " ")

def format_traffic(bytes_val):
    if not bytes_val or bytes_val <= 0: return "无限量"
    gb = bytes_val / (1024**3)
    return f"{round(gb/1024, 2)}TB" if gb >= 1000 else f"{round(gb, 2)}GB"

# ================== 5. 费用计算 (-1修正 + 3年付修正) ==================
def calculate_monthly_raw(price, cycle_days, remark):
    p = float(price)
    # 修复：负数全部归零
    if p < 0: return "One-time", 0.0, "Free/Err"

    try:
        days = float(cycle_days)
    except:
        days = 0.0
    
    if 1080 <= days <= 1110: return "Triennially", p / 36, "3年付"
    if 710 <= days <= 750:   return "Biennially", p / 24, "2年付"
    if 355 <= days <= 375:   return "Yearly", p / 12, "年付"
    if 170 <= days <= 190:   return "Semi-Annually", p / 6, "半年"
    if 80 <= days <= 100:    return "Quarterly", p / 3, "季付"
    if 20 <= days <= 40:     return "Monthly", p / 1, "月付"

    rem = str(remark).lower()
    if days < 1:
        if "inf" in rem or "free" in rem: return "One-time", 0.0, "Free"
    
    return "Monthly", p, "默认月付"

# ================== 6. 主程序 ==================
def run_sync():
    now = datetime.now()
    print(f"\n⏰ [{now.strftime('%H:%M:%S')}] 启动 V34 (Sorting + Sum Fix)...")
    
    rates = get_realtime_rates()
    os.system(f"docker cp {CONTAINER_NAME}:{DB_PATH_INSIDE} {TEMP_DB}")
    if not os.path.exists(TEMP_DB): return print("❌ 数据库复制失败")

    conn = sqlite3.connect(TEMP_DB)
    cursor = conn.cursor()
    
    cycle_col = "billing_cycle"
    try:
        cursor.execute("PRAGMA table_info(clients)")
        cols = [i[1] for i in cursor.fetchall()]
        if "cycle" in cols: cycle_col = "cycle"
    except: pass

    # ✅ 修复重点 1：增加 ORDER BY name ASC 实现字母排序
    sql = f"SELECT name, ipv4, ipv6, price, currency, remark, traffic_limit, region, os, {cycle_col} FROM clients ORDER BY name ASC"
    
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
    except:
        # 降级查询
        cursor.execute("SELECT name, ipv4, ipv6, price, currency, remark, traffic_limit, region, os FROM clients ORDER BY name ASC")
        rows = [list(r) + [0] for r in cursor.fetchall()]
    conn.close()

    print("⏳ 读取 Notion...")
    notion_pool = {}
    has_more, next_cursor = True, None
    while has_more:
        pl = {"page_size": 100}
        if next_cursor: pl["start_cursor"] = next_cursor
        try:
            r = requests.post(f"https://api.notion.com/v1/databases/{DATABASE_ID}/query", headers=HEADERS, json=pl).json()
            for p in r.get("results", []):
                ip = p["properties"].get("IP", {}).get("rich_text", [{}])[0].get("plain_text", "No IP")
                if ip not in notion_pool: notion_pool[ip] = []
                notion_pool[ip].append(p["id"])
            has_more = r.get("has_more", False)
            next_cursor = r.get("next_cursor")
        except: has_more = False

    print(f"🚀 正在同步 {len(rows)} 台服务器...")
    stats = Counter()
    total_yearly_cny = 0.0 
    
    for idx, row in enumerate(rows, 1):
        name, ipv4, ipv6, price, curr, remark, traffic, region, os_sys, db_days = row
        ip_main = ipv4 if ipv4 and ipv4 != "None" else (ipv6 if ipv6 else "No IP")
        
        # 地区
        reg_show = get_standard_region(region, name)
        stats[reg_show] += 1
        
        # 汇率
        curr = str(curr).upper() if curr else "CNY"
        ex_rate = rates.get(curr, 1.0)
        if ex_rate == 1.0 and curr == "USD": ex_rate = 7.25

        # 价格计算
        real_price = 0.0 if float(price) < 0 else float(price)
        cycle_label, monthly_raw, debug_note = calculate_monthly_raw(real_price, db_days, remark)
        
        # ✅ 修复重点 2：统计总额 = 月付原价 * 12 * 汇率 (模拟最后一列求和)
        annual_cny = monthly_raw * 12 * ex_rate
        total_yearly_cny += annual_cny

        props = {
            "name": {"title": [{"text": {"content": str(name)}}]},
            "序号": {"number": idx}, # 按字母顺序生成的序号
            "IP": {"rich_text": [{"text": {"content": str(ip_main)}}]},
            "IPv6": {"rich_text": [{"text": {"content": str(ipv6) if ipv6 else ""}}]},
            "OS": {"rich_text": [{"text": {"content": str(os_sys) if os_sys else ""}}]},
            "地区": {"select": {"name": reg_show}}, 
            "data traffic": {"rich_text": [{"text": {"content": format_traffic(traffic)}}]},
            "Billing Cycle": {"select": {"name": cycle_label}},
            "Currency": {"select": {"name": curr}},
            "Cost": {"number": real_price},
            "Monthly Raw Cost": {"number": round(monthly_raw, 2)}
        }

        page_id = notion_pool[ip_main].pop(0) if (ip_main in notion_pool and notion_pool[ip_main]) else None
        try:
            if page_id:
                requests.patch(f"https://api.notion.com/v1/pages/{page_id}", headers=HEADERS, json={"properties": props})
            else:
                requests.post("https://api.notion.com/v1/pages", headers=HEADERS, json={"parent": {"database_id": DATABASE_ID}, "properties": props})
            
            # 安全打印
            safe_reg = reg_show.encode('utf-8', 'ignore').decode('utf-8')
            print(f"   ✅ [{idx}] {name[:10]}... | {safe_reg}")
        except Exception as e:
            print(f"❌ 失败: {e}")
        
        time.sleep(0.12)

    print("🧹 清理旧数据...")
    for ip, ids in notion_pool.items():
        for pid in ids:
            requests.patch(f"https://api.notion.com/v1/pages/{pid}", headers=HEADERS, json={"archived": True})
            
    # 更新顶部统计
    if STATS_BLOCK_ID:
        try:
            region_text = "    ".join([f"{k} {v}" for k, v in sorted(stats.items(), key=lambda x: x[1], reverse=True)])
        except: region_text = ""

        content_text = (
            f"🖥️ 总数: **{len(rows)}台** "
            f"💰 年费预算: **¥{total_yearly_cny:,.2f}**\n"
            f"{region_text}"
        )
        try:
            requests.patch(f"https://api.notion.com/v1/blocks/{STATS_BLOCK_ID}", headers=HEADERS, json={
                "callout": {
                    "rich_text": [{"type": "text", "text": {"content": content_text}}],
                    "icon": {"emoji": "📊"}
                }
            })
            print(f"📊 统计已更新: ¥{total_yearly_cny:,.2f}")
        except: pass
    
    if os.path.exists(TEMP_DB): os.remove(TEMP_DB)
    print("🏁 V34 同步完成！")

if __name__ == "__main__":
    run_sync()
```

### 创建脚本
```
nano komari_to_notion.py
```

### 运行脚本

```
python3 komari_to_notion.py
```

### 定时任务
```
0 3 * * * /usr/bin/python3 /root/komari_smart_sync_final.py >> /root/komari_sync.log 2>&1
```

#_/_/_