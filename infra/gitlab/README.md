# GitLab-CI Installation

## Prerequisites

- A Kubernetes cluster
- The following tools installed on your local machine:
  - [Helm](https://helm.sh/docs/intro/install/)
  - [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Both Helm and Kubectl are available in the Homebrew package manager. To install them, run the following commands:

- Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- Install Helm and Kubectl:

```bash
brew install helm
brew install kubectl
```

## Configure Helm

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update
```

## Deploy GitLab-CI with Helm

```bash
helm install gitlab gitlab/gitlab --set global.edition=ce --set global.hosts.domain=scalastic.local --set certmanager.install=false
```

Get the Jenkins admin password:

```bash
kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode; echo
```

## Configure Ingress to access Jenkins

- Install Nginx Ingress Controller:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
```

- Create a `jenkins-ingress.yaml` file:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: jenkins.scalastic.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080
```

- Apply the configuration:

```bash
kubectl apply -f jenkins-ingress.yaml
```
