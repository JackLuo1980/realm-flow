---
id: B97A876B-5A64-407C-AAC3-9C3B3B257599
tags:
  - _
  - _IT_
---
- - -

## 查看DNS信息
```
cat /etc/resolv.conf
```


## RFC DNS修改
```
echo "nameserver 22.22.22.22" | sudo tee /etc/resolv.conf
```

## Zouter DNS修改
```
echo "nameserver 151.243.229.229" | sudo tee /etc/resolv.conf

```


## 个人搭建DNS解析服务器修改
```
echo "nameserver 128.241.253.8" | sudo tee /etc/resolv.conf
```


#_/_IT_