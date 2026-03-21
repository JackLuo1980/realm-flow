#!/bin/bash

# RealmFlow 部署脚本 - 修复版
set -e

SERVER_IP="91.233.10.38"
SERVER_PORT="22"
SERVER_USER="root"
SERVER_PASS="8ldnSIgH86xCRQczqQYi"
REMOTE_PATH="/opt/realm-flow"

echo "=== RealmFlow 部署到测试环境 ==="
echo "服务器: $SERVER_IP"
echo ""

# 步骤1: 在本地构建
echo "[1/3] 本地构建..."

# 构建后端
echo "  构建后端..."
cd go-backend
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ../bin/panel-linux ./cmd/server
cd ..

# 构建前端
echo "  构建前端..."
cd react-frontend
npm install
npm run build
cd ..

# 步骤2: 上传文件到服务器
echo "[2/3] 上传文件到服务器..."

# 创建远程目录
sshpass -p "$SERVER_PASS" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "mkdir -p $REMOTE_PATH/{bin,frontend}"

# 上传后端二进制文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT bin/panel-linux $SERVER_USER@$SERVER_IP:$REMOTE_PATH/bin/panel

# 上传前端文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT -r react-frontend/dist/* $SERVER_USER@$SERVER_IP:$REMOTE_PATH/frontend/

# 上传 docker-compose 文件
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT docker-compose.prod.yml $SERVER_USER@$SERVER_IP:$REMOTE_PATH/docker-compose.yml

# 上传 nginx 配置
sshpass -p "$SERVER_PASS" scp -P $SERVER_PORT nginx.conf $SERVER_USER@$SERVER_IP:$REMOTE_PATH/

# 步骤3: 在远程服务器上启动服务
echo "[3/3] 远程服务器启动服务..."

sshpass -p "$SERVER_PASS" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'REMOTE_EOF'

cd /opt/realm-flow

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 停止旧服务
docker-compose down 2>/dev/null || true

# 启动新服务
docker-compose up -d

# 等待服务启动
sleep 10

# 检查服务状态
echo ""
echo "服务状态:"
docker-compose ps

echo ""
echo "面板日志:"
docker-compose logs --tail=20 panel 2>/dev/null || echo "暂无日志"

echo ""
echo "前端日志:"
docker-compose logs --tail=20 frontend 2>/dev/null || echo "暂无日志"

REMOTE_EOF

echo ""
echo "=== 部署完成 ==="
echo "访问地址: http://$SERVER_IP:6366"
echo "API地址: http://$SERVER_IP:6365"
echo "默认登录: admin_user / admin_user"
echo ""
echo "查看日志: ssh $SERVER_USER@$SERVER_IP 'cd /opt/realm-flow && docker-compose logs -f'"
