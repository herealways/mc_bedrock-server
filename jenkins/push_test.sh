#!/bin/bash
docker login -u $DOCKER_HUB_USR -p $DOCKER_HUB_PSW
# Push specific version for testing
docker push herealways/bedrock-server:"$1"