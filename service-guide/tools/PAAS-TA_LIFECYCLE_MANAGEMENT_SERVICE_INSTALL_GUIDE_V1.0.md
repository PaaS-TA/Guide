## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)   
  1.3. [시스템 구성](#1.3)   
  1.4. [참고자료](#1.4)   

2. [라이프사이클 관리 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  
  
3. [라이프사이클 관리 서비스 관리 및 신청](#3)  
  3.1. [서비스 브로커 등록](#3.1)  
  3.2. [PaaS-TA 운영자 포탈 - 서비스 등록](#3.2)  
  3.3. [PaaS-TA 사용자 포탈 - 서비스 신청](#3.3)



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

### <div id="2.1"/> 2.1. Prerequisite 

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다. 

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

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/lifecycle-service/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                                         # stemcell os
stemcell_version: "315.64"                                                           # stemcell version

# VM_TYPE
vm_type_default: "medium"                                                            # vm type default
vm_type_highmem: "small-highmem-16GB"                                                # vm type highmemory

# NETWORK
private_networks_name: "default"                                                     # private network name
public_networks_name: "vip"                                                          # public network name :: The public network name can only use "vip" or "service_public".

# MARIA_DB
mariadb_azs: [z3]                                                                    # mariadb : azs
mariadb_instances: 1                                                                 # mariadb : instances (1) 
mariadb_persistent_disk_type: "10GB"                                                 # mariadb : persistent disk type 
mariadb_port: "<MARIADB_PORT>"                                                       # mariadb : database port (e.g. 31306) -- Do Not Use "3306"
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

# APP-LIFECYCLE
app_lifecycle_azs: [z7]                                                              # app-lifecycle : azs
app_lifecycle_instances: 2                                                           # app-lifecycle : instances (N)
app_lifecycle_persistent_disk_type: "20GB"                                           # app-lifecycle : persistent disk type
app_lifecycle_public_ips: "<APP_LIFECYCLE_PUBLIC_IPS>"                               # app-lifecycle : public ips (e.g. ["00.00.00.00" , "11.11.11.11"])
app_lifecycle_admin_password: "<APP_LIFECYCLE_ADMIN_PASSWORD>"                       # app-lifecycle : app-lifecycle super admin password (e.g. "admin!super")
app_lifecycle_serviceadmin_password: "<APP_LIFECYCLE_SERVICEADMIN_INIT_PASSWORD>"    # app-lifecycle : app-lifecycle serviceadmin user init password (e.g. "Service!admin")    
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/lifecycle-service/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d lifecycle-service deploy --no-redact lifecycle-service.yml \
    -o operations/${IAAS}-network.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/lifecycle-service
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식  

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-app-lifecycle-service-release.tgz](http://45.248.73.44/index.php/s/KZsLzMKE3kDr9SJ/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-app-lifecycle-service-release.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/lifecycle-service/deploy.sh

```
#!/bin/bash

# VARIABLES
BOSH_NAME="micro-bosh"                           # bosh name (e.g. micro-bosh)
IAAS="openstack"                                 # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"       # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d lifecycle-service deploy --no-redact lifecycle-service.yml \
    -o operations/${IAAS}-network.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -v inception_os_user_name="ubuntu"
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/lifecycle-service
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d lifecycle-service vms

```
Using environment '10.0.1.6' as client 'admin'

Task 108. Done

Deployment 'lifecycle-service'

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

## <div id="3"/>3.  라이프사이클 관리 서비스 관리 및 신청

PaaS-TA 운영자 포탈을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청 하여 사용할 수 있다.

### <div id="3.1"/> 3.1. 서비스 브로커 등록

서비스의 설치가 완료 되면, PaaS-TA 포탈에서 서비스를 사용하기 위해 서비스 브로커를 등록해 주어야 한다.  
서비스 브로커 등록 시에는 개방형 클라우드 플랫폼에서 서비스 브로커를 등록 할 수 있는 권한을 가진 사용자로 로그인 되어 있어야 한다.

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
$ cf create-service-broker app-lifecycle-service-broker admin cloudfoundry http://10.0.81.123:8080
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

### <div id="3.2"/>  3.2.	PaaS-TA 운영자 포탈 - 서비스 등록

-	PaaS-TA 운영자 포탈에 접속하여 서비스를 등록한다.  

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

## <div id="3.3"/>  3.3. PaaS-TA 사용자 포탈 - 서비스 신청
-	PaaS-TA 사용자  포탈에 접속하여, 카탈로그를 통해 서비스를 신청한다.   

![003]

-	대시보드 URL을 통해 서비스에 접근한다.  (서비스의 관리자 계정은 serviceadmin/[서비스 신청시 입력받은 패스워드])  

![004]  

 > 라이프사이클 관리 서비스 대시보드
 >
 > ![005]  
 >  
 > ![006]


- 라이프사이클 관리 서비스(TAIGA) 참고 자료  
  https://tree.taiga.io/support/

[001]:/service-guide/images/applifecycle-service/image001.png
[002]:/service-guide/images/applifecycle-service/image002.png
[003]:/service-guide/images/applifecycle-service/image003.png
[004]:/service-guide/images/applifecycle-service/image004.png
[005]:/service-guide/images/applifecycle-service/image005.png
[006]:/service-guide/images/applifecycle-service/image006.png
