#!/bin/bash

# RealmFlow 远程部署脚本
# 测试环境服务器信息
SERVER_IP="91.233.10.38"
SERVER_PORT="22"
SERVER_USER="root"
SERVER_PASS="8ldnSIgH86xCRQczqQYi"
REMOTE_PATH="/opt/realm-flow"

echo "=== RealmFlow 远程部署脚本 ==="

# 使用 SSH 在远程服务器上执行部署
sshpass -p "$SERVER_PASS" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'REMOTE_SCRIPT'

# 安装 Docker（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# 安装 Docker Compose（如果未安装）
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 创建项目目录
mkdir -p /opt/realm-flow
cd /opt/realm-flow

# 克隆或更新代码
if [ -d ".git" ]; then
    echo "更新代码..."
    git pull origin main
else
    echo "克隆代码仓库..."
    # 这里需要替换为实际的 GitHub 仓库地址
    git clone https://github.com/yourusername/realm-flow.git .
fi

# 构建并启动服务
echo "构建并启动服务..."
docker-compose down 2>/dev/null || true
docker-compose up --build -d

# 等待服务启动
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

# 检查日志
echo "面板服务日志:"
docker-compose logs --tail=20 panel

echo "前端服务日志:"
docker-compose logs --tail=20 frontend

echo "=== 部署完成 ==="
echo "访问地址: http://91.233.10.38:6366"
echo "默认登录: admin_user / admin_user"

REMOTE_SCRIPT

echo "远程部署执行完成"
