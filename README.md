# DockerComposeInstallerDemo 部署文档
DockerComposeInstallerDemo 为 DockerCompose 系统部署脚本，基于Python，Docker，DockerCompose实现。参考本文档即可完成DockerCompose系统的搭建

## 准备条件
- 公网服务器1台（X64架构、2核、4G、100G存储）
- 目前支持系统如下：
    - Deb系：Ubuntu 22.04+, Debian 10+
    - Dnf系：Fedora 39+, CentOS 9+, Rocky 9+, Redhat 9+, Circle 9+, Alibaba(OpenAnolis Edition) 3+, OpenCloudOS 8.8

- 公网域名1个域名以及子域名，列如：
    - 一级域名，xxx.org
    - 二级域名，aa.xxx.org    端口：18080
    - 二级域名，bb.xxx.org  端口：5222
    - 二级域名，cck.xxx.org 端口：1080
> 如有防火墙，请开放相关所需端口。
> 针对云服务器内存较低情况，请设置swap交换分区配置swappiness=100，具体操作请询问GPT！


## 系统依赖
> 具体请参考相关操作系统命令或者官方文档
- Docker24+ Or latest Podman 
- DockerCompose 2.19+ 
- Python3+



## 安装项目

- 克隆代码
```shell
git clone git@github.com:1809719570/docker-compose-installer-demo.git
```

- 执行安装
> 请使用root用户或者sudo执行命令，否则可能会出现莫名其妙的问题！
```shell
cd docker-compose-installer-demo
chmod a+x *.sh

# 请安装指定版本，有beta、latest和指定版本格式：v{VERSION}
./install.sh docker-compose-demo-{ce|ee}:beta       #开发/企业测试版
./install.sh docker-compose-demo-{ce|ee}:latest     #开发/企业最新版本
./install.sh docker-compose-demo-{ce|ee}:v{VERSION} #开发/企业指定版本
```
## 启动服务
```shell
# build参数可选，启动时重新构建镜像，用在修改docker-compose配置重新启动时
./startup.sh [--build]
```

## 配置服务

首次安装需要进行该步骤相关配置操作

### 配置xxx服务
- 登录：http://xxx:8080/admin/
- 输入帐号: `admin` 密码: `xxx` 登录后台.
- 到左上角，选择:...
- ...
#### 配置 xxx服务
- 到xxx目录
- ...

### 登录测试
- xxx服务，请访问：https://xxx:1080
- xxx管理服务，请访问：http://xxx:9090/



## 停止服务
```shell
./shutdown.h
```

## 卸载项目

```shell
# 该卸载仅仅是移除容器
# db数据可能因为权限无法删除需要手动执行（sudo）
./uninstall.sh

# 请删除相关本地缓存镜像,如下：
docker rmi xxx/xxx
docker rmi xxx

# 删除本项目
sudo rm -rf docker-compose-installer-demo
```

## 更新系统
- 更新项目
```shell
# 重置版本
git reset --hard
# 拉取最新代码
git pull origin main
```
- 执行安装
> 请参考上面的安装部门


- 启动服务即可


## 配置Nginx反向代理 

### 为 OkStack
```
    location / {
        proxy_cache off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:1080/;
    }

```

### 为 Keycloak
文件：depends/docker-compose.yml
```yaml
    - KC_HOSTNAME_STRICT=false
    - KC_PROXY_ADDRESS_FORWARDING=true
    - KC_PROXY_HEADERS=xforwarded
```

Nginx 配置
```
listen 443;
    listen [::]:443;
    server_name kc.okstar.org.cn;
    location / {
        proxy_cache off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_pass http://localhost:8080/;
    }
```

## 配置存储服务
本系统采用minio，配置信息位于`depends/docker-compose.yml`可根据需要仔细调整，初始内容如下：
```yml
  minio:
    image: "quay.io/minio/minio"
    restart: unless-stopped
    environment:
      MINIO_ACCESS_KEY: "minio"
      MINIO_SECRET_KEY: "minio1234567#"
    volumes:
      - ${DATA_DIR}/minio/data:/data
    ports:
      - 7001:7001
      - 7002:7002
    command: server -address ":7001" --console-address ":7002" /data  
    privileged: true
```
### 配置访问权限
- 访问管理后台`http://{host}:7002/`，输入配置的用户和密码
- 创建名称为`ok-stack`的Bucket，配置`Access Policy`为`Public`
- 进入`Access Keys`菜单，创建`Access key`和`Secret Key`,并且两个备份保存。

### 配置Nginx代理
> 为了便于浏览器域名访问，可以nginx配置如下：
```conf
server {
    listen 443;
    listen [::]:443;
    server_name s3.{host}; # 域名

    location / {
        proxy_cache off;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:7001/;
    }
}
```

### 后台配置Minio关联
- 进入`ok-stack`后台管理，`系统管理`/`集成设置`。
- 定位到`Minio 设置`菜单，参考如下配置。
```
访问Url：https://s3.{host}
写入Url：http://{host}:7001

# 写入对应Access Key和Secret Key
Access Key：frCFnmZZRlxq5FzssHmE
Secret Key：**********

```
- 保存即可。