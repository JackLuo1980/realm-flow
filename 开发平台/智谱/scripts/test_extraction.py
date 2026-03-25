#!/usr/bin/env python3
from docx import Document
from pathlib import Path

BASE_DIR = Path.home() / "Desktop" / "新版简历"
original_path = BASE_DIR / "原始简历" / "人员简历_何文进_202603.docx"

doc = Document(original_path)

info = {}
for table in doc.tables:
    for row in table.rows[:10]:
        for i in range(len(row.cells) - 1):
            cell_text = row.cells[i].text.strip()
            next_cell_text = row.cells[i + 1].text.strip()
            
            if '姓名' in cell_text and cell_text != '姓名' and cell_text != '姓名' * len(cell_text):
                if 'name' not in info:
                    info['name'] = next_cell_text
                    print(f'找到姓名: "{cell_text}" -> "{next_cell_text}"')
            elif '工作年限' in cell_text and cell_text != '工作年限':
                if 'work_years' not in info:
                    info['work_years'] = next_cell_text
                    print(f'找到工作年限: "{cell_text}" -> "{next_cell_text}"')
            elif '毕业学校' in cell_text and cell_text != '毕业学校':
                if 'school' not in info:
                    info['school'] = next_cell_text
                    print(f'找到毕业学校: "{cell_text}" -> "{next_cell_text}"')
            elif '个人简介' in cell_text and cell_text != '个人简介':
                if 'summary' not in info:
                    info['summary'] = next_cell_text
                    print(f'找到个人简介: "{cell_text}" -> "{next_cell_text}"')

print(f'\n最终提取的信息: {info}')
