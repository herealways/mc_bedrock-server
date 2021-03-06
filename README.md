# What is this?
This is a self-entertaining project to record how I deploy and maintain my self- entertaining Minecraft Bedrock server.  
[中文文档](README_zh.md)

# Overview
This project uses Docker to build, Jenkins and Ansible playbook to test and deploy my Minecraft Bedrock server. This repository has two branches. "dev" branch is used for test/staging environment, while "master" is used for production environment.

When some change is pushed to dev branch, pipeline defined in Jenkinsfile will be executed. It will build the new version of the bedrock server docker image, push the test docker image to Docker Hub, set up test/staging environment and allow me to check if the new version works well (Sadly, I don't have any method of automatic testing).

When some change is pushed to master branch, the pipeline will allow me to manually validate if I really want to update the production environment. If I really want to enjoy the new version of Minecraft Bedrock server, the pipeline will firstly tag and push the new docker image to Docker Hub. Then it will update the game server. Sometimes it is just some trival update that pushed to master branch (like update doc) and there is no need to touch production server, so I will abort the execution of pipeline.

# Anatomy of this repository
Here I will explain key components of this repository.

## Project directory
```
# tree mc_bedrock-server/ -L 2
mc_bedrock-server/
├── ansible_inventory
│   ├── production_server
│   ├── remote_test_server
│   └── test_server
├── docker-compose.yml        # To deploy the game server
├── Docker_image
│   └── Dockerfile
├── jenkins                   # Storing build and push scripts
│   ├── build.sh
│   ├── push.sh
│   ├── push_test.sh
│   ├── vm_halt.sh
│   └── vm_setup.sh
├── Jenkinsfile
├── LICENSE
├── mc_server.yml
├── README.md
├── requirements.yml          # Requirements file for Ansible role
├── roles
│   ├── mc_bedrock_server_deploy
│   └── mc_bedrock_server_update
└── Vagrant
    └── Vagrantfile
```

## mc_server.yml
This is an Ansible playbook. It is used for deploying, updating and stopping Minecraft Bedrock server.  
It takes a variable **"MC_VERSION"** which is used to specify the server version to deploy or to update to.  
Tags for this playbook:
  * **deploy**: Deploy the server.
  * **update**: Update the server.
  * **halt**: Stop the server.

## Ansible roles
* **mc_bedrock_server_deploy**: Deploy Minecraft Bedrock server.
* **mc_bedrock_server_update**: Update Minecraft Bedrock server.  
    See README.md under each role.
* **ansible_get_docker**: Install Docker on CentOS7, CentOS8 and Fedora30. 
See [ansible_get_docker](https://github.com/herealways/ansible_get_docker)

## Jenkinsfile
There are six stages defined in the pipeline: **Build**, **Push stage 1**, **Test**, **Stop test server**, **Push stage 2** and **Deploy**. The first four stages are for pushes on dev branch, while the last two stages are for pushes on master branch.  
  * **Build** stage is for building test docker image.
  * **Push stage 1** is for pushing the test docker image to Docker Hub.
  * **Test** is for deploying the test environment and allow me to test it.
  * **Stop test server** allows me to decide if I want to keep the test server running after testing it.
  * **Push stage 2** is for tagging and pushing the tested docker image to Docker Hub.
  * **Deploy** is used for updating game version on production server.

## Vagrant related
It was used to create virtual machines for local test environment. Now I decide to use a vps for testing. Therefore, it is unused for now.

## Service directory (on the server)
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

  * docker-compose.yml is for start and stop game server.
  * Backups:
    * daily_backup: Only backup setting files and world data on 4:10 everyday.
    * weekly_backup: Backup all the game data on Friday 4:10.
    * update_backup: Backup all the game data before updating the server. It will only save the last version of game data before update.
  **Note**: Backup files in tarball are under "bedrock-server" directory. When extracting them, you may need to add --strip=1 option.

**Game server data** is stored in **docker volume**. The volume is created by docker-compose and its name is **bedrock-server_bedrock-server_data**.