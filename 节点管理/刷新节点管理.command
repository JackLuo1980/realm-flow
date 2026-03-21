#!/bin/zsh
set -euo pipefail

PYTHON_BIN="/Users/jack/Documents/Playground/.venv-export/bin/python3"
SCRIPT_PATH="/Users/jack/Documents/Playground/obsidian-node-manager/export_nodes.py"
OUTPUT_DIR="/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/节点管理"

echo "正在刷新节点管理表..."
"$PYTHON_BIN" "$SCRIPT_PATH"
echo ""
echo "刷新完成。输出目录：$OUTPUT_DIR"
echo "按任意键关闭窗口。"
read -k 1
