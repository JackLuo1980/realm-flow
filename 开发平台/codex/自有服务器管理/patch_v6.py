from pathlib import Path
import re


PATH = Path("/root/v6-mng.sh")
PATTERN = r"ddns_api_cf\(\) \{.*?\n\}"
REPLACEMENT = """ddns_api_cf() {
    local ip="$1"; local token="$2"; local domain="$3"; local host="$4"; local email="$5"
    local headers=("-H" "Content-Type: application/json")
    if [[ -n "$email" ]]; then headers+=("-H" "X-Auth-Email: $email" "-H" "X-Auth-Key: $token"); else headers+=("-H" "Authorization: Bearer $token"); fi

    local record_name="$host"
    if [[ "$host" != *."$domain" ]]; then
        record_name="$host.$domain"
    fi

    local zid=$(curl -s "${headers[@]}" "https://api.cloudflare.com/client/v4/zones?name=$domain" | jq -r '.result[0].id')
    if [[ "$zid" == "null" || -z "$zid" ]]; then log "CF Error: ZoneID not found"; return 1; fi
    
    local record_info=$(curl -s "${headers[@]}" "https://api.cloudflare.com/client/v4/zones/$zid/dns_records?type=AAAA&name=$record_name")
    local rid=$(echo "$record_info" | jq -r '.result[0].id')
    local current_ip=$(echo "$record_info" | jq -r '.result[0].content')
    
    if [[ "$current_ip" == "$ip" ]]; then return 0; fi

    local method="POST"; local url="https://api.cloudflare.com/client/v4/zones/$zid/dns_records"; [[ "$rid" != "null" ]] && { method="PATCH"; url="$url/$rid"; }
    local res=$(curl -s -X "$method" "$url" "${headers[@]}" --data "{\"type\":\"AAAA\",\"name\":\"$record_name\",\"content\":\"$ip\",\"proxied\":false}")
    if [[ $(echo "$res" | jq -r '.success') == "true" ]]; then return 0; else log "CF Error: $(echo "$res" | jq -r '.errors[0].message // .messages[0]')"; return 1; fi
}"""


def main() -> None:
    text = PATH.read_text()
    if not re.search(PATTERN, text, flags=re.S):
        raise SystemExit("target block not found")
    PATH.write_text(re.sub(PATTERN, REPLACEMENT, text, count=1, flags=re.S))


if __name__ == "__main__":
    main()
