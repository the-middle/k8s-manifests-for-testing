files := $(wildcard *.yml)
image := $(shell grep image deployment.yml | cut -d ' ' -f 10)
service_name := $(shell grep name svc.yml | cut -d ' ' -f 4)
service_port := $(shell grep port svc.yml | cut -d ' ' -f 5)
local_port := 30555

start:
	minikube start --vm-driver=kvm

status:
	minikube status

stop:
	minikube stop

deploy_all:
	for i in ${files}; KUBECONFIG=${KUBECFG_FILE_NAME} do kubectl apply -f $${i}; done

port_forward:
	kubectl port-forward svc/${service_name} ${local_port}:${service_port}

update_deploy: scan
	KUBECONFIG=${KUBECFG_FILE_NAME} kubectl apply -f deployment.yml

scan:
	docker scan ${image}