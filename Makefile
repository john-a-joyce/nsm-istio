TAG ?= latest
ORG ?= networkservicemesh

# If GOPATH is made up of several paths, use the first one for our targets in this Makefile
GO_TOP := $(shell echo ${GOPATH} | cut -d ':' -f1)
export GO_TOP
export OUT_DIR=$(GO_TOP)/out
BUILDTYPE_DIR:=debug
export OUT_LINUX:=$(OUT_DIR)/linux_amd64/$(BUILDTYPE_DIR)
# scratch dir for building isolated images
DOCKER_BUILD_TOP:=${OUT_LINUX}/docker_build

.PHONY: build-nsm-svc-reg
build-nsm-svc-reg: 
	mkdir -p ${GOPATH}/bin/linux_amd64/nsm-istio
	GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' -o ${GOPATH}/bin/linux_amd64/nsm-istio/nsm_svc_reg ./nsm_svc_reg/cmd/nsm_svc_reg/...

.PHONY: docker-nsm-svc-reg
docker-nsm-svc-reg: build-nsm-svc-reg
	mkdir -p ${DOCKER_BUILD_TOP}/nsm_svc_reg
	cp -p ./nsm_svc_reg/docker/Dockerfile.nsm_svc_reg ${DOCKER_BUILD_TOP}/nsm_svc_reg/
	cp -p ${GOPATH}/bin/linux_amd64/nsm-istio/nsm_svc_reg ${DOCKER_BUILD_TOP}/nsm_svc_reg/
	cd ${DOCKER_BUILD_TOP}/nsm_svc_reg && docker build -t ${ORG}/nsm_svc_reg:${TAG} -f Dockerfile.nsm_svc_reg .
