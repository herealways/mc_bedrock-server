FROM ubuntu:18.04
LABEL version=1.14.60.5
ENV download_url="https://minecraft.azureedge.net/bin-linux/bedrock-server-1.14.60.5.zip"

RUN apt-get update \
&& apt-get install --no-install-recommends --no-install-suggests -y curl ca-certificates unzip \
&& curl $download_url  --output /bedrock-server.zip \
&& mkdir /bedrock-server \
&& unzip bedrock-server.zip -d /bedrock-server \
&& rm /bedrock-server.zip \
&& apt-get remove --purge --auto-remove -y unzip \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /bedrock-server
EXPOSE 19132/udp
VOLUME /bedrock-server
CMD LD_LIBRARY_PATH=. ./bedrock_server