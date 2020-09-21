FROM debian:stretch-slim
COPY rootfs /
ARG DOCKER_ARCH
RUN apt-dpkg-wrap apt-get update && apt-dpkg-wrap apt-get -y dist-upgrade && apt-dpkg-wrap apt-get -y install wget nfs-kernel-server samba cifs-utils
RUN wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.0/s6-overlay-${DOCKER_ARCH}.tar.gz -O /tmp/s6-overlay.tar.gz && tar xfz /tmp/s6-overlay.tar.gz -C / && rm -f /tmp/*.tar.gz
RUN mkdir /run/sendsigs.omit.d && mkdir /shared && useradd -u 1001 -U -d /shared -s /bin/false shared && usermod -G shared shared && usermod -G users shared

ENTRYPOINT [ "/init" ]
