# 关于此项目
这是一个带有自娱自乐性质的项目，用来记录我是如何部署和维护个人我的世界基岩版服务器。

# 概述
此项目使用了Docker来构建镜像，使用Jenkins和Ansible playbook来测试和部署游戏服务器。代码库包含有两个分支。"dev"分支用于测试/staging环境，"master"分支代表生产环境。

当推送代码到dev分支时，定义在Jenkinsfile里面的pipeline将会执行：首先将会构建新版本的游戏服务器镜像，然后pipeline会搭建起测试/staging环境，以便我检查新版本是否有问题（这里没有自动化测试）。如果新版本运行正常，pipeline会将新版本的镜像推送到Docker Hub。

当推送代码到master分支时，pipeline会让我手动确认是否要升级生产环境。如果我真的想这样做的话，pipeline就会自动升级游戏服务器。不过有时候我只是更新了文档，将其推送到了master分支。在这种情况下就不需要操作生产环境了。所以此时我会终止pipeline的执行。

## 项目组成
这里简单介绍一下该项目的核心部分。

## 项目目录
```
# tree mc_bedrock-server/ -L 2
mc_bedrock-server/
├── ansible_inventory
│   ├── production_server
│   ├── remote_test_server
│   └── test_server
├── docker-compose.yml        # 用来部署游戏服务器
├── Docker_image
│   └── Dockerfile
├── jenkins                   # 存放构建与推送镜像的脚本
│   ├── build.sh
│   ├── push.sh
│   ├── push_test.sh
│   ├── vm_halt.sh
│   └── vm_setup.sh
├── Jenkinsfile
├── LICENSE
├── mc_server.yml
├── README.md
├── requirements.yml          # Ansible role的requirements文件
├── roles
│   ├── mc_bedrock_server_deploy
│   └── mc_bedrock_server_update
└── Vagrant
    └── Vagrantfile
```

## mc_server.yml
此Ansible playbook用来部署、升级和停止我的世界基岩服务器。其需要设定"MC_VERSION"变量，用来指定游戏服务器版本。
该playbook有以下tags:
  * **deploy**: 部署服务器。
  * **update**: 升级服务器。
  * **halt**: 停止服务器。

## Ansible roles
* **mc_bedrock_server_deploy**: 部署游戏服务器。
* **mc_bedrock_server_update**: 升级游戏服务器。
    具体可参看各个role下的README文件
* **ansible_get_docker**: 在CentOS7, CentOS8和Fedora30上安装Docker。
可查看 [ansible_get_docker](https://github.com/herealways/ansible_get_docker)

## Jenkinsfile
Pipeline内包含六个阶段：**Build**, **Push stage 1**, **Test**, **Stop test server**, **Push stage 2** 和 **Deploy**。前五个阶段在dev分支上工作，最后一个阶段只在master分支上工作。  
  * **Build**: 该阶段负责构建docker image。
  * **Push stage 1**: 该阶段负责将测试镜像推送到Docker Hub。
  * **Test**: 该阶段负责部署测试环境，并执行测试。
  * **Stop test server**: 决定是否在测试完之后停止测试服务器。
  * **Push stage 2**: 该阶段为测试过的镜像打标签，并将其推送到Docker Hub。
  * **Deploy**: 该阶段负责升级生产环境的游戏版本。

## Vagrant相关
曾经我用它来搭建本地测试环境。不过后来我将测试环境移到了vps上。所以目前并未使用这些东西。

## 游戏服务器的目录结构
```
# tree /opt/bedrock-server
/opt/bedrock-server
├── backup
│   ├── backup_server.sh
│   ├── daily_backup
│   ├── update_backup
│   └── weekly_backup
└── docker-compose.yml
```

  * docker-compose.yml: 启动或停止游戏服务器。
  * 备份文件夹:
    * daily_backup: 在每天4:10时备份设置和世界文件。
    * weekly_backup: 在每周五4:10时备份所有游戏文件。
    * update_backup: 在升级前备份所有游戏文件。仅会保存上一个升级前版本的游戏文件。
  **注意**：压缩包内备份文件位于"bedrock-server"目录下。解压的时候可能需要加上 --strip=1参数。