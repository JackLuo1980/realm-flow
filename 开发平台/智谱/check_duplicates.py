import os
import re
from pathlib import Path

def check_duplicates_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 查找落地节点区块
    landing_pattern = r'## 落地节点\s*(?:<!-- flux-auto:start -->)?(.*?)(?=<!-- flux-auto:end -->|$)'
    landing_match = re.search(landing_pattern, content, re.DOTALL)
    
    if not landing_match:
        return None
    
    landing_section = landing_match.group(1)
    
    # 提取每个落地节点（包括标题和链接）
    # 匹配 ### 落地 xxx 到下一个 ### 落地 或区块结束
    node_pattern = r'### 落地\s+(.+?)\n+```(.+?)```'
    nodes = re.findall(node_pattern, landing_section, re.DOTALL)
    
    if len(nodes) <= 1:
        return None
    
    # 按节点名称和链接内容完全匹配来判断重复
    node_counts = {}
    duplicates = []
    
    for node in nodes:
        node_name = node[0].strip()
        node_link = node[1].strip()
        node_key = (node_name, node_link)
        
        if node_key in node_counts:
            node_counts[node_key] += 1
        else:
            node_counts[node_key] = 1
    
    # 按名称分组显示重复项
    node_groups = {}
    for (node_name, node_link), count in node_counts.items():
        if count > 1:
            if node_name not in node_groups:
                node_groups[node_name] = []
            node_groups[node_name].append({
                'link': node_link,
                'count': count
            })
    
    # 转换为输出格式
    for node_name, items in node_groups.items():
        total_count = sum(item['count'] for item in items)
        all_links = []
        for item in items:
            for _ in range(item['count']):
                all_links.append(item['link'])
        
        duplicates.append({
            'name': node_name,
            'count': total_count,
            'links': all_links
        })
    
    if duplicates:
        return {
            'file': file_path.name,
            'duplicates': duplicates
        }
    
    return None

def main():
    base_dir = Path("/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/个人资料/服务器资料")
    
    all_duplicates = []
    
    for md_file in base_dir.glob('*.md'):
        result = check_duplicates_in_file(md_file)
        if result:
            all_duplicates.append(result)
    
    # 输出结果
    if all_duplicates:
        print("=" * 80)
        print("落地节点重复检查结果")
        print("=" * 80)
        print()
        
        for item in all_duplicates:
            print(f"文件: {item['file']}")
            print("-" * 80)
            
            # 按重复次数排序
            sorted_dup = sorted(item['duplicates'], key=lambda x: x['count'], reverse=True)
            
            for dup in sorted_dup:
                print(f"  重复项: {dup['name']}")
                print(f"  重复次数: {dup['count']}")
                print(f"  所有链接:")
                for idx, link in enumerate(dup['links'], 1):
                    print(f"    {idx}. {link[:80]}...")
                print()
            
            print("=" * 80)
            print()
    else:
        print("未发现重复的落地节点")

if __name__ == '__main__':
    main()