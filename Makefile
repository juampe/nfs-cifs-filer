all:
	docker build . --build-arg DOCKER_ARCH=`docker version -f "{{.Server.Arch}}"` -t juampe/filer
