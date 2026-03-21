#!/bin/bash

# 自动部署到测试环境
SERVER="91.233.10.38"
USER="root"
PASSWORD="8ldnSIgH86xCRQczqQYi"

echo "=== 上传文件 ==="
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER "mkdir -p /opt/realm-flow"
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no ./bin/panel-linux $USER@$SERVER:/opt/realm-flow/panel
sshpass -p "$PASSWORD" scp -P 22 -o StrictHostKeyChecking=no -r ./react-frontend/dist $USER@$SERVER:/opt/realm-flow/

echo "=== 配置和启动服务 ==="
sshpass -p "$PASSWORD" ssh -p 22 -o StrictHostKeyChecking=no $USER@$SERVER << 'EOF'
cd /opt/realm-flow

# 设置权限
chmod +x panel
mkdir -p logs

# 安装 PostgreSQL
apt-get update -qq
apt-get install -y postgresql postgresql-contrib

# 创建数据库和用户
su - postgres << 'POSTGRES'
psql -c "CREATE USER realmflow WITH PASSWORD 'realmflow';"
psql -c "CREATE DATABASE realmflow OWNER realmflow;"
POSTGRES

# 安装 nginx
apt-get install -y nginx

# 配置 nginx
cat > /etc/nginx/sites-available/realmflow << 'NGINX'
server {
    listen 80;
    server_name _;
    root /opt/realm-flow/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:6365/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/realmflow /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# 创建 systemd 服务
cat > /etc/systemd/system/realmflow-panel.service << 'SYSTEMD'
[Unit]
Description=RealmFlow Panel
After=network.target postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/realm-flow
ExecStart=/opt/realm-flow/panel
Environment=DATABASE_URL=postgres://realmflow:realmflow@localhost:5432/realmflow?sslmode=disable
Environment=JWT_SECRET=your-secret-key-change-in-production
Environment=PORT=6365
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SYSTEMD

# 启动服务
systemctl daemon-reload
systemctl enable realmflow-panel
systemctl start realmflow-panel

# 等待服务启动
sleep 5

# 检查服务状态
systemctl status realmflow-panel --no-pager

echo ""
echo "=== 部署完成 ==="
echo "前端地址: http://91.233.10.38"
echo "后端 API: http://91.233.10.38/api"
echo "默认登录: admin_user / admin_user"
EOF

echo "部署完成！"
