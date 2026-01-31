all:
	docker build . --network=host  --build-arg TARGETARCH=`docker version -f "{{.Server.Arch}}"` -t juampe/filer
