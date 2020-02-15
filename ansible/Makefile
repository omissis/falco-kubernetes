_ANSIBLE_DIR=`pwd`
_ANSIBLE_ROLES_DIR=${HOME}/.ansible/roles/
_DOCKER_ANSIBLE_IMAGE=mullnerz/ansible-playbook:2.9.1
_DOCKER_FILELINT_IMAGE=cytopia/file-lint:0.3
_DOCKER_KUBECTL_IMAGE=bitnami/kubectl:1.17.3
_DOCKER_YAMLLINT_IMAGE=cytopia/yamllint:1.20
_FILELINT_BINDIR=/usr/bin
_FILELINT_IGNORE_PATHS=.git/,.github/,.plugin-cache,.roles,.vagrant,vendor/
_KUBE_CONFIG_FALCO_AWS_FILE=${HOME}/.kube/config-falco-aws
_KUBE_CONFIG_FALCO_VAGRANT_FILE=${HOME}/.kube/config-falco-vagrant
_KUBE_DASHBOARD_VERSION=v2.0.0-rc5
_OSTYPE=`uname -a | cut -f 1 -d ' ' | tr '[:upper:]' '[:lower:]'`
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

# $1: command
define run-docker-ansible-playbook
	@docker run -it --rm \
	--entrypoint="" \
	--env-file=.env \
	-v ${_ANSIBLE_ROLES_DIR}:/root/.ansible/roles/ \
	-v ${_ANSIBLE_DIR}:${_WORK_DIR} \
	-w ${_WORK_DIR} \
	${_DOCKER_ANSIBLE_IMAGE} \
	/bin/sh -c "apk update && apk add curl make && $1"
endef

# $1: config file path
# $2: command
define run-docker-kubectl
	docker run -it --rm \
	--entrypoint="" \
	-v $1:/.kube/config \
	${_DOCKER_KUBECTL_IMAGE} \
	/bin/sh -c "sudo apt update && apt install make && $2"
endef

# $1: config file path
define run-kubectl-install-dashboard
	kubectl --kubeconfig=$1 apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/${_KUBE_DASHBOARD_VERSION}/aio/deploy/recommended.yaml"
	kubectl --kubeconfig=$1 create serviceaccount dashboard-admin-sa
	kubectl --kubeconfig=$1 create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
endef

# Ansible playbook development targets
.PHONY: update-kube-flannel-manifest

update-kube-flannel-manifest:
	@curl -o files/kube-flannel.yml 'https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml' && \
	sed -i '' -e $$'s/--kube-subnet-mgr/--kube-subnet-mgr\\\n        - --iface=enp0s8/g' files/kube-flannel.yml

# Ansible's mitogen setup targets
.PHONY: symlink-mitogen symlink-mitogen-macos symlink-mitogen-debian

symlink-mitogen:
	@case "${_OSTYPE}" in \
		darwin*) \
			$(MAKE) symlink-mitogen-macos; \
		;; \
		linux*) \
			cat /etc/*-release | grep -q debian; \
			if [ $$? -eq 0 ] \
			then \
				$(MAKE) symlink-mitogen-debian; \
			else \
				echo "unsupported linux type."; \
				exit 1; \
			fi \
		;; \
		*) \
			echo "unsupported os type: '${_OSTYPE}'."; \
			exit 1; \
		;; \
	esac

symlink-mitogen-macos:
	@sudo ln -f -s \
		/usr/local/lib/python2.7/site-packages/ansible_mitogen/plugins/strategy \
		/opt/ansible_mitogen_plugin_strategy

symlink-mitogen-debian:
	@sudo ln -f -s \
		/usr/lib/python2.7/site-packages/ansible_mitogen/plugins/strategy \
		/opt/ansible_mitogen_plugin_strategy

# Lint targets
.PHONY: lint-docker lint-files-docker lint-yamlfiles-docker

lint-docker: lint-files-docker lint-yamlfiles-docker

lint-files-docker:
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-cr --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-crlf --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-trailing-single-newline --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-trailing-space --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-utf8 --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)
	$(call run-docker,${_DOCKER_FILELINT_IMAGE},file-utf8-bom --text --ignore '${_FILELINT_IGNORE_PATHS}' --path .)

lint-yamlfiles-docker:
	$(call run-docker,${_DOCKER_YAMLLINT_IMAGE},.)

# Ansible dependencies targets
.PHONY: deps deps-docker

deps:
	@ansible-galaxy install -r requirements.yml

deps-docker:
	$(call run-docker-ansible-playbook,make deps)

# Kubernetes on Vagrant targets
.PHONY: vagrant-kubernetes-single vagrant-kubernetes-single-docker
.PHONY: vagrant-kubernetes-multi vagrant-kubernetes-multi-docker
.PHONY: vagrant-kubernetes-dashboard vagrant-kubernetes-dashboard-docker

vagrant-kubernetes-single:
	$(MAKE) symlink-mitogen
	@ansible-playbook -i inventories/vagrant/hosts-single kubernetes.yml

vagrant-kubernetes-single-docker:
	$(call run-docker-ansible-playbook,make vagrant-kubernetes-single)

vagrant-kubernetes-multi:
	$(MAKE) symlink-mitogen
	@ansible-playbook -i inventories/vagrant/hosts-multi kubernetes.yml

vagrant-kubernetes-multi-docker:
	$(call run-docker-ansible-playbook,make vagrant-kubernetes-multi)

vagrant-kubernetes-dashboard:
	$(call run-kubectl-install-dashboard,${_KUBE_CONFIG_FALCO_VAGRANT_FILE})

vagrant-kubernetes-dashboard-docker:
	$(call run-docker-kubectl,${_KUBE_CONFIG_FALCO_VAGRANT_FILE},make vagrant-kubernetes-dashboard)

# Kubernetes on AWS targets
.PHONY: aws-kubernetes aws-kubernetes-docker aws-kubernetes-dashboard

aws-kubernetes:
	$(MAKE) symlink-mitogen
	@ansible-playbook -i inventories/aws/hosts kubernetes.yml

aws-kubernetes-docker:
	$(call run-docker-ansible-playbook,make aws-kubernetes)

aws-kubernetes-dashboard:
	$(call run-kubectl-install-dashboard,${_KUBE_CONFIG_FALCO_AWS_FILE})

aws-kubernetes-dashboard-docker:
	$(call run-docker-kubectl,${_KUBE_CONFIG_FALCO_AWS_FILE},make aws-kubernetes-dashboard)
