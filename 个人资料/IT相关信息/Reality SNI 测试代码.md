
- - -
### Bash格式代码

```
cat > reality_scan.sh << 'EOF'
#_/bin/bash

# --- 纯净精选域名列表 (无微软/Bing，约50个) ---
DOMAINS=(
# --- Apple 系列 (最稳首选) ---
"itunes.apple.com" "apps.apple.com" "p56-buy.itunes.apple.com"
"statici.icloud.com" "www.icloud.com" "ocsp2.apple.com"
"amp-api-edge.apps.apple.com" "fpinit.itunes.apple.com"
"configuration.ls.apple.com" "xp.apple.com" "gsp-ssl.ls.apple.com"

# --- Tesla & AWS (大厂业务) ---
"www.tesla.com" "location-services-prd.tesla.com"
"www.amazon.com" "aws.amazon.com" "vs.aws.amazon.com"
"a0.awsstatic.com" "prod.log.shortbread.aws.dev"
"checkip.amazonaws.com" "s3.amazonaws.com"

# --- 芯片与硬件巨头 (新增 Nvidia, Cisco) ---
"www.nvidia.com" "images.nvidia.com" "nvidiastreaming.com"
"www.intel.com" "intel.com" "intelcorp.scene7.com"
"www.amd.com" "amd.com" "download.amd.com"
"www.cisco.com" "www.ibm.com" "www.oracle.com"

# --- SaaS 与 知名 CDN (新增 Adobe, Salesforce, Shopify) ---
"www.adobe.com" "cc-api-data.adobe.io" "lcs-cops.adobe.io"
"www.salesforce.com" "slack.com" "cdn.shopify.com"
"www.dropbox.com" "www.box.com"
"cdn.bizible.com" "api.company-target.com"

# --- 冷门黑马 (低调速度快) ---
"gray.video-player.arcpublishing.com" "gray-config-prod.api.cdn.arcpublishing.com"
"c.6sc.co" "j.6sc.co" "cdn77.api.userway.org"
"s.go-mpulse.net" "publisher.liveperson.net"
"logx.optimizely.com" "ce.mf.marsflag.com"
"consent.trustarc.com" "lpcdn.lpsnmedia.net"
)

# --- 策略关键词 ---
# 这里的都是被认为优质的
PREFERRED=("apple.com" "icloud.com" "tesla.com" "nvidia.com" "adobe.com")

# 临时文件
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- 核心测速函数 ---
check_domain() {
    local domain=$1
    local t1=$(date +%s%3N)
    # 单线程模式，超时 1.5s
    if timeout 1.5 openssl s_client -connect $domain:443 -servername $domain < /dev/null > /dev/null 2>&1; then
        local t2=$(date +%s%3N)
        local latency=$((t2 - t1))
        echo "$latency $domain" >> "$TMP_FILE"
        echo -n "." # 打印进度
    else
        echo -n "x"
    fi
}

echo -e "正在进行单线程纯净测速 (${#DOMAINS_ 个域名)..."
echo -e "已剔除所有 Microsoft/Bing 域名，新增 Nvidia/Adobe/Cisco 等。\n"
echo -n "进度: "

# --- 串行执行 ---
for domain in "${DOMAINS[@]}"; do
    check_domain "$domain"
done

echo -e "\n\n============================================================"
printf "%-6s %-10s %-35s %-10s\n" "排名" "类型" "域名" "延迟"
echo -e "============================================================"

if [ ! -s "$TMP_FILE" ]; then
    echo "测试失败，无有效数据。"
    exit 1
fi

SORTED_RESULTS=$(sort -n "$TMP_FILE")

count=0
final_rec=""
rec_found=0
candidate_normal=""

while read -r latency domain; do
    if [ "$latency" -le 0 ]; then continue; fi

    tag="[黑马/通用]"
    color=$GREEN
    is_preferred=0
    
    for p in "${PREFERRED[@]}"; do
        if [[ "$domain" == *"$p"* ]]; then
            tag="[首选大厂]"
            color=$CYAN
            is_preferred=1
            break
        fi
    done

    if [ $count -lt 10 ]; then
        count=$((count+1))
        printf "%-6s ${color}%-10s${NC} %-35s %-10s\n" "[$count]" "$tag" "$domain" "${latency} ms"
    fi

    # 推荐逻辑
    if [ $count -le 15 ] && [ $rec_found -ne 1 ]; then
        # 首选大厂且延迟 < 200ms
        if [ $is_preferred -eq 1 ] && [ "$latency" -lt 200 ]; then
            final_rec=$domain
            final_reason="命中【首选】策略：国际大厂业务 (Apple/Nvidia/Tesla)，延迟优秀。"
            rec_found=1
        elif [ -z "$candidate_normal" ]; then
            candidate_normal=$domain
        fi
    fi

done <<< "$SORTED_RESULTS"

echo -e "============================================================"

if [ -z "$final_rec" ]; then
    if [ -n "$candidate_normal" ]; then
        final_rec=$candidate_normal
        final_reason="策略推荐：首选大厂延迟较高，改用当前速度最快的通用/黑马域名。"
    else
        first_line=$(head -n 1 "$TMP_FILE")
        final_rec=$(echo $first_line | awk '{print $2}')
        final_reason="备用方案：选取了当前测速最快的域名。"
    fi
fi

echo -e "\n💡 最终推荐采用: ${GREEN}${final_rec}${NC}"
echo -e "   理由: ${final_reason}\n"
EOF

chmod +x reality_scan.sh
bash reality_scan.sh
```


### GIthub 一键执行链接
```
bash <(curl -sL https://gist.githubusercontent.com/JackLuo1980/d2ad5b8eea916d476a441c5ce921611f/raw/RealityScanSNI.sh)
```

#_/_/_
