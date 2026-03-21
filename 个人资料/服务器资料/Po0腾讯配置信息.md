
---
1. 开启转发
```
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

2. 开启 IP 转发（必做）
```
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

3. 安装 Nftables（debian12系统内已默认安装，这步可省略）
```
apt install nftables -y
```

4. 部署 Nftables 专线转发
```
#!/bin/bash
# ============================================================
# PO0 中转机 nftables 端口转发一键部署
# IPv4 nftables 内核态转发 + 防火墙
#
# 适用: Ubuntu 22.04 / 24.04
# 用法: bash setup-relay.sh
# ============================================================
set -e

# ==================== 自动检测 ====================
WAN_IF=$(ip -4 route show default | awk '{print $5; exit}')
if [ -z "$WAN_IF" ]; then
  echo "❌ 无法检测默认网卡"; exit 1
fi

RELAY_LAN_IP=$(ip -4 addr show "$WAN_IF" | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
if [ -z "$RELAY_LAN_IP" ]; then
  echo "❌ 无法获取内网 IP"; exit 1
fi

random_port() {
  echo $(( RANDOM % 50000 + 10000 ))
}

echo ""
echo "============================================"
echo "  PO0 中转机端口转发部署"
echo "============================================"
echo ""
echo "  自动检测:"
echo "    网卡:   $WAN_IF"
echo "    内网IP: $RELAY_LAN_IP"
echo ""

# ==================== 用户输入 ====================
read -rp "  落地机数量 [1]: " LINE_COUNT
LINE_COUNT=${LINE_COUNT:-1}

if ! [[ "$LINE_COUNT" =~ ^[0-9]+$ ]] || [ "$LINE_COUNT" -lt 1 ] || [ "$LINE_COUNT" -gt 20 ]; then
  echo "❌ 数量无效 (1-20)"; exit 1
fi

declare -a DEST_IPS DEST_PORTS RELAY_PORTS LINE_NAMES

for i in $(seq 1 "$LINE_COUNT"); do
  echo ""
  if [ "$LINE_COUNT" -gt 1 ]; then
    echo "  --- 线路 $i ---"
    read -rp "  线路名称 (如 HK-T1, JP-CO) [线路${i}]: " name
    LINE_NAMES[$i]=${name:-"线路${i}"}
  else
    LINE_NAMES[$i]="默认线路"
  fi

  read -rp "  落地机 IP: " dest_ip
  if [ -z "$dest_ip" ]; then
    echo "❌ IP 不能为空"; exit 1
  fi
  DEST_IPS[$i]=$dest_ip

  read -rp "  落地机端口: " dest_port
  if [ -z "$dest_port" ]; then
    echo "❌ 端口不能为空"; exit 1
  fi
  DEST_PORTS[$i]=$dest_port

  rp=$(random_port)
  read -rp "  中转端口 [${rp}]: " relay_port
  RELAY_PORTS[$i]=${relay_port:-$rp}
done

# ==================== 确认 ====================
echo ""
echo "  ========== 转发规则 =========="
for i in $(seq 1 "$LINE_COUNT"); do
  echo "  [${LINE_NAMES[$i]}] :${RELAY_PORTS[$i]} -> ${DEST_IPS[$i]}:${DEST_PORTS[$i]}"
done
echo "  ==============================="
echo ""
read -rp "  确认部署? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "已取消"; exit 0
fi
echo ""

# --------------------------------------------------
echo "[1/4] 内核参数"
# --------------------------------------------------
sudo tee /etc/sysctl.d/99-relay.conf >/dev/null <<'EOF'
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.netfilter.nf_conntrack_max=65536
EOF
sudo sysctl --system >/dev/null
echo "  转发 + BBR + conntrack ✓"

# --------------------------------------------------
echo "[2/4] 禁用 UFW"
# --------------------------------------------------
if systemctl is-active --quiet ufw 2>/dev/null; then
  sudo systemctl disable --now ufw
fi
echo "  ✓"

# --------------------------------------------------
echo "[3/4] 生成 nftables 规则"
# --------------------------------------------------

NFT_VARS="define RELAY_LAN_IP = $RELAY_LAN_IP\n"
for i in $(seq 1 "$LINE_COUNT"); do
  NFT_VARS+="define DEST_IP_${i}   = ${DEST_IPS[$i]}\n"
  NFT_VARS+="define DEST_PORT_${i} = ${DEST_PORTS[$i]}\n"
  NFT_VARS+="define PORT_IN_${i}   = ${RELAY_PORTS[$i]}\n"
done

if [ "$LINE_COUNT" -eq 1 ]; then
  INPUT_PORTS="\$PORT_IN_1"
else
  INPUT_PORTS="\$PORT_IN_1"
  for i in $(seq 2 "$LINE_COUNT"); do
    INPUT_PORTS+=", \$PORT_IN_${i}"
  done
fi

NFT_DNAT=""
for i in $(seq 1 "$LINE_COUNT"); do
  NFT_DNAT+="        # [${LINE_NAMES[$i]}]\n"
  NFT_DNAT+="        meta l4proto { tcp, udp } th dport \$PORT_IN_${i} dnat to \$DEST_IP_${i}:\$DEST_PORT_${i}\n"
done

NFT_SNAT=""
for i in $(seq 1 "$LINE_COUNT"); do
  NFT_SNAT+="        # [${LINE_NAMES[$i]}]\n"
  NFT_SNAT+="        ip daddr \$DEST_IP_${i} meta l4proto { tcp, udp } th dport \$DEST_PORT_${i} snat to \$RELAY_LAN_IP\n"
done

NFT_FWD=""
for i in $(seq 1 "$LINE_COUNT"); do
  NFT_FWD+="        ip daddr \$DEST_IP_${i} meta l4proto { tcp, udp } th dport \$DEST_PORT_${i} accept\n"
done

if [ "$LINE_COUNT" -eq 1 ]; then
  MSS_MATCH="ip daddr \$DEST_IP_1"
else
  MSS_SET="\$DEST_IP_1"
  for i in $(seq 2 "$LINE_COUNT"); do
    MSS_SET+=", \$DEST_IP_${i}"
  done
  MSS_MATCH="ip daddr { ${MSS_SET} }"
fi

sudo tee /etc/nftables.conf >/dev/null <<EOF
#!/usr/sbin/nft -f
# ============================================================
# PO0 中转机 nftables 规则
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')
# ============================================================
flush ruleset

$(echo -e "$NFT_VARS")
# --- 防火墙 ---
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state { established, related } accept
        iif "lo" accept
        ip protocol icmp accept

        # SSH 防扫描: 新连接限速 10/分钟
        tcp dport 22 ct state new limit rate 10/minute burst 5 packets accept
        tcp dport 22 ct state established accept

        # 中转端口
        iifname "$WAN_IF" meta l4proto { tcp, udp } th dport { ${INPUT_PORTS} } accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state { established, related } accept
$(echo -e "$NFT_FWD")
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# --- NAT 转发 ---
table ip nat {
    chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
$(echo -e "$NFT_DNAT")
    }

    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
$(echo -e "$NFT_SNAT")
    }
}

# --- MSS 优化 (防止 MTU 不匹配导致断流) ---
table ip mangle {
    chain forward {
        type filter hook forward priority mangle; policy accept;
        ${MSS_MATCH} tcp flags syn tcp option maxseg size set 1452
    }
}
EOF

sudo nft -c -f /etc/nftables.conf && sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables
echo "  nftables ✓"

# --------------------------------------------------
echo "[4/4] 安装 conntrack"
# --------------------------------------------------
sudo apt install -y conntrack >/dev/null 2>&1
echo "  ✓"

# --------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ 部署完成"
echo "============================================"
echo ""
for i in $(seq 1 "$LINE_COUNT"); do
  echo "  [${LINE_NAMES[$i]}] :${RELAY_PORTS[$i]} -> ${DEST_IPS[$i]}:${DEST_PORTS[$i]}"
done
echo ""
echo "  防火墙: policy drop"
echo "    开放: SSH(22, 限速防扫描) + 中转端口"
echo "    其余入站全部丢弃"
echo "  BBR: 已开启"
echo "  MSS clamp: 1452"
echo "  conntrack max: 65536"
echo ""
echo "  常用命令:"
echo "    sudo nft list ruleset             # 查看规则"
echo "    sudo nft -a list ruleset          # 带 handle 查看"
echo "    sudo conntrack -C                 # 当前连接数"
echo "    sudo conntrack -L -d <落地机IP>    # 查看转发连接"
echo "============================================"

```
