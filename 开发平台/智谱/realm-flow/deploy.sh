#!/bin/bash

SERVER="91.233.10.38"
PORT="22"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"
REMOTE_PATH="/opt/realm-flow"

echo "=== RealmFlow 部署到测试环境 ==="

# 安装 sshpass（如果需要）
if ! command -v sshpass &> /dev/null; then
    echo "正在安装 sshpass..."
    brew install hudochenkov/sshpass/sshpass 2>/dev/null || {
        echo "请先安装 sshpass: brew install hudochenkov/sshpass/sshpass"
        exit 1
    }
fi

# 创建远程目录结构
echo "创建远程目录..."
sshpass -p "$PASSWORD" ssh -p $PORT -o StrictHostKeyChecking=no $USER@$SERVER "mkdir -p $REMOTE_PATH/{bin,dist,logs}"

# 上传后端二进制文件
echo "上传后端服务..."
sshpass -p "$PASSWORD" scp -P $PORT -o StrictHostKeyChecking=no ./bin/panel-linux $USER@$SERVER:$REMOTE_PATH/bin/panel

# 上传前端文件
echo "上传前端文件..."
sshpass -p "$PASSWORD" scp -P $PORT -o StrictHostKeyChecking=no -r ./react-frontend/dist/* $USER@$SERVER:$REMOTE_PATH/dist/

# 上传 Agent
echo "上传 Agent..."
sshpass -p "$PASSWORD" scp -P $PORT -o StrictHostKeyChecking=no ./bin/agent $USER@$SERVER:$REMOTE_PATH/bin/

# 在远程服务器上配置和启动
sshpass -p "$PASSWORD" ssh -p $PORT -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
set -e

cd /opt/realm-flow

# 安装必要的工具
apt-get update
apt-get install -y curl wget ca-certificates

# 创建 Docker Compose 配置
cat > docker-compose.yml << 'DOCKER_COMPOSE'
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    container_name: realmflow-postgres
    environment:
      POSTGRES_DB: realmflow
      POSTGRES_USER: realmflow
      POSTGRES_PASSWORD: realmflow
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U realmflow"]
      interval: 5s
      timeout: 5s
      retries: 5

  panel:
    image: golang:1.21-alpine
    container_name: realmflow-panel
    working_dir: /app
    command: /app/bin/panel
    volumes:
      - ./bin/panel:/app/bin/panel
    ports:
      - "6365:6365"
    environment:
      - DATABASE_URL=postgres://realmflow:realmflow@postgres:5432/realmflow?sslmode=disable
      - JWT_SECRET=your-secret-key-change-in-production
      - PORT=6365
    depends_on:
      postgres:
        condition: service_healthy
    restart: always

  frontend:
    image: nginx:alpine
    container_name: realmflow-frontend
    volumes:
      - ./dist:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "6366:80"
    depends_on:
      - panel
    restart: always

volumes:
  postgres_data:
DOCKER_COMPOSE

# 创建 nginx 配置
cat > nginx.conf << 'NGINX_CONF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://panel:6365/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_CONF

# 安装 Docker（如果需要）
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | sh || {
        wget -qO- https://get.docker.com | sh
    }
    systemctl start docker
    systemctl enable docker
fi

# 安装 Docker Compose（如果需要）
if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || {
        wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)"
    }
    chmod +x /usr/local/bin/docker-compose
fi

# 停止旧服务
echo "停止旧服务..."
docker-compose down 2>/dev/null || true
docker rm -f realmflow-panel realmflow-frontend realmflow-postgres 2>/dev/null || true

# 启动新服务
echo "启动服务..."
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 20

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

# 查看日志
echo ""
echo "=== 面板服务日志 ==="
docker logs realmflow-panel --tail=20

echo ""
echo "=== 前端服务日志 ==="
docker logs realmflow-frontend --tail=10

echo ""
echo "=== 数据库服务日志 ==="
docker logs realmflow-postgres --tail=10

echo ""
echo "=== 部署完成 ==="
echo "访问地址: http://91.233.10.38:6366"
echo "后端 API: http://91.233.10.38:6365/api"
echo "默认登录: admin_user / admin_user"
EOF

echo "部署完成！"
