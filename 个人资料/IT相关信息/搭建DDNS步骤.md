
---
# 

## 搭建 IP4 和 IP6 会发生变化的 VPS 访问，或者有动态公网 IP 的家里 NAS 访问。

1. 在 cf 上获取 “Global API Key”，在个人信息（左上角头像）-配置文件-API 令牌-API 密钥-Global API Key
2. 在 cf 确定一个需要使用的域名，例如 999999.xyz,若是获取 ip4，则添加一条信息，例如 a.999999.xyz,对应的 IP 填入 1.1.1.1（随意填写）。一旦脚本生效会自动获取正确的 IP。IP6 一样操作。
3. 在 vps 运行

curl -sSL https://raw.githubusercontent.com/goodbye-deepsea/ShellScript/refs/heads/main/ddns-modify.sh -o /root/ddns.sh
chmod +x /root/ddns.sh

 2. 然后再次运行

bash /root/ddns.sh

1. 根据提示填入“Global API Key”：e2a7f8549b53d07a1a08987b0a116f9004fa6
2. 根据提示填入cf 账号：luoming.cn@gmail.com
3. 根据提示填入刚刚添加的 cf 域名，一级域名：999999.xyz
4. 根据提示填入刚刚添加的 IP 4的二级域名的头：a.  千万别填写全部域名。若是没有 IP4，直接回车。若是没有 IP6 直接回车，若是有，一样填写域名头。
5. 等待运行完成。再次运行bash /root/ddns.sh，看下反馈的值是不是正确的 IP4 即可。同时去 cf 看下对应的 域名中的 IP 是否发生变化获取到正确的 IP4