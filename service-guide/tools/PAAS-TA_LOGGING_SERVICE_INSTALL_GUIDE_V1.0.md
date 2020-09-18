## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성](#1.3)  
  1.4. [참고자료](#1.4)  

2. [Logging 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  

3. [Logging 서비스 관리](#3)  
  3.1. [Logging 서비스 UAA Client 등록](#3.1)  
  3.2. [Logging 서비스 사용 활성화](#3.2)  



## <div id="1"/> 1. 문서 개요

### <div id="1.1"/> 1.1. 목적

본 문서는 Logging 서비스 Release를 Bosh2.0을 이용하여 설치 하는 방법을 기술하였다.

### <div id="1.2"/> 1.2. 범위

설치 범위는 Logging 서비스 Release를 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id="1.3"/> 1.3. 시스템 구성

본 장에서는 Logging 서비스의 시스템 구성에 대해 기술하였다. Logging 서비스 시스템은 Router, Collector, Queue, Parser, Elasticsearch, Visualization의 최소사항을 구성하였다.  
![001]

VM명 | 인스턴스 수 | vCPU수 | 메모리(GB) | 디스크(GB)
:--- | :---: | :---: | :---:| :---
Router | 1 | 1 |1 | Root 8G
Collector | 1 | 1 | 2 | Root 10G
Queue | 1 | 1 | 2 |  Root 10G + Persistent disk 10G
Parser | N | 1 | 2 | Root 10G
Elasticsearch Master | 1 | 1 | 2 | Root 10G + Persistent disk 10G
Elasticsearch Data | N | 2 | 4 | Root 20G + Persistent disk 30G
Visualization | 1 |  1 | 2 | Root 10G
maintenance | 1 | 1 | 1 | Root 8G

### <div id="1.4"/> 1.4. 참고자료
> http://bosh.io/docs  
> http://docs.cloudfoundry.org/  

## <div id="2"/> 2. Logging 서비스 설치  

### <div id="2.1"/> 2.1. Prerequisite 

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다. 

※ "firehose-to-syslog" uaac client 확인  

uaac client에 "firehose-to-syslog"가 등록되어 있는지 확인 하여, 등록되어 있는 경우에는 "authorities"를 확인하여 "cloud_controller.admin" 권한을 부여한다.  

```
# endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

# target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

# uaac 로그인
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>

# "firehose-to-syslog" uaac client 확인
$ uaac client get firehose-to-syslog
scope: cloud_controller.admin_read_only cloud_controller.global_auditor openid routing.router_groups.write network.write scim.read cloud_controller.admin uaa.user cloud_controller.read
    password.write routing.router_groups.read cloud_controller.write network.admin doppler.firehose scim.write
client_id: firehose-to-syslog
resource_ids: none
authorized_grant_types: client_credentials
autoapprove:
authorities: uaa.none doppler.firehose                   >>>>>>>>  cloud_controller.admin 권한 여부 확인
lastmodified: 1552530293656

# "firehose-to-syslog" uaac client 변경
$ uaac client update firehose-to-syslog --authorities "doppler.firehose, uaa.none, cloud_controller.admin"

# "firehose-to-syslog" uaac client 확인
$ uaac client get firehose-to-syslog
scope: cloud_controller.admin_read_only cloud_controller.global_auditor openid routing.router_groups.write network.write scim.read cloud_controller.admin uaa.user cloud_controller.read
    password.write routing.router_groups.read cloud_controller.write network.admin doppler.firehose scim.write
client_id: firehose-to-syslog
resource_ids: none
authorized_grant_types: client_credentials
autoapprove:
authorities: uaa.none doppler.firehose cloud_controller.admin
lastmodified: 1552530293656
```

### <div id="2.2"/> 2.2. Stemcell 확인  

Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell이 업로드 되어 있는 것을 확인한다.  (PaaS-TA 5.0 과 동일 stemcell 사용)

> $ bosh -e micro-bosh stemcells  

```
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID  
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    ami-0297ff649e8eea21b  

(*) Currently deployed

1 stemcells

Succeeded
```  

### <div id="2.3"/> 2.3. Deployment 다운로드

서비스 설치에 필요한 Deployment를 Git Repository에서 받아 서비스 설치 작업 경로로 위치시킨다.  

- Service Deployment Git Repository URL : https://github.com/PaaS-TA/service-deployment/tree/v5.0.2

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.0/deployment
$ cd ~/workspace/paasta-5.0/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/service-deployment.git -b v5.0.2
```

### <div id="2.4"/> 2.4. Deployment 파일 수정

BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment 파일에서 사용하는 network, vm_type, disk_type 등은 Cloud config를 활용하고, 활용 방법은 BOSH 2.0 가이드를 참고한다.   

- Cloud config 설정 내용을 확인한다.   

> $ bosh -e micro-bosh cloud-config   

```
Using environment '10.0.1.6' as client 'admin'

azs:
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z1
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z2

... ((생략)) ...

disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB

... ((생략)) ...

networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      security_groups: paasta-security-group
      subnet: subnet-00000000000000000
    dns:
    - 8.8.8.8
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.2 - 10.0.1.9
    static:
    - 10.0.1.10 - 10.0.1.120

... ((생략)) ...

vm_types:
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: minimal
- cloud_properties:
    ephemeral_disk:
      size: 10000
      type: gp2
    instance_type: t2.small
  name: small

... ((생략)) ...

Succeeded
```

- Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/logging-service/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                     # stemcell os
stemcell_version: "315.64"                                       # stemcell version

# VM_TYPE
vm_type_minimal: "minimal"                                       # vm type minimal
vm_type_default: "small"                                         # vm type small
vm_type_medium: "medium"                                         # vm type medium

# NETWORK
private_networks_name: "default"                                 # private network name 
public_networks_name: "vip"                                      # public network name
private_nat_networks_name: "default"                             # AWS의 경우, NATS Network Name

# ELASTICSEARCH_MASTER
es_master_azs: [z3]                                              # elasticsearch master : azs
es_master_instances: 1                                           # elasticsearch master : instances (1) 
es_master_persistent_disk_type: "10GB"                           # elasticsearch master : persistent disk type
es_master_private_ips: "<ES_MASTER_PRIVATE_IPS>"                 # elasticsearch master : private ips (e.g. ["10.0.81.11"])
es_master_private_url: "<ES_MASTER_PRIVATE_URL>"                 # elasticsearch master : private url (e.g. "10.0.81.11")

# QUEUE
queue_azs: [z3]                                                  # queue : azs
queue_instances: 1                                               # queue : instances (1)
queue_persistent_disk_type: "10GB"                               # queue : persistent disk type
queue_private_ips: "<QUEUE_PRIVATE_IPS>"                         # queue : private ips (e.g. ["10.0.81.12"])
queue_private_url: "<QUEUE_PRIVATE_URL>"                         # queue : private url (e.g. "10.0.81.12")

# MAINTENANCE
maintenance_azs: [z3]                                            # maintenance : azs
maintenance_instances: 1                                         # maintenance : instances (1)
maintenance_private_ips: "<MAINTENANCE_PRIVATE_IPS>"             # maintenance : private ips (e.g. ["10.0.81.13"])

# ELASTICSEARCH_DATA
es_data_azs: [z3]                                                # elasticsearch data : azs 
es_data_instances: 2                                             # elasticsearch data : instances (N)
es_data_persistent_disk_type: "20GB"                             # elasticsearch data : persistent disk type
es_data_private_ips: "<ES_DATA_PRIVATE_IPS>"                     # elasticsearch data : private ips (e.g. ["10.0.81.14", "10.0.81.15"])

# VISUALIZATION
visualization_azs: [z3]                                          # visualization : azs
visualization_instances: 1                                       # visualization : instances (1) 
visualization_private_ips: "<VISUALIZATION_PRIVATE_IPS>"         # visualization : private ips (e.g. ["10.0.81.16"])
visualization_version:  "5.3.0"                                  # visualization : version (5.3.0)

# COLLECTOR
collector_azs: [z3]                                              # collector : azs
collector_instances: 1                                           # collector : instances (1)
collector_private_ips: "<COLLECTOR_PRIVATE_IPS>"                 # collector : private ips (e.g. ["10.0.81.17"])

# PARSER
parser_azs: [z3]                                                 # parser : azs
parser_instances: 2                                              # parser : instances (N)
parser_private_ips: "<PARSER_PRIVATE_IPS>"                       # parser : private ips (e.g. ["10.0.81.18", "10.0.81.19"])
parser_es_index: "%{[@metadata][index]}-%{+YYYY.MM.dd.HH}"       # parser : elasticsearch index
parser_es_index_type: '%{[@metadata][type]}'                     # parser : elasticsearch index type

# ROUTER
router_azs: [z7]                                                 # router : azs 
router_instances: 1                                              # router : instances (1)
router_private_ips: "<ROUTER_PRIVATE_IPS>"                       # router : private ips (e.g. ["10.0.0.101"])
router_public_ips: "<ROUTER_PUBLIC_IPS>"                         # router : public ips (e.g. "13.209.212.226")
router_private_url: "<ROUTER_PRIVATE_URL>"                       # router : private url (e.g. "10.0.0.101")

# UAAC
uaa_client_laas_id: "laasclient"                                 # logging service uaa client id
uaa_client_laas_secret: "clientsecret"                           # logging service uaa client secret

# LOGGING SERVICE
es_config_index_prefix: "laas-"                                  # logging service elasticsearch index prefix ("laas-")
retention_period: 7                                              # logging service retention period
laas_logo: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALQAAABGCAYAAABll74gAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3FpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQyIDc5LjE2MDkyNCwgMjAxNy8wNy8xMy0wMTowNjozOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkYzhkNmI4YS1kZWNkLThkNGItOThiNC0zMjRjZjU1OTE0NmYiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MkRBNUQ0REMyQ0EwMTFFOEI2QkZBQUY2QUYwM0UzRjkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MkRBNUQ0REIyQ0EwMTFFOEI2QkZBQUY2QUYwM0UzRjkiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjQ5YzFjOTUyLWE2MDEtZTI0NC1iMzIzLTMzYTIyNzI1NDcxYiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpkYzhkNmI4YS1kZWNkLThkNGItOThiNC0zMjRjZjU1OTE0NmYiLz4gPC9y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"
```  

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/logging-service/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d logging-service deploy --no-redact logging-service.yml \
    -o operations/${IAAS}-network.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/logging-service
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식  

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-logging-service-release.tgz](http://45.248.73.44/index.php/s/eoCBY5QSFjJr3AS/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-logging-service-release.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/logging-service/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d logging-service deploy --no-redact logging-service.yml \
    -o operations/${IAAS}-network.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -v inception_os_user_name="ubuntu"
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/logging-service
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d logging-service vms
```
Using environment '10.30.40.111' as client 'admin'

Task 68432. Done

Deployment 'logging-service'

Instance                                                   Process State  AZ  IPs            VM CID                                   VM Type  Active  
collector/d2a1aed9-d10f-42df-91ec-e21f1baecfb8             running        z5  10.30.107.131  vm-e73085ec-e336-4c54-a842-37989dc4fe1d  default  true  
elasticsearch_data/d779c528-8f75-4b4c-b2d9-ac367c1e5ece    running        z5  10.30.107.133  vm-5b1fed2f-774f-47cf-9a14-edc015e790f1  medium   true  
elasticsearch_data/fa38698e-913c-4296-aac8-c0b56c84a71e    running        z5  10.30.107.134  vm-36a47dab-8d09-4daa-bb8c-0394f4d83fd7  medium   true  
elasticsearch_master/4698c36b-413d-4370-b671-44ee075a0cf0  running        z5  10.30.107.135  vm-46152b8f-d660-413c-9396-8b4068a4a454  default  true  
maintenance/dba09e1e-06c0-42bf-a30d-d97a62c536bc           running        z5  10.30.107.136  vm-780e1595-9aa9-445c-b056-27ff4e844017  minimal  true  
parser/3dfdc7bc-8dde-4ed1-95d0-eb638d4900fa                running        z5  10.30.107.138  vm-44210be7-0dab-46db-8cb6-d71a2c29d3c8  default  true  
parser/7ef8ffd6-7d8b-4ae0-bd8c-17f5e7092ca2                running        z5  10.30.107.137  vm-1eb78459-3050-4ab2-8f49-78f0ddb795b0  default  true  
queue/cc986003-b6c1-4570-b2d7-32ecfd40eedf                 running        z5  10.30.107.139  vm-f11ec996-5c1e-46a0-972a-8b1415267df0  default  true  
router/c64e9519-713c-4f24-9b04-4bbf2d0ac457                running        z5  10.30.107.140  vm-32ebc53c-6bef-48d7-854e-4b09a4dd9d01  minimal  true  
                                                                              115.68.47.181                                                      
visualization/d1ac0c78-aa4c-465d-9193-64f2e2de269a         running        z5  10.30.107.143  vm-75fdb6a6-e77f-4adb-8336-ec77254c82fa  default  true

```

## <div id="3"/>3.  Logging 서비스 관리

서비스 설치가 완료 되면, PaaS-TA 포탈에서 서비스를 사용하기 위해 Logging 서비스 UAA Client 등록 및 Logging 서비스 활성화 코드 등록을 해 주어야 한다.


### <div id="3.1"/>  3.1.	UAA Client 등록

-	uaac server의 endpoint를 설정한다.

```
# endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

# target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

```

-	uaac 로그인을 한다.

```
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>
Successfully fetched token via client credentials grant.
Target: https://uaa.<DOMAIN>
Context: admin, from client admin

```

-	Logging 서비스 계정을 생성 한다.  
$ uaac client add <CF_UAA_CLIENT_ID> -s <CF_UAA_CLIENT_SECRET> --redirect_uri <Logging 서비스 URI> --scope <퍼미션 범위> --authorized_grant_types <권한 타입> --authorities=<권한 퍼미션> --autoapprove=<자동승인권한>  

  -	<CF_UAA_CLIENT_ID> : uaac 클라이언트 id  
  -	<CF_UAA_CLIENT_SECRET> : uaac 클라이언트 secret  
  -	<Logging 서비스 URI> : 성공적으로 리다이렉션 할 Logging 서비스 접근 URI (http://<logging-service의 router public IP>)  
  -	<퍼미션 범위> : 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록  
  -	<권한 타입> : 서비스가 제공하는 API를 사용할 수 있는 권한 목록  
  -	<권한 퍼미션> : 클라이언트에 부여 된 권한 목록  
  -	<자동승인권한> : 사용자 승인이 필요하지 않은 권한 목록  

```  
# e.g. Logging 서비스 계정 생성
$ uaac client add laasclient -s clientsecret --redirect_uri " http://115.68.47.181" \
  --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
  --authorized_grant_types "authorization_code , client_credentials , refresh_token" \
  --authorities="uaa.resource" \
--autoapprove="openid , cloud_controller_service_permissions.read"

# e.g. Logging 서비스 계정 생성 확인
$ uaac clients
laasclient
    scope: cloud_controller.read cloud_controller.write cloud_controller_service_permissions.read openid
        cloud_controller.admin
    resource_ids: none
    authorized_grant_types: refresh_token client_credentials authorization_code
    redirect_uri: http://115.68.47.181
    autoapprove: cloud_controller_service_permissions.read openid
    authorities: uaa.resource
    name: laasclient
    lastmodified: 1542894096080

```  

## <div id="3.2"/>  3.2. Logging 서비스 활성화 코드 등록

-	PaaS-TA 운영자 포탈에 접속한다.
![002]

-	운영관리의 코드관리 메뉴로 이동하여 다음과 같이 코드를 등록한다.

> ※ Group Table  
> 코드 ID  : LAAS  
> 코드 이름 : Logging Service  
> ![003]
>
> ※ Detail Table  
> Key : laas_base_url  
> Value : http://<Logging Service 접근 IP>/app/laas  
> 요약 : Logging Service Base URL  
> 사용 : Y  
> ![004]

![005]

[001]:/service-guide/images/logging-service/image001.png
[002]:/service-guide/images/logging-service/image002.png
[003]:/service-guide/images/logging-service/image003.png
[004]:/service-guide/images/logging-service/image004.png
[005]:/service-guide/images/logging-service/image005.png
