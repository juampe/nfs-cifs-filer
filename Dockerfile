FROM debian:stretch-slim
ARG TARGETARCH
COPY rootfs /
RUN apt-dpkg-wrap apt-get update && apt-dpkg-wrap apt-get -y dist-upgrade && apt-dpkg-wrap apt-get -y install curl ca-certificates nfs-kernel-server samba cifs-utils
RUN /usr/bin/s6installer $TARGETARCH
RUN mkdir /run/sendsigs.omit.d && mkdir /shared && useradd -u 1001 -U -d /shared -s /bin/false shared && usermod -G shared shared && usermod -G users shared

ENTRYPOINT [ "/init" ]
