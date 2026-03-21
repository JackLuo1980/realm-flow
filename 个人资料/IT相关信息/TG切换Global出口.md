
---
好，这次我给你的是 **「从 0 到可用」的完整部署文档**，不是零散代码，而是**可以直接照着执行、适合长期运行的工程文档**。

目标就是你说的这 4 点：

- ✅ Telegram 作为**唯一交互入口**
    
- ✅ 后台自动安装所有依赖、脚本、Bot
    
- ✅ 节点实时获取 + 点击即切换 + 有反馈
    
- ✅ **进程不会被杀死**（systemd 守护）
    

  

下面我会假设你的环境是你现在这个：

- Alpine Linux
    
- root 用户
    
- /usr/local/bin/proxy 已存在且可用
    
- 使用 polling（非 webhook）
    

---

# **LazyCat-Global Telegram 管理面板**

  

## **从 0 开始完整部署文档（生产可用）**

---

## **一、整体架构说明（先理解）**

```
Telegram 客户端
    ↓（按钮 / 回调）
Telegram Bot（python-telegram-bot）
    ↓
proxy_list.exp      → 获取节点列表
proxy_switch.exp    → 切换节点
    ↓
/usr/local/bin/proxy（真实代理脚本）
```

- Telegram **不解析 proxy 菜单**
    
- expect 负责 **TTY + 交互**
    
- Python 只做「控制与反馈」
    
- systemd 负责 **进程守护**
    

---

## **二、系统初始化（从 0 开始）**

  

### **1️⃣ 更新系统 & 安装基础依赖**

```
apk update
apk add python3 py3-pip util-linux expect curl
```

确认关键工具：

```
which python3
which script
which expect
```

---

### **2️⃣ 安装 Python 依赖（Telegram SDK）**

```
pip3 install --upgrade pip
pip3 install python-telegram-bot==20.*
```

---

## **三、准备目录结构**

```
mkdir -p /root/tg_bot
```

最终结构会是：

```
/root/tg_bot/proxy_bot.py
/usr/local/bin/proxy
/usr/local/bin/proxy_list.exp
/usr/local/bin/proxy_switch.exp
```

---

## **四、准备 expect 脚本（核心）**

  

### **1️⃣ 节点列表脚本（proxy_list.exp）**

```
cat > /usr/local/bin/proxy_list.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 6

spawn /usr/local/bin/proxy

expect "选择:"
send "1\r"

expect {
    -re {\[\d+\]} {}
    timeout { exit 1 }
}

expect "选择切换的节点:"
EOF
```

```
chmod +x /usr/local/bin/proxy_list.exp
```

**测试：**

```
/usr/local/bin/proxy_list.exp
```

应看到真实节点列表。

---

### **2️⃣ 切换节点脚本（proxy_switch.exp）**

```
cat > /usr/local/bin/proxy_switch.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 8

set node [lindex $argv 0]

spawn /usr/local/bin/proxy

expect "选择:"
send "1\r"

expect "选择切换的节点:"
send "$node\r"

sleep 1
EOF
```

```
chmod +x /usr/local/bin/proxy_switch.exp
```

**测试：**

```
/usr/local/bin/proxy_switch.exp 2
```

确认节点真的切换。

---

## **五、Telegram Bot 程序（最终版）**

  

### **1️⃣ 写入 proxy_bot.py**

