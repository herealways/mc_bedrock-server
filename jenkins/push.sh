#!/bin/bash
docker tag test/bedrock herealways/bedrock-server:latest
docker tag test/bedrock herealways/bedrock-server:"$1"
docker tag test/bedrock herealways/bedrock-server:"$2"
docker login -u herealways -p $DOCKER_HUB
docker push herealways/bedrock-server:latest
docker push herealways/bedrock-server:"$1"
docker push herealways/bedrock-server:"$2"