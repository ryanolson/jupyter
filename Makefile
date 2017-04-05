BASE_IMAGE ?= nvcr.io/nvidia/tensorflow:17.03
IMAGE_NAME ?= tf-jupyter
RELEASE_IMAGE ?= ryanolson/tf-jupyter

ifdef APT_CACHE_SERVER
    CACHES = --build-arg http_proxy=${APT_CACHE_SERVER}
else
    CACHES =
endif


.PHONY: build release clean distclean


default: build

Dockerfile: Dockerfile.j2
	j2docker --base-image=${BASE_IMAGE} Dockerfile.j2

build: clean Dockerfile
	docker build ${CACHES} -t ${IMAGE_NAME} . 

release: build
	docker tag ${IMAGE_NAME} ${RELEASE_IMAGE}
	docker push ${RELEASE_IMAGE}

output:
	@echo Docker Image: ${DOCKER_IMAGE}

clean:
	@rm -f Dockerfile 2> /dev/null ||:
	@rm -f *.img ||:
	@docker rm -v `docker ps -a -q -f "status=exited"` 2> /dev/null ||:
	@docker rmi `docker images -q -f "dangling=true"` 2> /dev/null ||:

distclean: clean
	@docker rmi ${IMAGE_NAME} 2> /dev/null ||:
	@docker rmi ${RELEASE_IMAGE} 2> /dev/null ||:
