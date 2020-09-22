# nfs-cifs-filer
NFS service to serve docker volumes

`docker run --init -d --restart=always --network=eraser --ip 192.168.0.128 --dns 192.168.123.123 --name="filer" --hostname "filer" -e "TZ=Europe/Madrid" --cap-add=SYS_ADMIN -v /opt/docker/filer/data/exports:/etc/exports -v /opt/docker/filer/data/samba:/etc/samba -v /shared:/shared juampe/filer`

Use the share as a volume in containers like owncloud

`docker volume create --driver local --opt type=nfs --opt o=addr=filer,nfsvers=3,rw,nolock,hard,intr,rsize=8192,wsize=8192,timeo=14 --opt device=:/shared/OwnCloud owncloud`
