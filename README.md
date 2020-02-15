# Falcoctl Kubernetes Dev Environment

Welcome to the Falcoctl development environment!

## Requirements

Depending on the OS you're in and the installation method you choose requirements may vary: see the requirements section below for more information.

Please note that makefile targets have been designed to be ran either on the local system using the actual command or via a docker wrapper: this means you are not forced to install each and every tool if you don't want to as you can rely on docker to take care of everything.

This repository has been developed using docker-machine using the [xhyve driver](https://github.com/machine-drivers/docker-machine-driver-xhyve), so Docker for Mac compatibility is not guaranteed yet.

In order to create a docker-machine, you can use the following command, adjusting resource sizing and nfs share path as needed:

```sh
docker-machine create \
    --driver=xhyve \
    --xhyve-cpu-count=2 \
    --xhyve-memory-size=8092 \
    --xhyve-disk-size=40000 \
    --xhyve-experimental-nfs-share /path/you/wish/to/share/with/docker/containers \
    --xhyve-experimental-nfs-share-root / \
    --xhyve-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso
```

## Local kubernetes installation 🏡

Requirements:

- git

Fork and clone this repository, then pick your installation method: `minikube`, `vagrant single node`, `vagrant multi node` or `aws`.

### Minikube setup 🚀

Requirements:

- brew
- curl


This option will download, install and run minikube-1.4.0 and its dashboard. In order to make it all work you just need to go through the following steps:

```sh
make minikube
make helm
```

Note: minikube is pinned to `1.4.0` as it's the last version for which the pre-built version of Falco's probe is available and on minikube's linux distro is not possible to build it. Both issues are being addressed by the respective communities, so they will eventually go away.

### Vagrant single node setup 🎯

Requirements:

- jq
- yq
- docker
- vagrant (+ 2 plugins: vagrant-vbguest, vagrant-scp. they are installed by the `make vagrant` target)
- ansible (optional if using `-docker` makefile targets)
- kubectl (optional if using `-docker` makefile targets)

This option will setup a single vagrant box and deploy kubernetes on top of it: this is probably the best compromise for working on `falcoctl`, as you have more control over the environment compared to minikube. The flexibility comes with a cost, as it's slower than minikube to setup.

```sh
make vagrant
make -f ansible/Makefile vagrant-kubernetes-single
make vagrant-download-kube-config
make kubernetes-install-dashboard
```

### Vagrant multi node setup 💪

Requirements:

- same as `Vagrant single node setup`

In case you need to verify very specific use-cases, you can also deploy a multi-node installation of kubernetes.

```sh
make vagrant
make -f ansible/Makefile vagrant-kubernetes-multi
make vagrant-download-kube-config
make kubernetes-install-dashboard
```

## AWS kubernetes installation 🤯

Coming soon. ish.

```sh
cp .env.dist .env
sed "s/__YOUR_EMAIL_ADDRESS__/your.actual.email.address@example.com/g" .env
```

## Falco installation

```sh
make helm
```
