## Table of Contents

[1. 문서 개요](#1)

  - [1.1. 목적](#1.1)
  - [1.2. 범위](#1.2)
  - [1.3. 시스템 구성](#1.3)
  - [1.4. 참고자료](#1.4)

[2. 라이프사이클 관리 서비스 설치](#2)

  - [2.1. 설치 전 준비 사항](#2.1)
  - [2.1.1. 라이프사이클 관리 서비스 설치 파일 다운로드](#2.1.1)
  - [2.1.2. Stemcell 다운로드](#2.1.2)
  - [2.2. 라이프사이클 관리 서비스 릴리즈 업로드](#2.2)
  - [2.3. 라이프사이클 관리 서비스 Deployment 파일 수정 및 배포](#2.3)
  - [2.4. 라이프사이클 관리 서비스 브로커 등록](#2.4)

[3. 라이프사이클 관리 서비스 관리 및 신청](#3)

  - [3.1. PaaS-TA 운영자 포탈 - 라이프사이클 관리 서비스 등록](#3.1)
  - [3.2. PaaS-TA 사용자 포탈 - 라이프사이클 관리 서비스 신청](#3.2)



## <div id="1"/> 1. 문서 개요

### <div id="1.1"/> 1.1. 목적

본 문서는 라이프사이클 관리 서비스 Release를 Bosh2.0을 이용하여 설치 하는 방법을 기술하였다.

### <div id="1.2"/> 1.2. 범위

설치 범위는 라이프사이클 관리 서비스 Release를 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id="1.3"/> 1.3. 시스템 구성

본 장에서는 라이프사이클 관리 서비스의 시스템 구성에 대해 기술하였다. 라이프사이클 관리 서비스 시스템은 service-broker, mariadb, app-lifecycle(TAIGA)서비스의 최소사항을 구성하였다.  
![001]

VM명 | 인스턴스 수 | vCPU수 | 메모리(GB) | 디스크(GB)
:--- | :---: | :---: | :---:| :---
service-broker | 1 | 1 |1 |
mariadb | 1 | 1 | 2 | Root 8G + Persistent disk 10G
app-lifecycle | N | 1 | 4 |  Root 10G + Persistent disk 20G

### <div id="1.4"/> 1.4. 참고자료
> http://bosh.io/docs  
> http://docs.cloudfoundry.org/  

## <div id="2"/> 2. 라이프사이클 관리 서비스 설치  

### <div id="2.1"/> 2.1. 설치 전 준비 사항  

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 라이프사이클 관리 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다. 

### <div id="2.1.1"/> 2.1.1 라이프사이클 관리 서비스 설치 파일 다운로드

라이프사이클 관리 서비스 설치에 필요한 Deployment 및 릴리즈 파일을 다운로드 받아 서비스 설치 작업 경로로 위치시킨다.

-	설치 파일 다운로드 위치 : https://paas-ta.kr/download/package  
  = Deployment : paasta-app-lifecycle-service    
  = 릴리즈 파일 : paasta-app-lifecycle-service-release.tgz

-	설치 작업 경로 생성 및 파일 다운로드

```
# Deployment 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/deployment/service-deployment

# Deployment 다운로드(paasta-app-lifecycle-service) 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/deployment/service-deployment/paasta-app-lifecycle-service  
README.md  deploy-paasta-app-lifecycle-service.sh  manifests

# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드(paasta-app-lifecycle-service-release.tgz) 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-app-lifecycle-service-release.tgz

```

### <div id="2.1.2"/> 2.1.2 Stemcell 다운로드

라이프사이클 관리 서비스 설치에 필요한 Stemcell을 확인하여 존재하지 않을 경우 BOSH 설치 가이드 문서를 참고 하여 Stemcell을 업로드 한다. (라이프사이클 관리 서비스는 Stemcell ubuntu-xenial 315.64 버전을 사용, PaaSTA-Stemcell.zip)

-	설치 파일 다운로드 위치 : https://paas-ta.kr/download/package

```
# Stemcell 목록 확인
$ bosh -e micro-bosh stemcells
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID  
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    ami-0297ff649e8eea21b  

(*) Currently deployed

1 stemcells

Succeeded
```

### <div id="2.2"/> 2.2. 라이프사이클 관리 서비스 릴리즈 업로드

- 릴리즈 목록을 확인하여 라이프사이클 관리 서비스 릴리즈(paasta-app-lifecycle-service)가 업로드 되어 있지 않은 것을 확인한다.

```
# 릴리즈 목록 확인 (검색)
$ bosh -e micro-bosh releases | grep "app-lifecycle-service"

# 릴리즈 목록 확인 (전체)
$ bosh -e micro-bosh releases
Using environment '10.0.1.6' as client 'admin'

Name                   Version    Commit Hash  
binary-buildpack       1.0.32*    2399a07  
bosh-dns               1.12.0*    5d607ed  
bosh-dns-aliases       0.0.3*     eca9c5a  
bpm                    1.1.0*     27e1c8f  
capi                   1.83.0*    6b3cd37

... ((생략)) ...

(*) Currently deployed
(+) Uncommitted changes

34 releases

Succeeded
```

- 라이프사이클 관리 서비스 릴리즈 파일을 업로드한다.

```
# 릴리즈 파일 업로드
$ bosh -e micro-bosh upload-release ~/workspace/paasta-5.0/release/service/paasta-app-lifecycle-service-release.tgz

Using environment '10.0.1.6' as client 'admin'

######################################################## 100.00% 143.81 MiB/s 6s
Task 103

Task 103 | 06:11:59 | Extracting release: Extracting release (00:00:06)
Task 103 | 06:12:05 | Verifying manifest: Verifying manifest (00:00:00)
Task 103 | 06:12:05 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 103 | 06:12:05 | Creating new packages: app-lifecycle/5180829fda06256327280d717a023e04f6faef97c952cb2b8a7b4c06e5081701 (00:00:01)
Task 103 | 06:12:06 | Creating new packages: common/1213e44f16684a87f85f2a1784f1a8bb2b6d4dc8bb8caf8fed62a94c80352a20 (00:00:00)
Task 103 | 06:12:06 | Creating new packages: java/9ee03ac5327ece3bc9f8e67dd78abded89b56b1cff6079620b820e88ef336889 (00:00:01)
Task 103 | 06:12:07 | Creating new packages: mariadb/5ca7d73845bf5b8047c389bae4eb3bd91217e1a3fa64baacfa183524bbb3c078 (00:00:09)
Task 103 | 06:12:16 | Creating new packages: nginx/d4c0e2e80bd94e0d56b6e4479d271216d348a3f84ffb4bf1aeb9636c55d4b307 (00:00:01)
Task 103 | 06:12:17 | Creating new packages: service-broker/ae7d27c83e673435e93673d2bff99e648a65fc42df04ec382235ee727e389574 (00:00:01)
Task 103 | 06:12:18 | Creating new jobs: app-lifecycle/78d6d7219352458994ed832c91edd63caeb56e77332c21b3a7ca847f00e19f53 (00:00:00)
Task 103 | 06:12:18 | Creating new jobs: mariadb/3802b058c761286c27aed724bd371279ae8873714f6cd1e4108b8077047b7d1e (00:00:00)
Task 103 | 06:12:18 | Creating new jobs: service-broker/c5d95721ec29a51b242cae2f9753b2853e8b595f9fe229063e895541ba4d2a8e (00:00:00)
Task 103 | 06:12:18 | Release has been created: paasta-app-lifecycle-service/1.0 (00:00:00)

Task 103 Started  Thu Nov  7 06:11:59 UTC 2019
Task 103 Finished Thu Nov  7 06:12:18 UTC 2019
Task 103 Duration 00:00:19
Task 103 done

Succeeded
```

- 릴리즈 목록을 확인하여 라이프사이클 관리 서비스 릴리즈(paasta-app-lifecycle-service)가 업로드 되어 있는 것을 확인한다.

```
# 릴리즈 목록 확인 (검색)
$ bosh -e micro-bosh releases | grep "app-lifecycle-service"
paasta-app-lifecycle-service	1.0      	81df11b+

# 릴리즈 목록 확인 (전체)
$ bosh -e micro-bosh releases
Using environment '10.0.1.6' as client 'admin'

Name                          Version    Commit Hash  
binary-buildpack              1.0.32*    2399a07  
bosh-dns                      1.12.0*    5d607ed  
bosh-dns-aliases              0.0.3*     eca9c5a  
bpm                           1.1.0*     27e1c8f  
capi                          1.83.0*    6b3cd37  
cf-cli                        1.16.0*    05d9348  
paasta-app-lifecycle-service  1.0        81df11b+

... ((생략)) ...

(*) Currently deployed
(+) Uncommitted changes

35 releases

Succeeded
```

### <div id="2.3"/> 2.3. 라이프사이클 관리 서비스 Deployment 파일 수정 및 배포

BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment 파일에서 사용하는 network, vm_type, disk_type 등은 Cloud config를 활용하고, 활용 방법은 BOSH 2.0 가이드를 참고한다.

-	Cloud config 설정 내용을 확인한다.

```
# Cloud config 조회
$ bosh -e micro-bosh cloud-config
Using environment '10.0.1.6' as client 'admin'

azs:
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z1
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z2

... ((생략)) ...

- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z7
compilation:
  az: z4
  network: default
  reuse_compilation_vms: true
  vm_type: xlarge
  workers: 5
disk_types:
- disk_size: 1024
  name: default

... ((생략)) ...

- cloud_properties:
    type: gp2
  disk_size: 500000
  name: 50GB_GP2
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

- cloud_properties:
    ephemeral_dist:
      size: 4096
      type: gp2
    instance_type: t2.small
  name: caas_small
- cloud_properties:
    ephemeral_dist:
      size: 30000
      type: gp2
    instance_type: m4.xlarge
  name: caas_small_highmem

Succeeded
```

- Deployment YAML에서 사용하는 변수들을 서버 환경에 맞게 수정한다.

```
# 변수 설정
$ vi ~/workspace/paasta-5.0/deployment/service-deployment/paasta-app-lifecycle-service/manifests/vars.yml

# RELEASE
service_release_name: "paasta-app-lifecycle-service"                                 # release name
service_release_version: "1.0"                                                       # release version

# STEMCELL
stemcell_os: "ubuntu-xenial"                                                         # stemcell os
stemcell_version: "315.64"                                                           # stemcell version

# VM_TYPE
vm_type_default: "medium"                                                            # vm type default
vm_type_highmem: "small-highmem-16GB"                                                # vm type highmemory

# NETWORK
private_networks_name: "service_private"                                             # private network name
public_networks_name: "service_public"                                               # public network name :: The public network name can only use "vip" or "service_public".
#private_nat_networks_name: "service_private"                                        # AWS의 경우, NATS Network Name

# MARIA_DB
mariadb_azs: [z3]                                                                    # mariadb : azs
mariadb_instances: 1                                                                 # mariadb : instances (1)
mariadb_persistent_disk_type: "10GB"                                                 # mariadb : persistent_disk_type
mariadb_port: "<MARIADB_PORT>"                                                       # mariadb : database port (e.g. 3306)
mariadb_admin_password: "<MARIADB_ADMIN_PASSWORD>"                                   # mariadb : database admin password (e.g. "paas-ta!admin")
mariadb_broker_username: "<MARIADB_BROKER_USERNAME>"                                 # mariadb : service-broker-user id (e.g. "applifecycle")
mariadb_broker_password: "<MARIADB_BROKER_PASSWORD>"                                 # mariadb : service-broker-user password (e.g. "broker!admin")

# SERVICE-BROKER
broker_azs: [z3]                                                                     # service-broker : azs
broker_instances: 1                                                                  # service-broker : instances (1)
broker_port: "<SERVICE_BROKER_PORT>"                                                 # service-broker : broker port (e.g. "8080")
broker_logging_level_broker: "INFO"                                                  # service-broker : broker logging level
broker_logging_level_hibernate: "INFO"                                               # service-broker : hibernate logging level
broker_services_id: "<SERVICE_BROKER_SERVICES_GUID>"                                 # service-broker : service guid (e.g. "b988f110-2bc3-46ce-8e55-9b8d50e529d4")
broker_services_plans_id: "<SERVICE_BROKER_SERVICES_PLANS_GUID>"                     # service-broker : service plan id (e.g. "6eb97b3e-91db-4880-ad8a-503003e8e7dd")
bosh_client_id: "<BOSH_CLIENT_ID>"                                                   # service-broker : bosh client id
bosh_client_secret: "<BOSH_CLIENT_SECRET>"                                           # service-broker : bosh client secret
bosh_url: "<BOSH_URL>"                                                               # service-broker : bosh url (e.g. https://00.000.0.0:25555)
bosh_oauth_url: "<BOSH_OAUTH_URL>"                                                   # service-broker : bosh oauth url (e.g. https://00.000.0.0:8443)

# APP-LIFECYCLE
app_lifecycle_azs: [z3]                                                              # app-lifecycle : azs
app_lifecycle_instances: 2                                                           # app-lifecycle : instances (N)
app_lifecycle_persistent_disk_type: "20GB"                                           # app-lifecycle : persistent_disk_type
app_lifecycle_public_ips: "<APP_LIFECYCLE_PUBLIC_IPS>"                               # app-lifecycle : public ips (e.g. ["00.00.00.00" , "11.11.11.11"])
app_lifecycle_admin_password: "<APP_LIFECYCLE_ADMIN_PASSWORD>"                       # app-lifecycle : app-lifecycle super admin password (e.g. "admin!super")
app_lifecycle_serviceadmin_password: "<APP_LIFECYCLE_SERVICEADMIN_INIT_PASSWORD>"    # app-lifecycle : app-lifecycle serviceadmin user init password (e.g. "Service!admin")
```

-	Deploy 스크립트 파일을 서버 환경에 맞게 수정한다.  
  = vSphere : -o manifests/ops-files/vsphere-network.yml  
  = AWS : -o manifests/ops-files/aws-network.yml  
  = OpenStack : -o manifests/ops-files/openstack-network.yml  
  = Azure : -o manifests/ops-files/azure-network.yml  
  = GCP : -o manifests/ops-files/gcp-network.yml  

```
# Deploy 스크립트 수정
$ vi ~/workspace/paasta-5.0/deployment/service-deployment/paasta-app-lifecycle-service/deploy-paasta-app-lifecycle-service.sh

#!/bin/bash

# VARIABLES
DEPLOYMENT_NAME="paasta-app-lifecycle-service"
BOSH2_NAME="micro-bosh"

# DEPLOY
bosh -e ${BOSH2_NAME} -n -d ${DEPLOYMENT_NAME} deploy --no-redact manifests/${DEPLOYMENT_NAME}.yml \
    -o manifests/ops-files/vsphere-network.yml \
    -l manifests/vars.yml \
    -v deployment_name=${DEPLOYMENT_NAME}

```

- 라이프사이클 관리 서비스를 배포한다.

```
# 라이프사이클 관리 서비스 Deploy (e.g AWS)
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-app-lifecycle-service
$ sh ./deploy-paasta-app-lifecycle-service.sh

Using environment '10.0.1.6' as client 'admin'

Using deployment 'paasta-app-lifecycle-service'

+ azs:
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z1
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z2
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z3
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z4
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z5
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z6
+ - cloud_properties:
+     availability_zone: ap-northeast-2a
+   name: z7

... ((생략)) ...  

+ - cloud_properties:
+     type: gp2
+   disk_size: 500000
+   name: 50GB_GP2

+ stemcells:
+ - alias: default
+   os: ubuntu-xenial
+   version: '315.64'

+ releases:
+ - name: paasta-app-lifecycle-service
+   version: '1.0'

+ update:
+   canaries: 1
+   canary_watch_time: 30000-600000
+   max_in_flight: 1
+   serial: true
+   update_watch_time: 10000-600000

... ((생략)) ...  

+ instance_groups:
+ - azs:
+   - z3
+   instances: 1
+   jobs:
+   - name: mariadb
+     properties:
+       database:
+         admin_password: "<redacted>"
+         broker:
+           password: "<redacted>"
+           username: "<redacted>"
+         port: "<redacted>"
+     release: paasta-app-lifecycle-service
+   name: mariadb
+   networks:
+   - name: default
+   persistent_disk_type: 10GB
+   stemcell: default
+   update:
+     max_in_flight: 1
+   vm_type: medium
+ - azs:
+   - z3
+   instances: 1
+   jobs:
+   - name: service-broker
+     properties:
+       bosh:
+         client:
+           id: "<redacted>"
+           secret: "<redacted>"
+         deployment_name: "<redacted>"
+         oauth_url: "<redacted>"
+         url: "<redacted>"
+       logging:
+         level_broker: "<redacted>"
+         level_hibernate: "<redacted>"
+       port: "<redacted>"
+       service:
+         init_password: "<redacted>"
+       services:
+         id: "<redacted>"
+         plans:
+           id: "<redacted>"
+     release: paasta-app-lifecycle-service
+   name: service-broker
+   networks:
+   - name: default
+   stemcell: default
+   update:
+     max_in_flight: 1
+   vm_type: medium
+ - azs:
+   - z7
+   instances: 2
+   jobs:
+   - name: app-lifecycle
+     properties:
+       service:
+         admin_password: "<redacted>"
+         init_password: "<redacted>"
+     release: paasta-app-lifecycle-service
+   name: app-lifecycle
+   networks:
+   - default:
+     - dns
+     - gateway
+     name: default
+   - name: vip
+     static_ips:
+     - 13.124.4.62
+     - 52.78.10.153
+   persistent_disk_type: 20GB
+   stemcell: default
+   update:
+     max_in_flight: 1
+   vm_type: medium

+ name: paasta-app-lifecycle-service
Task 104

Task 104 | 06:40:27 | Preparing deployment: Preparing deployment (00:00:02)
Task 104 | 06:40:29 | Preparing deployment: Rendering templates (00:00:01)
Task 104 | 06:40:30 | Preparing package compilation: Finding packages to compile (00:00:00)
Task 104 | 06:40:30 | Compiling packages: app-lifecycle/5180829fda06256327280d717a023e04f6faef97c952cb2b8a7b4c06e5081701
Task 104 | 06:40:30 | Compiling packages: nginx/d4c0e2e80bd94e0d56b6e4479d271216d348a3f84ffb4bf1aeb9636c55d4b307
Task 104 | 06:40:30 | Compiling packages: java/9ee03ac5327ece3bc9f8e67dd78abded89b56b1cff6079620b820e88ef336889
Task 104 | 06:40:30 | Compiling packages: service-broker/ae7d27c83e673435e93673d2bff99e648a65fc42df04ec382235ee727e389574
Task 104 | 06:40:30 | Compiling packages: mariadb/5ca7d73845bf5b8047c389bae4eb3bd91217e1a3fa64baacfa183524bbb3c078
Task 104 | 06:41:46 | Compiling packages: service-broker/ae7d27c83e673435e93673d2bff99e648a65fc42df04ec382235ee727e389574 (00:01:16)
Task 104 | 06:41:46 | Compiling packages: common/1213e44f16684a87f85f2a1784f1a8bb2b6d4dc8bb8caf8fed62a94c80352a20
Task 104 | 06:41:49 | Compiling packages: java/9ee03ac5327ece3bc9f8e67dd78abded89b56b1cff6079620b820e88ef336889 (00:01:19)
Task 104 | 06:41:51 | Compiling packages: common/1213e44f16684a87f85f2a1784f1a8bb2b6d4dc8bb8caf8fed62a94c80352a20 (00:00:05)
Task 104 | 06:41:52 | Compiling packages: app-lifecycle/5180829fda06256327280d717a023e04f6faef97c952cb2b8a7b4c06e5081701 (00:01:22)
Task 104 | 06:42:05 | Compiling packages: nginx/d4c0e2e80bd94e0d56b6e4479d271216d348a3f84ffb4bf1aeb9636c55d4b307 (00:01:35)
Task 104 | 06:44:53 | Compiling packages: mariadb/5ca7d73845bf5b8047c389bae4eb3bd91217e1a3fa64baacfa183524bbb3c078 (00:04:23)
Task 104 | 06:45:30 | Creating missing vms: app-lifecycle/4a4e1dc8-7214-46ca-9d3a-4254cb784e6f (0)
Task 104 | 06:45:30 | Creating missing vms: service-broker/3307c237-d9a9-4885-ae78-007db70a0e22 (0)
Task 104 | 06:45:30 | Creating missing vms: mariadb/e859e63c-4358-4ef7-bbeb-93fa19be7baf (0)
Task 104 | 06:45:30 | Creating missing vms: app-lifecycle/a066d71a-0c93-48e3-bddc-0e6dadb1ffcd (1)
Task 104 | 06:46:34 | Creating missing vms: service-broker/3307c237-d9a9-4885-ae78-007db70a0e22 (0) (00:01:04)
Task 104 | 06:46:34 | Creating missing vms: app-lifecycle/a066d71a-0c93-48e3-bddc-0e6dadb1ffcd (1) (00:01:04)
Task 104 | 06:46:37 | Creating missing vms: app-lifecycle/4a4e1dc8-7214-46ca-9d3a-4254cb784e6f (0) (00:01:07)
Task 104 | 06:46:39 | Creating missing vms: mariadb/e859e63c-4358-4ef7-bbeb-93fa19be7baf (0) (00:01:09)
Task 104 | 06:46:39 | Updating instance mariadb: mariadb/e859e63c-4358-4ef7-bbeb-93fa19be7baf (0) (canary) (00:02:22)
Task 104 | 06:49:01 | Updating instance service-broker: service-broker/3307c237-d9a9-4885-ae78-007db70a0e22 (0) (canary) (00:00:42)
Task 104 | 06:49:43 | Updating instance app-lifecycle: app-lifecycle/4a4e1dc8-7214-46ca-9d3a-4254cb784e6f (0) (canary) (00:06:24)
Task 104 | 06:56:07 | Updating instance app-lifecycle: app-lifecycle/a066d71a-0c93-48e3-bddc-0e6dadb1ffcd (1) (00:06:04)

Task 104 Started  Thu Nov  7 06:40:27 UTC 2019
Task 104 Finished Thu Nov  7 07:02:11 UTC 2019
Task 104 Duration 00:21:44
Task 104 done

Succeeded
```

- 배포된 라이프사이클 관리 서비스를 확인한다.

```
$ bosh -e micro-bosh -d paasta-app-lifecycle-service vms

Using environment '10.0.1.6' as client 'admin'

Task 108. Done

Deployment 'paasta-app-lifecycle-service'

Instance                                             Process State  AZ  IPs           VM CID               VM Type  Active  
app-lifecycle/4a4e1dc8-7214-46ca-9d3a-4254cb784e6f   running        z7  10.0.0.122    i-08fdee7878ea1fd77  medium   true  
                                                                        13.124.4.62                                   
app-lifecycle/a066d71a-0c93-48e3-bddc-0e6dadb1ffcd   running        z7  10.0.0.123    i-044fcd1932afeda19  medium   true  
                                                                        52.78.10.153                                  
mariadb/e859e63c-4358-4ef7-bbeb-93fa19be7baf         running        z3  10.0.81.122   i-0091a0c9848be5277  medium   true  
service-broker/3307c237-d9a9-4885-ae78-007db70a0e22  running        z3  10.0.81.123   i-00c9496182c78d040  medium   true  

4 vms

Succeeded
```

### <div id="2.4"/> 2.4. 라이프사이클 관리 서비스 브로커 등록

라이프사이클 관리 서비스의 배포가 완료 되면, PaaS-TA 포탈에서 서비스를 사용하기 위해 라이프사이클 관리 서비스 브로커를 등록해 주어야 한다. 서비스 브로커 등록 시에는 개방형 클라우드 플랫폼에서 서비스 브로커를 등록 할 수 있는 권한을 가진 사용자로 로그인 되어 있어야 한다.

- 서비스 브로커 목록을 확인한다
> $ cf service-brokers

  ```
  Getting service brokers as admin...

  name   url
  No service brokers found
  ```

- 라이프사이클 관리 서비스 브로커를 등록한다.
> $ cf create-service-broker [SERVICE_BROKER] [USERNAME] [PASSWORD] [SERVICE_BROKER_URL]  
> - [SERVICE_BROKER] : 서비스 브로커 명  
> - [USERNAME] / [PASSWORD] : 서비스 브로커에 접근할 수 있는 사용자 ID / PASSWORD  
> - [SERVICE_BROKER_URL] : 서비스 브로커 접근 URL

  ```
  ### e.g. 라이프사이클 관리 서비스 브로커 등록
  $ cf create-service-broker app-lifecycle-service-broker admin cloudfoundry http://10.0.81.123:8081
  Creating service broker app-lifecycle-service-broker as admin...  
  OK                                                               
  ```

- 등록된 라이프사이클 관리 서비스 브로커를 확인한다.
> $ cf service-brokers

  ```
  Getting service brokers as admin...

  name                           url
  app-lifecycle-service-broker   http://10.0.81.123:8081
  ```

- 라이프사이클 관리 서비스의 서비스 접근 정보를 확인한다.
> $ cf service-access -b app-lifecycle-service-broker   

  ```
  Getting service access for broker app-lifecycle-service-broker as admin...
  broker: app-lifecycle-service-broker
     service         plan           access   orgs
     app-lifecycle   dedicated-vm   none
  ```

- 라이프사이클 관리 서비스의 서비스 접근 허용을 설정(전체)하고 서비스 접근 정보를 재확인 한다.
> $ cf enable-service-access app-lifecycle  
> $ cf service-access -b app-lifecycle-service-broker  

```
$ cf enable-service-access app-lifecycle  
Enabling access to all plans of service app-lifecycle for all orgs as admin...
OK

$ cf service-access -b app-lifecycle-service-broker  
Getting service access for broker app-lifecycle-service-broker as admin...
broker: app-lifecycle-service-broker
   service         plan           access   orgs
   app-lifecycle   dedicated-vm   all
```

## <div id="3"/>3.  라이프사이클 관리 서비스 관리 및 신청

PaaS-TA 운영자 포탈을 통해 라이프사이클 관리 서비스를 등록 및 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청 하여 사용할 수 있다.

### <div id="3.1"/>  3.1.	PaaS-TA 운영자 포탈 - 라이프사이클 관리 서비스 등록
-	PaaS-TA 운영자 포탈에 접속하여 라이프사이클 관리 서비스를 등록한다.  

> ※ 운영관리 > 카탈로그 > 앱서비스 등록
> - 이름 : 라이프사이클 관리 서비스
> - 분류 :  개발 지원 도구
> - 서비스 : app-lifecycle
> - 썸네일 : [라이프사이클 관리 서비스 썸네일]
> - 문서 URL : https://github.com/PaaS-TA/PAAS-TA-APP-LIFECYCLE-SERVICE-BROKER
> - 서비스 생성 파라미터 : password / 패스워드
> - 앱 바인드 사용 : N
> - 공개 : Y
> - 대시보드 사용 : Y
> - 온디멘드 : N
> - 태그 : paasta / tag1, free / tag2
> - 요약 : 라이프사이클 관리 서비스
> - 설명 :
> 체계적인 Agile 개발 지원과 프로젝트 협업에 필요한 커뮤니케이션 중심의 문서 및 지식 공유 지원 기능을 제공하는 TAIGA를 dedicated 방식으로 제공합니다.
> 서비스 관리자 계정은 serviceadmin/<서비스 신청 시 입력한 Password> 입니다.
>  
> ![002]

## <div id="3.2"/>  3.2. PaaS-TA 사용자 포탈 - 라이프사이클 관리 서비스 신청
-	PaaS-TA 사용자  포탈에 접속하여, 카탈로그를 통해 라이프사이클 관리 서비스를 신청한다.   

![003]

-	대시보드 URL을 통해 서비스에 접근한다.  (서비스의 관리자 계정은 serviceadmin/[서비스 신청시 입력받은 패스워드])  

![004]  

 > 라이프사이클 관리 서비스 대시보드
 >
 > ![005]  
 >  
 > ![006]


- 라이프사이클 관리 서비스(TAIGA) 참고 자료
> https://tree.taiga.io/support/

[001]:/service-guide/images/applifecycle-service/image001.png
[002]:/service-guide/images/applifecycle-service/image002.png
[003]:/service-guide/images/applifecycle-service/image003.png
[004]:/service-guide/images/applifecycle-service/image004.png
[005]:/service-guide/images/applifecycle-service/image005.png
[006]:/service-guide/images/applifecycle-service/image006.png
