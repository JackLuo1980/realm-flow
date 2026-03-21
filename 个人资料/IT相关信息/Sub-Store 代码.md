---
id: 8E0565C4-06CF-4D21-A7D7-40C73FA9B509
tags:
  - _
  - _IT_
---
- - -
## 服务器链接
```
http://156.238.251.254:3001?api=http://156.238.251.254:3001/MgT1Uga9q1wc9i9471DF
```

## 部署代码
```
docker run -it -d \
  --restart=always \
  -e "SUB_STORE_CRON=55 23 * * *" \
  -e SUB_STORE_FRONTEND_BACKEND_PATH=/MgT1Uga9q1wc9i9471DF\
  -p 3001:3001 \
  -v /etc/sub-store:/opt/app/data \
  --name sub-store \
  xream/sub-store
```

#_/_IT_