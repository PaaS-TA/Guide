## Table of Contents

1. [문서개요](#1)
  * [목적](#2)
  * [범위](#3)
  * [참고자료](#4)
2. [PaaS-TA Monitoring Architecture](#5)    
    * [PaaS Monitoring Architecture](#6)
    * [PaaS 자원정보 수집 Architecture](#7)
    * [CaaS Monitoring Architecture](#8)
    * [CaaS 자원정보 수집 Architecture](#9)
    * [SaaS Monitoring Architecture](#10)
    * [SaaS 자원정보 수집 Architecture](#11)
    * [IaaS Monitoring Architecture](#11-1) 
3. [PaaS-TA Monitoring 설치](#12)
    * [Pre-requsite](#13)
    * [PaaS-TA 5.0 Monitoring 설치 파일 다운로드](#14)
    * [PaaS-TA Monitoring 설치환경](#15)
    * [Logsearch 설치](#16)
        *  [logsearch-deployment.yml](#17)
        *  [deploy.sh](#18)
    * [PaaS-TA Pinpoint Monitoring release 설치](#19)    
    * [PaaS-TA Container service 설치 및 Prometheus Agent 정보확인](#19-1)
    * [PaaS-TA Monitoring 설치](#20)
        *  [paasta-monitoring.yml](#21)
        *  [deploy-paasta-monitoring.sh](#22)
    * [PaaS-TA Monitoring IaaS 설치](#23)    
    * [PaaS-TA Monitoring dashboard 접속](#24)

# <div id='1'/>1.  문서 개요 

## <div id='2'/>1.1.  목적
본 문서(설치가이드)는 PaaS-TA(5.0) 환경기준으로 PaaS-TA Monitoring 설치를 위한 가이드를 제공한다.

## <div id='3'/>1.2.  범위
본 문서(설치가이드)는 PaaS-TA(5.0) 환경기준으로 PaaS-TA Monitoring 설치를 위한 가이드를 제공한다. Monitoring 중 IaaS-PaaS 통합 Monitoring은 별도 통합 Monitoring 문서를 제공하며 본문서는 PaaS, CaaS, SaaS Monitoring 설치 가이드를 제공함에 있다.

## <div id='4'/>1.3.  참고자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

Cloud Foundry Document: [https://docs.cloudfoundry.org/](https://docs.cloudfoundry.org/)

BOSH DEPLOYMENT: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

CF DEPLOYMENT: [https://github.com/cloudfoundry/cf-deployment](https://github.com/cloudfoundry/cf-deployment)



# <div id='5'/>2. PaaS-TA Monitoring Architecture

## <div id='6'/>2.1. PaaS Monitoring Architecture
PaaS Monitoring 운영환경에서는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.
Batch 프로세스는 PaaS-TA Portal에서 등록한 임계치 정보와 AutoScale 대상 정보를 기준으로 주기적으로 시스템 metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송하며, 임계치를 초과한 컨테이너 리스트 중에서 AutoScale 대상의 컨테이너 존재시 AutoScale Server 서비스에 관련 정보를 전송하여, 자동으로 AutoScaling 기능이 수행되도록 처리한다.
PaaS-TA Monitoring 시스템은 TSDB(InfluxDB)로부터 시스템 환경 정보 데이터를 조회하고, Lucene(Elasticsearch)을 통해 로그 정보를 조회한다. 조회된 정보로 PaaS-TA Monitoring 시스템의 현재 자원 사용 현황을 조회하고, PaaS-TA Monitoring dashboard를 통해 로그 정보를 조회할 수 있도록 한다. PaaS-TA Monitoring dashboard는 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, 컨테이너 배치 현황과 장애 발생 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다

![PaaSTa_Monit_architecure_Image]

## <div id='7'/>2.2. PaaS 자원정보 수집 Architecture
PaaS는 내부적으로 메트릭스 정보를 수집 및 전달하는 Metric Agent와 로그 정보를 수집 및 전달하는 syslog 모듈을 제공한다. Metric Agent는 시스템 관련 메트릭스를 수집하여 InfluxDB에 정보를 저장한다. syslog는 PaaS-TA를 Deploy 하기 위한 manfiest 파일의 설정으로도 로그 정보를 ELK 서비스에 전달할 수 있으며, 로그 정보를 전달하기 위해서는 relp 프로토콜(reliable event logging protocol)을 사용한다.

![PaaSTa_Monit_collect_architecure_Image]

## <div id='8'/>2.3. CaaS Monitoring Architecture
CaaS Monitoring 운영환경에는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.
Batch 프로세스는 CaaS에서 등록한 임계치 정보를 기준으로 주기적으로 시스템 metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송한다.
PaaS-TA Monitoring 시스템은 K8s(Prometheus Agent)로부터 시스템 메트릭 데이터를 조회하고, 조회된 정보로 CaaS Monitoring 시스템의 현재 자원 사용 현황을 조회한다.
PaaS-TA Monitoring dashboard는 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, kubernests Pod 현황 및 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다

![Caas_Monit_architecure_Image]

## <div id='9'/>2.4. CaaS 자원정보 수집 Architecture
CaaS는 내부적으로 메트릭스 정보를 수집 하는 Prometheus Metric Agent(Node Exporter, cAdvisor) 제공한다. Prometheus 기본 제공되는 로컬 디지스 Time-Series Database 정보를 저장한다. 해당 정보를 조회하기 위해서는 Prometheus 제공하는 API를 통하여 조회할 수 있다.

![Caas_Monit_collect_architecure_Image]

## <div id='10'/>2.5. SaaS Monitoring Architecture
Saas Monitoring 운영환경에는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.
Batch 프로세스는 PaaS-TA Portal SaaS 서비스에서 등록한 임계치 정보를 기준으로 주기적으로 시스템 metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송한다.
Monitoring 시스템 은 PINPOINT APM Server 로부터 시스템 메트 데이터를 조회하고, 조회된 정보는 SaaS Monitoring 시스템의 현재 자원 사용 현황을 조회한다.
Monitoring Portal은 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, Application 현황 및 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다

![Saas_Monit_architecure_Image]

## <div id='11'/>2.6. SaaS 자원정보 수집 Architecture
PaaS-TA SaaS는 내부적으로 메트릭스 정보를 수집 하는 PINPOINT Metric Agent 제공한다. Metric Agent는 Application JVM 관련 메트릭스를 수집하여 Hbase DB에 정보를 저장한다. 해당 정보는 PINPOINT APM 서버의 API를 통하여 조회할 수 있다.

![Saas_Monit_collect_architecure_Image]

## <div id='11-1'/>2.7. IaaS  Monitoring Architecture
IaaS 서비스 모니터링 운영환경은 IaaS는 Openstack과 Monasca를 기반으로 구성되어 있다. IaaS는 Openstack Node에 monasca Agent가 설치되어 Metric Data를 Monasca에 전송하여 InfluxDB에 저장한다. PaaS는 PaaS-TA에 모니터링 Agent가 설치되어 InfluxDB에 전송 저장한다. 
Log Agent도 IaaS/PaaS에 설치되어 Log Data를 각각의 Log Repository에 전송한다.
![IaaSTa_Monit_architecure_Image]



# <div id='12'/>3.	PaaS-TA Monitoring 설치

## <div id='13'/>3.1. Pre-requsite

1. PaaS-TA 5.0 Monitoring을 설치 하기 위해서는 bosh 설치과정에서 언급한 것 처럼 관련 deployment, release , stemcell을 PaaS-TA 사이트에서 다운로드 받아 정해진 경로에 복사 해야 한다.
2. PaaS-TA 5.0이 설치되어 있어야 하며, monitoring Agent가 설치되어 있어야 한다.
3. bosh login이 되어 있어야 한다.

## <div id='14'/>3.2.	PaaS-TA 5.0 Monitoring 설치 파일 다운로드

> **[설치 파일 다운로드 받기](https://paas-ta.kr/download/package)**

> **[PaaS-TA Monitoring Source Github](https://github.com/PaaS-TA/PaaS-TA-Monitoring)**

PaaS-TA 사이트에서 [PaaS-TA 설치 릴리즈] 파일을 다운로드 받아 ~/workspace/paasta-5.0/release 이하 디렉토리에 압축을 푼다. 압출을 풀면 아래 그림과 같이 ~/workspace/paasta-5.0/release/paasta-monitoring 이하 디렉토리가 생성되며 이하에 릴리즈 파일(tgz)이 존재한다.

![PaaSTa_release_dir_5.0]

## <div id='15'/>3.3. PaaS-TA Monitoring 설치환경

~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring 이하 디렉토리에는 paasta-monitoring, paasta-pinpoint-monitoring 디렉토리가 존재한다. Logsearch는 logAgent에서 발생한 Log정보를 수집하여 저장하는 Deployment이다. paasta-monitoring은 PaaS-TA VM에서 발생한 Metric 정보를 수집하여 Monitoring을 실행한다.

```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring
```

## <div id='16'/>3.4.	Logsearch 설치

PaaS-TA VM Log수집을 위해서는 logsearch가 설치되어야 한다. 

```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring/paasta-monitoring
```

### <div id='17'/>3.4.1.	logsearch-deployment.yml
logsearch-deployment.yml에는 ls-router, cluster-monitor, elasticsearch_data, elastic_master, kibana, mainternance 의 명세가 정의되어 있다. 

```
---
name: logsearch
update:
  canaries: 3
  canary_watch_time: 30000-1200000
  max_in_flight: 1
  serial: false
  update_watch_time: 5000-1200000
instance_groups:
- name: elasticsearch_master
  azs:
  - z5
  instances: 1
  persistent_disk_type: 10GB
  vm_type: medium
  stemcell: default
  update:
    max_in_flight: 1
    serial: true
  networks:
  - name: default
  jobs:
  - name: elasticsearch
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
    provides:
      elasticsearch: {as: elasticsearch_master}
    properties:
      elasticsearch:
        node:
          allow_master: true
  - name: syslog_forwarder
    release: logsearch
    consumes:
      syslog_forwarder: {from: cluster_monitor}
    properties:
      syslog_forwarder:
        config:
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stdout.log
          service: elasticsearch
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stderr.log
          service: elasticsearch
        - file: /var/vcap/sys/log/cerebro/cerebro.stdout.log
          service: cerebro
        - file: /var/vcap/sys/log/cerebro/cerebro.stderr.log
          service: cerebro
  - name: route_registrar
    release: logsearch-for-cloudfoundry
    consumes:
      nats: {from: nats, deployment: paasta}
    properties:
      route_registrar:
        routes:
        - name: elasticsearch
          port: 9200
          registration_interval: 60s
          uris:
          - "elastic.((system_domain))"

- name: cluster_monitor
  azs:
  - z6
  instances: 1
  persistent_disk_type: 10GB
  vm_type: medium
  stemcell: default
  update:
    max_in_flight: 1
    serial: true
  networks:
  - name: default
  jobs:
  - name: elasticsearch
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_cluster_monitor}
    provides:
      elasticsearch: {as: elasticsearch_cluster_monitor}
    properties:
      elasticsearch:
        cluster_name: monitor
        node:
          allow_data: true
          allow_master: true
  - name: elasticsearch_config
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_cluster_monitor}
    properties:
      elasticsearch_config:
        templates:
        - shards-and-replicas: '{ "template" : "logstash-*", "order" : 100, "settings"
            : { "number_of_shards" : 1, "number_of_replicas" : 0 } }'
        - index-settings: /var/vcap/jobs/elasticsearch_config/index-templates/index-settings.json
        - index-mappings: /var/vcap/jobs/elasticsearch_config/index-templates/index-mappings.json
  - name: ingestor_syslog
    release: logsearch
    provides:
      syslog_forwarder: {as: cluster_monitor}
    properties:
      logstash_parser:
        filters:
        - monitor: /var/vcap/packages/logsearch-config/logstash-filters-monitor.conf
  - name: curator
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_cluster_monitor}
    properties:
      curator:
        purge_logs:
          retention_period: 7
  - name: kibana
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_cluster_monitor}
    properties:
      kibana:
        memory_limit: 30
        wait_for_templates: [shards-and-replicas]
- name: maintenance
  azs:
  - z5
  - z6
  instances: 1
  vm_type: medium 
  stemcell: default
  update:
    serial: true
  networks:
  - name: default
  jobs:
  - name: elasticsearch_config
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
    properties:
      elasticsearch_config:
        index_prefix: logs-
        templates:
          - shards-and-replicas: /var/vcap/jobs/elasticsearch_config/index-templates/shards-and-replicas.json
          - index-settings: /var/vcap/jobs/elasticsearch_config/index-templates/index-settings.json
          - index-mappings: /var/vcap/jobs/elasticsearch_config/index-templates/index-mappings.json
          - index-mappings-lfc: /var/vcap/jobs/elasticsearch-config-lfc/index-mappings.json
          - index-mappings-app-lfc: /var/vcap/jobs/elasticsearch-config-lfc/index-mappings-app.json
          - index-mappings-platform-lfc: /var/vcap/jobs/elasticsearch-config-lfc/index-mappings-platform.json
  - name: curator
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
  - name: elasticsearch-config-lfc
    release: logsearch-for-cloudfoundry
  - name: syslog_forwarder
    release: logsearch
    consumes:
      syslog_forwarder: {from: cluster_monitor}
    properties:
      syslog_forwarder:
        config:
        - file: /var/vcap/sys/log/curator/curator.log
          service: curator
- name: elasticsearch_data
  azs:
  - z5
  - z6
  instances: 2
  persistent_disk_type: 30GB
  vm_type: medium 
  stemcell: default
  update:
    max_in_flight: 1
    serial: true
  networks:
  - name: default
  jobs:
  - name: elasticsearch
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
    properties:
      elasticsearch:
        node:
          allow_data: true
  - name: syslog_forwarder
    release: logsearch
    consumes:
      syslog_forwarder: {from: cluster_monitor}
    properties:
      syslog_forwarder:
        config:
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stdout.log
          service: elasticsearch
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stderr.log
          service: elasticsearch
        - file: /var/vcap/sys/log/cerebro/cerebro.stdout.log
          service: cerebro
        - file: /var/vcap/sys/log/cerebro/cerebro.stderr.log
          service: cerebro
- name: kibana
  azs:
  - z5
  instances: 1
  persistent_disk_type: 5GB
  vm_type: medium 
  stemcell: default
  networks:
  - name: default

  jobs:
  - name: elasticsearch
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
  - name: redis
    release: logsearch-for-cloudfoundry
    provides:
      redis: {as: redis_link}
  - name: kibana
    release: logsearch
    provides:
      kibana: {as: kibana_link}
    consumes:
      elasticsearch: {from: elasticsearch_master}
    properties:
      kibana:
        health:
          timeout: 300
        env:
          - NODE_ENV: production
  - name: syslog_forwarder
    release: logsearch
    consumes:
      syslog_forwarder: {from: cluster_monitor}
    properties:
      syslog_forwarder:
        config:
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stdout.log
          service: elasticsearch
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stderr.log
          service: elasticsearch
        - file: /var/vcap/sys/log/cerebro/cerebro.stdout.log
          service: cerebro
        - file: /var/vcap/sys/log/cerebro/cerebro.stderr.log
          service: cerebro
- name: ingestor
  azs:
  - z4
  - z6
  instances: 2
  persistent_disk_type: 10GB
  vm_type: medium 
  stemcell: default
  networks:
  - name: default
  jobs:
  - name: elasticsearch
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
  - name: parser-config-lfc
    release: logsearch-for-cloudfoundry
  - name: ingestor_syslog
    release: logsearch
    provides:
      ingestor: {as: ingestor_link}
    properties:
      logstash_parser:
        filters:
          - logsearch-for-cf: /var/vcap/packages/logsearch-config-logstash-filters/logstash-filters-default.conf
        elasticsearch:
          index: logs-%{[@metadata][index]}-%{+YYYY.MM.dd}
        deployment_dictionary:
          - /var/vcap/packages/logsearch-config/deployment_lookup.yml
          - /var/vcap/jobs/parser-config-lfc/config/deployment_lookup.yml
  - name: syslog_forwarder
    release: logsearch
    consumes:
      syslog_forwarder: {from: cluster_monitor}
    properties:
      syslog_forwarder:
        config:
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stdout.log
          service: elasticsearch
        - file: /var/vcap/sys/log/elasticsearch/elasticsearch.stderr.log
          service: elasticsearch
        - file: /var/vcap/sys/log/ingestor_syslog/ingestor_syslog.stdout.log
          service: ingestor
        - file: /var/vcap/sys/log/ingestor_syslog/ingestor_syslog.stderr.log
          service: ingestor
- name: ls-router
  azs:
  - z4
  instances: 1
  vm_type: small
  stemcell: default
  networks:
  - name: default
    static_ips: 
    - ((router_ip)) 
  jobs:
  - name: haproxy
    release: logsearch
    consumes:
      elasticsearch: {from: elasticsearch_master}
      ingestor: {from: ingestor_link}
      kibana: {from: kibana_link}
      syslog_forwarder: {from: cluster_monitor}
    properties:
      inbound_port:
        https: 4443
  - name: route_registrar
    release: logsearch-for-cloudfoundry
    consumes:
      nats: {from: nats, deployment: paasta}
    properties:
      route_registrar:
        routes:
        - name: kibana
          port: 80
          registration_interval: 60s
          uris:
          - "logs.((system_domain))"

variables:
- name: kibana_oauth2_client_secret
  type: password
- name: firehose_client_secret
  type: password

releases:
- name: logsearch
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/paasta-monitoring/logsearch-boshrelease-209.0.1.tgz
  version: "209.0.1"
- name: logsearch-for-cloudfoundry
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/paasta-monitoring/logsearch-for-cloudfoundry-207.0.1.tgz
  version: "207.0.1"
stemcells:
- alias: default
  os: ubuntu-xenial
  version: "315.36"
```

### <div id='18'/>3.4.2. deploy-logsearch.sh

deploy.sh의 –v 의 inception_os_user_name, router_ip, system_domain 및 director_name을 시스템 상황에 맞게 설정한다.
system_domain은 PaaS-TA 설치시 설정했던 system_domain을 입력하면 된다.
router_ip는 ls-router가 설치된 azs에서 정의한 cider값의 적당한 IP를 지정한다.

```
bosh –e {director_name} -d logsearch deploy logsearch-deployment.yml \
  -v inception_os_user_name=ubuntu \  # home user명 (release file path와 연관성 있음. /home/ubuntu/paasta-5.0 이하 release 파일들의 경로 설정)
  -v router_ip=10.20.50.34 \   # 배포한 ls-router VM의 private ip
  -v system_domain={system_domain}  #PaaS-TA 설치시 설정한 System Domain
```

deploy.sh을 실행하여 logsearch를 설치 한다.

```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring/paasta-monitoring
$ sh deploy-logsearch.sh
```

logsearch가 설치 완료 되었음을 확인한다.
```
$ bosh –e {director_name} vms
```
![PaaSTa_logsearch_vms_5.0]

## <div id='19'/>3.5.	PaaS-TA Pinpoint Monitoring release 설치

PaaS-TA SaaS는 Application CPU, Memory, Thread , Response Time 정보를 수집을 위해서는 paasta-pinpoint-monitoring가 설치되어야 한다. 
자세한 설치 방법은 아래 링크를 참조하길 바랍니다.
> **[PaaS-TA Pinpoint Monitoring release 설치](https://github.com/PaaS-TA/PAAS-TA-PINPOINT-MONITORING-RELEASE)**

## <div id='19-1'/>3.6.	PaaS-TA Container service 설치 및 Prometheus Agent 정보확인

PaaS-TA CaaS 서비스는 Kubernetes Cluster, Workload, Pod 및 Alarm 정보를 수집을 위하여 paasta-container-service에 Prometheus Agent가 설치되어야 한다. 
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
```

### <div id='19-2'/>3.6.1	manifests/paasta-container-service-vars-{Cloud Provider}.yml
Deployment YAML에서 사용하는 변수들을 서버 환경에 맞게 수정한다. 

```
# INCEPTION OS USER NAME
inception_os_user_name: "ubuntu"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "1.0"

# IAAS
auth_url: 'http://<IAAS-IP>:5000/v3'
openstack_domain: '<OPENSTACK_DOMAIN>'
openstack_username: '<OPENSTACK_USERNAME>'
openstack_password: '<OPENSTACK_PASSWORD>'
openstack_project_id: '<OPENSTACK_PROJECT_ID>'
region: '<OPENSTACK_REGION>'
ignore-volume-az: true

# STEMCELL
stemcell_os: "ubuntu-trusty"
stemcell_version: "315.36"
stemcell_alias: "trusty"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "minimal"

# NETWORK
service_private_networks_name: "default"
service_public_networks_name: "vip"

# IPS
caas_master_public_url: "115.68.151.178"   # CAAS-MASTER-PUBLIC-URL
haproxy_public_ips: "115.68.151.177"       # HAPROXY-PUBLIC-URL

# CREDHUB
credhub_server_url: "10.20.0.7:8844"       # Bosh credhub server URL
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>"
cf_api_url: "https://api.<DOMAIN>"
cf_uaa_oauth_client_id: "<CF_UAA_OAUTH_CLIENT_ID>"
cf_uaa_oauth_client_secret: "<CF_UAA_OAUTH_CLIENT_SECRET>"

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z1]

# MARIADB
mariadb_port: "<MARIADB_PORT>"
mariadb_azs: [z2]
mariadb_persistent_disk_type: "10GB"
mariadb_admin_user_id: "<MARIADB_ADMIN_USER_ID>"
mariadb_admin_user_password: "<MARIADB_ADMIN_USER_PASSWORD>"
mariadb_role_set_administrator_code_name: "Administrator"
mariadb_role_set_administrator_code: "RS0001"
mariadb_role_set_regular_user_code_name: "Regular User"
mariadb_role_set_regular_user_code: "RS0002"
mariadb_role_set_init_user_code_name: "Init User"
mariadb_role_set_init_user_code: "RS0003"

# DASHBOARD
caas_dashboard_instances: 1
caas_dashboard_port: 8091
caas_dashboard_azs: [z3]
caas_dashboard_management_security_enabled: false
caas_dashboard_logging_level: "INFO"

# API
caas_api_instances: 1
caas_api_port: 3333
caas_api_azs: [z1]
caas_api_management_security_enabled: false
caas_api_logging_level: "INFO"

# COMMON API
caas_common_api_instances: 1
caas_common_api_port: 3334
caas_common_api_azs: [z2]
caas_common_api_logging_level: "INFO"

# SERVICE BROKER
caas_service_broker_instances: 1
caas_service_broker_port: 8888
caas_service_broker_azs: [z3]

# (OPTIONAL) PRIVATE IMAGE REPOSITORY
private_image_repository_release_name: "private-image-repository-release"
private_image_repository_release_version: "1.0"
private_image_repository_azs: [z1]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/lib/docker-registry"
private_image_repository_user_name: "<PRIVATE_IMAGE_REPOSITORY_USER_NAME>"
private_image_repository_user_password: "#################" # cloudfoundry (encoding by Bcrypt)
private_image_repository_public_url: "115.68.151.99"     # PRIVATE-IMAGE-REPOSITORY-PUBLIC-URL
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z2]

# MASTER
caas_master_backend_port: 8443
caas_master_port: 8443
caas_master_azs: [z3]
caas_master_persistent_disk_type: 5120

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z1,z2,z3]
```

### <div id='19-3'/>3.6.2.	PaaS-TA Container service 설치
Cloud Provider 환경에 맟는 deploy shell 스크립트를 실행한다. 

```
$  ./deploy-{Cloud Provider}.sh
```

### <div id='19-4'/>3.6.3.	PaaS-TA Container service의 설치 완료를 확인한다. 
![PaaSTa_paasta_container_service_vms]

### <div id='19-5'/>3.6.4.	Kubernetes Prometheus Pods 정보를 확인한다.  
```
$  bosh -e {director_name} ssh -d paasta-container-service master
$  /var/vcap/packages/kubernetes/bin/kubectl get pods --all-namespaces -o wide
```
![PaaSTa_paasta_container_service_pods]

### <div id='19-6'/>3.6.5.	prometheus-prometheus-prometheus-oper-prometheus-0 POD의 Node IP를 확인한다.
```
$  /var/vcap/packages/kubernetes/bin/kubectl get nodes -o wide
```
![PaaSTa_paasta_container_service_nodes]

### <div id='19-7'/>3.6.6.	Kubernetes API URL(serverAddress)를 확인한다.
```
$  curl localhost:8080/api
```
![PaaSTa_paasta_container_service_kubernetes_api]

### <div id='19-8'/>3.6.7.	Kubernetes API Request 호출시 Header(Authorization) 인증을 위한 Token값을 확인한다. 
```
$  /var/vcap/packages/kubernetes/bin/kubectl -n kube-system describe secret $(/var/vcap/packages/kubernetes/bin/kubectl -n kube-system get secret | grep monitoring-admin | awk '{print $1}')
```
![PaaSTa_paasta_container_service_kubernetes_token]


## <div id='20'/>3.7.	PaaS-TA Monitoring 설치

PaaS Monitoring을 위해서 paasta-monitoring이 설치되어야 한다. 

```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring/paasta-monitoring
```

### <div id='21'/>3.7.1.	paasta-monitoring.yml
paasta-monitoring.yml에는 redis, influxdb(metric_db), mariadb, monitoring-web, monitoring-batch에 대한 명세가 있다.

```
---
name: paasta-monitoring                      # 서비스 배포이름(필수) bosh deployments 로 확인 가능한 이름

addons:
- name: bpm
  jobs:
  - name: bpm
    release: bpm

stemcells:
- alias: default
  os: ubuntu-xenial
  version: latest

releases:
- name: paasta-monitoring  # 서비스 릴리즈 이름(필수) bosh releases로 확인 가능
  version: latest                                              # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/monitoring/monitoring-release.tgz 
- name: bpm
  sha1: 0845cccca348c6988debba3084b5d65fa7ca7fa9
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/paasta/bpm-0.13.0-ubuntu-xenial-97.28-20181023-211102-981313842.tgz
  version: 0.13.0
- name: redis
  version: 14.0.1
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/service/redis-14.0.1.tgz
  sha1: fd4a6107e1fb8aca1d551054d8bc07e4f53ddf05
- name: influxdb
  version: latest
  url: file:///home/((inception_os_user_name))/workspace/paasta-5.0/release/service/influxdb.tgz
  sha1: 2337d1f26f46100b8d438b50b71e300941da74a2


instance_groups:
- name: redis
  azs: [z4]
  instances: 1
  vm_type: small
  stemcell: default
  persistent_disk: 10240
  networks:
  - name: default
    default: [dns, gateway]
    static_ips:
    - ((redis_ip))
  - name: vip
    static_ips:
    - 115.68.151.177 
 
  jobs:
  - name: redis
    release: redis
    properties:
      password: ((redis_password))
- name: sanity-tests
  azs: [z4]
  instances: 1
  lifecycle: errand
  vm_type: small
  stemcell: default
  networks: [{name: default}]
  jobs:
  - name: sanity-tests
    release: redis

- name: influxdb
  azs: [z5]
  instances: 1
  vm_type: large
  stemcell: default
  persistent_disk_type: 10GB
  networks:
  - name: default
    default: [dns, gateway]
    static_ips:
    - ((influxdb_ip)) 
  - name: vip
    static_ips: 
    - 115.68.151.187

  jobs:
  - name: influxdb
    release: influxdb
    properties:
      influxdb:
        database: cf_metric_db                                        #InfluxDB default database
        user: root                                                                                              #admin account
        password: root                                                                                  #admin password
        replication: 1
        ips: 127.0.0.1                                                                                  #local I2
  - name: chronograf
    release: influxdb

- name: mariadb
  azs: [z5]
  instances: 1
  vm_type: medium 
  stemcell: default
  persistent_disk_type: 5GB
  networks:
  - name: default
    default: [dns, gateway]
    static_ips: ((mariadb_ip))
  - name: vip
    static_ips:
    - 115.68.151.188
  jobs:
  - name: mariadb
    release: paasta-monitoring
    properties:
      mariadb:
        port: ((mariadb_port))                                        #InfluxDB default database
        admin_user:
          password: '((mariadb_password))'                             # MARIA DB ROOT 계정 비밀번호

- name: monitoring-batch
  azs: [z6]
  instances: 1
  vm_type: small 
  stemcell: default
  networks:
  - name: default
  jobs:
  - name: monitoring-batch
    release: paasta-monitoring
    consumes:
      influxdb: {from: influxdb}
    properties:
      monitoring-batch:
        influxdb:
          url: ((influxdb_ip)):8086
        db:
          ip: ((mariadb_ip))
          port: ((mariadb_port))
          username: ((mariadb_username))
          password: ((mariadb_password))
        paasta:
          cell_prefix: ((paasta_cell_prefix))
        bosh:
          url: ((bosh_url))
          password: ((bosh_password))
          director_name: ((director_name))
          paasta:
            deployments: ((paasta_deploy_name))
        mail:
          smtp:
            url: ((smtp_url))
            port: ((smtp_port))
          sender:
            name: ((mail_sender))
            password: ((mail_password))
          resource:
            url: ((resource_url))
          send: ((mail_enable))
          tls: ((mail_tls_enable))
        redis:
          url: ((redis_ip)):6379
          password: ((redis_password))
        paasta:
          apiurl: http://api.((system_domain))
          uaaurl: https://uaa.((system_domain))
          username: ((paasta_username))
          password: ((paasta_password))

- name: caas-monitoring-batch
  azs: [z6]
  instances: 1
  vm_type: small
  stemcell: default
  networks:
  - name: default
  jobs:
  - name: caas-monitoring-batch
    release: paasta-monitoring
    consumes:
      influxdb: {from: influxdb}
    properties:
      caas-monitoring-batch:
        db:
          ip: ((mariadb_ip))
          port: ((mariadb_port))
          username: ((mariadb_username))
          password: ((mariadb_password))
        mail:
          smtp:
            url: ((smtp_url))
            port: ((smtp_port))
          sender:
            name: ((mail_sender))
            password: ((mail_password))
          resource:
            url: ((resource_url))
          send: ((mail_enable))
          tls: ((mail_tls_enable))

- name: saas-monitoring-batch
  azs: [z6]
  instances: 1
  vm_type: small
  stemcell: default
  networks:
  - name: default
  jobs:
  - name: saas-monitoring-batch
    release: paasta-monitoring
    consumes:
      influxdb: {from: influxdb}
    properties:
     saas-monitoring-batch:
        db:
          ip: ((mariadb_ip))
          port: ((mariadb_port))
          username: ((mariadb_username))
          password: ((mariadb_password))
        mail:
          smtp:
            url: ((smtp_url))
            port: ((smtp_port))
          sender:
            name: ((mail_sender))
            password: ((mail_password))
          resource:
            url: ((resource_url))
          send: ((mail_enable))
          tls: ((mail_tls_enable))

- name: monitoring-web
  azs: [z6]
  instances: 1
  vm_type: small 
  stemcell: default
  networks:
  - name: default
    default: [dns, gateway]
  - name: vip
    static_ips: [((monit_public_ip))]

  jobs:
  - name: monitoring-web
    release: paasta-monitoring
    properties:
      monitoring-web:
        db:
          ip: ((mariadb_ip))
          port: ((mariadb_port))
          username: ((mariadb_username))
          password: ((mariadb_password))
        influxdb:
          url: http://((influxdb_ip)):8086
        paasta:
          system_domain: ((system_domain))
        bosh:
          ip: ((bosh_url))
          password: ((bosh_password))
          director_name: ((director_name))
        redis:
          url: ((redis_ip)):6379
          password: ((redis_password))
        time:
          gap: ((utc_time_gap))
        prometheus:
          url: ((prometheus_ip)):30090
        kubernetes:
          url: ((kubernetes_ip)):8443
          token: ((kubernetes_token))
        pinpoint:
          url: ((pinpoint_ip)):8079
        pinpointWas:
          url: ((pinpoint_was_ip)):8080
        caasbroker:
          url: ((cassbroker_ip)):3334

variables:
- name: redis_password
  type: password


update:
  canaries: 1
  canary_watch_time: 1000-180000
  max_in_flight: 1
  serial: true
  update_watch_time: 1000-180000

```

### <div id='22'/>3.7.2.	deploy-paasta-monitoring.sh
deploy-paasta-monitoring.sh의 –v 의 inception_os_user_name, system_domain 및 director_name을 시스템 상황에 맞게 설정한다.

```
bosh –e {director_name} -d paasta-monitoring deploy paasta-monitoring.yml  \
     -v inception_os_user_name=ubuntu \
     -v mariadb_ip=10.20.50.11 \  # mariadb vm private IP
     -v mariadb_port=3306 \      # mariadb port
     -v mariadb_username=root \  # mariadb root 계정
     -v mariadb_password=password \  # mariadb root 계정 password
     -v influxdb_ip=10.20.50.15 \   # influxdb vm private IP
     -v bosh_url=10.20.0.7 \        # bosh private IP
     -v bosh_password=2w87no4mgc9mtpc0zyus \  # bosh admin password
     -v director_name=micro-bosh \       # bosh director 명
     -v paasta_deploy_name=paasta \      # paasta deployment 명
     -v paasta_cell_prefix=cell \        # paasta cell 명
     -v paasta_username=admin \          # paasta admin 계정
     -v paasta_password=admin \          # paasta admin password
     -v smtp_url=127.0.0.1 \             # smtp server url
     -v smtp_port=25 \                   # smtp server port
     -v mail_sender=csupshin\            # smtp server admin id
     -v mail_password=xxxx\              # smtp server admin password
     -v mail_enable=flase \              # alarm 발생시 mail전송 여부
     -v mail_tls_enable=false \          # smtp서버 인증시 tls모드인경우 true
     -v redis_ip=10.20.40.11 \           # redis private ip
     -v redis_password=password \        # redis 인증 password
     -v utc_time_gap=9 \                 # utc time zone과 Client time zone과의 시간 차이
     -v monit_public_ip=xxx.xxx.xxx.xxx \ # 설치시 monitoring-web VM의 public ip
     -v system_domain={System_domain}    #PaaS-TA 설치시 설정한 System Domain
     -v prometheus_ip=35.188.183.252 \
     -v kubernetes_ip=211.251.238.234 \
     -v pinpoint_ip=101.55.50.216 \
     -v pinpoint_was_ip=10.1.81.123 \
     -v cassbroker_ip=13.124.44.35 \
     -v kubernetes_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm........

```

Note: 
1)	mariadb, influxdb, redis vm은 사용자가 직접 ip를 지정한다. Ip 지정시 paasta-monitoring.yml의 az와 cloud-config의 subnet이 일치하는 ip대역내에 ip를 지정한다.
2)	bosh_url: bosh 설치시 설정한 bosh private ip
3)	bosh_password: bosh admin Password로 bosh deploy시 생성되는 bosh admin password를 입력해야 한다. 
~/workspace/paasta-5.0/deployment/bosh-deployment/{iaas}/creds.yml
creds.yml
admin_password: xxxxxxxxx 
4)	smtp_url: smtp Server ip (PaaS-TA를 설치한 시스템에서 사용가능한 smtp 서버 IP
5)	monit_public_ip: monitoring web의 public ip로 외부에서 Monitoring 화면에 접속하기 위해 필요한 외부 ip(public ip 필요)
6)	system_domain: paasta를 설치 할때 설정한 system_domain을 입력한다.
7) pinpoint_ip는 설지한 pinpoint_haproxy_webui public ip를 지정한다.
8) pinpoint_was_ip는 설치한 pinpoint_haproxy_webui 내부 ip를 지정한다
9) prometheus_ip는 Kubernetes의 prometheus-prometheus-prometheus-oper-prometheus-0 Pod의 Node ip를 지정한다.
    <br>
   참조) [3.6.4. prometheus-prometheus-prometheus-oper-prometheus-0 POD의 Node IP를 확인한다.](#19-5)   
10) kubernetes_ip는 Kubernetes의 서비스 API ip를 지정한다.   
   참조) [3.6.5. Kubernetes API URL serverAddress를 확인한다.](#19-6)
11) kubernetes_token는 Kubernetes 서비스 API를 Request 호출할 수 있도록 Header에 설정하는 인증 토큰값을 지정한다.
   참조) [3.6.6. Kubernetes API Request 호출시 Header(Authorization) 인증을 위한 Token값을 확인한다.](#19-7) 
12) cassbroker_ip는 CaaS 서비스 로그인 인증 처리를 위한 API ip를 지정한다.        

deploy-paasta-monitoring.sh을 실행하여 PaaS-TA Monitoring을 설치 한다
```
$ cd ~/workspace/paasta-5.0/deployment/paasta-deployment-monitoring/paasta-monitoring
$ deploy-paasta-monitoring.sh
```

PaaS-TA Monitoring이 설치 완료 되었음을 확인한다.
```
$ bosh –e {director_name} vms
```
![PaaSTa_monitoring_vms_5.0]


## <div id='23'/>3.8.	PaaS-TA Monitoring IaaS 설치

### <div id='23-1'/>3.8.1. Pre-requsite
 1. Openstack Queens version 이상
 2. PaaS-TA가 Openstack에 설치 되어 있어야 한다.
 3. 설치된 Openstack위에 PaaS-TA에 설치 되어 있어야 한다.(PaaS-TA Agent설치 되어 있어야 한다)
 4. IaaS-PaaS-Monitoring 시스템에는 선행작업(Prerequisites)으로 Monasca Server가 설치 되어 있어야 한다. Monasca Client(agent)는 openstack controller, compute node에 설치되어 있어야 한다. 아래 Monasca Server/Client를 먼저 설치 후 IaaS-PaaS-Monitoring을 설치 해야 한다.
 
### <div id='23-2'/>3.8.2.	Monasca 설치
Monasca는 Server와 Client로 구성되어 있다. Openstack controller/compute Node에 Monasca-Client(Agent)를 설치 하여 Monasca 상태정보를 Monasca-Server에 전송한다. 수집된 Data를 기반으로 IaaS 모니터링을 수행한다.
Monasca-Server는 Openstack에서 VM을 수동 생성하여 설치를 진행한다.

#### <div id='23-3'/>3.8.2.1.	Monasca Server 설치

> **[Monasca - Server](./monasca-server.md)**

#### <div id='23-4'/>3.8.2.2.	Monasca Client(agent) 설치

> **[Monasca - Client](./monasca-client.md)** 
 

## <div id='24'/>3.9. PaaS-TA Monitoring dashboard 접속
 
 http://{monit_public_ip}:8080/public/login.html 에 접속하여 회원 가입 후 Main Dashboard에 접속한다.

 Login 화면에서 회원 가입 버튼을 클릭한다.

 ![PaaSTa_monitoring_login_5.0]


member_info에는 사용자가 사용할 ID/PWD를 입력하고 하단 paas-info에는 PaaS-TA admin 권한의 계정을 입력한다. PaaS-TA deploy시 입력한 admin/pwd를 입력해야 한다. 입력후 [인증수행]를 실행후 Joing버튼을 클릭하면 회원가입이 완료된다.

 ![PaaSTa_monitoring_join_5.0]

PaaS-TA Monitoring main dashboard 화면

 ![PaaSTa_monitoring_main_dashboard_5.0]

[IaaSTa_Monit_architecure_Image]:./images/iaas-archi.png
[PaaSTa_Monit_architecure_Image]:./images/monit_architecture.png
[Caas_Monit_architecure_Image]:./images/caas_monitoring_architecture.png
[Saas_Monit_architecure_Image]:./images/saas_monitoring_architecture.png
[PaaSTa_Monit_collect_architecure_Image]:./images/collect_architecture.png
[CaaS_Monit_collect_architecure_Image]:./images/caas_collect_architecture.png
[SaaS_Monit_collect_architecure_Image]:./images/saas_collect_architecture.png
[PaaSTa_release_dir_5.0]:./images/paasta-release_5.0.png
[PaaSTa_logsearch_vms_5.0]:./images/logsearch_5.0.png
[PaaSTa_monitoring_vms_5.0]:./images/paasta-monitoring_5.0.png

[PaaSTa_monitoring_login_5.0]:./images/monit_login_5.0.png
[PaaSTa_monitoring_join_5.0]:./images/member_join_5.0.png
[PaaSTa_monitoring_main_dashboard_5.0]:./images/monit_main_5.0.png

[PaaSTa_paasta_container_service_vms]:./images/paasta-container-service-vms.png
[PaaSTa_paasta_container_service_pods]:./images/paasta-container-service-pods.png
[PaaSTa_paasta_container_service_nodes]:./images/paasta-container-service-nodes.png
[PaaSTa_paasta_container_service_kubernetes_api]:./images/paasta-container-service-kubernetes-api.png
[PaaSTa_paasta_container_service_kubernetes_token]:./images/paasta-container-service-kubernetes-token.png
