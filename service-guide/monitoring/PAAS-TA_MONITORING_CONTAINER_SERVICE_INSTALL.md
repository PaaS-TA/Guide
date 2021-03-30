## Table of Contents

1. [문서개요](#1)  
2. [PaaS-TA Container Monitoring 설치](#2)  
3. [PaaS-TA Container Monitoring 설치 확인](#3)  
4. [Prometheus 정보 확인](#4)  
5. [Grafana 정보 확인](#5)  
 
## <div id='1'/>1. 문서 개요
본 문서(PaaS-TA-CaaS-Monitoring)는 설치된 CaaS에서 Container Usage 수집하여 paasta-monitoring에 나타내기 위한 설치 방법을 기술하였다.

### <div id='1.1'/>1.1 목적
본 문서는 CaaS에서 Container Usage를 수집하고 paasta-monitoring으로 나타내는데 그 목적이 있다.
  
### <div id='1.2'/>1.2 범위
본 문서는 paas-ta-container-platform의 master를 기준으로 CaaS 배포의 Kubespray 및 CaaS를 설치하는 것을 기준으로 작성되었다.      

## <div id='2'/>2.	CaaS 모니터링 설치

### <div id='2.1'/>2.1 Prerequisite
본 설치 가이드는 Ubuntu환경에서 설치하는 것을 기준으로 작성하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.5, PaaS-TA 포털 API, PaaS-TA 포털 UI, Kubespray 설치, CaaS 배포가 설치 되어 있어야 한다.
- [BOSH 2.0 설치 가이드](https://github.com/PaaS-TA/Guide/blob/master/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)
- [PaaS-TA 5.5 설치 가이드](https://github.com/PaaS-TA/Guide/blob/master/install-guide/paasta/PAAS-TA_CORE_INSTALL_GUIDE_V5.0.md)
- [PaaS-TA 포털 API 설치 가이드](https://github.com/PaaS-TA/Guide/blob/master/install-guide/portal/PAAS-TA_PORTAL_API_SERVICE_INSTALL_GUIDE_V1.0.md)
- [PaaS-TA 포털 UI 설치 가이드](https://github.com/PaaS-TA/Guide/blob/master/install-guide/portal/PAAS-TA_PORTAL_UI_SERVICE_INSTALL_GUIDE_V1.0.md)
- [Kubespray 설치 가이드](https://github.com/PaaS-TA/paas-ta-container-platform/blob/master/install-guide/standalone/paas-ta-container-platform-standalone-deployment-guide-v1.0.md)
- [CaaS 배포 설치 가이드](https://github.com/PaaS-TA/paas-ta-container-platform/blob/master/install-guide/bosh/paas-ta-container-platform-bosh-deployment-caas-guide-v1.0.md)

### <div id='2.2'/>2.2 Helm 설치  (v3)
> Helm 다운로드 및 실행 
```
#  Helm 다운로드
$  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

#  Helm 파일 권한 수정
$  chmod 700 get_helm.sh

#  Helm 실행
$  ./get_helm.sh
```

> Helm 설치 및 버전 확인
```
$  helm version

WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
version.BuildInfo{Version:"v3.5.3", GitCommit:"041ce5a2c17a58be0fcd5f5e16fb3e7e95fea622", GitTreeState:"dirty", GoVersion:"go1.15.8"}
```

> Helm Repository 추가 및 적용 
```
$  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$  helm repo update
```

> Helm에 등록한 Repo에 대한 세부 정보 확인 
```
$  helm search repo prometheus

NAME                                                CHART VERSION   APP VERSION     DESCRIPTION
prometheus-community/kube-prometheus-stack          14.3.0          0.46.0          kube-prometheus-stack collects Kubernetes manif...
prometheus-community/prometheus                     13.6.0          2.24.0          Prometheus is a monitoring system and time seri...
prometheus-community/prometheus-adapter             2.12.1          v0.8.3          A Helm chart for k8s prometheus adapter
prometheus-community/prometheus-blackbox-exporter   4.10.2          0.18.0          Prometheus Blackbox Exporter
prometheus-community/prometheus-cloudwatch-expo...  0.14.1          0.10.0          A Helm chart for prometheus cloudwatch-exporter
prometheus-community/prometheus-consul-exporter     0.4.0           0.4.0           A Helm chart for the Prometheus Consul Exporter
prometheus-community/prometheus-couchdb-exporter    0.2.0           1.0 A           Helm chart to export the metrics from couchdb...
prometheus-community/prometheus-druid-exporter      0.9.0           v0.8.0          Druid exporter to monitor druid metrics with Pr...
prometheus-community/prometheus-elasticsearch-e...  4.3.0           1.1.0           Elasticsearch stats exporter for Prometheus
prometheus-community/prometheus-kafka-exporter      1.0.0           v1.2.0          A Helm chart to export the metrics from Kafka i...
prometheus-community/prometheus-mongodb-exporter    2.8.1           v0.10.0         A Prometheus exporter for MongoDB metrics
prometheus-community/prometheus-mysql-exporter      1.1.0           v0.12.1         A Helm chart for prometheus mysql exporter with...
prometheus-community/prometheus-nats-exporter       2.6.0           0.7.0           A Helm chart for prometheus-nats-exporter
prometheus-community/prometheus-node-exporter       1.16.2          1.1.2           A Helm chart for prometheus node-exporter
prometheus-community/prometheus-operator            9.3.2           0.38.1          DEPRECATED - This chart will be renamed. See ht...
prometheus-community/prometheus-pingdom-exporter    2.3.2           20190610-1      A Helm chart for Prometheus Pingdom Exporter
prometheus-community/prometheus-postgres-exporter   2.2.0           0.9.0 A         Helm chart for prometheus postgres-exporter
prometheus-community/prometheus-pushgateway         1.7.1           1.3.0 A         Helm chart for prometheus pushgateway
prometheus-community/prometheus-rabbitmq-exporter   0.7.0           v0.29.0         Rabbitmq metrics exporter for prometheus
prometheus-community/prometheus-redis-exporter      4.0.0           1.11.1          Prometheus exporter for Redis metrics
prometheus-community/prometheus-snmp-exporter       0.1.2           0.19.0          Prometheus SNMP Exporter
prometheus-community/prometheus-stackdriver-exp...  1.8.2           0.11.0          Stackdriver exporter for Prometheus
prometheus-community/prometheus-statsd-exporter     0.3.1           0.20.0          A Helm chart for prometheus stats-exporter
prometheus-community/prometheus-to-sd               0.4.0           0.5.2           Scrape metrics stored in prometheus format and ...
prometheus-community/alertmanager                   0.8.0           v0.21.0         The Alertmanager handles alerts sent by client ...
```

> Kubernetes namespace 생성 및 확인
```
#  Kubernetes namespace 생성 
$  kubectl create namespace paas-ta-container-monitoring

#  Kubernetes namespace 확인
$  kubectl get namespace
```

> Kubernetes default namespace 변경 (paas-ta-contianer-monitoring을 위한 네임스페이스를 설정한다.)  
```
#  Kubernetes namespace 변경 
$  kubectl config set-context --current --namespace=paas-ta-container-monitoring
```

> Helm을 이용한 Prometheus 설치    
```
$  helm install prometheus-community/kube-prometheus-stack --generate-name

#  설치가 완료되면 아래와 같은 메세지가 출력된다.
NAME: kube-prometheus-stack-1616563003
LAST DEPLOYED: Wed Mar 24 05:16:51 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
kubectl --namespace default get pods -l "release=kube-prometheus-stack-1616563003"
Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

> 배포 상태 확인    
```
$  kubectl get deploy,po,svc

NAME                                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kube-prometheus-stack-1617-operator                   1/1     1            1           20m
deployment.apps/kube-prometheus-stack-1617006674-grafana              1/1     1            1           20m
deployment.apps/kube-prometheus-stack-1617006674-kube-state-metrics   1/1     1            1           20m

NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/alertmanager-kube-prometheus-stack-1617-alertmanager-0            2/2     Running   0          20m
pod/kube-prometheus-stack-1617-operator-64b644c454-kc4jv              1/1     Running   0          20m
pod/kube-prometheus-stack-1617006674-grafana-74fc6bc6c9-s8z8r         2/2     Running   0          20m
pod/kube-prometheus-stack-1617006674-kube-state-metrics-c86f6dqs52k   1/1     Running   0          20m
pod/kube-prometheus-stack-1617006674-prometheus-node-exporter-8jwvd   1/1     Running   0          20m
pod/kube-prometheus-stack-1617006674-prometheus-node-exporter-f4zv4   1/1     Running   0          20m
pod/kube-prometheus-stack-1617006674-prometheus-node-exporter-sr5gf   1/1     Running   0          20m
pod/prometheus-kube-prometheus-stack-1617-prometheus-0                2/2     Running   0          20m

NAME                                                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                                       ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   20m
service/kube-prometheus-stack-1617-alertmanager                     ClusterIP   10.233.9.127    <none>        9093/TCP                     20m
service/kube-prometheus-stack-1617-operator                         ClusterIP   10.233.16.79    <none>        443/TCP                      20m
service/kube-prometheus-stack-1617-prometheus                       ClusterIP   10.233.50.86    <none>        9090/TCP                     20m
service/kube-prometheus-stack-1617006674-grafana                    ClusterIP   10.233.39.116   <none>        80/TCP                       20m
service/kube-prometheus-stack-1617006674-kube-state-metrics         ClusterIP   10.233.63.208   <none>        8080/TCP                     20m
service/kube-prometheus-stack-1617006674-prometheus-node-exporter   ClusterIP   10.233.22.17    <none>        9100/TCP                     20m
service/prometheus-operated                                         ClusterIP   None            <none>        9090/TCP                     20m
```

> Prometheus ClusterIP 타입을 NodePort 타입으로 변경 (Port 30090)    
```
$  kubectl edit svc kube-prometheus-stack-1617-prometheus
-----------------------------before-----------------------------------
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: kube-prometheus-stack-1617006674
    meta.helm.sh/release-namespace: paas-ta-container-monitoring
  creationTimestamp: "2021-03-29T08:31:29Z"
  labels:
    app: kube-prometheus-stack-prometheus
    app.kubernetes.io/managed-by: Helm
    chart: kube-prometheus-stack-14.4.0
    heritage: Helm
    release: kube-prometheus-stack-1617006674
    self-monitor: "true"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:meta.helm.sh/release-name: {}
          f:meta.helm.sh/release-namespace: {}
        f:labels:
          .: {}
          f:app: {}
          f:app.kubernetes.io/managed-by: {}
          f:chart: {}
          f:heritage: {}
          f:release: {}
          f:self-monitor: {}
      f:spec:
        f:ports:
          .: {}
          k:{"port":9090,"protocol":"TCP"}:
            .: {}
            f:name: {}
            f:port: {}
            f:protocol: {}
            f:targetPort: {}
        f:selector:
          .: {}
          f:app: {}
          f:prometheus: {}
        f:sessionAffinity: {}
        f:type: {}
    manager: Go-http-client
    operation: Update
    time: "2021-03-29T08:31:29Z"
  name: kube-prometheus-stack-1617-prometheus
  namespace: paas-ta-container-monitoring
  resourceVersion: "1284586"
  selfLink: /api/v1/namespaces/paas-ta-container-monitoring/services/kube-prometheus-stack-1617-prometheus
  uid: a9bbe2f4-abf8-42a5-8329-7621119fcbad
spec:
  clusterIP: 10.233.50.86
  ports:
  - name: web
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    app: prometheus
    prometheus: kube-prometheus-stack-1617-prometheus
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}

-----------------------------after-----------------------------------

apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: kube-prometheus-stack-1617006674
    meta.helm.sh/release-namespace: paas-ta-container-monitoring
  creationTimestamp: "2021-03-29T08:31:29Z"
  labels:
    app: kube-prometheus-stack-prometheus
    app.kubernetes.io/managed-by: Helm
    chart: kube-prometheus-stack-14.4.0
    heritage: Helm
    release: kube-prometheus-stack-1617006674
    self-monitor: "true"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:meta.helm.sh/release-name: {}
          f:meta.helm.sh/release-namespace: {}
        f:labels:
          .: {}
          f:app: {}
          f:app.kubernetes.io/managed-by: {}
          f:chart: {}
          f:heritage: {}
          f:release: {}
          f:self-monitor: {}
      f:spec:
        f:ports:
          .: {}
          k:{"port":9090,"protocol":"TCP"}:
            .: {}
            f:name: {}
            f:port: {}
            f:protocol: {}
            f:targetPort: {}
        f:selector:
          .: {}
          f:app: {}
          f:prometheus: {}
        f:sessionAffinity: {}
        f:type: {}
    manager: Go-http-client
    operation: Update
    time: "2021-03-29T08:31:29Z"
  name: kube-prometheus-stack-1617-prometheus
  namespace: paas-ta-container-monitoring
  resourceVersion: "1284586"
  selfLink: /api/v1/namespaces/paas-ta-container-monitoring/services/kube-prometheus-stack-1617-prometheus
  uid: a9bbe2f4-abf8-42a5-8329-7621119fcbad
spec:
  clusterIP: 10.233.50.86
  ports:
  - name: web
    nodePort: 30090
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    app: prometheus
    prometheus: kube-prometheus-stack-1617-prometheus
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

```

> Grafana의 ClusterIP 타입을 NodePort 타입으로 변경 (Port 30091)    
```
$  kubectl edit svc kube-prometheus-stack-1617006674-grafana
-----------------------------before-----------------------------------
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: kube-prometheus-stack-1617006674
    meta.helm.sh/release-namespace: paas-ta-container-monitoring
  creationTimestamp: "2021-03-29T08:31:29Z"
  labels:
    app.kubernetes.io/instance: kube-prometheus-stack-1617006674
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 7.4.5
    helm.sh/chart: grafana-6.6.4
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:meta.helm.sh/release-name: {}
          f:meta.helm.sh/release-namespace: {}
        f:labels:
          .: {}
          f:app.kubernetes.io/instance: {}
          f:app.kubernetes.io/managed-by: {}
          f:app.kubernetes.io/name: {}
          f:app.kubernetes.io/version: {}
          f:helm.sh/chart: {}
      f:spec:
        f:ports:
          .: {}
          k:{"port":80,"protocol":"TCP"}:
            .: {}
            f:name: {}
            f:port: {}
            f:protocol: {}
            f:targetPort: {}
        f:selector:
          .: {}
          f:app.kubernetes.io/instance: {}
          f:app.kubernetes.io/name: {}
        f:sessionAffinity: {}
    manager: Go-http-client
    operation: Update
    time: "2021-03-29T08:31:29Z"
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:spec:
        f:externalTrafficPolicy: {}
        f:ports:
          k:{"port":80,"protocol":"TCP"}:
            f:nodePort: {}
        f:type: {}
    manager: kubectl
    operation: Update
    time: "2021-03-29T09:01:37Z"
  name: kube-prometheus-stack-1617006674-grafana
  namespace: paas-ta-container-monitoring
  resourceVersion: "1290056"
  selfLink: /api/v1/namespaces/paas-ta-container-monitoring/services/kube-prometheus-stack-1617006674-grafana
  uid: 08c55f35-7572-4c29-8ed4-07e956bf41c3
spec:
  clusterIP: 10.233.39.116
  externalTrafficPolicy: Cluster
  ports:
  - name: service
    port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app.kubernetes.io/instance: kube-prometheus-stack-1617006674
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}

-----------------------------after-----------------------------------
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: kube-prometheus-stack-1617006674
    meta.helm.sh/release-namespace: paas-ta-container-monitoring
  creationTimestamp: "2021-03-29T08:31:29Z"
  labels:
    app.kubernetes.io/instance: kube-prometheus-stack-1617006674
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 7.4.5
    helm.sh/chart: grafana-6.6.4
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:meta.helm.sh/release-name: {}
          f:meta.helm.sh/release-namespace: {}
        f:labels:
          .: {}
          f:app.kubernetes.io/instance: {}
          f:app.kubernetes.io/managed-by: {}
          f:app.kubernetes.io/name: {}
          f:app.kubernetes.io/version: {}
          f:helm.sh/chart: {}
      f:spec:
        f:ports:
          .: {}
          k:{"port":80,"protocol":"TCP"}:
            .: {}
            f:name: {}
            f:port: {}
            f:protocol: {}
            f:targetPort: {}
        f:selector:
          .: {}
          f:app.kubernetes.io/instance: {}
          f:app.kubernetes.io/name: {}
        f:sessionAffinity: {}
    manager: Go-http-client
    operation: Update
    time: "2021-03-29T08:31:29Z"
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:spec:
        f:externalTrafficPolicy: {}
        f:ports:
          k:{"port":80,"protocol":"TCP"}:
            f:nodePort: {}
        f:type: {}
    manager: kubectl
    operation: Update
    time: "2021-03-29T09:01:37Z"
  name: kube-prometheus-stack-1617006674-grafana
  namespace: paas-ta-container-monitoring
  resourceVersion: "1290056"
  selfLink: /api/v1/namespaces/paas-ta-container-monitoring/services/kube-prometheus-stack-1617006674-grafana
  uid: 08c55f35-7572-4c29-8ed4-07e956bf41c3
spec:
  clusterIP: 10.233.39.116
  externalTrafficPolicy: Cluster
  ports:
  - name: service
    nodePort: 30091
    port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app.kubernetes.io/instance: kube-prometheus-stack-1617006674
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```

>  Kubernetes 기본 namespace 변경 
```
$  kubectl config set-context --current --namespace=""
```


## <div id='3'/>3.	PaaS-TA Container Monitoring 설치 확인

>  Monitoring-Web에 접속하여 CaaS 메뉴를 클릭하여 확인한다.
 
![paasta_container_monitoring]


## <div id='4'/>4.	Prometheus 정보 확인 

>  Kubernetes Master IP와 Prometheus의 외부 포트를 통해 접속하여 확인한다.

![paasta_container_monitoring_prometheus]

## <div id='5'/>5.	Grafana 정보 확인

>  Kubernetes Secret 목록을 확인한다.
 ```
 NAME                                                              TYPE                                  DATA   AGE
 alertmanager-kube-prometheus-stack-1617-alertmanager              Opaque                                1      15h
 alertmanager-kube-prometheus-stack-1617-alertmanager-generated    Opaque                                1      15h
 alertmanager-kube-prometheus-stack-1617-alertmanager-tls-assets   Opaque                                0      15h
 default-token-lw5ks                                               kubernetes.io/service-account-token   3      17h
 kube-prometheus-stack-1617-admission                              Opaque                                3      15h
 kube-prometheus-stack-1617-alertmanager-token-vc8x6               kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617-operator-token-xkd9x                   kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617-prometheus-token-7lfmn                 kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617006674-grafana                          Opaque                                3      15h
 kube-prometheus-stack-1617006674-grafana-test-token-wq4xh         kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617006674-grafana-token-zd2cg              kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617006674-kube-state-metrics-token-d54rf   kubernetes.io/service-account-token   3      15h
 kube-prometheus-stack-1617006674-prometheus-node-exporter-94khs   kubernetes.io/service-account-token   3      15h
 prometheus-kube-prometheus-stack-1617-prometheus                  Opaque                                1      15h
 prometheus-kube-prometheus-stack-1617-prometheus-tls-assets       Opaque                                1      15h
 sh.helm.release.v1.kube-prometheus-stack-1617006674.v1            helm.sh/release.v1                    1      15h
 ```

>  Grafana의 Admin 비밀번호를 확인한다.
 ```
$  kubectl get secret kube-prometheus-stack-1617006674-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
 *************
 ```

>  Kubernetes Master IP와 Grafana의 외부 포트를 통해 접속하여 확인한다. 

![paasta_container_monitoring_grafana]

[paasta_container_monitoring]:./images/paasta-container-monitoring.png
[paasta_container_monitoring_prometheus]:./images/paasta-container-monitoring-prometheus.png
[paasta_container_monitoring_grafana]:./images/paasta-container-monitoring-grafana.png