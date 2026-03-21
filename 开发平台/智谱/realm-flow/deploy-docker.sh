#!/bin/bash

# RealmFlow Docker 一键部署到测试环境
# 91.233.10.38:22, root/8ldnSIgH86xCRQczqQYi

set -e

echo "=== RealmFlow Docker 部署 ==="

# 检查 docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 请先安装 docker-compose"
    exit 1
fi

# 构建 Docker 镜像
echo "构建 Docker 镜像..."
docker-compose -f docker-compose.yml build

# 部署到远程服务器
SERVER="91.233.10.38"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"

echo "部署到远程服务器..."

# 创建远程目录并上传配置
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
mkdir -p /opt/realm-flow
cd /opt/realm-flow
EOF

# 上传 docker-compose.yml
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no ./docker-compose.yml $USER@$SERVER:/opt/realm-flow/

# 在远程服务器启动服务
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
cd /opt/realm-flow

# 拉取并启动服务
docker-compose pull || true
docker-compose down 2>/dev/null || true
docker-compose up -d

# 等待服务启动
sleep 15

# 显示状态
docker-compose ps
docker logs realmflow-panel --tail=20

echo ""
echo "=== 部署完成 ==="
echo "前端地址: http://91.233.10.38:6366"
echo "后端 API: http://91.233.10.38:6365/api"
echo "默认登录: admin_user / admin_user"
EOF

echo "部署完成！"
