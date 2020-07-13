1. [개요](#1)  
2. [PaaS-TA Container service 설치](#2)  
3. [PaaS-TA Container service 설치 완료 확인](#3)  
4. [Kubernetes Prometheus Pods 정보 확인](#4)  
5. [prometheus-prometheus-prometheus-oper-prometheus-0 POD Node IP 확인](#5)  
6. [Kubernetes API URL(serverAddress) 확인](#6)  
7. [Kubernetes API Request 호출시 Header(Authorization) 인증을 위한 Token값 확인](#7)  

 
## <div id='1'/>1. 개요

본 문서는 PaaS-TA Monitoring을 설치하기 앞서 PaaS-TA의 Container Log 수집을 위하여 BOSH 2.0을 이용하여 Container를 설치하고 Monitoring에 작성할 값을 확인하는 방법을 기술하였다.


## <div id='2'/>2.	PaaS-TA Container service 설치

[PaaS-TA Container service 설치 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/service-guide/tools/PAAS-TA_CONTAINER_SERVICE_INSTALL_GUIDE_V2.0.md)

## <div id='3'/>3.	PaaS-TA Container service 설치 완료 확인 
![PaaSTa_paasta_container_service_vms]


## <div id='4'/>4.	Kubernetes Prometheus Pods 정보 확인  
```
$  bosh -e {director_name} ssh -d paasta-container-service master
$  /var/vcap/packages/kubernetes/bin/kubectl get pods --all-namespaces -o wide
```
![PaaSTa_paasta_container_service_pods]

## <div id='5'/>5.	prometheus-prometheus-prometheus-oper-prometheus-0 POD Node IP 확인
```
$  /var/vcap/packages/kubernetes/bin/kubectl get nodes -o wide
```
![PaaSTa_paasta_container_service_nodes]

### <div id='6'/>6.	Kubernetes API URL(serverAddress) 확인
```
$  curl localhost:8080/api
```
![PaaSTa_paasta_container_service_kubernetes_api]

## <div id='7'/>7.	Kubernetes API Request 호출시 Header(Authorization) 인증을 위한 Token값 확인
```
$  /var/vcap/packages/kubernetes/bin/kubectl -n kube-system describe secret $(/var/vcap/packages/kubernetes/bin/kubectl -n kube-system get secret | grep monitoring-admin | awk '{print $1}')
```
![PaaSTa_paasta_container_service_kubernetes_token]




[PaaSTa_paasta_container_service_vms]:./images/paasta-container-service-vms.png
[PaaSTa_paasta_container_service_pods]:./images/paasta-container-service-pods.png
[PaaSTa_paasta_container_service_nodes]:./images/paasta-container-service-nodes.png
[PaaSTa_paasta_container_service_kubernetes_api]:./images/paasta-container-service-kubernetes-api.png
[PaaSTa_paasta_container_service_kubernetes_token]:./images/paasta-container-service-kubernetes-token.png
