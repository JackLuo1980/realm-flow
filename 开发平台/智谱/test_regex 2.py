import re

file_path = "/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料/Uzumaru Global-1B.Small - 198.176.54.180.md"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 查找落地节点区块
landing_pattern = r'## 落地节点\s*(?:<!-- flux-auto:start -->)?(.*?)(?=<!-- flux-auto:end -->|$)'
landing_match = re.search(landing_pattern, content, re.DOTALL)

if landing_match:
    print("找到落地节点区块！")
    landing_section = landing_match.group(1)
    print(f"区块长度: {len(landing_section)}")
    print(f"区块前200字符: {landing_section[:200]}")
    
    # 提取每个落地节点
    node_pattern = r'### 落地\s+(.+?)\n+```(.+?)```'
    nodes = re.findall(node_pattern, landing_section, re.DOTALL)
    print(f"找到 {len(nodes)} 个落地节点")
    
    for idx, node in enumerate(nodes, 1):
        print(f"\n节点 {idx}:")
        print(f"  名称: {node[0].strip()}")
        print(f"  链接: {node[1].strip()[:80]}...")
else:
    print("未找到落地节点区块")