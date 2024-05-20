FROM jenkins/jenkins:latest-jdk17

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update
RUN apt-get install -y \
    docker-ce=5:26.1.3-1~debian.12~bookworm \
    docker-ce-cli=5:26.1.3-1~debian.12~bookworm \
    containerd.io

RUN apt-get update
RUN apt-get install -y docker-compose-plugin

RUN usermod -aG docker jenkins
RUN groupadd -g 994 tempgroup
RUN usermod -aG 994 jenkins

USER jenkins