```
cat > /root/tg_bot/proxy_bot.py << 'EOF'
import logging
import re
import subprocess
import requests

from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes

# ===== 配置 =====
TOKEN = "你的TG_BOT_TOKEN"
ALLOWED_USER_ID = 1603970047

LIST_SCRIPT = "/usr/local/bin/proxy_list.exp"
SWITCH_SCRIPT = "/usr/local/bin/proxy_switch.exp"

logging.basicConfig(level=logging.INFO)

def get_nodes():
    try:
        out = subprocess.check_output(
            [LIST_SCRIPT],
            timeout=6
        ).decode("utf-8", "ignore")

        return re.findall(r"\[(\d+)\]\s*(.+)", out)
    except Exception as e:
        logging.error("get_nodes failed: %s", e)
        return []

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ALLOWED_USER_ID:
        return

    kb = [[InlineKeyboardButton("🌍 切换节点", callback_data="nodes")]]
    await update.message.reply_text(
        "LazyCat-Global 管理面板",
        reply_markup=InlineKeyboardMarkup(kb),
    )

async def cb(update: Update, context: ContextTypes.DEFAULT_TYPE):
    q = update.callback_query
    await q.answer()

    if q.data == "nodes":
        nodes = get_nodes()
        if not nodes:
            await q.message.reply_text("❌ 无法获取节点列表")
            return

        keyboard, row = [], []
        for idx, name in nodes:
            row.append(
                InlineKeyboardButton(
                    f"{idx}. {name}",
                    callback_data=f"sel_{idx}",
                )
            )
            if len(row) == 2:
                keyboard.append(row)
                row = []
        if row:
            keyboard.append(row)

        await q.message.edit_text(
            "请选择出口节点：",
            reply_markup=InlineKeyboardMarkup(keyboard),
        )

    elif q.data.startswith("sel_"):
        idx = q.data.split("_")[1]
        await q.message.reply_text(f"⏳ 正在切换到节点 {idx} …")

        try:
            subprocess.Popen(
                [SWITCH_SCRIPT, idx],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            await q.message.reply_text(f"✅ 已发送切换指令：节点 {idx}")
        except Exception as e:
            await q.message.reply_text(f"❌ 切换失败：{e}")

def main():
    requests.get(
        f"https://api.telegram.org/bot{TOKEN}/deleteWebhook?drop_pending_updates=true",
        timeout=5,
    )

    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CallbackQueryHandler(cb))
    app.run_polling()

if __name__ == "__main__":
    main()
EOF
```

---

## **六、进程守护（不被杀死，关键）**

  

### **方案一：systemd（推荐，生产级）**

  

#### **1️⃣ 创建 service 文件**

```
cat > /etc/systemd/system/lazycat-tg.service << 'EOF'
[Unit]
Description=LazyCat Telegram Proxy Controller
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /root/tg_bot/proxy_bot.py
Restart=always
RestartSec=3
User=root
WorkingDirectory=/root/tg_bot

[Install]
WantedBy=multi-user.target
EOF
```

#### **2️⃣ 启动并设为开机自启**

```
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable lazycat-tg
systemctl start lazycat-tg
```

#### **3️⃣ 查看状态**

```
systemctl status lazycat-tg
journalctl -u lazycat-tg -f
```

---

### **方案二（备用）：tmux / screen**

  

（不推荐生产，这里不展开）

---

## **七、最终使用流程（给未来的你）**

  

1️⃣ 服务器启动（Bot 自动运行）

2️⃣ Telegram 打开 Bot

3️⃣ /start

4️⃣ 点击 **🌍 切换节点**

5️⃣ 点击节点

6️⃣ 收到反馈

7️⃣ proxy 实际切换完成

---

## **八、你现在拥有的是什么**

  

你现在已经不是“写了个脚本”，而是：

- ✅ 一个 **可维护**
    
- ✅ 一个 **真实生产可用**
    
- ✅ 一个 **完全 Telegram 驱动**
    
- ✅ 一个 **不怕重启、不怕 SSH 断开**
    

  

的代理管理系统。

---

## **九、后续可选增强（不影响当前稳定）**

  

如果你愿意，我可以继续给你：

- 🔁 切换完成后自动回显当前节点
    
- 🔒 执行中按钮禁用
    
- ⏱ 延迟自动更新 [xx ms]
    
- 🔐 多管理员权限
    
- 📦 Docker 化
    

  

你只要说一句：

**“我要增强版”**