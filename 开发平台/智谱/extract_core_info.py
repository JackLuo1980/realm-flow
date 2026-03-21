import re
from urllib.parse import urlparse, parse_qs, unquote

def extract_core_info(link):
    """提取链接的核心信息"""
    link = link.strip()
    
    if link.startswith('ss://'):
        # Shadowsocks链接格式: ss://method:password@server:port#name
        # 先解码base64部分
        try:
            # 提取ss://之后的部分
            ss_part = link[5:]
            # 分离认证信息和服务器信息
            if '@' in ss_part:
                auth_part = ss_part.split('@')[0]
                server_part = ss_part.split('@')[1]
                # 分离服务器和端口
                if ':' in server_part:
                    server = server_part.split(':')[0]
                    port = server_part.split(':')[1].split('#')[0] if '#' in server_part else server_part.split(':')[1]
                    
                    # 尝试解码认证部分
                    try:
                        decoded_auth = unquote(auth_part)
                        return {
                            'protocol': 'ss',
                            'server': server,
                            'port': port,
                            'auth': decoded_auth[:50]  # 只取前50个字符
                        }
                    except:
                        pass
        except Exception as e:
            pass
            
    elif link.startswith('vless://'):
        # VLESS Reality链接格式
        try:
            vless_part = link[8:]
            # 格式: uuid@server:port?params...
            if '@' in vless_part:
                uuid_part = vless_part.split('@')[0]
                server_port_part = vless_part.split('@')[1]
                
                # 提取服务器和端口
                if ':' in server_port_part:
                    server = server_port_part.split(':')[0]
                    port_part = server_port_part.split(':')[1]
                    port = port_part.split('?')[0] if '?' in port_part else port_part
                    
                    return {
                        'protocol': 'vless',
                        'server': server,
                        'port': port,
                        'uuid': uuid_part[:20]  # 只取前20个字符
                    }
        except Exception as e:
            pass
    
    return None

def test_extraction():
    test_links = [
        "ss://2022-blake3-aes-128-gcm%3AvHjmuiHFS%2BUuLQCLSxt3LA%3D%3D@14.116.246.198:21403#test",
        "ss://MjAyMi1ibGFrZTMtYWVzLTEyOC1nY206dkhqbXVpSEZTK1V1TFFDTFN4dDNMQT09@14.116.246.198:21403#test",
        "vless://5bc45954-6b53-43e9-9b28-44e824f742bc@103.192.179.240:20003?encryption=none#test"
    ]
    
    for link in test_links:
        info = extract_core_info(link)
        print(f"链接: {link[:80]}...")
        print(f"核心信息: {info}")
        print()

if __name__ == '__main__':
    test_extraction()