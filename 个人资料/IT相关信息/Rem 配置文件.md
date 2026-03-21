
---
 Kaze HKG 配置文件
 
```
{
  "log": {
    "loglevel": "info"
  },
  "dns": {
    "queryStrategy": "UseIPv4"
  },
  "inbounds": [
    {
      "tag": "SS-50000",
      "port": 50000,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    },
    {
      "tag": "SS-52990",
      "port": 52990,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    },
    {
      "tag": "SS-53990",
      "port": 53990,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    },
    {
      "tag": "SS-54990",
      "port": 55990,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "DIRECT",
      "protocol": "freedom",
      "streamSettings": {
        "sockopt": {
          "domainStrategy": "UseIPv4"
        }
      }
    },
    {
      "tag": "hkt",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "port": 10000,
            "users": [],
            "address": "socks-1.kconnect.to"
          }
        ]
      }
    },
    {
      "tag": "hinet",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "port": 10000,
            "users": [],
            "address": "socks-2.kconnect.to"
          }
        ]
      }
    },
    {
      "tag": "cmhk",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "port": 10000,
            "users": [],
            "address": "socks-3.kconnect.to"
          }
        ]
      }
    },
    {
      "tag": "BLOCK",
      "protocol": "blackhole"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["SS-50000"],
        "outboundTag": "DIRECT"
      },
      {
        "type": "field",
        "ip": ["geoip:private", "geoip:cn"],
        "outboundTag": "BLOCK"
      },
      {
        "type": "field",
        "inboundTag": ["SS-52990"],
        "outboundTag": "hkt"
      },
      {
        "type": "field",
        "inboundTag": ["SS-53990"],
        "outboundTag": "hinet"
      },
      {
        "type": "field",
        "inboundTag": ["SS-54990"],
        "outboundTag": "cmhk"
      }
    ],
    "domainStrategy": "AsIs"
  }
}
```

vless

```
{
"log": {
    "loglevel": "info"
  },
  "inbounds": [
    {
      "tag": "test2",
      "port": 30004,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "www.amd.com:443",
          "show": false,
          "xver": 0,
          "spiderX": "",
          "shortIds": [
            "42aeec",
            "66c8bd6b1002427d",
            "5a1f",
            "6c",
            "adfb6126",
            "ce557a621e",
            "5fc062b8b4c2b9",
            "e4cfaf01e274"
          ],
          "publicKey": "EeCROc9SC8vUNREpxNk9D8yHkXhm5GzyaFRc4jiEl10",
          "privateKey": "m5mIb4EXjqkcfDDHRW_pU7Vz-hehwNgR5Hi2HFCO4S0",
          "serverNames": [
            "www.amd.com"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "DIRECT",
      "protocol": "freedom"
    },
    {
      "tag": "BLOCK",
      "protocol": "blackhole"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "protocol": [
          "bittorrent"
        ],
        "outboundTag": "BLOCK"
      }
    ]
  }
}

```



客户端命令

```
mkdir /opt/remnanode && cd /opt/remnanode && touch docker-compose.yml
```


```
docker compose up -d
```



```
{
 "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "ss2022aes128",
      "port": 51990,
      "listen": null,
      "protocol": "shadowsocks",
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "clients": [],
        "ivCheck": false,
        "network": "tcp,udp",
        "password": "vN1Oclr1w2wRgetqMvcGZQ=="
      },
      "sniffing": {
        "enabled": false,
        "routeOnly": false,
        "destOverride": [
          "http",
          "tls",
          "quic",
          "fakedns"
        ],
        "metadataOnly": false
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "header": {
            "type": "none"
          },
          "acceptProxyProtocol": false
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "blocked",
      "protocol": "blackhole"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "source": [
          "geoip:private",
          "geoip:cn"
        ],
        "inboundTag": [
          "inbound-4357"
        ],
        "outboundTag": "blocked"
      }
    ],
    "domainStrategy": "AsIs"
  }
}

```
