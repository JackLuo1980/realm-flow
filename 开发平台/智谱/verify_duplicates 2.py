import re

file_path = "/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料/Uzumaru Global-1B.Small - 198.176.54.180.md"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

landing_pattern = r'## 落地节点\s*(?:<!-- flux-auto:start -->)?(.*?)(?=<!-- flux-auto:end -->|$)'
landing_match = re.search(landing_pattern, content, re.DOTALL)

if landing_match:
    landing_section = landing_match.group(1)
    node_pattern = r'### 落地\s+(.+?)\n+```(.+?)```'
    nodes = re.findall(node_pattern, landing_section, re.DOTALL)
    
    print(f"文件: {file_path.split('/')[-1]}")
    print(f"找到 {len(nodes)} 个落地节点\n")
    
    for idx, node in enumerate(nodes, 1):
        node_name = node[0].strip()
        node_link = node[1].strip()
        print(f"节点 {idx}: {node_name}")
        print(f"链接: {node_link}")
        print("-" * 80)
    
    # 检查名称重复但链接不同的情况
    name_groups = {}
    for node in nodes:
        node_name = node[0].strip()
        node_link = node[1].strip()
        if node_name not in name_groups:
            name_groups[node_name] = []
        name_groups[node_name].append(node_link)
    
    print("\n名称重复但链接不同的情况：")
    for name, links in name_groups.items():
        if len(links) > 1:
            print(f"\n节点名称: {name}")
            for idx, link in enumerate(links, 1):
                print(f"  链接{idx}: {link[:100]}...")
                print(f"  是否完全相同: {len(set(links)) == 1}")