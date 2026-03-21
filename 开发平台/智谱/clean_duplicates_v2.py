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
    
    # 查找落地节点区块
    landing_start = content.find('## 落地节点')
    if landing_start == -1:
        return False, "未找到落地节点区块"
    
    # 找到区块结束位置
    flux_end = content.find('<!-- flux-auto:end -->', landing_start)
    if flux_end == -1:
        flux_end = len(content)
    else:
        flux_end = flux_end + len('<!-- flux-auto:end -->')
    
    landing_section = content[landing_start:flux_end]
    
    # 提取所有节点
    node_pattern = r'### 落地\s+(.+?)\n+```(.+?)```'
    nodes = re.findall(node_pattern, landing_section, re.DOTALL)
    
    if len(nodes) <= 1:
        return False, "没有重复项"
    
    # 找出需要保留的节点
    seen_keys = set()
    keep_nodes = []
    
    for node_name, node_link in nodes:
        node_name = node_name.strip()
        node_link = node_link.strip()
        
        core_info = extract_core_info(node_link)
        if core_info:
            core_key = (
                core_info['protocol'],
                core_info['server'],
                core_info['port']
            )
            
            if core_key not in seen_keys:
                seen_keys.add(core_key)
                keep_nodes.append((node_name, node_link))
        else:
            keep_nodes.append((node_name, node_link))
    
    if len(keep_nodes) == len(nodes):
        return False, "没有重复项"
    
    # 重建落地节点区块
    new_landing_section = "## 落地节点\n\n<!-- flux-auto:start -->\n"
    
    for node_name, node_link in keep_nodes:
        new_landing_section += f"### 落地 {node_name}\n\n```\n{node_link}\n```\n\n"
    
    new_landing_section += "<!-- flux-auto:end -->"
    
    # 替换原内容
    new_content = content[:landing_start] + new_landing_section + content[flux_end:]
    
    # 输出到新文件（由于权限限制）
    from pathlib import Path
    output_dir = Path("/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/智谱")
    output_path = output_dir / f"{file_path.stem}_cleaned.md"
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    removed_count = len(nodes) - len(keep_nodes)
    return True, f"成功删除 {removed_count} 个重复项，保留 {len(keep_nodes)} 个节点（已保存到: {output_path.name}）"

def main():
    base_dir = Path("/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料")
    
    files_to_clean = [
        "Uzumaru JPBL1.Small -  142.91.109.151.md",
        "Uzumaru TWHN2.Small - 155.117.188.252.md",
        "Uzumaru TWTBC2.Small - twtbc2.uzuma.ru.md",
        "云曦幻境.md",
        "Uzumaru TWSN3.Small - twsn3.uzuma.ru.md",
        "Uzumaru JPNTT1.Small - 210.231.177.93.md",
        "Uzumaru Global-1.Small - 198.176.54.180.md",
        "Uzumaru Global-1B.Small - 198.176.54.180.md",
        "Uzumaru JPKD2.Small - 142.91.109.89.md",
        # 不清理这两个文件
        # "Heptasky Trinity-V6-IPLC-500G流量款.md",
        # "HaloCloud 深圳三线IEPL.md"
    ]
    
    print("=" * 80)
    print("开始清理重复的落地节点")
    print("=" * 80)
    print()
    
    total_removed = 0
    
    for filename in files_to_clean:
        file_path = base_dir / filename
        if file_path.exists():
            success, message = clean_file(file_path)
            status = "✓" if success else "○"
            print(f"{status} {filename}")
            print(f"  {message}")
            if success:
                removed_count = int(message.split()[1])
                total_removed += removed_count
            print()
        else:
            print(f"✗ {filename}")
            print("  文件不存在")
            print()
    
    print("=" * 80)
    print(f"清理完成，总共删除 {total_removed} 个重复项")
    print("=" * 80)

if __name__ == '__main__':
    main()