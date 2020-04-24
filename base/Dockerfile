# Base Image UBUNTU 18.04
FROM ubuntu:18.04

# Working directory as root
USER root
WORKDIR "/root"

# No prompts please
ENV DEBIAN_FRONTEND=noninteractive

# Fixes some weird terminal issues such as broken clear / CTRL+L
ENV TERM=linux

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID webuser
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID webuser

# Perform Installations
COPY docker-runs.sh /root/
RUN /root/docker-runs.sh

VOLUME /var/www
VOLUME /var/www/html
VOLUME /root/scripts

RUN mkdir -p /var/www/scripts

# Copying neccessary files

COPY ./supervisord/supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY wait.sh /usr/local/bin/wait.sh

USER webuser
WORKDIR "/var/www"

ENTRYPOINT wait.sh && docker-entrypoint.sh

EXPOSE 8080