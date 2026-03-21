#!/bin/bash

# RealmFlow 简化部署 - 直接运行 Docker

SERVER="91.233.10.38"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"

echo "=== RealmFlow 简化部署 ==="

# 准备远程服务器
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
set -e

# 安装必要工具
apt-get update -qq
apt-get install -y docker.io docker-compose wget

# 创建目录
mkdir -p /opt/realm-flow/{bin,dist}

cd /opt/realm-flow

# 下载预编译的二进制文件（如果还没上传）
if [ ! -f bin/panel ]; then
    echo "请先上传 panel 二进制文件到 /opt/realm-flow/bin/panel"
    exit 1
fi

if [ ! -d dist ]; then
    echo "请先上传前端文件到 /opt/realm-flow/dist/"
    exit 1
fi

# 确保 panel 可执行
chmod +x bin/panel

# 创建 docker-compose.yml
cat > docker-compose.yml << 'COMPOSE'
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
    command: /app/panel
    volumes:
      - ./bin/panel:/app/panel
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
COMPOSE

# 创建 nginx.conf
cat > nginx.conf << 'NGINX'
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
NGINX

echo "配置文件已创建"
EOF

echo "上传文件到服务器..."

# 上传后端
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no ./bin/panel-linux $USER@$SERVER:/opt/realm-flow/bin/panel

# 上传前端
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no -r ./react-frontend/dist/* $USER@$SERVER:/opt/realm-flow/dist/

echo "在服务器上启动服务..."

sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
cd /opt/realm-flow

# 停止旧服务
docker-compose down 2>/dev/null || true

# 启动新服务
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 20

# 检查状态
docker-compose ps

# 查看日志
echo ""
echo "=== 面板日志 ==="
docker logs realmflow-panel --tail=20

echo ""
echo "=== 前端日志 ==="
docker logs realmflow-frontend --tail=10

echo ""
echo "=== 数据库日志 ==="
docker logs realmflow-postgres --tail=10

echo ""
echo "=== 部署完成 ==="
echo "前端地址: http://91.233.10.38:6366"
echo "后端 API: http://91.233.10.38:6365/api"
echo "默认登录: admin_user / admin_user"
EOF

echo "部署完成！"
