FROM debian:bullseye-slim
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
ENV S6_VERBOSITY=2

COPY rootfs /
RUN apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get -y install --no-install-recommends curl ca-certificates xz-utils nfs-kernel-server samba cifs-utils python3 minidlna net-tools \
    && dpkg --force-confold -i /wsdd_0.7.0_all.deb && rm -Rf /*.deb
RUN /usr/bin/s6installer $TARGETARCH
RUN mkdir /run/sendsigs.omit.d \
    && mkdir /shared \
    && useradd -u 1000 -U -d /shared -s /bin/false shared \
    && usermod -G shared shared \
    && usermod -G users shared \
    && rm -f /etc/exports \
    && chmod +x /usr/bin/healthcheck

# Healthcheck: verifica Samba, WSDD y MiniDLNA cada minuto
# - Espera 90s después del inicio antes de la primera comprobación
# - Timeout de 15s por comprobación
# - 3 intentos fallidos antes de marcar como unhealthy
HEALTHCHECK --interval=1m --timeout=15s --retries=3 --start-period=90s \
    CMD /usr/bin/healthcheck || exit 1

ENTRYPOINT [ "/init" ]
