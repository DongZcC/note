# 1、Docker 组件

## docker 客户端和服务器

docker客户端像docker服务器或者守护进程发出请求，服务端或者守护进程将完成所有工作并返回结果。

## docker 镜像

镜像是构建Docker世界的基石。用户基于镜像来运行自己的容器。

镜像也是Docker生命周期中的构建部分。镜像是基于Union文件系统的一种层式结构，有一系列指令一步一步构建出来：

* 添加一个文件
* 执行一个命令
* 打开一个端口

可以把镜像当做容器的源代码。

## Registry

docker用Registry来保存用户构建的镜像。registry分为公共和私有两种。

Docker公司运营的公共Registry叫做DockerHub 。

## 容器

Docker可以帮你构建和部署容器，你只需要把自己的应用程序或服务打包放进容器即可。

容器是基于镜像启动起来的，容器中可以运行一个或多个进程，我们可以认为，镜像是Docker生命周期中的构建或打包阶段，而容器则是启动执行阶段。

Docker容器：

- 一个镜像格式
- 一系列标准的操作
- 一个执行环境

# 2、Docker 入门

## 运行第一个docker容器

命令：

```bash
docker run -i -t ubuntu /bin/bash
```

![image-20180520151203136](/Users/dzczyw/Documents/docker/images/image-20180520151203136.png)



- 首先，告诉docker执行docker run命令， 并指定了 -i  和 -t 两个命令行参数。

-i : 保证容器中STDIN是开启的，

-t：告诉Docker为要创建的容器，分配一个伪tty终端。这样新创建的容器才能提供一个交互式shell。

如果要在命令行下创建一个我们能与之进行交互的容器，而不是运行一个后台服务的容器，则这两个参数是最基本的参数。  可以用docker help run,  man docker-run 

- 告诉Docker基于什么镜像来创建容器，示例中使。用的事ubunt

  （docker会首先检查本地是否存在ubuntu镜像，如果本地没后则会连接官方维护Docker Hub Registry一旦找到就会下载，并保存到本地宿主机中）

- Docker在文件系统内部用这个镜像创建了一个新容器，该容器拥有自己的网络、IP地址，以及一个用来和宿主机进行通信的桥接网络接口。

- 告诉Docker在新容器中执行什么命令， 在本例中 运行 /bin/bash 启动了一个bash shell



## 关闭容器

使用 exit 退出容器 。并关闭容器

如果想只退出容器，不关闭 需要按Ctrl+P+Q进行退出容器 



## docker ps 命令

docker ps - a 可以列出所有的容器，包括正在运行的和已经停止的。

docker ps -l  会列出最后一次运行的容器。包括正在运行的和已经停止的。

有三种方式可以指代唯一容器：

- 短 UUID
- 长 UUID
- name  （在创建时docker会为容器生成一个随机名称，如果想指定名称可以用 —name 来实现

容器的名称必须唯一，试图创建两个名称相同的容器，命令将会失败， 可以用docker  rm 命令来删除已经有的容器。 

## 重新启动已经停止的容器

#### Docker start 命令

docker start name / id

docker restart 来重启

## 附着到容器上

#### docker attach

使用命令，重新回到容器中。

## 创建守护式容器

通过指定 -d 参数，会将docker容器放到后台执行。

