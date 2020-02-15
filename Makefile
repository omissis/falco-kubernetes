_FALCO_VERSION=0.17.1
_KUBE_CONFIG_FALCO_VAGRANT_FILE=${HOME}/.kube/config-falco-vagrant
_MINIKUBE_VERSION=1.4.0

# Vagrant targets
.PHONY: vagrant

vagrant:
	@vagrant plugin install vagrant-vbguest
	@vagrant plugin install vagrant-scp
	@vagrant up
	@vagrant reload

vagrant-download-kube-config:
	@vagrant ssh -c "sudo cp /etc/kubernetes/admin.conf ~/.kube-config-admin.conf && sudo chown vagrant:vagrant ~/.kube-config-admin.conf" && \
	vagrant scp kube1:~/.kube-config-admin.conf ${_KUBE_CONFIG_FALCO_VAGRANT_FILE} && \
	vagrant ssh -c "rm ~/.kube-config-admin.conf"

vagrant-update-kube-config-dashboard-token:
	@KUBE_DASHBOARD_SECRET=`kubectl --kubeconfig=${_KUBE_CONFIG_FALCO_VAGRANT_FILE} get secret | grep 'dashboard-admin-sa-token' | cut -f 1 -d ' '` && \
	KUBE_DASHBOARD_TOKEN=`kubectl --kubeconfig=${_KUBE_CONFIG_FALCO_VAGRANT_FILE} describe secret $$KUBE_DASHBOARD_SECRET | grep -e '^token' | tr -s ' ' | cut -d' ' -f 2` && \
	yq r ${_KUBE_CONFIG_FALCO_VAGRANT_FILE} -j | jq ".users[0].user += {\"token\": \"$$KUBE_DASHBOARD_TOKEN\"}" | yq r -P - > ${_KUBE_CONFIG_FALCO_VAGRANT_FILE}.new && \
	mv ${_KUBE_CONFIG_FALCO_VAGRANT_FILE}.new ${_KUBE_CONFIG_FALCO_VAGRANT_FILE}

# Minikube targets
.PHONY: minikube-install minikube

# TODO: add linux support
minikube-install:
	@if [ ! -f /usr/local/bin/minikube-${_MINIKUBE_VERSION} ]; then \
		curl -LO https://storage.googleapis.com/minikube/releases/v${_MINIKUBE_VERSION}/minikube-darwin-amd64 -o $$HOME && \
		sudo install $$HOME/minikube-darwin-amd64 /usr/local/bin/minikube-${_MINIKUBE_VERSION} && \
		rm $$HOME/minikube-darwin-amd64 && \
	fi

minikube: install-minikube
	@minikube-${_MINIKUBE_VERSION} start --vm-driver=hyperkit --memory=2048 && \
	minikube-${_MINIKUBE_VERSION} dashboard;

# Helm targets
.PHONY: helm-install helm

# TODO: add linux support
install-helm:
	@HELM_PATH=`which helm` && \
	if [ ! -f $$HELM_PATH ]; then \
		brew install helm; \
	fi

helm: install-helm
	@HELM_REPO_STABLE_INSTALLED=`helm --kubeconfig=${_KUBE_CONFIG_FALCO_VAGRANT_FILE} repo list | grep stable` ; \
	if [ -z "$$HELM_REPO_STABLE_INSTALLED" ]; then \
		helm --kubeconfig=${_KUBE_CONFIG_FALCO_VAGRANT_FILE} repo add stable https://kubernetes-charts.storage.googleapis.com/ ; \
	fi; \
	helm --kubeconfig=${_KUBE_CONFIG_FALCO_VAGRANT_FILE} install falco stable/falco --set image.tag=${_FALCO_VERSION}
