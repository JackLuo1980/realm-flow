import re
from pathlib import Path

def extract_core_info(link):
    """提取链接的核心信息：协议、服务器、端口"""
    link = link.strip()
    
    if link.startswith('ss://'):
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

def clean_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    landing_pattern = r'(## 落地节点\s*(?:<!-- flux-auto:start -->)?)(.*?)(?=<!-- flux-auto:end -->|$)'
    landing_match = re.search(landing_pattern, content, re.DOTALL)
    
    if not landing_match:
        return False, "未找到落地节点区块"
    
    prefix = landing_match.group(1)
    landing_section = landing_match.group(2)
    
    node_pattern = r'(### 落地\s+(.+?)\n+```(.+?)```)'
    nodes = list(re.finditer(node_pattern, landing_section, re.DOTALL))
    
    if len(nodes) <= 1:
        return False, "没有重复项"
    
    # 找出需要保留的节点
    seen_keys = set()
    keep_ranges = []
    
    for node_match in nodes:
        node_name = node_match.group(1).strip()
        node_link = node_match.group(2).strip()
        
        core_info = extract_core_info(node_link)
        if core_info:
            core_key = (
                core_info['protocol'],
                core_info['server'],
                core_info['port']
            )
            
            if core_key not in seen_keys:
                seen_keys.add(core_key)
                keep_ranges.append((node_match.start(), node_match.end()))
        else:
            # 无法提取核心信息的，保留
            keep_ranges.append((node_match.start(), node_match.end()))
    
    if len(keep_ranges) == len(nodes):
        return False, "没有重复项"
    
    # 重建落地节点区块
    new_landing_section = ""
    last_end = 0
    
    for start, end in sorted(keep_ranges):
        new_landing_section += landing_section[last_end:start] + landing_section[start:end]
        last_end = end
    
    # 替换原内容
    new_content = content[:landing_match.start(1)] + prefix + new_landing_section + content[landing_match.end(2):]
    
    # 写回文件
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    removed_count = len(nodes) - len(keep_ranges)
    return True, f"成功删除 {removed_count} 个重复项，保留 {len(keep_ranges)} 个节点"

def main():
    base_dir = Path("/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料")
    
    files_to_clean = [
        "Uzumaru JPBL1.Small - 142.91.109.151.md",
        "Uzumaru TWHN2.Small - 155.117.188.252.md",
        "Uzumaru TWTBC2.Small - twtbc2.uzuma.ru.md",
        "云曦幻境.md",
        "Uzumaru TWSN3.Small - twsn3.uzuma.ru.md",
        "Uzumaru JPNTT1.Small - 210.231.177.93.md",
        "Uzumaru Global-1.Small - 198.176.54.180.md",
        "Uzumaru Global-1B.Small - 198.176.54.180.md",
        "Uzumaru JPKD2.Small - 142.91.109.89.md",
        "Heptasky Trinity-V6-IPLC-500G流量款.md",
        "HaloCloud 深圳三线IEPL.md"
    ]
    
    print("=" * 80)
    print("开始清理重复的落地节点")
    print("=" * 80)
    print()
    
    for filename in files_to_clean:
        file_path = base_dir / filename
        if file_path.exists():
            success, message = clean_file(file_path)
            status = "✓" if success else "○"
            print(f"{status} {filename}")
            print(f"  {message}")
            print()
        else:
            print(f"✗ {filename}")
            print("  文件不存在")
            print()
    
    print("=" * 80)
    print("清理完成")
    print("=" * 80)

if __name__ == '__main__':
    main()