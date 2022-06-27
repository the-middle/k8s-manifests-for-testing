# K8s manifests for testing k8s capabilities

> You need Make to use *Makefile*

## Use Minikube to test it locally

- Install [Minikube](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)
- Start Minikube

    ```shell
    make start
    ```

- Wait till the start is complete and proceed

## Deployment

- Make sure Minikube is running and your kubectl is configured to use it

    ```shell
    $ make status
    
    --- OUTPUT ---
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured
    
    $ kubectl config current-context

    --- OUTPUT ---
    minikube

    ```

- Go to the **ci-cd** folder and go through the **README.md** to create SA for the deployment process specifically

- Deploy all files to the cluster

    ```shell
    make deploy_all
    ```

- Check that Nginx homepage is loading

    ```shell
    make port_forward
    ```

    Open <http://localhost:30555> or <http://127.0.0.1:30555> in your brouser. You should see Nginx welcome page

---

To make HPA work, you need to deploy **kube-state-metrics** app to your cluster

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install kube-state-metrics prometheus-community/kube-state-metrics
```

You can check default values if you want to change something

```shell
helm show values prometheus-community/kube-state-metrics
```

---
`make scan` scans your image for valnerabilities \
`make update_deploy` scans your image and upgrades deployment.yml to your cluster \
`make start` start Minikube cluster \
`make status` check Minikube cluster status \
`make stop` stop Minikube cluster \
`make port_forward` start port-forwarding to your app service
