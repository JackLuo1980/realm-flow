#!/bin/bash

# 在远程服务器上直接部署 RealmFlow

echo "=== RealmFlow 远程 Docker 部署 ==="

SERVER="91.233.10.38"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"

# 创建远程目录并准备 docker-compose.yml
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
mkdir -p /opt/realm-flow
cd /opt/realm-flow

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
    command: sh -c "wget -O panel http://localhost:8000/panel || true && ./panel"
    volumes:
      - ./panel:/app/panel
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

echo "Docker 配置已创建"
EOF

echo "上传编译好的二进制文件和前端..."
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no \
    ./bin/panel-linux \
    $USER@$SERVER:/opt/realm-flow/panel

sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no -r \
    ./react-frontend/dist/* \
    $USER@$SERVER:/opt/realm-flow/dist/

echo "在远程服务器上启动服务..."
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
cd /opt/realm-flow

# 确保 Docker 已安装
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    apt-get update && apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
fi

# 停止旧服务
docker-compose down 2>/dev/null || true
docker rm -f realmflow-panel realmflow-frontend realmflow-postgres 2>/dev/null || true

# 启动服务
docker-compose up -d

# 等待服务启动
sleep 15

# 显示状态
docker-compose ps

echo ""
echo "=== 部署完成 ==="
echo "前端地址: http://91.233.10.38:6366"
echo "后端 API: http://91.233.10.38:6365/api"
echo "默认登录: admin_user / admin_user"

# 查看日志
echo ""
echo "=== 面板日志 ==="
docker logs realmflow-panel --tail=20
EOF

echo "部署完成！"