```bash
docker run --name daemon_dave -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

那么通过上述方式，创建了的容器，容器内部在做什么呢？

使用命令 

```bash
docker logs daemon_dave 
```

可以看到，容器中一直在打印hello world

可以使用

```bash
docker logs -f daemon_dave
```

使用-f参数来监控docker日志。类似于tail -f 参数。

## 查看容器内的进程

可以使用命令来查看容器内部的进程

```bash
docker top daemon_dave
```

## 在容器内部运行进程

可以使用exec 命令，在容器内部额外启动新进程。可以在容器内运行的进程有两种类型：

- 后台任务

```bash
docker exec -d daemon_dave touch /etc/new_config_file
```

通过这条命令，在容器中新建了一个文件。

- 交互式任务

```bash
docker exec -t -i daemon_dave /bin/bash
```

这条命令在容器新建一个bash会话，有了这个会话，就可以在容器中运行其他命令了。

## 停止守护式容器

```bash
docker stop daemon_dave  # id 也可以
#如果想快速停止可以使用
docker kill daemon_dave
# 可以使用 docker ps -n x  列出最后x 个容器，无论这个容器是否已经停止运行。
```

## 重新启动容器

如果由于某种错误而导致容器停止运行，可以通过 --restart标志，让docker重启该容器

```bash
sudo docker run --restart=always --name damon_dave -d ubuntu /bin/bash -c ""
```

例子中， --restart  被设置为always ， 无论容器的退出代码是什么，Docker都会自动重启该容器，

除了always标志，还可以设置 

* on-failure : 只有当容器退出代码非0 值的时候，才会自动重启 ，还可以接受一个重启次数  --restart=on-faile:5

## 深入容器

可以使用docker inspect 来获取更多的容器信息.

命令会对容器进行纤细的检查，返回其配置信息，包括名称、命令、网络配置以及很多有用的数据。

可以使用 -f 或者 --format 标志来选定查看结果。

```bash
sudo docker inspect --format='{{.State.Running}}' name
```

-f 选项，支持完整的GO语言模板。

## 删除容器

如果容器不需要再使用， 可以使用 docker rm 命令来删除 (运行中的docker 容器 无法删除)

```bash
docker rm `docker ps -a -q`
```

列出所有的容器， 让rm 命令移除 。

# 3、使用Docker镜像和仓库

docker使用的机制是写时复制（Copy on Write ） 。每个镜像层都是只读的，并且以后永远都不会发生变化。当创建一个新容器时，Docker会构建出一个镜像栈 ， 并在栈的最顶端添加一个读写层。这个读写层再加上其下面的镜像层以及一些配置数据， 就构成了一个容器。

## 3.1 列出镜像

```bash
docker images
```

> 本地镜像都保存在docker宿主机的 /var/lib/docker 目录下， 每个镜像都保存在docker锁采用的存储驱动目录下面。 也可以在 /var/lib/docker/containers 目录下看到所有的容器、

镜像从仓库下载下来，镜像保存在仓库中，而仓库存在于Registry中。默认的Registry是由Docker公司运营的公共Registry服务。即Docker Hub。

> DockerRegistry 是开源的，可以运行自己私有的Registry (恒生有自己的仓库)

可以使用命令，拉取仓库中关于镜像的所有版本.

```bash
docker pull ubuntu
```

为了区分同一个仓库中的不同镜像，Docker提供了Tag(标签)的功能。每个镜像在列出来的时候都带有一个标签。如：12.10 , 12.04, quantal 等。

可以通过在仓库名称后面加上一个 冒号 和 标签名来指定仓库中的某一个镜像

```bash
docker run -t -i --name new_container ubuntu:12.04 /bin/bash
```

Docker Hub 中有两种类型的仓库

* 用户仓库 （user Repository）：由Docker用户创建 ，用户仓库的命名，由有户名和仓库名两部分组成，如：jamtur01/puppet
* 顶层仓库 （top-level repository） ：Docker内部人管理，顶层仓库只包含库名部分，如ubuntu仓库。

## 3.2 拉取镜像

docker run 命令从镜像启动一个容器时，如果该镜像不在本地，Docker会先从DockerHub下载该镜像，如果没有指定具体的镜像标签，那么Docker会自动下载 lastest 标签的镜像。

## 3.3 查找镜像

可以通过Docker search命令来查找所有Docker Hub上公共可用的镜像

```bash
docker search ubuntu
```

> 也可以在Docker hub 网站上在线查找可用镜像

返回如下信息：

* 仓库名
* 镜像藐视
* 用户评价（Starts）
* 是否官方（Offical）
* 自动构建（Automated）

## 3.4 构建镜像

如何修改自己的镜像， 并且更新和管理这些镜像？

* 使用docker commit 命令
* 使用 docker build 命令和 Dockerfile文件 (推荐)

### 3.4.1 创建Docker Hub 账号

在官网创建账号之后，可以使用

```bash
docker login
```

> 个人认证信息江湖保存到 $HOME/.dockercfg 文件中

### 3.4.2 使用docker commit 命令创建镜像

启动一个容器，并在容器中安装 Apache ，会将这个容器作为一个web服务器来运行，所以我们想把它的当前状态保存下来。这样就不比每次都创建一个新容器并再次安装Apache了

```bash
docker commit containerId  userId/repositoryname
```

可以通过 指定 -m 来增加更多描述 , --author 列出镜像坐着信息

### 3.4.3 使用Dockerfile构建镜像

