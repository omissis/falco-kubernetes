_DOCKER_FILELINT_IMAGE=cytopia/file-lint:latest
_DOCKER_JSONLINT_IMAGE=cytopia/jsonlint:latest
_DOCKER_PACKER_IMAGE=hashicorp/packer:1.5.1
_FILELINT_BINDIR=/usr/bin
_FILELINT_IGNORE_PATHS=.git/,.github/,.plugin-cache,.roles,.vagrant,vendor/
_PACKER_DIR=`pwd`
_WORK_DIR=/srv

# $1: docker image
# $2: command
define run-docker
	@docker run -it --rm \
	-v ${_PACKER_DIR}:${_WORK_DIR} \
	-w ${_WORK_DIR} \
	$1 \
	$2
endef

define run-docker-packer
	@docker run -it --rm \
	--entrypoint="" \
	--env-file=.env \
	-v ${_PACKER_DIR}:${_WORK_DIR} \
	-w ${_WORK_DIR} \
	${_DOCKER_PACKER_IMAGE} \
	/bin/sh -c "apk update && apk add make && $2"
endef

.PHONY: lint-docker lint-files-docker lint-jsonfiles-docker validate validate-docker build-ubuntu-1804 build-ubuntu-1804-docker

lint-docker: lint-files-docker lint-jsonfiles-docker

lint-files-docker:
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-cr --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-crlf --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-trailing-single-newline --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-trailing-space --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-utf8 --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-utf8-bom --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)

lint-jsonfiles-docker:
	$(call run-docker,${_DOCKER_JSONLINT_IMAGE},*.json)

validate:
	@find . -maxdepth 1 -type f -name '*.json' -exec packer validate {} \;

validate-docker:
	$(call run-docker-packer,make validate)

build-ubuntu-1804:
	@if [ -f .env ]; then \
		export $(grep -v '^#' .env | xargs) ; \
	fi ; \
	packer build -force aws.ubuntu-18-04.json

build-ubuntu-1804-docker:
	$(call run-docker-packer,make build-ubuntu-1804)
