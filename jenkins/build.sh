#!/bin/bash
cd Docker_image && docker build -t herealways/bedrock-server:"$1"  .