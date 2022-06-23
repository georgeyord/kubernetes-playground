# Run Kubernetes locally using kind

> Read more: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx

## Installation

### Mac

```sh
brew install kind
```

## Use do.sh

`do.sh` is a small helper script to perform basic actions in the kind cluster. Run `./do.sh help` to learn more of the functionalities provided or just run `./do.sh reset` to get the following:

- Delete cluster (if found)
- Create cluster
- Set context
- Add ingress controller
- Deploy sample ingress app
- Deploy argocd
- Login argocd
- Load argocd apps from Github repo
- Deploy backstage

> **Remember** to change `.env` file contents to your needs! To use the urls unchanged add the follwoing line in `/etc/hosts`:

```
127.0.0.1 argocd.lan test1.lan test2.lan test3.lan backstage.lan
```
