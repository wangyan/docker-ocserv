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

如果需要，去掉对UDP 443端口的支持，命令行修改如下，因为UDP现在似乎受到的干扰比较多，所以仅仅使用TCP 443端口。如果UDP与TCP端口一起打开的话，Anyconnect默认先会试着使用UDP，如果有问题会退回使用TCP端口。
``` 
docker run --name ocserv  --privileged   -p 443:443  -v /var/docker/ocserv:/var/docker/ocserv  -d myidwy/ocserv
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
docker exec -it ocserv bash
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
用户p12证书创建好后，在docker容器的/etc/ocserv/certs/文件夹下，然后可以用docker cp或者scp把p12证书文件拷贝出来

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
