## Table of Contents  

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  
  
2. [GlusterFS 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  
  
3. [GlusterFS 연동 Sample App 설명](#3)    
  3.1. [서비스 브로커 등록](#3.1)   
  3.2. [Sample App 구조](#3.2)    
  3.3. [PaaS-TA에서 서비스 신청](#3.3)   



## <div id="1"/> 1. 문서 개요

### <div id="1.1"/>1.1. 목적
본 문서(GlusterFS 서비스팩 설치 가이드)는 전자정부 표준 프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 GlusterFS 서비스팩을 Bosh를 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application 에서GlusterFS 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id="1.2"/> 1.2. 범위
설치 범위는 GlusterFS 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id="1.3"/>1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. Mysql Server, GlusterFS 서비스 브로커로 최소사항을 구성하였고 서비스 백엔드는 외부에 구성되어 있다.
![시스템 구성도][glusterfs_image_01]

* 설치할때 cloud config에서 사용하는 VM_Tpye명과 스펙 

| VM_Type | 스펙 |
|--------|-------|
|minimal| 1vCPU / 1GB RAM / 8GB Disk|

* 각 Instance의 Resource Pool과 스펙

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| paasta-glusterfs-broker | minimal | 1vCPU / 1GB RAM / 8GB Disk |
| mysql | minimal | 1vCPU / 1GB RAM / 8GB Disk |

<br>

### <div id="1.4"/>1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs) <br>
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

## <div id="2"/>2. GlusterFS 서비스 설치

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

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/glusterfs/vars.yml

```
# STEMCELL
stemcell_os: "ubuntu-xenial"                                     # stemcell os
stemcell_version: "315.64"                                       # stemcell version


# NETWORK
private_networks_name: "default"                                 # private network name
public_networks_name: "vip"                                      # public network name


# MYSQL
mysql_azs: [z4]                                                  # mysql azs
mysql_instances: 1                                               # mysql instances 
mysql_vm_type: "medium"                                          # mysql vm type
mysql_persistent_disk_type: "1GB"                                # mysql persistent disk type
mysql_port: 13306                                                # mysql port (e.g. 13306) -- Do Not Use "3306"
mysql_admin_username: "<MYSQL_ADMIN_USERNAME>"                   # mysql admin username (e.g. "root")
mysql_admin_password: "<MYSQL_ADMIN_PASSWORD>"                   # mysql admin password (e.g. "admin1234")


# GLUSTERFS SERVER
glusterfs_url: "<GLUSTERFS_PUBLIC_IP>"                           # Glusterfs 서비스 public 주소
glusterfs_tenantname: "<GLUSTERFS_TENANT_NAME>"                  # Glusterfs 서비스 테넌트 이름(e.g. "service")
glusterfs_username: "<GLUSTERFS_USERNAME>"                       # Glusterfs 서비스 계정 아이디(e.g. "swift")
glusterfs_password: "<GLUSTERFS_PASSWORD>"                       # Glusterfs 서비스 암호(e.g. "password")


# GLUSTERFS_BROKER
broker_azs: [z4]                                                 # glusterfs broker azs
broker_instances: 1                                              # glusterfs broker instances 
broker_persistent_disk_type: "4GB"                               # glusterfs broker persistent disk type
broker_vm_type: "small"                                          # glusterfs broker vm type


# GLUSTERFS_BROKER_REGISTRAR
broker_registrar_azs: [z4]                                       # broker registrar azs
broker_registrar_instances: 1                                    # broker registrar instances 
broker_registrar_vm_type: "small"                                # broker registrar vm type


# GLUSTERFS_BROKER_DEREGISTRAR
broker_deregistrar_azs: [z4]                                     # broker deregistrar azs
broker_deregistrar_instances: 1                                  # broker deregistrar instances 
broker_deregistrar_vm_type: "small"                              # broker deregistrar vm type
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/glusterfs/deploy.sh

```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="<BOSH_NAME>"                         # bosh name (e.g. micro-bosh)
IAAS="<IAAS_NAME>"                              # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"      # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

bosh -e ${BOSH_NAME} -n -d glusterfs deploy --no-redact glusterfs.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/glusterfs  
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-glusterfs-2.0.1.tgz](http://45.248.73.44/index.php/s/Y3dirSrzNtQ9WPf/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-glusterfs-2.0.1.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/glusterfs/deploy.sh
```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="<BOSH_NAME>"                         # bosh name (e.g. micro-bosh)
IAAS="<IAAS_NAME>"                              # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"      # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

bosh -e ${BOSH_NAME} -n -d glusterfs deploy --no-redact glusterfs.yml \
    -o operations/use-compiled-releases.yml \
    -l ${COMMON_VARS_PATH} \
    -l vars.yml \
    -v inception_os_user_name="ubuntu"
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/glusterfs  
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d glusterfs vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 1343. Done

Deployment 'glusterfs'

Instance                                                      Process State  AZ  IPs          VM CID                                   VM Type  Active  
mysql/8770bc70-8681-4079-8360-086219d6231b                    running        z3  10.30.52.10  vm-96697221-0ff9-4520-8a68-2314c62057a5  medium   true  
paasta-glusterfs-broker/229fb890-645b-4213-89a1-fc2116de3f54  running        z3  10.30.52.11  vm-ace55b8f-3ce0-4482-b03b-96fbc567592e  medium   true  

2 vms

Succeeded
```

## <div id="3"/>3. GlusterFS 연동 Sample App 설명
본 Sample Web App은 PaaS-TA에 배포되며 GlusterFS의 서비스를 Provision과 Bind를 한 상태에서 사용이 가능하다.

### <div id="3.1"/> 3.1. 서비스 브로커 등록  

GlusterFS 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 GlusterFS 서비스 브로커를 등록해 주어야 한다.
서비스 브로커 등록시에는 PaaS-TA에서 서비스 브로커를 등록할 수 있는 사용자로 로그인 하여야 한다

##### 서비스 브로커 목록을 확인한다.

>`$ cf service-brokers`
```  
$ cf service-brokers
Getting service brokers as admin...

name   url
No service brokers found
```  

##### GlusterFS 서비스 브로커를 등록한다.  
> $ cf create-service-broker [SERVICE_BROKER] [USERNAME] [PASSWORD] [SERVICE_BROKER_URL]
> 
> [SERVICE_BROKER] : 서비스 브로커 명
> [USERNAME] / [PASSWORD] : 서비스 브로커에 접근할 수 있는 사용자 ID / PASSWORD
> [SERVICE_BROKER_URL] : 서비스 브로커 접근 URL
>`$ cf create-service-broker glusterfs-service admin cloudfoundry http://10.30.107.197:8080`
```  
$ cf create-service-broker glusterfs-service admin cloudfoundry http://10.30.107.197:8080
Creating service broker glusterfs-service as admin...
OK
```  

##### 등록된 GlusterFS 서비스 브로커를 확인한다.

>`$ cf service-brokers`  
```  
$ cf service-brokers
Getting service brokers as admin...

name                           url
glusterfs-service              http://10.30.107.197:8080
```  

##### 접근 가능한 서비스 목록을 확인한다.

>`$ cf service-access`  
```  
$ cf service-access
Getting service access as admin...
broker: glusterfs-service
   service     plan               access   orgs
   glusterfs   glusterfs-5Mb      none
   glusterfs   glusterfs-100Mb    none
   glusterfs   glusterfs-1000Mb   none
```  
>서비스 브로커 등록시 최초에는 접근을 허용하지 않는다. 따라서 access는 none으로 설정된다.

##### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)

>`$ cf enable-service-access glusterfs`  
>`$ cf service-access`  
```  
$ cf enable-service-access glusterfs
Enabling access to all plans of service glusterfs for all orgs as admin...
OK

$ cf service-access
Getting service access as admin...
broker: glusterfs-service
   service     plan               access   orgs
   glusterfs   glusterfs-5Mb      all
   glusterfs   glusterfs-100Mb    all
   glusterfs   glusterfs-1000Mb   all
```  



### <div id="3.2"/> 3.2. Sample App 구조

Sample Web App은 PaaS-TA에 App으로 배포가 된다. 배포 완료 후 정상적으로 App 이 구동되면 브라우저나 curl로 해당 App에 접속 하여 GlusterFS 환경정보(서비스 연결 정보)와파일 업로드하고 확인하는 기능을 제공한다.

Sample App 구조는 다음과 같다.
<table>
  <tr>
    <td>이름</td>
    <td>설명</td>
  </tr>
  <tr>
    <td>src</td>
    <td>Sample 소스디렉토리</td>
  </tr>
  <tr>
    <td>manifest</td>
    <td>PaaS-TA에 app 배포시 필요한 설정을 저장하는 파일</td>
  </tr>
  <tr>
    <td>pom.xml</td>
    <td>maven project 설정 파일</td>
  </tr>
  <tr>
    <td>target</td>
    <td>maven build시 생성되는 디렉토리(war 파일, classes 폴더 등)</td>
  </tr>
</table>

<br>

##### PaaSTA-Sample-Apps.zip 파일 압축을 풀고 Service폴더안에 있는 GlusterFSSample Web App인 hello-spring-glusterfs를 복사한다.

>`$ ls -all`

>![glusterfs_image_07]

<br>

### <div id="3.3"/> 3.3. PaaS-TA에서 서비스 신청
Sample App에서 GlusterFS 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.
*참고: 서비스 신청시 PaaS-TA에서 서비스를 신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.

##### 먼저 PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.

>`$ cf marketplace`

>![glusterfs_image_08]

<br>

##### Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 한다.

>`$ cf create-service {서비스명} {서비스 플랜} {내 서비스명}`
- **서비스명** : p-rabbitmq로 Marketplace에서 보여지는 서비스 명칭이다.
- **서비스플랜** : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. RabbitMQ 서비스는 standard plan만 지원한다.
- **내 서비스명** : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경 설정 정보를 가져온다.

>`$ cf create-service glusterfs glusterfs-1000Mb glusterfs-service-instance`

>![glusterfs_image_09]

<br>


##### 생성된 GlusterFS 서비스 인스턴스를 확인한다.

>`$ cf services`

>![glusterfs_image_10]

<br>


##### 브라우에서 이미지 확인

> ![glusterfs_image_17]

[glusterfs_image_01]:/service-guide/images/glusterfs/glusterfs_image_01.png

[glusterfs_image_07]:/service-guide/images/glusterfs/glusterfs_image_07.png
[glusterfs_image_08]:/service-guide/images/glusterfs/glusterfs_image_08.png
[glusterfs_image_09]:/service-guide/images/glusterfs/glusterfs_image_09.png
[glusterfs_image_10]:/service-guide/images/glusterfs/glusterfs_image_10.png
[glusterfs_image_11]:/service-guide/images/glusterfs/glusterfs_image_11.png
[glusterfs_image_12]:/service-guide/images/glusterfs/glusterfs_image_12.png
[glusterfs_image_13]:/service-guide/images/glusterfs/glusterfs_image_13.png
[glusterfs_image_14]:/service-guide/images/glusterfs/glusterfs_image_14.png
[glusterfs_image_15]:/service-guide/images/glusterfs/glusterfs_image_15.png
[glusterfs_image_16]:/service-guide/images/glusterfs/glusterfs_image_16.png
[glusterfs_image_17]:/service-guide/images/glusterfs/glusterfs_image_17.jpeg

