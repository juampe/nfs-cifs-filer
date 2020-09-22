FROM debian:stretch-slim
ARG TARGETARCH
COPY rootfs /
RUN apt-dpkg-wrap apt-get update && apt-dpkg-wrap apt-get -y dist-upgrade && apt-dpkg-wrap apt-get -y install wget nfs-kernel-server samba cifs-utils
RUN curl -o /tmp/s6-overlay.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.0/s6-overlay-${TARGETARCH}.tar.gz && tar xfz /tmp/s6-overlay.tar.gz -C / && rm -f /tmp/*.tar.gz 
RUN mkdir /run/sendsigs.omit.d && mkdir /shared && useradd -u 1001 -U -d /shared -s /bin/false shared && usermod -G shared shared && usermod -G users shared

ENTRYPOINT [ "/init" ]
