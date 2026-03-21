import re
from urllib.parse import unquote
from pathlib import Path

def extract_core_info(link):
    """提取链接的核心信息：协议、服务器、端口"""
    link = link.strip()
    
    if link.startswith('ss://'):
        # Shadowsocks链接
        try:
            ss_part = link[5:]
            if '@' in ss_part:
                server_part = ss_part.split('@')[1]
                if ':' in server_part:
                    server = server_part.split(':')[0]
                    port_part = server_part.split(':')[1]
                    port = port_part.split('#')[0] if '#' in port_part else port_part
                    return {
                        'protocol': 'ss',
                        'server': server,
                        'port': port
                    }
        except:
            pass
            
    elif link.startswith('vless://'):
        # VLESS链接
        try:
            vless_part = link[8:]
            if '@' in vless_part:
                server_port_part = vless_part.split('@')[1]
                if ':' in server_port_part:
                    server = server_port_part.split(':')[0]
                    port_part = server_port_part.split(':')[1]
                    port = port_part.split('?')[0] if '?' in port_part else port_part
                    return {
                        'protocol': 'vless',
                        'server': server,
                        'port': port
                    }
        except:
            pass
    
    return None

def check_duplicates_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    landing_pattern = r'## 落地节点\s*(?:<!-- flux-auto:start -->)?(.*?)(?=<!-- flux-auto:end -->|$)'
    landing_match = re.search(landing_pattern, content, re.DOTALL)
    
    if not landing_match:
        return None
    
    landing_section = landing_match.group(1)
    node_pattern = r'### 落地\s+(.+?)\n+```(.+?)```'
    nodes = re.findall(node_pattern, landing_section, re.DOTALL)
    
    if len(nodes) <= 1:
        return None
    
    # 按核心信息分组
    node_groups = {}
    
    for node in nodes:
        node_name = node[0].strip()
        node_link = node[1].strip()
        
        core_info = extract_core_info(node_link)
        if core_info:
            core_key = (
                core_info['protocol'],
                core_info['server'],
                core_info['port']
            )
            
            if core_key not in node_groups:
                node_groups[core_key] = []
            
            node_groups[core_key].append({
                'name': node_name,
                'link': node_link,
                'core': core_info
            })
    
    # 找出重复项
    duplicates = []
    for core_key, items in node_groups.items():
        if len(items) > 1:
            protocol, server, port = core_key
            duplicates.append({
                'protocol': protocol,
                'server': server,
                'port': port,
                'count': len(items),
                'items': items
            })
    
    if duplicates:
        return {
            'file': file_path.name,
            'duplicates': duplicates
        }
    
    return None

def main():
    base_dir = Path("/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料")
    
    all_results = []
    
    for md_file in base_dir.glob('*.md'):
        result = check_duplicates_in_file(md_file)
        if result:
            all_results.append(result)
    
    if all_results:
        print("=" * 80)
        print("落地节点重复检查结果（基于服务器地址+端口）")
        print("=" * 80)
        print()
        
        for result in all_results:
            print(f"文件: {result['file']}")
            print("-" * 80)
            
            for dup in result['duplicates']:
                print(f"重复节点: {dup['protocol'].upper()}://{dup['server']}:{dup['port']}")
                print(f"重复次数: {dup['count']}")
                print(f"所有实例:")
                
                for idx, item in enumerate(dup['items'], 1):
                    print(f"  {idx}. 名称: {item['name']}")
                    print(f"     链接: {item['link'][:100]}...")
                    print()
            
            print("=" * 80)
            print()
    else:
        print("未发现重复的落地节点")

if __name__ == '__main__':
    main()