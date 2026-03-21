

```
TG-Video-Bot
应用程序(客户端) ID
:
8fe80a94-3836-43e7-84c0-335be58927b4


对象 ID
:
ce387792-a114-4a12-8861-f9033d3845b7


目录(租户) ID
:
c0c38d57-ec57-4f1d-afaa-f913972f5628
受支持的帐户类型
:
所有 Microsoft 帐户用户


tgvedio

值 ZFQ8Q~cRPC70ZooI9DF.tlbmcHmjn3lFxWirbcqm
密码 1acb3356-89fd-49be-85d2-c82217d8f2d7
```


onedriver


[jack@744446.onmicrosoft.com](mailto:jack@744446.onmicrosoft.com)

P*020434479946om


查看 
cd /root/telegram_media_downloader && tail -f downloader.log

看磁盘
df -h

网页
http://107.174.52.43:5000

最后有效脚本

```
1. 彻底清空正在死锁的进程
pkill -f media_downloader.py && fuser -k 5000/tcp

# 2. 清理数据库残留锁
rm -f /root/telegram_media_downloader/media_downloader.session-journal

# 3. 写入你要求的“原路径镜像”配置
cat <<EOF > /root/telegram_media_downloader/config.yaml
api_hash: 76382bffa9c1c06ec595ea18e34a3e98
api_id: 27042025
chat:
  - chat_id: -1002137757879
    last_read_message_id: 0
  - chat_id: -1001386271793
    last_read_message_id: 0
file_formats:
  video: [all]
  photo: [all]
# 核心：必须保留这两项，确保本地生成 [频道名/日期] 的结构
file_path_prefix:
  - chat_title
  - media_datetime
media_types:
  - photo
  - video
save_path: /root/telegram_media_downloader/downloads
language: EN
upload_drive:
  enable_upload_file: true
  rclone_path: /usr/bin/rclone
  # 指向主目录，Rclone 会自动复刻子目录结构
  remote_dir: "onedrive:TG_Backup"
  after_upload_file_delete: true
# 强烈建议设为 1，确保下载和上传是线性的，防止路径并发错乱
max_download_task: 1
# 设定你要求的日期文件夹格式
date_format: "%Y_%m"
web_host: 0.0.0.0
web_port: 5000
EOF

# 4. 重新启动服务并挂起后台
nohup python3 /root/telegram_media_downloader/media_downloader.py > /root/telegram_media_downloader/downloader.log 2>&1 &
[1] 826738
root@linux:~/telegram_media_downloader# # 1. 彻底清空正在死锁的进程                                                                                              
pkill -f media_downloader.py && fuser -k 5000/tcp

# 2. 清理数据库残留锁
rm -f /root/telegram_media_downloader/media_downloader.session-journal

# 3. 写入你要求的“原路径镜像”配置
cat <<EOF > /root/telegram_media_downloader/config.yaml
api_hash: 76382bffa9c1c06ec595ea18e34a3e98
api_id: 27042025
chat:
  - chat_id: -1002137757879
    last_read_message_id: 0
  - chat_id: -1001386271793
    last_read_message_id: 0
file_formats:
  video: [all]
  photo: [all]
# 核心：必须保留这两项，确保本地生成 [频道名/日期] 的结构
file_path_prefix:
  - chat_title
  - media_datetime
media_types:
  - photo
  - video
save_path: /root/telegram_media_downloader/downloads
language: EN
upload_drive:
  enable_upload_file: true
  rclone_path: /usr/bin/rclone
  # 指向主目录，Rclone 会自动复刻子目录结构
  remote_dir: "onedrive:TG_Backup"
  after_upload_file_delete: true
# 强烈建议设为 1，确保下载和上传是线性的，防止路径并发错乱
max_download_task: 3
# 设定你要求的日期文件夹格式
date_format: "%Y_%m"
web_host: 0.0.0.0
web_port: 5000
EOF

# 4. 重新启动服务并挂起后台
nohup python3 /root/telegram_media_downloader/media_downloader.py > /root/telegram_media_downloader/downloader.log 2>&1 &
[2] 827127
[1]   Terminated              nohup python3 /root/telegram_media_downloader/media_downloader.py > /root/telegram_media_downloader/downloader.log 2>&1
root@linux:~/telegram_media_downloader# 
```
