
## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4) 

2. [Container 서비스 설치](#2)  
  2.1. [Prerequisite](#2.1)  
  2.2. [Stemcell 확인](#2.2)  
  2.3. [Deployment 다운로드](#2.3)  
  2.4. [Deployment 파일 수정](#2.4)  
  2.5. [서비스 설치](#2.5)  
  2.6. [서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식](#2.6)  
  2.7. [서비스 설치 확인](#2.7)    
  
3. [Container 서비스 관리 및 신청](#3)  
  3.1. [서비스 브로커 등록](#3.1)  
  3.2. [UAA Client 등록](#3.2)  
  3.3. [PaaS-TA 포탈에서 Container 서비스 조회 설정](#3.3)  
  3.4. [Jenkins 서비스 설정 (Optional)](#3.4)  
  
4. [쿠버네티스 마스터 노드 IP 변경 시 인증서 갱신 (Optional)](#4)  

5. [서비스 삭제](#5)


## <div id='1'/> 1. 문서 개요

### <div id='1.1'/> 1.1. 목적
본 문서(Container 서비스팩 설치 가이드)는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에서 제공되는 서비스팩인 Container 서비스팩을 Bosh를 이용하여 설치 및 서비스 등록하는 방법을 기술하였다.

PaaS-TA 3.5 버전부터는 Bosh 2.0 기반으로 배포(deploy)를 진행한다. 기존 Bosh 1.0 기반으로 설치를 원할 경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.


### <div id='1.2'/> 1.2. 범위
설치 범위는 Container 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.


### <div id='1.3'/> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. Container 서비스 Server, Container 서비스 브로커, Private Image Registry 로 최소사항을 구성하였다.

![Architecture]

<table>
  <tr>
    <th>VM명</th>
    <th>인스턴스수</th>
    <th>vCPU 수</th>
    <th>메모리(GB)</th>
    <th>디스크(GB)</th>
  </tr>
  <tr>
    <td>master</td>
    <td>1</td>
    <td>1</td>
    <td>4G</td>
    <td>Root 4G + 영구디스크 50G</td>
  </tr>
  <tr>
    <td>worker</td>
    <td>N</td>
    <td>8</td>
    <td>16G</td>
    <td>Root 4G + 영구디스크 100G</td>
  </tr>
  <tr>
    <td>container-service-api<br></td>
    <td>N</td>
    <td>1</td>
    <td>1G</td>
    <td>Root 4G</td>
  </tr>
  <tr>
    <td>container-service-common-api</td>
    <td>N</td>
    <td>1</td>
    <td>1G</td>
    <td>Root 4G</td>
  </tr>
  <tr>
    <td>container-service-broker</td>
    <td>N</td>
    <td>1</td>
    <td>1G</td>
    <td>Root 4G</td>
  </tr>
  <tr>
    <td>container-service-dashboard</td>
    <td>1</td>
    <td>1</td>
    <td>1G</td>
    <td>Root 4G</td>
  </tr>
  <tr>
    <td>private-image-repository</td>
    <td>1</td>
    <td>1</td>
    <td>1G</td>
    <td>Root 4G + 영구디스크 10G</td>
  </tr>
  <tr>
    <td>DBMS<br>(MariaDB)</td>
    <td>1</td>
    <td>1</td>
    <td>2G</td>
    <td>Root 4G + 영구디스크 20G</td>
  </tr>
  <tr>
    <td>HAProxy</td>
    <td>1</td>
    <td>1</td>
    <td>2G</td>
    <td>Root 4G </td>
  </tr>
</table>

### <div id='1.4'/> 1.4. 참고 자료
> http://bosh.io/docs<br>
> http://docs.cloudfoundry.org


## <div id='2'/> 2. Container 서비스 설치

### <div id='2.1'/> 2.1. Prerequisite
본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

- ※ Container 서비스팩 설치 전 Bosh 2.0 배포 주의사항
> **IaaS 환경이 OPENSTACK 인 경우 bosh deploy 시 /home/{inception_os_user_name}/workspace/paasta-5.0/deployment/bosh-deployment/openstack/disable-readable-vm-names.yml 파일을 옵션으로 추가한 후 배포한다.**


### <div id='2.2'/> 2.2. Stemcell 확인

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

### <div id='2.3'/> 2.3. Deployment 다운로드

서비스 설치에 필요한 Deployment를 Git Repository에서 받아 서비스 설치 작업 경로로 위치시킨다.  

- Service Deployment Git Repository URL : https://github.com/PaaS-TA/service-deployment/tree/v5.0.2

```
# Deployment 다운로드 파일 위치 경로 생성 및 설치 경로 이동
$ mkdir -p ~/workspace/paasta-5.0/deployment
$ cd ~/workspace/paasta-5.0/deployment

# Deployment 파일 다운로드
$ git clone https://github.com/PaaS-TA/service-deployment.git -b v5.0.2
```

### <div id='2.4'/> 2.4. Deployment 파일 수정

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

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/container-service/{IAAS}-vars.yml   
> (e.g. {IAAS} :: openstack)

```
# BOSH NAME
director_name: "micro-bosh"                                                   # bosh name (caas_cluster_name에 필요.)

# IAAS
auth_url: 'http://<IAAS-IP>:5000/v3'                                          # auth url
openstack_domain: '<OPENSTACK_DOMAIN>'                                        # openstack domain
openstack_username: '<OPENSTACK_USERNAME>'                                    # openstack username
openstack_password: '<OPENSTACK_PASSWORD>'                                    # openstack password
openstack_project_id: '<OPENSTACK_PROJECT_ID>'                                # openstack project id
region: '<OPENSTACK_REGION>'                                                  # region
ignore-volume-az: true                                                        # ignore volume az (default : true)

# STEMCELL
stemcell_os: "ubuntu-xenial"                                                  # stemcell os
stemcell_version: "315.64"                                                    # stemcell version
stemcell_alias: "xenial"                                                      # stemcell alias

# VM_TYPE
vm_type_small: "small"                                                        # vm type small
vm_type_small_highmem_16GB: "small-highmem-16GB"                              # vm type small highmem
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"                        # vm type small highmem_100GB
vm_type_caas_small: "small"                                                   # vm type small for caas's etc
vm_type_caas_small_api: "small"                                               # vm type small for caas's api

# NETWORK
private_networks_name: "default"                                              # private network name
public_networks_name: "vip"                                                   # public network name

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"                            # caas master's public IP
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"                                    # haproxy's public IP

# CREDHUB
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"                  # credhub admin secret ('$(bosh int <creds.yml FILE_PATH> --path /credhub_admin_client_secret)' 명령어를 통해 확인 가능 )

# CAAS UAAC CLIENT
paasta_uaa_oauth_client_id: "<PAASTA_UAA_OAUTH_CLIENT_ID>"                            # Container service's UAA Client Id (e.g. caasclient)
paasta_uaa_oauth_client_secret: "<PAASTA_UAA_OAUTH_CLIENT_SECRET>"                    # Container service's UAA Client secret (e.g. clientsecret)

# HAPROXY
haproxy_http_port: 8080                                                       # haproxy port
haproxy_azs: [z7]                                                             # haproxy azs

# MARIADB
mariadb_port: "13306"                                                         # mariadb port (e.g. 13306)-- Do Not Use "3306"
mariadb_azs: [z5]                                                             # mariadb azs
mariadb_persistent_disk_type: "10GB"                                          # mariadb persistent disk type
mariadb_admin_user_id: "<MARIADB_ADMIN_USER_ID>"                              # mariadb admin user name (e.g. root)
mariadb_admin_user_password: "<MARIADB_ADMIN_USER_PASSWORD>"                  # mariadb admin user password (e.g. paasta!admin)
mariadb_role_set_administrator_code_name: "Administrator"                     # administrator role's code name (e.g. Administrator)
mariadb_role_set_administrator_code: "RS0001"                                 # administrator role's code (e.g. RS0001)
mariadb_role_set_regular_user_code_name: "Regular User"                       # regular user role's code name (e.g. Regular User)
mariadb_role_set_regular_user_code: "RS0002"                                  # regular user role's code (e.g. RS0002)
mariadb_role_set_init_user_code_name: "Init User"                             # init user role's code name (e.g. Init User)
mariadb_role_set_init_user_code: "RS0003"                                     # init user role's code (e.g. RS0003)

# DASHBOARD
caas_dashboard_instances: 1                                                   # caas dashboard instances
caas_dashboard_port: 8091                                                     # caas dashboard port
caas_dashboard_azs: [z6]                                                      # caas dashboard azs
caas_dashboard_management_security_enabled: false                             # caas dashboard management security (default : false)
caas_dashboard_logging_level: "INFO"                                          # caas dashboard logging level

# API
caas_api_instances: 1                                                         # caas api instances
caas_api_port: 3333                                                           # caas api port
caas_api_azs: [z6]                                                            # caas api azs
caas_api_management_security_enabled: false                                   # caas api management security (default : false)
caas_api_logging_level: "INFO"                                                # caas api logging level

# COMMON API
caas_common_api_instances: 1                                                  # caas common api instances
caas_common_api_port: 3334                                                    # caas common api port
caas_common_api_azs: [z6]                                                     # caas common api azs
caas_common_api_logging_level: "INFO"                                         # caas common api logging level

# SERVICE BROKER
caas_service_broker_instances: 1                                              # caas service broker instances
caas_service_broker_port: 8888                                                # caas service broker port
caas_service_broker_azs: [z6]                                                 # caas service broker azs

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]                                                     # private image repository azs
private_image_repository_port: 15001                                                   # private image repository port (e.g. 15001)-- Do Not Use "5000"
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"     # private image repository root directory
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"           # private image repository's public IP
private_image_repository_persistent_disk_type: "10GB"                                  # private image repository's persistent disk type

# ADDON
caas_apply_addons_azs: [z5]                                                    # caas apply addons azs

# MASTER
caas_master_backend_port: "8443"                                               # caas master backend port (default : 8443)
caas_master_port: "8443"                                                       # caas master port (default : 8443)
caas_master_azs: [z7]                                                          # caas master azs
caas_master_persistent_disk_type: "50GB"                                       # caas master's persistent disk type

# WORKER
caas_worker_instances: 3                                                       # caas worker node instances (N)
caas_worker_azs: [z4,z5,z6]                                                    # caas worker node azs

# JENKINS
jenkins_broker_instances: 1                                                                    # jenkins broker instances
jenkins_broker_port: 8787                                                                      # jenkins broker port
jenkins_broker_azs: [z6]                                                                       # jenkins broker azs
jenkins_namespace: "paasta-jenkins"                                                            # jenkins namespace
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"          # docker file directory for create jenkins's secret
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"    # docker file directory for create jenkins's namespace
```


### <div id='2.5'/> 2.5. 서비스 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다. 

> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/container-service/deploy-{IAAS}.sh

```
#!/bin/bash

# VARIABLES
BOSH_NAME="<BOSH_NAME>"                             # bosh name (e.g. micro-bosh)
IAAS="openstack"                                    # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"          # common_vars.yml File Path (e.g. /home/ubuntu/paasta-5.0/common/common_vars.yml)
DEPLOYMENT_NAME="container-service"                 # deployment name

# DEPLOY
bosh -e ${BOSH_NAME} -n -d ${DEPLOYMENT_NAME} deploy --no-redact container-service.yml \
    -l ${COMMON_VARS_PATH} \
    -l ${IAAS}-vars.yml \
    -o operations/paasta-container-service/${IAAS}-network.yml \
    -o operations/iaas/${IAAS}/cloud-provider.yml \
    -o operations/rename.yml \
    -o operations/misc/single-master.yml \
    -o operations/misc/first-time-deploy.yml \
    -v deployment_name=${DEPLOYMENT_NAME}
```

- 서비스 설치 전 remove-all-addons.sh 을 환경에 맞게 수정한 뒤 실행한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/container-service/operations  
$ vim remove-all-addons.sh  
$ sh ./remove-all-addons.sh  
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/container-service  
$ sh ./deploy-{IAAS}.sh  
```  

### <div id='2.6'/> 2.6. 서비스 설치 - 다운로드 된 PaaS-TA Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  
  - 설치 릴리즈 파일 다운로드 : [paasta-container-service-projects-release-2.0.1.tgz](http://45.248.73.44/index.php/s/2Tc3Bca2md3f289/download)

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service

# 릴리즈 파일 다운로드(paasta-container-service-projects-release-2.0.tgz) 및 파일 경로 확인
$ ls ~/workspace/paasta-5.0/release/service
paasta-container-service-projects-release-2.0.1.tgz
```
  
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정하고 Option file 및 변수를 추가한다.  
     (추가) -o operations/use-compiled-releases.yml  
     (추가) -v inception_os_user_name="<HOME_USER_NAME>"  
     
> $ vi ~/workspace/paasta-5.0/deployment/service-deployment/container-service/deploy-{IAAS}.sh
  
```       
#!/bin/bash

# VARIABLES
BOSH_NAME="<BOSH_NAME>"                             # bosh name (e.g. micro-bosh)
IAAS="openstack"                                    # IaaS (e.g. aws/azure/gcp/openstack/vsphere)
COMMON_VARS_PATH="<COMMON_VARS_FILE_PATH>"          # common_vars.yml File Path (e.g. /home/ubuntu/workspace/paasta-5.0/deployment/common/common_vars.yml)
DEPLOYMENT_NAME="container-service"                 # deployment name

# DEPLOY
bosh -e ${BOSH_NAME} -n -d ${DEPLOYMENT_NAME} deploy --no-redact container-service.yml \
    -l ${COMMON_VARS_PATH} \
    -l ${IAAS}-vars.yml \
    -o operations/use-compiled-releases.yml \
    -o operations/paasta-container-service/${IAAS}-network.yml \
    -o operations/iaas/${IAAS}/cloud-provider.yml \
    -o operations/rename.yml \
    -o operations/misc/single-master.yml \
    -o operations/misc/first-time-deploy.yml \
    -v deployment_name=${DEPLOYMENT_NAME} \
    -v inception_os_user_name="ubuntu"    
    
```

- 서비스 설치 전 remove-all-addons.sh 을 환경에 맞게 수정한 뒤 실행한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/container-service/operations  
$ vim remove-all-addons.sh  
$ sh ./remove-all-addons.sh  
```

- 서비스를 설치한다.  
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/container-service  
$ sh ./deploy-{IAAS}.sh  
```  

### <div id='2.7'/> 2.7. 서비스 설치 확인

설치 된 서비스를 확인한다.  

> $ bosh -e micro-bosh -d container-service vms  

```
Using environment '10.0.1.6' as client 'admin'

Task 294249. Done

Deployment 'container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  Stemcell  
container-jenkins-broker/129ad9e6-3fb9-48f4-a876-9bd1aeb2793d      running        z2  10.0.41.135    4a7c6cd6-d338-424d-ab30-66b563c0f0c5  small               true    -  
container-service-api/f7902066-0978-4de3-bf2d-e432b0c14199         running        z5  10.0.161.127   ab210e7e-af10-476e-8dfa-4d6081fd494c  small               true    -  
container-service-broker/e193844e-6d47-4477-a73c-b5014d4573e7      running        z6  10.0.201.141   e31e74a9-a567-4b38-9e21-b796492f3466  small               true    -  
container-service-common-api/b2b5e67b-0a5f-4943-a3da-6e9826a6f8fa  running        z5  10.0.161.128   03ad70ab-b2c1-4791-b8fb-5903b6b680ba  small               true    -  
container-service-dashboard/300fead4-4487-4a65-b77c-5e3487818453   running        z6  10.0.201.140   fec06a82-df4c-4c00-b8e8-bd646ad4e1cc  small               true    -  
haproxy/cd60739e-a6b7-436d-9fe9-a515d28629fd                       running        z7  10.0.0.126     b8bad420-e726-41c8-9aae-f7d45c2f2679  small               true    -  
                                                                                      101.55.50.201                                                                      
mariadb/9755e6a4-243f-4350-a6d8-517566c6dcbf                       running        z5  10.0.161.126   ef081b0a-7c1a-4854-a695-200d80194db2  small               true    -  
master/68782774-455e-43f7-95a4-20d09fa4936c                        running        z7  10.0.0.125     0da12a95-9f2b-4fa7-9079-d4c59b573c3a  small-highmem-16GB  true    -  
                                                                                      101.55.50.204                                                                      
private-image-repository/1a416603-ced1-4b1c-8090-5f3962309456      running        z7  10.0.0.127     895010f1-ae53-457f-bd8d-138a68ca847c  small               true    -  
                                                                                      101.55.50.202                                                                      
worker/23886843-ab6b-4ae1-a676-89f7307d5b01                        running        z5  10.0.161.125   e4eaa60c-084c-4384-ab3f-915aca22dc4c  small-highmem-16GB  true    -  
worker/3c37840f-c743-410e-81c7-f6754afb60f7                        running        z6  10.0.201.139   7a44994c-b833-4b6c-a6dd-f314d048b171  small-highmem-16GB  true    -  
worker/d6ef01d8-d783-40a6-a8f7-b43f8fd4c52f                        running        z4  10.0.121.122   ab557f46-57b7-480c-8826-ce9aac256f9f  small-highmem-16GB  true    -  

12 vms

Succeeded
```

## <div id="3"/>3.  Container 서비스 관리 및 신청

PaaS-TA 운영자 포탈을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청 하여 사용할 수 있다.

### <div id='3.1'/> 3.1. Container 서비스 브로커 등록
Container 서비스팩 배포가 완료되었으면 PaaS-TA 포탈에서 서비스 팩을 사용하기 위해서 먼저 Container 서비스 브로커를 등록해 주어야 한다. 서비스 브로커 등록 시 개방형 클라우드 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

- 서비스 브로커 목록을 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                               url
mysql-service-broker               http://10.0.121.71:8080
```

- Container 서비스 브로커를 등록한다.


>$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}
> - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
> - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
> - 서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL

```
$ cf create-service-broker container-service-broker admin cloudfoundry http://xxx.xxx.xxx.xxx:8888
```

- 등록된 Container 서비스 브로커를 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:8888
mysql-service-broker       http://10.0.121.71:8080
```

- 접근 가능한 서비스 목록을 확인한다.

```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
   service             plan       access   orgs
   container-service   Advanced   all      
   container-service   Micro      all      
   container-service   Small      all      

broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    all      
   Mysql-DB   Mysql-Plan2-100con   all      

```

- 특정 조직에 해당 서비스 접근 허용을 할당한다.

```
$ cf enable-service-access container-service
Enabling access to all plans of service container-service for all orgs as admin...
OK
```

- 접근 가능한 서비스 목록을 확인한다.

```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
   service             plan       access   orgs
   container-service   Advanced   all      
   container-service   Micro      all      
   container-service   Small      all      

broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    all      
   Mysql-DB   Mysql-Plan2-100con   all      
```

### <div id='3.2'/> 3.2. Container 서비스 UAA Client 등록
UAA 포털 계정 등록 절차에 대한 순서를 확인한다.

- Container 서비스 대시보드에 접근이 가능한 IP를 알기 위해 **haproxy IP** 를 확인한다.

```
Deployment 'container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  Stemcell  
container-jenkins-broker/129ad9e6-3fb9-48f4-a876-9bd1aeb2793d      running        z2  10.0.41.135    4a7c6cd6-d338-424d-ab30-66b563c0f0c5  small               true    -  
container-service-api/f7902066-0978-4de3-bf2d-e432b0c14199         running        z5  10.0.161.127   ab210e7e-af10-476e-8dfa-4d6081fd494c  small               true    -  
container-service-broker/e193844e-6d47-4477-a73c-b5014d4573e7      running        z6  10.0.201.141   e31e74a9-a567-4b38-9e21-b796492f3466  small               true    -  
container-service-common-api/b2b5e67b-0a5f-4943-a3da-6e9826a6f8fa  running        z5  10.0.161.128   03ad70ab-b2c1-4791-b8fb-5903b6b680ba  small               true    -  
container-service-dashboard/300fead4-4487-4a65-b77c-5e3487818453   running        z6  10.0.201.140   fec06a82-df4c-4c00-b8e8-bd646ad4e1cc  small               true    -  
haproxy/cd60739e-a6b7-436d-9fe9-a515d28629fd                       running        z7  10.0.0.126     b8bad420-e726-41c8-9aae-f7d45c2f2679  small               true    -  
                                                                                      101.55.50.201                                                                      
mariadb/9755e6a4-243f-4350-a6d8-517566c6dcbf                       running        z5  10.0.161.126   ef081b0a-7c1a-4854-a695-200d80194db2  small               true    -  
master/68782774-455e-43f7-95a4-20d09fa4936c                        running        z7  10.0.0.125     0da12a95-9f2b-4fa7-9079-d4c59b573c3a  small-highmem-16GB  true    -  
                                                                                      101.55.50.204                                                                      
private-image-repository/1a416603-ced1-4b1c-8090-5f3962309456      running        z7  10.0.0.127     895010f1-ae53-457f-bd8d-138a68ca847c  small               true    -  
                                                                                      101.55.50.202                                                                      
worker/23886843-ab6b-4ae1-a676-89f7307d5b01                        running        z5  10.0.161.125   e4eaa60c-084c-4384-ab3f-915aca22dc4c  small-highmem-16GB  true    -  
worker/3c37840f-c743-410e-81c7-f6754afb60f7                        running        z6  10.0.201.139   7a44994c-b833-4b6c-a6dd-f314d048b171  small-highmem-16GB  true    -  
worker/d6ef01d8-d783-40a6-a8f7-b43f8fd4c52f                        running        z4  10.0.121.122   ab557f46-57b7-480c-8826-ce9aac256f9f  small-highmem-16GB  true    -  

12 vms

Succeeded
```

- uaac server의 endpoint를 설정한다.

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

- Container 서비스 계정 생성을 한다.

> $ uaac client add caasclient -s {클라이언트 비밀번호} --redirect_uri {컨테이너 서비스 대시보드 URI} --scope {퍼미션 범위} --authorized_grant_types {권한 타입} --authorities={권한 퍼미션} --autoapprove={자동승인권한}
  -	<CF_UAA_CLIENT_ID> : uaac 클라이언트 id  
  -	<CF_UAA_CLIENT_SECRET> : uaac 클라이언트 secret  
  -	<Logging 서비스 URI> : 성공적으로 리다이렉션 할 Logging 서비스 접근 URI (http://<logging-service의 router public IP>)  
  -	<퍼미션 범위> : 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록  
  -	<권한 타입> : 서비스가 제공하는 API를 사용할 수 있는 권한 목록  
  -	<권한 퍼미션> : 클라이언트에 부여 된 권한 목록  
  -	<자동승인권한> : 사용자 승인이 필요하지 않은 권한 목록

```  
# e.g. Container 서비스 계정 생성
$ uaac client add caasclient -s clientsecret --redirect_uri "http://xxx.xxx.xxx.xxx:8091" --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"

# e.g. Container 서비스 계정 생성 확인
$ uaac clients
caasclient
    scope: cloud_controller.read cloud_controller.write cloud_controller_service_permissions.read openid cloud_controller.admin
    resource_ids: none
    authorized_grant_types: refresh_token client_credentials authorization_code
    redirect_uri: http://101.55.50.201:8091
    autoapprove: cloud_controller_service_permissions.read openid
    authorities: uaa.resource
    name: caasclient
    lastmodified: 1592962300888

```  

### <div id='3.3'/> 3.3. PaaS-TA 포탈에서 Container 서비스 조회 설정

해당 설정은 PaaS-TA 포탈에 Container 서비스 상의 자원들을 간략하게 조회하기 위한 설정이다.

1) PaaS-TA 어드민 포탈에 접속한다.
![Portal_CaaS_01]
<br>

2) 왼쪽 네비게이션 바에서 [설정]-[설정정보] 를 클릭한 후 나타나는 페이지의 오른쪽 상단 [인프라 등록] 버튼을 클릭하여 해당 정보들을 입력한다.


- 해당 정보를 입력하기 위해 필요한 값들을 찾는다.
> $ bosh -e micro-bosh -d portal-api vms
>> haproxy 의 IP 를 찾아 Portal_Api_Uri 에 입력한다.
```
Deployment 'portal-api'

Instance                                                          Process State  AZ  IPs            VM CID                                VM Type        Active  Stemcell  
binary_storage/f8b140f0-6061-46a1-99fa-216d124423fe               running        z6  10.0.201.132   dca829c1-a76f-4771-9ffa-dd734364c6f4  portal_small   true    -  
haproxy/c248579f-b7c7-4010-9e6a-b6aab14a0d7b                      running        z6  10.0.201.131   a3c5dca3-6989-46f4-97f0-508b3122aa85  small          true    -  
                                                                                     101.55.50.211                                                                 
mariadb/fba7cd79-58ba-4e70-a2dc-8fe180058665                      running        z6  10.0.201.130   13b2c8f8-1a99-46dc-81b1-be3a678580c0  portal_small   true    -  
paas-ta-portal-api/f73e323a-c080-407a-ba55-da54e076bc2f           running        z6  10.0.201.135   48f1801d-cd01-4f19-bbb0-a96f8d36c3cc  portal_medium  true    -  
paas-ta-portal-common-api/d3479dfb-d6fb-46f4-b879-059eb3ba200d    running        z6  10.0.201.136   b391fb2f-3b74-43cf-a243-d00968cae836  portal_small   true    -  
paas-ta-portal-gateway/1eab2fe3-09ff-48da-9bb2-a4a7f8ba707c       running        z6  10.0.201.133   617c3f08-3e46-48c5-bb08-c867d7b97466  portal_small   true    -  
paas-ta-portal-log-api/6b3407bf-8099-4aa0-a0db-28394f512145       running        z6  10.0.201.138   bbcea9e9-81c5-409e-a732-46a8835c5a54  portal_small   true    -  
paas-ta-portal-registration/27852b28-92e7-4c11-8201-e0822118e6d8  running        z6  10.0.201.134   15e4c4f5-f599-474b-a779-a142943b8e5c  portal_small   true    -  
paas-ta-portal-storage-api/e92c1252-dc67-43d4-9984-9340fd4fc832   running        z6  10.0.201.137   5d3a0ef9-def1-49a1-975b-c4b93985b269  portal_small   true    -  

9 vms
```


<br>

> $ bosh -e micro-bosh -d container-service vms
>> haproxy 의 IP 를 찾아 CaaS_Api_Uri 에 입력한다.

```
Using environment '10.0.1.6' as client 'admin'

Task 294249. Done

Deployment 'container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  Stemcell  
container-jenkins-broker/129ad9e6-3fb9-48f4-a876-9bd1aeb2793d      running        z2  10.0.41.135    4a7c6cd6-d338-424d-ab30-66b563c0f0c5  small               true    -  
container-service-api/f7902066-0978-4de3-bf2d-e432b0c14199         running        z5  10.0.161.127   ab210e7e-af10-476e-8dfa-4d6081fd494c  small               true    -  
container-service-broker/e193844e-6d47-4477-a73c-b5014d4573e7      running        z6  10.0.201.141   e31e74a9-a567-4b38-9e21-b796492f3466  small               true    -  
container-service-common-api/b2b5e67b-0a5f-4943-a3da-6e9826a6f8fa  running        z5  10.0.161.128   03ad70ab-b2c1-4791-b8fb-5903b6b680ba  small               true    -  
container-service-dashboard/300fead4-4487-4a65-b77c-5e3487818453   running        z6  10.0.201.140   fec06a82-df4c-4c00-b8e8-bd646ad4e1cc  small               true    -  
haproxy/cd60739e-a6b7-436d-9fe9-a515d28629fd                       running        z7  10.0.0.126     b8bad420-e726-41c8-9aae-f7d45c2f2679  small               true    -  
                                                                                      101.55.50.201                                                                      
mariadb/9755e6a4-243f-4350-a6d8-517566c6dcbf                       running        z5  10.0.161.126   ef081b0a-7c1a-4854-a695-200d80194db2  small               true    -  
master/68782774-455e-43f7-95a4-20d09fa4936c                        running        z7  10.0.0.125     0da12a95-9f2b-4fa7-9079-d4c59b573c3a  small-highmem-16GB  true    -  
                                                                                      101.55.50.204                                                                      
private-image-repository/1a416603-ced1-4b1c-8090-5f3962309456      running        z7  10.0.0.127     895010f1-ae53-457f-bd8d-138a68ca847c  small               true    -  
                                                                                      101.55.50.202                                                                      
worker/23886843-ab6b-4ae1-a676-89f7307d5b01                        running        z5  10.0.161.125   e4eaa60c-084c-4384-ab3f-915aca22dc4c  small-highmem-16GB  true    -  
worker/3c37840f-c743-410e-81c7-f6754afb60f7                        running        z6  10.0.201.139   7a44994c-b833-4b6c-a6dd-f314d048b171  small-highmem-16GB  true    -  
worker/d6ef01d8-d783-40a6-a8f7-b43f8fd4c52f                        running        z4  10.0.121.122   ab557f46-57b7-480c-8826-ce9aac256f9f  small-highmem-16GB  true    -  

12 vms

Succeeded
```


```
ex)
- NAME : PaaS-TA 5.0 (Openstack)
- Portal_Api_Uri : http://<portal_haproxy_IP>:2225
- UAA_Uri : https://api.<CF DOMAIN>
- Authorization : Basic YWRtaW46b3BlbnBhYXN0YQ==
- 설명 : PaaS-TA 5.0 install infra
- CaaS_Api_Uri : http://<container_service_haproxy_IP>
- CaaS_Authorization : Basic YWRtaW46UGFhUy1UQQ==
```

![Portal_CaaS_02]

<br>

### <div id='3.4'/> 3.4. Jenkins 서비스 설정 (Optional)
해당 설정은 Jenkins 서비스에서 설치된 Jenkins 서비스를 이용하기 위한 설정이다.

1) 배포된 Jenkins 서비스 VM 목록을 확인한다.
> $ bosh -e micro-bosh -d container-service vms

```
Deployment 'container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  Stemcell  
container-jenkins-broker/129ad9e6-3fb9-48f4-a876-9bd1aeb2793d      running        z2  10.0.41.135    4a7c6cd6-d338-424d-ab30-66b563c0f0c5  small               true    -  
container-service-api/f7902066-0978-4de3-bf2d-e432b0c14199         running        z5  10.0.161.127   ab210e7e-af10-476e-8dfa-4d6081fd494c  small               true    -  
container-service-broker/e193844e-6d47-4477-a73c-b5014d4573e7      running        z6  10.0.201.141   e31e74a9-a567-4b38-9e21-b796492f3466  small               true    -  
container-service-common-api/b2b5e67b-0a5f-4943-a3da-6e9826a6f8fa  running        z5  10.0.161.128   03ad70ab-b2c1-4791-b8fb-5903b6b680ba  small               true    -  
container-service-dashboard/300fead4-4487-4a65-b77c-5e3487818453   running        z6  10.0.201.140   fec06a82-df4c-4c00-b8e8-bd646ad4e1cc  small               true    -  
haproxy/cd60739e-a6b7-436d-9fe9-a515d28629fd                       running        z7  10.0.0.126     b8bad420-e726-41c8-9aae-f7d45c2f2679  small               true    -  
                                                                                      101.55.50.201                                                                      
mariadb/9755e6a4-243f-4350-a6d8-517566c6dcbf                       running        z5  10.0.161.126   ef081b0a-7c1a-4854-a695-200d80194db2  small               true    -  
master/68782774-455e-43f7-95a4-20d09fa4936c                        running        z7  10.0.0.125     0da12a95-9f2b-4fa7-9079-d4c59b573c3a  small-highmem-16GB  true    -  
                                                                                      101.55.50.204                                                                      
private-image-repository/1a416603-ced1-4b1c-8090-5f3962309456      running        z7  10.0.0.127     895010f1-ae53-457f-bd8d-138a68ca847c  small               true    -  
                                                                                      101.55.50.202                                                                      
worker/23886843-ab6b-4ae1-a676-89f7307d5b01                        running        z5  10.0.161.125   e4eaa60c-084c-4384-ab3f-915aca22dc4c  small-highmem-16GB  true    -  
worker/3c37840f-c743-410e-81c7-f6754afb60f7                        running        z6  10.0.201.139   7a44994c-b833-4b6c-a6dd-f314d048b171  small-highmem-16GB  true    -  
worker/d6ef01d8-d783-40a6-a8f7-b43f8fd4c52f                        running        z4  10.0.121.122   ab557f46-57b7-480c-8826-ce9aac256f9f  small-highmem-16GB  true    -  

12 vms
```
<br>




2) Jenkins 서비스 브로커를 등록한다.

- 서비스 브로커 목록을 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                               url
delivery-pipeline-service-broker   http://xxx.xxx.xxx.xxx:8080
```

- Jenkins 서비스 브로커를 등록한다.


>$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}
> - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
> - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
> - 서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL

```
$ cf create-service-broker jenkins-service-broker admin cloudfoundry http://xxx.xxx.xxx.xxx:8787
```

- 등록된 Jenkins 서비스 브로커를 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                               url
jenkins-service-broker             http://xxx.xxx.xxx.xxx:8787
delivery-pipeline-service-broker   http://xxx.xxx.xxx.xxx:8080
```

- 접근 가능한 서비스 목록을 확인한다.

```
$ cf service-access
Getting service access as admin...
broker: jenkins-service-broker
   service                     plan                        access   orgs
   container-jenkins-service   jenkins_20GB                limit     

broker: delivery-pipeline-service-broker
   service                plan                          access   orgs
   delivery-pipeline-v2   delivery-pipeline-shared      all
   delivery-pipeline-v2   delivery-pipeline-dedicated   all
```

- 특정 조직에 해당 서비스 접근 허용을 할당한다.

```
$ cf enable-service-access container-jenkins-service
Enabling access to all plans of service container-jenkins-service for all orgs as admin...
OK
```
- 접근 가능한 서비스 목록을 확인한다.

```
$ cf service-access
Getting service access as admin...
broker: jenkins-service-broker
   service                     plan                     access   orgs
   container-jenkins-service   jenkins_20GB             all   

broker: delivery-pipeline-service-broker
   service                plan                          access   orgs
   delivery-pipeline-v2   delivery-pipeline-shared      all
   delivery-pipeline-v2   delivery-pipeline-dedicated   all

```

### <div id='4'/> 4. 쿠버네티스 마스터 노드 IP 변경 시 인증서 갱신 (Optional)
쿠버네티스 마스터 노드의 IP가 변경되어 재설치를 하는 경우 해당 IP를 포함한 인증서를 삭제해주어야 신규 인증서가 생성되므로 이 경우 설치 스크립트는 자동으로 인증서를 삭제 후 배포를 진행한다. 만약 CredHub에 로그인이 되어 있지 않으면 아래와 같은 메세지가 나타나며 CredHub 로그인 이후 다시 시도해야 한다.

```
$ ./deploy-vsphere.sh
You are not currently authenticated to CredHub. Please log in to continue.
$
```

- CredHub 로그인  
CredHub에 로그인이 되어있지 않은 경우 [**CredHub 가이드**](/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md#1037)를 참조한다.  

### <div id='5'/> 5. 서비스 삭제
서비스 삭제 시 CredHub에 로그인이 되어 있는 상태 에서 이하의 script를 실행하여 credHub의 credential 삭제 처리를 진행한다.

```
$ sh operations/remove-service-credentials.sh <BOSH NAME> <DEPLOYMENT NAME>

e.g.
$ sh operations/remove-service-credentials.sh micro-bosh container-service
```

[Architecture]:../images/container-service/Container_Service_Architecture.png
[Portal_CaaS_01]:../images/container-service/portal-admin.png
[Portal_CaaS_02]:../images/container-service/portal-infra-setting.png
