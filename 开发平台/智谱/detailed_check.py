import re
from urllib.parse import unquote

def decode_url(url):
    try:
        return unquote(url)
    except:
        return url

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
    
    # 检查完全相同的重复（名称+链接都相同）
    exact_duplicates = {}
    
    # 检查URL解码后相同的重复（同一节点的不同编码）
    decoded_duplicates = {}
    
    for node in nodes:
        node_name = node[0].strip()
        node_link = node[1].strip()
        
        # 完全相同的检查
        exact_key = (node_name, node_link)
        if exact_key in exact_duplicates:
            exact_duplicates[exact_key] += 1
        else:
            exact_duplicates[exact_key] = 1
        
        # URL解码后的检查
        decoded_link = decode_url(node_link)
        decoded_key = (node_name, decoded_link)
        if decoded_key in decoded_duplicates:
            decoded_duplicates[decoded_key].append({
                'original': node_link,
                'decoded': decoded_link
            })
        else:
            decoded_duplicates[decoded_key] = [{
                'original': node_link,
                'decoded': decoded_link
            }]
    
    # 整理结果
    result = {
        'file': file_path.name,
        'exact_duplicates': [],
        'decoded_duplicates': []
    }
    
    # 完全相同的重复
    for (name, link), count in exact_duplicates.items():
        if count > 1:
            result['exact_duplicates'].append({
                'name': name,
                'count': count,
                'link': link
            })
    
    # URL解码后相同的重复
    for (name, decoded_link), items in decoded_duplicates.items():
        if len(items) > 1:
            links = [item['original'] for item in items]
            result['decoded_duplicates'].append({
                'name': name,
                'count': len(items),
                'decoded_link': decoded_link,
                'links': links
            })
    
    if result['exact_duplicates'] or result['decoded_duplicates']:
        return result
    
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
        print("落地节点详细检查结果")
        print("=" * 80)
        print()
        
        for result in all_results:
            print(f"文件: {result['file']}")
            print("-" * 80)
            
            if result['exact_duplicates']:
                print("【完全相同的重复】（名称+链接都相同）:")
                for dup in result['exact_duplicates']:
                    print(f"  重复项: {dup['name']}")
                    print(f"  重复次数: {dup['count']}")
                    print(f"  链接: {dup['link'][:80]}...")
                    print()
            
            if result['decoded_duplicates']:
                print("【URL解码后相同的重复】（同一节点的不同编码）:")
                for dup in result['decoded_duplicates']:
                    print(f"  重复项: {dup['name']}")
                    print(f"  重复次数: {dup['count']}")
                    print(f"  解码后链接: {dup['decoded_link'][:80]}...")
                    print(f"  原始链接:")
                    for idx, link in enumerate(dup['links'], 1):
                        print(f"    {idx}. {link[:80]}...")
                    print()
            
            if not result['exact_duplicates'] and not result['decoded_duplicates']:
                print("  未发现重复")
            
            print("=" * 80)
            print()
    else:
        print("未发现重复的落地节点")

if __name__ == '__main__':
    from pathlib import Path
    main()