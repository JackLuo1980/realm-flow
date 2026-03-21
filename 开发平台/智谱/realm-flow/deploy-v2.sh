#!/bin/bash

# RealmFlow 部署脚本 v2
set -e

SERVER_IP="91.233.10.38"
SERVER_PORT="22"
SERVER_USER="root"
SERVER_PASS="8ldnSIgH86xCRQczqQYi"
REMOTE_PATH="/opt/realm-flow"

echo "=== RealmFlow 部署脚本 v2 ==="

# 步骤1: 在本地构建二进制文件
echo "[1/5] 本地构建二进制文件..."

# 构建后端
cd go-backend
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ../bin/panel-linux ./cmd/server
cd ..

# 构建前端
cd react-frontend
npm install
npm run build
cd ..

# 步骤2: 上传文件到服务器
echo "[2/5] 上传文件到服务器..."

# 创建远程目录
sshpass -p "$SERVER_PASS" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "mkdir -p $REMOTE_PATH/{bin,frontend}"

# 上传后端二进制文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT bin/panel-linux $SERVER_USER@$SERVER_IP:$REMOTE_PATH/bin/panel

# 上传前端文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT -r react-frontend/dist/* $SERVER_USER@$SERVER_IP:$REMOTE_PATH/frontend/

# 上传 docker-compose 文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT docker-compose.prod.yml $SERVER_USER@$SERVER_IP:$REMOTE_PATH/docker-compose.yml

# 步骤3: 在远程服务器上配置和启动
echo "[3/5] 远程服务器配置..."

sshpass -p "$SERVER_PASS" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << EOF

cd $REMOTE_PATH

# 安装 Docker（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 停止旧服务
docker-compose down 2>/dev/null || true

# 启动新服务
docker-compose up -d

# 等待服务启动
sleep 5

# 检查状态
echo "服务状态:"
docker-compose ps

echo "面板日志:"
docker-compose logs --tail=10 panel 2>/dev/null || echo "暂无日志"

echo "前端日志:"
docker-compose logs --tail=10 frontend 2>/dev/null || echo "暂无日志"

EOF

echo "[4/5] 部署完成"
echo "[5/5] 验证服务..."

# 本地验证服务是否可访问
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP:6366 || echo "前端服务可能还未完全启动"
curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP:6365/api/health || echo "后端服务可能还未完全启动"

echo ""
echo "=== 部署完成 ==="
echo "访问地址: http://$SERVER_IP:6366"
echo "API地址: http://$SERVER_IP:6365"
echo "默认登录: admin_user / admin_user"
