#!/bin/bash
# Tag latest version
docker tag herealways/bedrock-server:"$1" herealways/bedrock-server:latest
# Tag major version
docker tag herealways/bedrock-server:"$1" herealways/bedrock-server:"$2"
docker login -u $DOCKER_HUB_USR -p $DOCKER_HUB_PSW
# Push all the tags
docker push herealways/bedrock-server:latest
docker push herealways/bedrock-server:"$1"
docker push herealways/bedrock-server:"$2"