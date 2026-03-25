#!/usr/bin/env python3
from docx import Document
from pathlib import Path

BASE_DIR = Path.home() / "Desktop" / "新版简历"
original_path = BASE_DIR / "原始简历" / "人员简历_何文进_202603.docx"
doc = Document(original_path)

print("=== 原始简历完整内容 ===")
for i, table in enumerate(doc.tables):
    print(f"\n表格 {i+1}:")
    for row_idx, row in enumerate(table.rows[:30]):
        row_cells = []
        for cell in row.cells[:8]:
            cell_text = cell.text.strip()
            if cell_text:
                row_cells.append(f"[{cell_text[:25]}]")
            else:
                row_cells.append("[]")
        if any(c != "[]" for c in row_cells):
            print(f"  行{row_idx}: {' '.join(row_cells)}")
