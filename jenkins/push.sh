#!/bin/bash
docker tag test/bedrock herealways/bedrock-server:latest
docker tag test/bedrock herealways/bedrock-server:"$1"
docker tag test/bedrock herealways/bedrock-server:"$2"
docker login -u $DOCKER_HUB_USR -p $DOCKER_HUB_PSW
docker push herealways/bedrock-server:latest
docker push herealways/bedrock-server:"$1"
docker push herealways/bedrock-server:"$2"