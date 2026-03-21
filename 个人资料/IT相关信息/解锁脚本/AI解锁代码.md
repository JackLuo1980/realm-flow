{
  "log": {
    "access": "none",
    "dnsLog": false,
    "error": "",
    "loglevel": "warning",
    "maskAddress": ""
  },
  "api": {
    "tag": "api",
    "services": \[
      "HandlerService",
      "LoggerService",
      "StatsService"
    \]
  },
  "inbounds": \[
    {
      "tag": "api",
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "tunnel",
      "settings": {
        "address": "127.0.0.1"
      }
    }
  \],
  "outbounds": \[
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "AsIs",
        "redirect": "",
        "noises": \[\]
      }
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    },
    {
      "protocol": "shadowsocks",
      "settings": {
        "servers": \[
          {
            "address": "103.196.20.133",
            "port": 23924,
            "password": "Ix1t1jwvtU79QYJKylrx6EdfF0W2tvZ3Ea8rMLK88dgj",
            "method": "aes-128-gcm"
          }
        \]
      },
      "tag": "AI",
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "header": {
            "type": "none"
          }
        }
      }
    },
    {
      "protocol": "shadowsocks",
      "settings": {
        "servers": \[
          {
            "address": "halo.744445.xyz",
            "port": 10257,
            "password": "h0BC2uJkJIsTExB+eetCUf6bdQHRbKWKEXWDaPHkjnI=",
            "method": "aes-128-gcm"
          }
        \]
      },
      "tag": "AI SG",
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "header": {
            "type": "none"
          }
        }
      }
    }
  \],
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true,
      "statsOutboundDownlink": false,
      "statsOutboundUplink": false
    }
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": \[
      {
        "type": "field",
        "domain": \[
          "geosite:openai",
          "geosite:tiktok",
          "geosite:google",
          "geosite:microsoft",
          "domain:claude.com",
          "domain:translate.googleapis.com",
          "domain:copilot.microsoft.com",
          "domain:bing.com",
          "domain:login.live.com",
          "domain:login.microsoftonline.com"
        \],
        "outboundTag": "AI SG"
      },
      {
        "type": "field",
        "inboundTag": \[
          "api"
        \],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "ip": \[
          "geoip:private"
        \]
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": \[
          "bittorrent"
        \]
      }
    \]
  },
  "stats": {},
  "metrics": {
    "tag": "metrics_out",
    "listen": "127.0.0.1:11111"
  }
}