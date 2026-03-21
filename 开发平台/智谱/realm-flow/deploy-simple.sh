#!/bin/bash

# RealmFlow Docker 简单部署脚本

SERVER="91.233.10.38"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"

echo "=== RealmFlow Docker 部署 ==="

# 检查 sshpass
if ! command -v sshpass &> /dev/null; then
    echo "安装 sshpass..."
    brew install hudochenkov/sshpass/sshpass
fi

# 创建远程目录
echo "准备远程服务器..."
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER "mkdir -p /opt/realm-flow"

# 上传所有文件
echo "上传代码到服务器..."
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no -r \
    ./docker-compose.yml \
    ./go-backend \
    ./react-frontend \
    $USER@$SERVER:/opt/realm-flow/

# 在远程服务器上构建和部署
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
cd /opt/realm-flow

# 检查并安装 Docker
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    apt-get update && apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
fi

# 检查并安装 docker-compose
if ! command -v docker &> /dev/null; then
    echo "安装 docker-compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 停止旧服务
docker-compose down 2>/dev/null || true

# 构建并启动
echo "构建并启动服务..."
docker-compose up -d --build

# 等待服务启动
sleep 20

# 显示状态
docker-compose ps

echo ""
echo "=== 部署完成 ==="
echo "前端地址: http://91.233.10.38:6366"
echo "后端 API: http://91.233.10.38:6365/api"
echo "默认登录: admin_user / admin_user"
EOF

echo "部署完成！"
