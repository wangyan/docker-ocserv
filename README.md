# DOCKER-OCSERV

`docker-ocserv `  是基于 `debian:jessie` 构建的Docker镜像，镜像默认安装配置了`OpenConnect` 服务端，支持证书和密码认证登陆。

# 一般使用

``` 
docker run --name ocserv \
--privileged \
-p 443:443 -p 443:443/udp \
-v /var/docker/ocserv:/var/docker/ocserv \
-d myidwy/ocserv
```

# 配置文件

- 主配置文件：`/etc/ocserv/ocserv.conf`
- 用户账号密码：`/etc/ocserv/ocpasswd`
- 证书目录：`/etc/ocserv/certs`

# 常用命令

查看日志

``` 
docker logs ocserv
```

进入容器：

``` 
docker exec -it shadowsocks bash
```

创建用户

``` 
docker exec -it ocserv ocpasswd -c /etc/ocserv/ocpasswd <your_username>
```

删除用户

``` 
docker exec -it ocserv ocpasswd -c /etc/ocserv/ocpasswd -d <your_username>
```

创建用户p12证书

注：创建证书需要定义一个key和证书密码

``` 
/cert.sh <your_username>
```

重启服务

``` 
supervisortl restart ocserv
```

# 环境变量

用于自定义证书，一般不用理会。

| 变量名          | 默认值             |
| ------------ | --------------- |
| **CA_CN**    | VPN CA          |
| **CA_ORG**   | Big Corp        |
| **CA_DAYS**  | -1              |
| **SRV_CN**   | VPN server      |
| **SRV_DNS**  | www.example.com |
| **SRV_ORG**  | My Company      |
| **SRV_DAYS** | -1              |