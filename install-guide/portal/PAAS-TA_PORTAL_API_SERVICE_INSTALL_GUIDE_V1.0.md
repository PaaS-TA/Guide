## Table of Contents  

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  

2. [PaaS-TA Portal 설치](#2)  
  2.1. [Prerequisite](#2.1)   
  2.2. [Stemcell 확인](#2.2)    
  2.3. [Deployment 다운로드](#2.3)   
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)    
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)   
  2.7. [서비스 설치 확인](#2.7)  

3. [PaaS-TA Portal 운영](#3)  
  3.1. [사용자의 조직 생성 Flag 활성화](#3.1)  
  3.2. [사용자포탈 UAA 페이지 오류](#3.2)  
  3.3. [운영자포탈 유저 페이지 조회 오류](#3.3)  
  3.4. [DB Migration](#3.4)  
  3.5. [Log](#3.5)  
  3.6. [카탈로그 적용](#3.6)  
  

## <div id="1"/> 1. 문서 개요
### <div id="1.1"/> 1.1. 목적

본 문서(PaaS-TA Portal Release 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 PaaS-TA Portal Release를 Bosh2.0을 이용하여 설치 하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 내부 네트워크는 link를 적용시켜 자동으로 Ip가 할당이 된다. 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id="1.2"/> 1.2. 범위
설치 범위는 PaaS-TA Portal Release를 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id="1.3"/> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. Binary Storage, Mariadb, Proxy, Gateway Api, Registration Api, Portal Api, Common Api, Log Api, Storage Api, Webadmin, Webuser로 최소사항을 구성하였다.

![시스템구성도][paas-ta-portal-01]
* Paas-TA Portal 설치할때 cloud config에 추가적으로 정의한 VM_Tpye명과 스펙 

| VM_Type | 스펙 |
|--------|-------|
|portal_tiny| 1vCPU / 256MB RAM / 4GB Disk|
|portal_medium| 1vCPU / 1GB RAM / 4GB Disk|
|portal_small| 1vCPU / 512MB RAM / 4GB Disk|


* Paas-TA Portal각 Instance의 Resource Pool과 스펙

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| binary_storage | portal_small | 1vCPU / 512MB RAM / 4GB Disk 10GB(영구적 Disk) |
| haproxy |portal_small| 1vCPU / 512MB RAM / 4GB Disk|
| mariadb | portal_small | 1vCPU / 512MB RAM / 4GB Disk +10GB(영구적 Disk) |
| paas-ta-portal-registration | portal_small | 1vCPU / 512MB RAM / 4GB Disk |
| paas-ta-portal-gateway | portal_small | 1vCPU / 512MB RAM / 4GB Disk |
| paas-ta-portal-api | portal_medium | 1vCPU / 1GB RAM / 4GB Disk |
| paas-ta-portal-common-api | portal_small | 1vCPU / 512MB RAM / 4GB Disk |
| paas-ta-portal-log-api | portal_small | 1vCPU / 512MB RAM / 4GB Disk |
| paas-ta-portal-storage-api | portal_small | 1vCPU / 512MB RAM / 4GB Disk |

### <div id="1.4"/> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

## <div id="2"/> 2. PaaS-TA Portal 설치

### <div id="2.1"/> 2.1. Prerequisite  
본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 먼저 BOSH CLI v2 가 설치 되어 있어야 하고 BOSH 에 로그인이 되어 있어야 한다.<br>
BOSH CLI v2 가 설치 되어 있지 않을 경우 먼저 BOSH2.0 설치 가이드 문서를 참고 하여 BOSH CLI v2를 설치를 하고 사용법을 숙지 해야 한다.<br>

- BOSH2.0 사용자 가이드

>[BOSH2 사용자 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)<br>
>[BOSH CLI V2 사용자 가이드](https://github.com/PaaS-TA/Guide-4.0-ROTELLE/blob/master/Use-Guide/Bosh/PaaS-TA_BOSH_CLI_V2_사용자_가이드v1.0.md)

- bosh runtime-config를 확인하여 bosh-dns include deployments 에 paasta가 있는지 확인한다.<br>
 ※ bosh-dns include deployments에 paasta가 없다면 ~/workspace/paasta-5.0/deployment/bosh-deployment/runtime-configs 의 dns.yml 을 열어서 paasta를 추가하고, bosh runtime-config를 업데이트 해준다.    

> $ bosh -e micro-bosh runtime-config
```
Using environment '10.0.1.6' as client 'admin'

---
addons:
- include:
    deployments:
    - paasta
    - pinpoint
    - paasta-pinpoint-monitoring
    stemcell:
    - os: ubuntu-trusty
    - os: ubuntu-xenial
  jobs:
  - name: bosh-dns
    properties:
      api:
        client:
          tls: "((/dns_api_client_tls))"
        server:
          tls: "((/dns_api_server_tls))"
      cache:
        enabled: true
      health:
        client:
          tls: "((/dns_healthcheck_client_tls))"
        enabled: true
        server:
          tls: "((/dns_healthcheck_server_tls))"
    release: bosh-dns
  name: bosh-dns
...(생략)...

Succeeded

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

- Service Deployment Git Repository URL : https://github.com/PaaS-TA/portal-deployment.git

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.0/deployment
$ cd ~/workspace/paasta-5.0/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/portal-deployment.git
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

> $ vi ~/workspace/paasta-5.0/deployment/portal-deployment/portal-api/vars.yml

```
# STEMCELL INFO
stemcell_os: "ubuntu-xenial"                                    # stemcell os
stemcell_version: "315.64"                                      # stemcell version

# NETWORKS INFO
private_networks_name: "default"                                # private network name
public_networks_name: "vip"                                     # public network name

# MARIADB INFO
mariadb_azs: [z6]                                               # mariadb : azs
mariadb_instances: 1                                            # mariadb : instances (1) 
mariadb_vm_type: "minimal"                                      # mariadb : vm type
mariadb_persistent_disk_type: "10GB"                            # mariadb : persistent disk type
mariadb_port: "<MARIADB_PORT>"                                  # mariadb : database port (e.g. 3306)
mariadb_admin_password: "<MARIADB_ADMIN_PASSWORD>"              # mariadb : database admin password (e.g. "Paasta@2019")

# HAPROXY INFO
haproxy_azs: [z7]                                               # haproxy : azs
haproxy_instances: 1                                            # haproxy : instances (1)
haproxy_vm_type: "small"                                        # haproxy : vm type
haproxy_public_ips: "<HAPROXY_PUBLIC_IPS>"                      # haproxy : public ips (e.g. "00.00.00.00")
haproxy_infra_admin: false                                      # haproxy : infra admin (default "false")

# BINARY_STORAGE INFO
binary_storage_azs: [z6]                                        # binary storage : azs
binary_storage_instances: 1                                     # binary storage : instances (1)
binary_storage_vm_type: "minimal"                               # binary storage : vm type
binary_storage_persistent_disk_type: "10GB"                     # binary storage : persistent disk type
binary_storage_username: "<BINARY_STORAGE_USERNAME>"            # binary storage : username (e.g. "paasta-portal")
binary_storage_password: "<BINARY_STORAGE_PASSWORD>"            # binary storage : password (e.g. "paasta")
binary_storage_tenantname: "<BINARY_STORAGE_TENANTNAME>"        # binary storage : tenantname (e.g. "paasta-portal")
binary_storage_email: "<BINARY_STORAGE_EMAIL>"                  # binary storage : email (e.g. "paasta@paasta.com")

# PORTAL_GATEWAY INFO
gateway_azs: [z6]                                               # gateway : azs
gateway_instances: 1                                            # gateway : instances (1)
gateway_vm_type: "small"                                        # gateway : vm type

# PORTAL_REGISTRATION INFO
registration_azs: [z6]                                          # registration : azs
registration_instances: 1                                       # registration : instances (1)
registration_vm_type: "small"                                   # registration : vm type
registration_infra_admin: false                                 # registration : infra admin (default "false")

# PORTAL_API INFO
api_azs: [z6]                                                   # portal-api : azs
api_instances: 1                                                # portal-api : instances (1)
api_vm_type: "minimal"                                          # portal-api : vm type
api_infra_admin: false                                          # portal-api : infra admin (default "false")

# PORTAL_COMMON_API INFO
common_api_azs: [z6]                                            # portal-common-api : azs
common_api_instances: 1                                         # portal-common-api : instances (1)
common_api_vm_type: "small"                                     # portal-common-api : vm type
common_api_infra_admin: false                                   # portal-common-api : infra admin (default "false")

# PORTAL_STORAGE_API INFO
storage_api_azs: [z6]                                           # portal-storage-api : azs
storage_api_instances: 1                                        # portal-storage-api : instances (1)
storage_api_vm_type: "small"                                    # portal-storage-api : vm type
storage_api_infra_admin: false                                  # portal-storage-api : infra admin (default "false")

# PORTAL_LOG_API INFO
log_api_azs: [z6]                                               # portal-log-api : azs
log_api_instances: 1                                            # portal-log-api : instances (1)
log_api_vm_type: "small"                                        # portal-log-api : vm type
log_api_infra_admin: false                                      # portal-log-api : infra admin (default "false")

# MAIL_SMTP INFO
mail_smtp_host: "<MAIL_SMTP_HOST>"                              # mail-smtp : host (e.g. "smtp.gmail.com")
mail_smtp_port: "<MAIL_SMTP_PORT>"                              # mail-smtp : port (e.g. "465")
mail_smtp_username: "<MAIL_SMTP_USERNAME>"                      # mail-smtp : user name
mail_smtp_password: "<MAIL_SMTP_PASSWORD>"                      # mail-smtp : password
mail_smtp_useremail: "<MAIL_SMTP_USER_EMAIL>"                   # mail-smtp : user email
mail_smtp_properties_auth: "true"                               # mail-smtp : properties auth
mail_smtp_properties_starttls_enable: "true"                    # mail-smtp : properties starttls enable
mail_smtp_properties_starttls_required: "true"                  # mail-smtp : properties starttls required
mail_smtp_properties_subject: "MAIL_SMTP_PROPERTIES_SUBJECT"    # mail-smtp : properties subject (e.g. "PaaS-TA User Potal")
```

### <div id="2.5"/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/portal-deployment/portal-api/deploy.sh
```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                                # bosh name (e.g. micro-bosh)
IAAS="openstack"                                      # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"            # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d portal-api deploy --no-redact portal-api.yml \
   -o operations/${IAAS}-network.yml \
   -l ${COMMON_VARS_PATH} \
   -l vars.yml
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/portal-deployment/portal-api   
$ sh ./deploy.sh  
```  

### <div id="2.6"/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 파일 다운로드 위치 : https://paas-ta.kr/download/package    
  - 릴리즈 파일 : paasta-portal-api-release-2.0.tgz   

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/portal

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/portal
paasta-portal-api-release-2.0.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/portal-deployment/portal-api/deploy.sh
  
```
#!/bin/bash
  
# VARIABLES
BOSH_NAME="micro-bosh"                                # bosh name (e.g. micro-bosh)
IAAS="openstack"                                      # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"            # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)

# DEPLOY
bosh -e ${BOSH_NAME} -n -d portal-api deploy --no-redact portal-api.yml \
   -o operations/${IAAS}-network.yml \
   -o operations/use-compiled-releases.yml \
   -l ${COMMON_VARS_PATH} \
   -l vars.yml \
   -v inception_os_user_name="ubuntu"
```  

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/portal-deployment/portal-api  
$ sh ./deploy.sh  
```  

### <div id="2.7"/> 2.7. 서비스 설치 확인

설치 완료된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d portal-api vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 4823. Done

Deployment 'portal-api'

Instance                                                          Process State  AZ  IPs            VM CID                                   VM Type        Active  
binary_storage/9f58a9b7-2a3d-4ee9-8975-7b04b99c0a21               running        z5  10.30.107.212  vm-e65ad396-ce65-4ef0-962d-5c54fa411769  portal_large   true  
haproxy/8cc2d633-2b43-4f3d-a2e8-72f5279c11d5                      running        z5  10.30.107.213  vm-315bfa1b-9829-46de-a19d-3bd65e9f9ad4  portal_large   true  
										     115.68.46.214                                                            
mariadb/117cbf05-b223-4133-bf61-e15f16494e21                      running        z5  10.30.107.211  vm-bc5ae334-12d4-41d4-8411-d9315a96a305  portal_large   true  
paas-ta-portal-api/48fa0c5a-52eb-4ae8-a7b9-91275615318c           running        z5  10.30.107.217  vm-9d2a1929-0157-4c77-af5e-707ec496ed87  portal_medium  true  
paas-ta-portal-common-api/060320fa-7f26-4032-a1d9-6a7a41a044a8    running        z5  10.30.107.219  vm-f35e9838-74cf-40e0-9f97-894b53a68d1f  portal_medium  true  
paas-ta-portal-gateway/6baba810-9a4a-479d-98b2-97e5ba651784       running        z5  10.30.107.214  vm-7ec75160-bf34-442e-b755-778ae7dd3fec  portal_medium  true  
paas-ta-portal-log-api/a4460008-42b5-4ba0-84ee-fff49fe6c1bd       running        z5  10.30.107.218  vm-9ec0a1b0-09f6-415b-8e23-53af91fd94b8  portal_medium  true  
paas-ta-portal-registration/3728ed73-451e-4b93-ab9b-c610826c3135  running        z5  10.30.107.215  vm-c4020514-c458-41c6-bcbc-7e0ee1bc6f42  portal_small   true  
paas-ta-portal-storage-api/2940366a-8294-4509-a9c0-811c8140663a   running        z5  10.30.107.220  vm-79ad6ee1-1bb5-4308-8b71-9ed30418e2c1  portal_medium  true  

9 vms

Succeeded
```

## <div id="3"/>3. PaaS-TA Portal 운영

### <div id="3.1"/> 3.1. 사용자의 조직 생성 Flag 활성화

PaaS-TA는 기본적으로 일반 사용자는 조직을 생성할 수 없도록 설정되어 있다. 포털 배포를 위해 조직 및 공간을 생성해야 하고 또 테스트를 구동하기 위해서도 필요하므로 사용자가 조직을 생성할 수 있도록 user_org_creation FLAG를 활성화 한다. FLAG 활성화를 위해서는 PaaS-TA 운영자 계정으로 로그인이 필요하다.

```
$ cf enable-feature-flag user_org_creation
```
```
Setting status of user_org_creation as admin...
OK

Feature user_org_creation Enabled.
```

### <div id="3.2"/> 3.2. 사용자포탈 UAA페이지 오류  

>![paas-ta-portal-31]
1. uaac portalclient가 등록이 되어있지 않다면 해당 화면과 같이 redirect오류가 발생한다.
2. uaac client add를 통해 potalclient를 추가시켜주어야 한다.
    > $ uaac target\
    $ uaac token client get\
        Client ID:  admin\
        Client secret:  *****
        
3. uaac client add portalclient –s “portalclient Secret” 
>--redirect_uri "사용자포탈 Url, 사용자포탈 Url/callback"\
$ uaac client add portalclient -s xxxxx --redirect_uri "http://portal-web-user.xxxx.xip.io, http://portal-web-user.xxxx.xip.io/callback" \
--scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
--authorized_grant_types "authorization_code , client_credentials , refresh_token" \
--authorities="uaa.resource" \
--autoapprove="openid , cloud_controller_service_permissions.read"

 >![paas-ta-portal-32]
1. uaac portalclient가 url이 잘못 등록되어있다면 해당 화면과 같이 redirect오류가 발생한다. 
2. uaac client update를 통해 url을 수정해야한다.
   > $ uaac target\
    $ uaac token client get\
   Client ID:  admin\
   Client secret:  *****
3. uaac client update portalclient --redirect_uri "사용자포탈 Url, 사용자포탈 Url/callback"
    >$ uaac client update portalclient --redirect_uri "http://portal-web-user.xxxx.xip.io, http://portal-web-user.xxxx.xip.io/callback"

### <div id="3.3"/> 3.3. 운영자 포탈 유저 페이지 조회 오류
1. 페이지 이동시 정보를 가져오지 못하고 오류가 났을 경우 common-api VM으로 이동후에 DB 정보 config를 수정후 재시작을 해 주어야 한다.

### <div id="3.4"/> 3.4. DB Migration
이전버전에서 사용한 Portal DB를 PaaS-TA 3.5 Portal DB에 마이그레이션 하는 방법을 설명한다.
##### 1. DB tool을 이용해 기존에 사용한 DB와 Paas-TA 3.5 Portal DB를 연결한다. 
 * 가이드의 DB tool을 이용한 마이그레이션 설명은 navicat을 기준으로 한다.
##### 2. 마이그레이션할 table의 레코드 데이터를 전부 삭제한다.
>![paas-ta-portal-25]
##### 3. Tools - Data Transfer를 클릭해서 마이그레이션 설정창을 띄운다.
>![paas-ta-portal-21]
##### 4. 마이그레이션할 source DB(기존 DB), target DB(Paas-TA 3.5 Portal DB)를 설정한다.
>![paas-ta-portal-20]
##### 5. Option에 들어가 Table Options의 Create tables 옵션에 체크를 해제, Orther Options의 Contiune on error를 체크한 후 next를 누른다.
>![paas-ta-portal-24]
##### 6. 데이터를 이동할 테이블을 설정 후 next를 누른다.
>![paas-ta-portal-22]
##### 7-1. 마이그레이션이 정상적으로 완료된 모습
>![paas-ta-portal-23]
##### 7-2. 마이그레이션 오류난 모습
>![paas-ta-portal-26]
##### 7-3. 기존 DB에 오류난 Paas-TA Portal table의 Design에 맞춰 수정후에 다시 마이그레이션을 진행한다.
  
### <div id="3.5"/> 3.5. Log
Paas-TA Portal 각각 Instance의 log를 확인 할 수 있다.
1. 로그를 확인할 Instance에 접근한다.
    > bosh ssh -d [deployment name] [instance name]
       
       Instance                                                          Process State  AZ  IPs            VM CID                                   VM Type        Active  
       binary_storage/9f58a9b7-2a3d-4ee9-8975-7b04b99c0a21               running        z5  10.30.107.212  vm-e65ad396-ce65-4ef0-962d-5c54fa411769  portal_large   true  
       haproxy/8cc2d633-2b43-4f3d-a2e8-72f5279c11d5                      running        z5  10.30.107.213  vm-315bfa1b-9829-46de-a19d-3bd65e9f9ad4  portal_large   true  
                                                                                            115.68.46.214                                                            
       mariadb/117cbf05-b223-4133-bf61-e15f16494e21                      running        z5  10.30.107.211  vm-bc5ae334-12d4-41d4-8411-d9315a96a305  portal_large   true  
       paas-ta-portal-api/48fa0c5a-52eb-4ae8-a7b9-91275615318c           running        z5  10.30.107.217  vm-9d2a1929-0157-4c77-af5e-707ec496ed87  portal_medium  true  
       paas-ta-portal-common-api/060320fa-7f26-4032-a1d9-6a7a41a044a8    running        z5  10.30.107.219  vm-f35e9838-74cf-40e0-9f97-894b53a68d1f  portal_medium  true  
       paas-ta-portal-gateway/6baba810-9a4a-479d-98b2-97e5ba651784       running        z5  10.30.107.214  vm-7ec75160-bf34-442e-b755-778ae7dd3fec  portal_medium  true  
       paas-ta-portal-log-api/a4460008-42b5-4ba0-84ee-fff49fe6c1bd       running        z5  10.30.107.218  vm-9ec0a1b0-09f6-415b-8e23-53af91fd94b8  portal_medium  true  
       paas-ta-portal-registration/3728ed73-451e-4b93-ab9b-c610826c3135  running        z5  10.30.107.215  vm-c4020514-c458-41c6-bcbc-7e0ee1bc6f42  portal_small   true  
       paas-ta-portal-storage-api/2940366a-8294-4509-a9c0-811c8140663a   running        z5  10.30.107.220  vm-79ad6ee1-1bb5-4308-8b71-9ed30418e2c1  portal_medium  true  
       paas-ta-portal-webadmin/8047fcbd-9a98-4b61-b161-0cbb277fa643      running        z5  10.30.107.221  vm-188250fd-e918-4aab-9cbe-7d368852ea8a  portal_medium  true  
       paas-ta-portal-webuser/cb206717-81c9-49ed-a0a8-e6c3b957cb66       running        z5  10.30.107.222  vm-822f68a5-91c8-453a-b9b3-c1bbb388e377  portal_medium  true  
       
       11 vms
       
       Succeeded
       inception@inception:~$ bosh ssh -d paas-ta-portal-v2 paas-ta-portal-api  << instance 접근(bosh ssh) 명령어 입력
       Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)
       
       Using deployment 'paas-ta-portal-v2'
       
       Task 5195. Done
       Unauthorized use is strictly prohibited. All access and activity
       is subject to logging and monitoring.
       Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 4.4.0-92-generic x86_64)
       
        * Documentation:  https://help.ubuntu.com/
       
       The programs included with the Ubuntu system are free software;
       the exact distribution terms for each program are described in the
       individual files in /usr/share/doc/*/copyright.
       
       Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
       applicable law.
       
       Last login: Tue Sep  4 07:11:42 2018 from 10.30.20.28
       To run a command as administrator (user "root"), use "sudo <command>".
       See "man sudo_root" for details.
       
       paas-ta-portal-api/48fa0c5a-52eb-4ae8-a7b9-91275615318c:~$ 

2. 로그파일이 있는 폴더로 이동한다.
    > 위치 : /var/vcap/sys/log/[job name]/
    
         paas-ta-portal-api/48fa0c5a-52eb-4ae8-a7b9-91275615318c:~$ cd /var/vcap/sys/log/paas-ta-portal-api/
         paas-ta-portal-api/48fa0c5a-52eb-4ae8-a7b9-91275615318c:/var/vcap/sys/log/paas-ta-portal-api$ ls
         paas-ta-portal-api.stderr.log  paas-ta-portal-api.stdout.log

3. 로그파일을 열어 내용을 확인한다.
    > vim [job name].stdout.log
        
        예)
        vim paas-ta-portal-api.stdout.log
        2018-09-04 02:08:42.447 ERROR 7268 --- [nio-2222-exec-1] p.p.a.e.GlobalControllerExceptionHandler : Error message : Response : org.springframework.security.web.firewall.FirewalledResponse@298a1dc2
        Occured an exception : 403 Access token denied.
        Caused by...
        org.cloudfoundry.client.lib.CloudFoundryException: 403 Access token denied. (error="access_denied", error_description="Access token denied.")
                at org.cloudfoundry.client.lib.oauth2.OauthClient.createToken(OauthClient.java:114)
                at org.cloudfoundry.client.lib.oauth2.OauthClient.init(OauthClient.java:70)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientImpl.initialize(CloudControllerClientImpl.java:187)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientImpl.<init>(CloudControllerClientImpl.java:163)
                at org.cloudfoundry.client.lib.rest.CloudControllerClientFactory.newCloudController(CloudControllerClientFactory.java:69)
                at org.cloudfoundry.client.lib.CloudFoundryClient.<init>(CloudFoundryClient.java:138)
                at org.cloudfoundry.client.lib.CloudFoundryClient.<init>(CloudFoundryClient.java:102)
                at org.openpaas.paasta.portal.api.service.LoginService.login(LoginService.java:47)
                at org.openpaas.paasta.portal.api.controller.LoginController.login(LoginController.java:51)
                at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
                at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
                at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
                at java.lang.reflect.Method.invoke(Method.java:498)
                at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
                at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:133)
                at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:97)
                at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:827)
                at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:738)
                at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85)
                at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:967)
                at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:901)
                at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)
                at org.springframework.web.servlet.FrameworkServlet.doPost(FrameworkServlet.java:872)
                at javax.servlet.http.HttpServlet.service(HttpServlet.java:661)
                at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:846)
                at javax.servlet.http.HttpServlet.service(HttpServlet.java:742)
                at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:231)
                at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
                at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52)
                at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193)
                at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)

### <div id="3.6"/> 3.6. 카탈로그 적용
##### 1. Catalog 빌드팩, 서비스팩 추가
Paas-TA Portal 설치 후에 관리자 포탈에서 빌드팩, 서비스팩을 등록해야 사용자 포탈에서 사용이 가능하다.
 
 1. 관리자 포탈에 접속한다.(portal-web-admin.[public ip].xip.io)
    >![paas-ta-portal-15]
 2. 운영관리를 누른다.
    >![paas-ta-portal-16]
 2. 카탈로그 페이지에 들어간다.
    >![paas-ta-portal-17]
 3. 빌드팩, 서비스팩 상세화면에 들어가서 각 항목란에 값을 입력후에 저장을 누른다.
    >![paas-ta-portal-18]
 4. 사용자포탈에서 변경된값이 적용되어있는지 확인한다.
    >![paas-ta-portal-19] 
    
[paas-ta-portal-01]:../../install-guide/portal/images/Paas-TA-Portal_01.png
[paas-ta-portal-02]:../../install-guide/portal/images/Paas-TA-Portal_02.png
[paas-ta-portal-03]:../../install-guide/portal/images/Paas-TA-Portal_03.png
[paas-ta-portal-04]:../../install-guide/portal/images/Paas-TA-Portal_04.png
[paas-ta-portal-05]:../../install-guide/portal/images/Paas-TA-Portal_05.png
[paas-ta-portal-06]:../../install-guide/portal/images/Paas-TA-Portal_06.png
[paas-ta-portal-07]:../../install-guide/portal/images/Paas-TA-Portal_07.png
[paas-ta-portal-08]:../../install-guide/portal/images/Paas-TA-Portal_08.png
[paas-ta-portal-09]:../../install-guide/portal/images/Paas-TA-Portal_09.png
[paas-ta-portal-10]:../../install-guide/portal/images/Paas-TA-Portal_10.png
[paas-ta-portal-11]:../../install-guide/portal/images/Paas-TA-Portal_11.png
[paas-ta-portal-12]:../../install-guide/portal/images/Paas-TA-Portal_12.png
[paas-ta-portal-13]:../../install-guide/portal/images/Paas-TA-Portal_13.png
[paas-ta-portal-14]:../../install-guide/portal/images/Paas-TA-Portal_14.png
[paas-ta-portal-15]:../../install-guide/portal/images/Paas-TA-Portal_15.png
[paas-ta-portal-16]:../../install-guide/portal/images/Paas-TA-Portal_16.png
[paas-ta-portal-17]:../../install-guide/portal/images/Paas-TA-Portal_17.png
[paas-ta-portal-18]:../../install-guide/portal/images/Paas-TA-Portal_18.png
[paas-ta-portal-19]:../../install-guide/portal/images/Paas-TA-Portal_19.png
[paas-ta-portal-20]:../../install-guide/portal/images/Paas-TA-Portal_20.png
[paas-ta-portal-21]:../../install-guide/portal/images/Paas-TA-Portal_21.png
[paas-ta-portal-22]:../../install-guide/portal/images/Paas-TA-Portal_22.png
[paas-ta-portal-23]:../../install-guide/portal/images/Paas-TA-Portal_23.png
[paas-ta-portal-24]:../../install-guide/portal/images/Paas-TA-Portal_24.png
[paas-ta-portal-25]:../../install-guide/portal/images/Paas-TA-Portal_25.png
[paas-ta-portal-26]:../../install-guide/portal/images/Paas-TA-Portal_26.png
[paas-ta-portal-27]:../../install-guide/portal/images/Paas-TA-Portal_27.PNG
[paas-ta-portal-28]:../../install-guide/portal/images/Paas-TA-Portal_28.PNG
[paas-ta-portal-29]:../../install-guide/portal/images/Paas-TA-Portal_29.png
[paas-ta-portal-31]:../../install-guide/portal/images/Paas-TA-Portal_27.jpg
[paas-ta-portal-32]:../../install-guide/portal/images/Paas-TA-Portal_28.jpg
