# Add SA for CI/CD process

> You need to install jq in order to parse JSON in this example.

## Create SA

```shell
export SERVICE_ACCOUNT_NAME="cicd-user"
export NAMESPACE="default"

kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}"
```

## Create a target folder

```shell
export TARGET_FOLDER="$HOME/tmp/kube"

mkdir -p "${TARGET_FOLDER}"
```

## Extract secret name and public key

```shell
export SECRET_NAME=$(kubectl get sa "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}" -o json | jq -r .secrets[].name)

kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["ca.crt"]' | base64 --decode > "${TARGET_FOLDER}/ca.crt"
```

## Fetch the usertoken

```shell
export USER_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 --decode)
```

## Generate config file

```shell
export KUBECFG_FILE_NAME="$HOME/tmp/kube/k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-conf"

export context=$(kubectl config current-context)

export CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)


export ENDPOINT=$(kubectl config view \
-o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")

kubectl config set-cluster "${CLUSTER_NAME}" \
--kubeconfig="${KUBECFG_FILE_NAME}" \
--server="${ENDPOINT}" \
--certificate-authority="${TARGET_FOLDER}/ca.crt" \
--embed-certs=true

kubectl config set-credentials \
"${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
--kubeconfig="${KUBECFG_FILE_NAME}" \
--token="${USER_TOKEN}"


kubectl config set-context \
"${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
--kubeconfig="${KUBECFG_FILE_NAME}" \
--cluster="${CLUSTER_NAME}" \
--user="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
--namespace="${NAMESPACE}"

kubectl config use-context "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
--kubeconfig="${KUBECFG_FILE_NAME}"
```

## Assign a Role via RoleBinding

```shell
kubectl apply -f cicd-role-config.yml
```

---

## Test the SA

```shell
KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods
```
