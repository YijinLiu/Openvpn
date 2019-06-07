FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt upgrade -y && \
    apt install -qq -y --no-install-recommends \
        bash bash-completion easy-rsa iptables openvpn pkg-config ssh sudo tzdata && \
    echo America/Los_Angeles > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

ADD build.sh /tmp/

ARG NAME
ARG PORT
RUN /tmp/build.sh --name $NAME --port $PORT
EXPOSE $PORT/udp
