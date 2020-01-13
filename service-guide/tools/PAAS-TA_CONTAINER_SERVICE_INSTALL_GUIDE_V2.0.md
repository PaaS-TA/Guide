
## Table of Contents

[1. 문서 개요](#1)

  -  [1.1. 목적](#11)
  -  [1.2. 범위](#12)
  -  [1.3. 시스템 구성도](#13)
  -  [1.4. 참고 자료](#14)

[2. Container 서비스팩 설치](#2)

  -  [2.1. 설치 전 준비사항](#21)
  -  [2.1.1. Deployment 및 Release 파일 다운로드](#211)
  -  [2.2. Stemcell 업로드](#22)
  -  [2.3. Container 서비스 릴리즈 Deployment 파일 수정 및 배포](#23)
  -  [2.4. Container 서비스 브로커 등록](#24)
  -  [2.5. Container 서비스 UAA Client Id 등록](#25)
  -  [2.6. PaaS-TA 포탈에서 Container 서비스 조회 설정](#26)
  -  [2.7. Jenkins 서비스 설정 (Optional)](#27)
  -  [2.7.1. Jenkins 서비스 브로커 등록](#27_1)
  -  [2.8. 쿠버네티스 마스터 노드 IP 변경 시 인증서 갱신 (Optional)](#28)

# <div id='1'/> 1. 문서 개요

### <div id='11'/> 1.1. 목적
본 문서(Container 서비스팩 설치 가이드)는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에서 제공되는 서비스팩인 Container 서비스팩을 Bosh를 이용하여 설치 및 서비스 등록하는 방법을 기술하였다.

PaaS-TA 3.5 버전부터는 Bosh 2.0 기반으로 배포(deploy)를 진행한다. 기존 Bosh 1.0 기반으로 설치를 원할 경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.


### <div id='12'/> 1.2. 범위
설치 범위는 Container 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.


### <div id='13'/> 1.3. 시스템 구성도
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

### <div id='14'/> 1.4. 참고 자료
>http://bosh.io/docs
http://docs.cloudfoundry.org


# <div id='2'/> 2. Container 서비스팩 설치

### <div id='21'/> 2.1. 설치 전 준비사항
본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

- Container 서비스팩 설치 전 Bosh 2.0 배포 주의사항

>IaaS 환경이 OPENSTACK 인 경우 bosh deploy 시 /home/{user_name}/workspace/paasta-5.0/deployment/bosh-deployment/openstack/disable-readable-vm-names.yml 파일을 옵션으로 추가한 후 배포한다.

#### <div id='211'/> 2.1.1. Container 서비스 Deployment 및 Release 파일 다운로드

Container 서비스 설치에 필요한 Deployment 및 릴리즈 파일을 다운로드 받아 서비스 설치 작업 경로로 위치시킨다.

-	설치 파일 다운로드 위치 : https://paas-ta.kr/download/package
-	Release, deployment 파일은 /home/{user_name}/workspace/paasta-5.0 이하에 다운로드 받아야 한다.
-	설치 작업 경로 생성 및 파일 다운로드

>	Deployment 파일
>
>	> paasta-container-service-2.0

> Release 파일
 >> bosh-dns-release-1.12.0.tgz<br>
 >> bpm-release-1.0.4.tgz<br>
 >> cfcr-etcd-release-1.11.1.tgz<br>
 >> docker-35.2.1.tgz<br>
 >> kubo-release-0.34.1.tgz<br>
 >> paasta-container-service-projects-release-2.0.tgz<br>


```
- Deployment 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0

- 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/service
```

-	Deployment 파일을 다운로드 받아 ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0 이하 디렉토리에 이동한다.
-	Release 파일을 다운로드 받아 ~/workspace/paasta-5.0/release/service 이하 디렉토리에 이동한다.


### <div id='22'/> 2.2. Stemcell 업로드

- Deploy시 사용할 Stemcell을 확인한다.

>Stemcell 목록이 존재 하지 않을 경우, BOSH 설치 가이드 문서를 참고하여 Stemcell을 업로드를 해야 한다. (Stemcell 315.64 버전 사용, PaaSTA-Stemcell.zip)

- Stemcell 다운로드 위치

  >https://paas-ta.kr/download/package


```
**사용 예시**

$ bosh -e micro-bosh stemcells
Using environment '10.0.1.6' as client 'admin'

Name                                       Version  OS             CPI  CID  
bosh-openstack-kvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    a2d704b0-2768-4e55-84a6-4f3b1311e6f9  

(*) Currently deployed

1 stemcells
```


### <div id='23'/> 2.3. Container 서비스 릴리즈 Deployment 파일 수정 및 배포
BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다.

Deployment 파일에서 사용하는 network, vm_type 등은 Cloud config를 활용하고 해당 가이드는 BOSH 2.0 가이드를 참고한다.

- Cloud config 내용 조회

```
Using environment '10.0.1.6' as client 'admin'

azs:
- cloud_properties:
    availability_zone: nova
  name: z1
- cloud_properties:
    availability_zone: nova
  name: z2
- cloud_properties:
    availability_zone: nova
  name: z3
- cloud_properties:
    availability_zone: nova
  name: z4
- cloud_properties:
    availability_zone: nova
  name: z5
- cloud_properties:
    availability_zone: nova
  name: z6
- cloud_properties:
    availability_zone: nova
  name: z7
compilation:
  az: z3
  network: default
  reuse_compilation_vms: true
  vm_type: large
  workers: 5
disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB
- disk_size: 2048
  name: 2GB
- disk_size: 4096
  name: 4GB
- disk_size: 5120
  name: 5GB
- disk_size: 8192
  name: 8GB
- disk_size: 10240
  name: 10GB
- disk_size: 20480
  name: 20GB
- disk_size: 30720
  name: 30GB
- disk_size: 51200
  name: 50GB
- disk_size: 102400
  name: 100GB
- disk_size: 1048576
  name: 1TBB
- cloud_properties:
    type: SSD1
  disk_size: 2000
  name: 2GB_GP2
- cloud_properties:
    type: SSD1
  disk_size: 5000
  name: 5GB_GP2
- cloud_properties:
    type: SSD1
  disk_size: 10000
  name: 10GB_GP2
- cloud_properties:
    type: SSD1
  disk_size: 50000
  name: 50GB_GP2
networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.1 - 10.0.1.9
    static:
    - 10.0.1.10 - 10.0.1.120
  - az: z2
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.41.1
    range: 10.0.41.0/24
    reserved:
    - 10.0.41.1 - 10.0.41.9
    static:
    - 10.0.41.10 - 10.0.41.120
  - az: z3
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.81.1
    range: 10.0.81.0/24
    reserved:
    - 10.0.81.1 - 10.0.81.9
    static:
    - 10.0.81.10 - 10.0.81.120
  - az: z4
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.121.1
    range: 10.0.121.0/24
    reserved:
    - 10.0.121.1 - 10.0.121.9
    static:
    - 10.0.121.10 - 10.0.121.120
  - az: z5
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.161.1
    range: 10.0.161.0/24
    reserved:
    - 10.0.161.1 - 10.0.161.9
    static:
    - 10.0.161.10 - 10.0.161.120
  - az: z6
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.201.1
    range: 10.0.201.0/24
    reserved:
    - 10.0.201.1 - 10.0.201.9
    static:
    - 10.0.201.10 - 10.0.201.120
  - az: z7
    cloud_properties:
      name: random
      net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
      security_groups:
      - paasta-v50-security
    dns:
    - 8.8.8.8
    gateway: 10.0.0.1
    range: 10.0.0.0/24
    reserved:
    - 10.0.0.1 - 10.0.0.9
    static:
    - 10.0.0.10 - 10.0.0.120
- name: vip
  type: vip
vm_extensions:
- cloud_properties:
    ports:
    - host: 3306
  name: mysql-proxy-lb
- name: cf-router-network-properties
- name: cf-tcp-router-network-properties
- name: diego-ssh-proxy-network-properties
- name: cf-haproxy-network-properties
- cloud_properties:
    ephemeral_disk:
      size: 51200
      type: gp2
  name: small-50GB
- cloud_properties:
    ephemeral_disk:
      size: 102400
      type: gp2
  name: small-highmem-100GB
vm_types:
- cloud_properties:
    instance_type: m1.tiny
  name: minimal
- cloud_properties:
    instance_type: m1.medium
  name: default
- cloud_properties:
    instance_type: m1.small
  name: small
- cloud_properties:
    instance_type: m1.medium
  name: medium
- cloud_properties:
    instance_type: m1.medium
  name: medium-memory-8GB
- cloud_properties:
    instance_type: m1.large
  name: large
- cloud_properties:
    instance_type: m1.xlarge
  name: xlarge
- cloud_properties:
    instance_type: m1.medium
  name: small-50GB
- cloud_properties:
    instance_type: m1.medium
  name: small-50GB-ephemeral-disk
- cloud_properties:
    instance_type: m1.large
  name: small-100GB-ephemeral-disk
- cloud_properties:
    instance_type: m1.large
  name: small-highmem-100GB-ephemeral-disk
- cloud_properties:
    instance_type: m1.large
  name: small-highmem-16GB
- cloud_properties:
    instance_type: m1.medium
  name: service_medium
- cloud_properties:
    instance_type: m1.medium
  name: service_medium_2G
- cloud_properties:
    instance_type: m1.tiny
  name: portal_small
- cloud_properties:
    instance_type: m1.small
  name: portal_medium
- cloud_properties:
    instance_type: m1.small
  name: portal_large

Succeeded

```
-	Deployment 를 하기 전에 remove-all-addons.sh 을 환경에 맞게 수정한다.
```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi remove-all-addons.sh


#!/bin/bash

director_name='micro-bosh'

bosh -e ${director_name} update-runtime-config manifests/ops-files/paasta-container-service/remove-all-addons.yml

```
- Deployment YAML에서 사용하는 변수들을 서버 환경에 맞게 수정한다.

>*<CREDHUB_ADMIN_CLIENT_SECRET> 에는 /home/{user_name}/workspace/paasta-5.0/deployment/bosh-deployment/{각 iaas}/creds.yml 의 'credhub_admin_client_secret' key 값의 value 를 입력한다.*
<br>

> vSphere용

```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi ./manifests/paasta-container-service-vars-vsphere.yml

# INCEPTION OS USER NAME
inception_os_user_name: "inception"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.0"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "2.0"
cfcr_release_name: "kubo-release"
cfcr_release_version: "0.34.1"

# IAAS
vcenter_master_user: "<VCENTER_MASTER_USER>"
vcenter_master_password: "<VCENTER_MASTER_PASSWORD>"
vcenter_ip: "<VCENTER_IP>"
vcenter_dc: "<VCENTER_DC>"
vcenter_ds: "<VCENTER_DS>"
vcenter_vms: "<VCENTER_VMS>"

# STEMCELL
stemcell_os: "ubuntu-xenial"
stemcell_version: "315.64"
stemcell_alias: "xenial"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "small"

# NETWORK
service_private_networks_name: "service_private"
service_public_networks_name: "service_public"

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"


# CREDHUB
credhub_server_url: "10.30.50.1:8844"
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>.xip.io"
cf_api_url: "https://api.<DOMAIN>.xip.io"
cf_uaa_oauth_client_id: "<CAAS_CF_UAA_OAUTH_CLIENT_ID>"         # caasclient (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 id 와 같아야 한다.)
cf_uaa_oauth_client_secret: "<CAAS_CF_UAA_OAUTH_CLIENT_SECRET>" # clientsecret (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 password 와 같아야 한다.)

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z1]

# MARIADB
mariadb_port: "3306"
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

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z1]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z2]

# MASTER
caas_master_backend_port: 8443
caas_master_port: 8443
caas_master_azs: [z3]
caas_master_persistent_disk_type: 51200

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z1,z2,z3]

# JENKINS
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z3]
jenkins_namespace: "paasta-jenkins"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```

> AWS용

```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi ./manifests/paasta-container-service-vars-aws.yml

# INCEPTION OS USER NAME
inception_os_user_name: "ubuntu"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.0"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "2.0"
cfcr_release_name: "kubo-release"
cfcr_release_version: "0.34.1"

# IAAS
aws_access_key_id_master: '<AWS_ACCESS_KEY_ID_MASTER>'
aws_secret_access_key_master: '<AWS_SECRET_ACCESS_KEY_MASTER>'
aws_access_key_id_worker: '<AWS_ACCESS_KEY_ID_WORKER>'
aws_secret_access_key_worker: '<AWS_SECRET_ACCESS_KEY_WORKER>'
kubernetes_cluster_tag: 'kubernetes'    # Do not update!

# STEMCELL
stemcell_os: "ubuntu-xenial"
stemcell_version: "315.64"
stemcell_alias: "xenial"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "small"

# NETWORK
service_private_nat_networks_name: "default"
service_private_networks_name: "default"
service_public_networks_name: "vip"

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"

# CREDHUB
credhub_server_url: "10.0.1.6:8844"
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>.xip.io"
cf_api_url: "https://api.<DOMAIN>.xip.io"
cf_uaa_oauth_client_id: "<CAAS_CF_UAA_OAUTH_CLIENT_ID>"         # caasclient (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 id 와 같아야 한다.)
cf_uaa_oauth_client_secret: "<CAAS_CF_UAA_OAUTH_CLIENT_SECRET>" # clientsecret (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 password 와 같아야 한다.)

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z7]

# MARIADB
mariadb_port: "3306"
mariadb_azs: [z5]
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
caas_dashboard_azs: [z6]
caas_dashboard_management_security_enabled: false
caas_dashboard_logging_level: "INFO"

# API
caas_api_instances: 1
caas_api_port: 3333
caas_api_azs: [z6]
caas_api_management_security_enabled: false
caas_api_logging_level: "INFO"

# COMMON API
caas_common_api_instances: 1
caas_common_api_port: 3334
caas_common_api_azs: [z6]
caas_common_api_logging_level: "INFO"

# SERVICE BROKER
caas_service_broker_instances: 1
caas_service_broker_port: 8888
caas_service_broker_azs: [z6]

#PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z5]

# MASTER
caas_master_backend_port: "8443"
caas_master_port: "8443"
caas_master_azs: [z7]
caas_master_persistent_disk_type: 51200

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z4,z5,z6]

# JENKINS
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z6]
jenkins_namespace: "paasta-jenkins"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```


> OpenStack용

```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi ./manifests/paasta-container-service-vars-openstack.yml

# INCEPTION OS USER NAME
inception_os_user_name: "ubuntu"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.0"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "2.0"
cfcr_release_name: "kubo-release"
cfcr_release_version: "0.34.1"

# IAAS
auth_url: 'http://<IAAS-IP>:5000/v3'
openstack_domain: '<OPENSTACK_DOMAIN>'
openstack_username: '<OPENSTACK_USERNAME>'
openstack_password: '<OPENSTACK_PASSWORD>'
openstack_project_id: '<OPENSTACK_PROJECT_ID>'
region: '<OPENSTACK_REGION>'
ignore-volume-az: true

# STEMCELL
stemcell_os: "ubuntu-xenial"
stemcell_version: "315.64"
stemcell_alias: "xenial"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "small"

# NETWORK
service_private_networks_name: "default"
service_public_networks_name: "vip"

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"

# CREDHUB
credhub_server_url: "10.0.1.6:8844"
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>.xip.io"
cf_api_url: "https://api.<DOMAIN>.xip.io"
cf_uaa_oauth_client_id: "<CAAS_CF_UAA_OAUTH_CLIENT_ID>"         # caasclient (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 id 와 같아야 한다.)
cf_uaa_oauth_client_secret: "<CAAS_CF_UAA_OAUTH_CLIENT_SECRET>" # clientsecret (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 password 와 같아야 한다.)

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z7]

# MARIADB
mariadb_port: "3306"    #"<MARIADB_PORT>"
mariadb_azs: [z5]
mariadb_persistent_disk_type: "10GB"
mariadb_admin_user_id: "root"   #"<MARIADB_ADMIN_USER_ID>"
mariadb_admin_user_password: "Paasta@2019" #"<MARIADB_ADMIN_USER_PASSWORD>"
mariadb_role_set_administrator_code_name: "Administrator"
mariadb_role_set_administrator_code: "RS0001"
mariadb_role_set_regular_user_code_name: "Regular User"
mariadb_role_set_regular_user_code: "RS0002"
mariadb_role_set_init_user_code_name: "Init User"
mariadb_role_set_init_user_code: "RS0003"

# DASHBOARD
caas_dashboard_instances: 1
caas_dashboard_port: 8091
caas_dashboard_azs: [z6]
caas_dashboard_management_security_enabled: false
caas_dashboard_logging_level: "INFO"

# API
caas_api_instances: 1
caas_api_port: 3333
caas_api_azs: [z5]
caas_api_management_security_enabled: false
caas_api_logging_level: "INFO"

# COMMON API
caas_common_api_instances: 1
caas_common_api_port: 3334
caas_common_api_azs: [z5]
caas_common_api_logging_level: "INFO"

# SERVICE BROKER
caas_service_broker_instances: 1
caas_service_broker_port: "8888"
caas_service_broker_azs: [z6]

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z5]

# MASTER
caas_master_backend_port: 8443
caas_master_port: 8443
caas_master_azs: [z7]
caas_master_persistent_disk_type: 51200

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z4,z5,z6]

# JENKINS
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z2]
jenkins_namespace: "paasta-jenkins"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```


> GCP용

```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi ./manifests/paasta-container-service-vars-gcp.yml

# INCEPTION OS USER NAME
inception_os_user_name: "inception"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.0"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "2.0"
cfcr_release_name: "kubo-release"
cfcr_release_version: "0.34.1"

# IAAS
project_id: "<PROJECT_ID>"
network: "<NETWORK>"
director_name: "<DIRECTOR_NAME>"
deployment_name: "<DEPLOYMENT_NAME>"

# STEMCELL
stemcell_os: "ubuntu-xenial"
stemcell_version: "315.64"
stemcell_alias: "xenial"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "small"

# NETWORK
service_private_nat_networks_name: "default"
service_private_networks_name: "default"
service_public_networks_name: "vip"

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"

# CREDHUB
credhub_server_url: "10.174.0.3:8844"
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>.xip.io"
cf_api_url: "https://api.<DOMAIN>.xip.io"
cf_uaa_oauth_client_id: "<CAAS_CF_UAA_OAUTH_CLIENT_ID>"         # caasclient (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 id 와 같아야 한다.)
cf_uaa_oauth_client_secret: "<CAAS_CF_UAA_OAUTH_CLIENT_SECRET>" # clientsecret (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 password 와 같아야 한다.)

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z7]

# MARIADB
mariadb_port: "3306"
mariadb_azs: [z5]
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
caas_dashboard_azs: [z5]
caas_dashboard_management_security_enabled: false
caas_dashboard_logging_level: "INFO"

# API
caas_api_instances: 1
caas_api_port: 3333
caas_api_azs: [z5]
caas_api_management_security_enabled: false
caas_api_logging_level: "INFO"

# COMMON API
caas_common_api_instances: 1
caas_common_api_port: 3334
caas_common_api_azs: [z5]
caas_common_api_logging_level: "INFO"

# SERVICE BROKER
caas_service_broker_instances: 1
caas_service_broker_port: 8888
caas_service_broker_azs: [z5]

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z6]

# MASTER
caas_master_backend_port: 8443
caas_master_port: 8443
caas_master_azs: [z7]
caas_master_persistent_disk_type: 51200

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z4,z5,z6]

# JENKINS
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z5]
jenkins_namespace: "paasta-jenkins"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```


> Azure용

```
$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi ./manifests/paasta-container-service-vars-azure.yml

# INCEPTION OS USER NAME
inception_os_user_name: "ubuntu"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.0"

# RELEASE
caas_projects_release_name: "paasta-container-service-projects-release"
caas_projects_release_version: "2.0"
cfcr_release_name: "kubo-release"
cfcr_release_version: "0.34.1"

# IAAS
azure_cloud_name: "<AZURE_CLOUD_NAME>"
location: "<LOCATION>"
primary_availability_set: "<PRIMARY_AVAILABILITY_SET>"
resource_group_name: "<RESOURCE_GROUP_NAME>"
default_security_group: "<DEFAULT_SECURITY_GROUP>"
subnet_name: "<SUBNET_NAME>"
subscription_id: "<SUBSCRIPTION_ID>"
tenant_id: "<TENANT_ID>"
vnet_name: "<VNET_NAME>"
vnet_resource_group_name: "<VNET_RESOURCE_GROUP_NAME>"

# STEMCELL
stemcell_os: "ubuntu-xenial"
stemcell_version: "315.64"
stemcell_alias: "xenial"

# VM_TYPE
vm_type_small: "small"
vm_type_small_highmem_16GB: "small-highmem-16GB"
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"
vm_type_caas_small: "small"
vm_type_caas_small_api: "small"

# NETWORK
service_private_nat_networks_name: "default"
service_private_networks_name: "default"
service_public_networks_name: "vip"

# IPS
caas_master_public_url: "<CAAS_MASTER_PUBLIC_URL>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"

# CREDHUB
credhub_server_url: "10.0.1.6:8844"
credhub_admin_client_secret: "<CREDHUB_ADMIN_CLIENT_SECRET>"

# CF
cf_uaa_oauth_uri: "https://uaa.<DOMAIN>.xip.io"
cf_api_url: "https://api.<DOMAIN>.xip.io"
cf_uaa_oauth_client_id: "<CAAS_CF_UAA_OAUTH_CLIENT_ID>"         # caasclient (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 id 와 같아야 한다.)
cf_uaa_oauth_client_secret: "<CAAS_CF_UAA_OAUTH_CLIENT_SECRET>" # clientsecret (2.5. Container 서비스 UAA Client Id 등록 부분의 client 계정 password 와 같아야 한다.)

# HAPROXY
haproxy_http_port: 8080
haproxy_azs: [z7]

# MARIADB
mariadb_port: "3306"
mariadb_azs: [z5]
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
caas_dashboard_azs: [z6]
caas_dashboard_management_security_enabled: false
caas_dashboard_logging_level: "INFO"

# API
caas_api_instances: 1
caas_api_port: 3333
caas_api_azs: [z6]
caas_api_management_security_enabled: false
caas_api_logging_level: "INFO"

# COMMON API
caas_common_api_instances: 1
caas_common_api_port: 3334
caas_common_api_azs: [z6]
caas_common_api_logging_level: "INFO"

# SERVICE BROKER
caas_service_broker_instances: 1
caas_service_broker_port: 8888
caas_service_broker_azs: [z6]

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]
private_image_repository_port: 5000
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"
private_image_repository_persistent_disk_type: "10GB"

# ADDON
caas_apply_addons_azs: [z5]

# MASTER
caas_master_backend_port: "8443"
caas_master_port: "8443"
caas_master_azs: [z7]
caas_master_persistent_disk_type: 51200

# WORKER
caas_worker_instances: 3
caas_worker_azs: [z4,z5,z6]

# JENKINS
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z6]
jenkins_namespace: "paasta-jenkins"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```

- Deploy 스크립트 파일을 서버 환경에 맞게 수정한다.
  - vSphere : **deploy-vsphere.sh**
  - AWS : **deploy-aws.sh**
  - OpenStack : **deploy-openstack.sh**
  - GCP : **deploy-gcp.sh**
  - Azure : **deploy-azure.sh**

```

$ cd ~/workspace/paasta-5.0/deployment/service-deployment/paasta-container-service-2.0
$ vi deploy-vsphere.sh

#!/bin/bash

# SET VARIABLES
export CAAS_DEPLOYMENT_NAME='paasta-container-service'
export CAAS_BOSH2_NAME='micro-bosh'
export CAAS_BOSH2_UUID=`bosh int <(bosh -e ${CAAS_BOSH2_NAME} environment --json) --path=/Tables/0/Rows/0/uuid`

# DEPLOY
bosh -e ${CAAS_BOSH2_NAME} -n -d ${CAAS_DEPLOYMENT_NAME} deploy --no-redact manifests/paasta-container-service-deployment-vsphere.yml \
    -l manifests/paasta-container-service-vars-vsphere.yml \
    -o manifests/ops-files/paasta-container-service/network-vsphere.yml \
    -o manifests/ops-files/iaas/vsphere/cloud-provider.yml \
    -o manifests/ops-files/iaas/vsphere/set-working-dir-no-rp.yml \
    -o manifests/ops-files/rename.yml \
    -o manifests/ops-files/misc/single-master.yml \
    -o manifests/ops-files/misc/first-time-deploy.yml \
    -v director_uuid=${CAAS_BOSH2_UUID} \
    -v director_name=${CAAS_BOSH2_NAME} \
    -v deployment_name=${CAAS_DEPLOYMENT_NAME}


```

- Container 서비스팩을 배포한다.

```
$ ./remove-all-addons.sh
$ ./deploy-openstack.sh

Using environment '10.0.1.6' as client 'admin'

Using deployment 'paasta-container-service'

######################################################## 100.00% 177.74 KiB/s 0s
########################################################## 100.00% 5.57 KiB/s 0s
######################################################### 100.00% 30.84 KiB/s 0s
######################################################## 100.00% 770.66 KiB/s 0s

Task 611
Task 613
Task 612
Task 611 | 08:11:56 | Extracting release: Extracting release (00:00:00)
Task 611 | 08:11:56 | Verifying manifest: Verifying manifest
Task 610 | 08:11:56 | Extracting release: Extracting release (00:00:00)
Task 610 | 08:11:56 | Verifying manifest: Verifying manifest (00:00:00)
Task 611 | 08:11:56 | Verifying manifest: Verifying manifest (00:00:00)
Task 611 | 08:11:57 | Resolving package dependencies: Resolving package dependencies
Task 613 | 08:11:57 | Extracting release: Extracting release (00:00:00)
Task 613 | 08:11:57 | Verifying manifest: Verifying manifest
Task 610 | 08:11:57 | Resolving package dependencies: Resolving package dependencies
Task 611 | 08:11:57 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 611 | 08:11:57 | Processing 3 existing jobs: Processing 3 existing jobs (00:00:00)
Task 611 | 08:11:57 | Compiled Release has been created: bpm/1.0.4 (00:00:00)

Task 611 Started  Fri Nov 22 08:11:56 UTC 2019
Task 611 Finished Fri Nov 22 08:11:57 UTC 2019
Task 611 Duration 00:00:01
Task 611 done

Task 613 | 08:11:57 | Verifying manifest: Verifying manifest (00:00:00)
Task 613 | 08:11:57 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 613 | 08:11:58 | Processing 6 existing jobs: Processing 6 existing jobs (00:00:00)
Task 613 | 08:11:58 | Compiled Release has been created: docker/35.2.1 (00:00:00)

Task 613 Started  Fri Nov 22 08:11:57 UTC 2019
Task 613 Finished Fri Nov 22 08:11:58 UTC 2019
Task 613 Duration 00:00:01
Task 613 done

Task 610 | 08:11:57 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 610 | 08:11:57 | Processing 4 existing jobs: Processing 4 existing jobs (00:00:00)
Task 610 | 08:11:57 | Compiled Release has been created: cfcr-etcd/1.11.1 (00:00:00)

Task 610 Started  Fri Nov 22 08:11:56 UTC 2019
Task 610 Finished Fri Nov 22 08:11:57 UTC 2019
Task 610 Duration 00:00:01
Task 610 done

Task 612 | 08:11:58 | Extracting release: Extracting release (00:00:00)
Task 612 | 08:11:58 | Verifying manifest: Verifying manifest (00:00:00)
Task 612 | 08:11:58 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 612 | 08:11:58 | Processing 6 existing packages: Processing 6 existing packages (00:00:02)
Task 612 | 08:12:00 | Processing 4 existing jobs: Processing 4 existing jobs (00:00:00)
Task 612 | 08:12:00 | Release has been created: bosh-dns/1.12.0 (00:00:00)

Task 612 Started  Fri Nov 22 08:11:58 UTC 2019
Task 612 Finished Fri Nov 22 08:12:00 UTC 2019
Task 612 Duration 00:00:02
Task 612 done
######################################################### 100.00% 96.30 MiB/s 4s

Task 614

Task 614 | 08:12:26 | Extracting release: Extracting release (00:00:02)
Task 614 | 08:12:29 | Verifying manifest: Verifying manifest (00:00:00)
Task 614 | 08:12:29 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 614 | 08:12:29 | Creating new packages: cifs-utils/5cdcfa2be82cf12c60e1d18cac67b2edd460e3dce1c309496e9aafb5e969cb31 (00:00:00)
Task 614 | 08:12:29 | Creating new packages: cni/733d130f18b3988a8a2dac37e66e886cbd368116b4fbf56438946795b59b8409 (00:00:01)
Task 614 | 08:12:30 | Creating new packages: conntrack/a4fcc71e14eba1dd1f27115fb3647bc9d913a13ef3842d312c8ab288954d6899 (00:00:00)
Task 614 | 08:12:30 | Creating new packages: etcdctl/fb69bb4734751c6ad5e4d1e019c4c7edc1727994dcdc24404f116d3e1064ceaf (00:00:00)
Task 614 | 08:12:30 | Creating new packages: flanneld/5b571d993714ca9563d1f2fdeeae1c2db71835ce548a9b75cdc4e8bd8bb20621 (00:00:01)
Task 614 | 08:12:31 | Creating new packages: golang-1.12-linux/2566cc8c8b3c0f3ccf6c832a6a4657a14f938197a70c2d2b6243be051439a395 (00:00:01)
Task 614 | 08:12:32 | Creating new packages: ipset/238365bbfb0001eb0ea16431c05f6b76845c101c78a905c31299f32cc820dc5a (00:00:01)
Task 614 | 08:12:33 | Creating new packages: jq/5ac19aae3c9b3648140589b03b673db4ce896733505562b4c0d9e64b9a880b38 (00:00:00)
Task 614 | 08:12:33 | Creating new packages: kubernetes/208b979e87b52a5cc64bcc4bc82e54532edab3f13377b24f5baa83d73a51957d (00:00:08)
Task 614 | 08:12:41 | Creating new packages: nfs/9e30f53d1743d5ae1898520bc1c501b28647cd2f7e5bd5eddd2c34c560763771 (00:00:00)
Task 614 | 08:12:41 | Creating new packages: pid_utils/a2a905d267548c461ccf91937963ff7d26356f8f2edd928490ba529d0cc94aa4 (00:00:00)
Task 614 | 08:12:41 | Creating new packages: prometheus/641a811c8b53b4572daff1c857b052cfa41e44f8700f31503623f99c1e78a6a9 (00:00:00)
Task 614 | 08:12:41 | Creating new packages: smoke-tests/0f3e7c3d8594c6f5bff2e0e54b0390fa57c95d99aba0f3fef54a85f9242b985b (00:00:00)
Task 614 | 08:12:41 | Creating new packages: socat/5737907822eb2c5ab7aa509d699acc566f349b7e86d8a8d176037b90d3427dbe (00:00:00)
Task 614 | 08:12:41 | Creating new jobs: apply-specs/16f5acd86b9cf75db5326a8d61739ac6296b728341e681f3dc2eca47f99cb512 (00:00:00)
Task 614 | 08:12:41 | Creating new jobs: bbr-kube-apiserver/56cbb995f6cdac6d27577f4ffd166b148aad57ff44ecf9b2c687bdbdf403e9a1 (00:00:00)
Task 614 | 08:12:41 | Creating new jobs: cifs-utils/41efca0df09260293d95b618d4858e6f18aab226d64a7e6f80951134ea82bcdd (00:00:01)
Task 614 | 08:12:42 | Creating new jobs: cloud-provider/ce4e4103d4560fa3ddbd267e7456f4883ebe3340cd97cc1fe0c827d01d4b095d (00:00:00)
Task 614 | 08:12:42 | Creating new jobs: flanneld/c9fa0facf6840eb82562c5d1714963ca24a8d430d2681db861cc93085070ab0a (00:00:01)
Task 614 | 08:12:43 | Creating new jobs: kube-apiserver/b6cb4e9cc04f9ee4221def47265ce0074bec1412941e79de659ca670d83b105d (00:00:00)
Task 614 | 08:12:43 | Creating new jobs: kube-controller-manager/2cc0863c2fc4f218d90eff06882872015341aa8eaa8bdbaee4e5a7a70c8e2bb7 (00:00:00)
Task 614 | 08:12:43 | Creating new jobs: kube-proxy/65e036f59b63b3a160ccf456f3819b220e101e230206ad27a96dbaa4bb4b0975 (00:00:00)
Task 614 | 08:12:43 | Creating new jobs: kube-scheduler/575969aff53426e9fa25041f0e599ec9b1e9758c28d94ab8795e2b6af6226b38 (00:00:00)
Task 614 | 08:12:44 | Creating new jobs: kubelet/691a8fe39a9943cfe8887d818e222d5e58a2385abcf62bf7cb128a257efe427b (00:00:00)
Task 614 | 08:12:44 | Creating new jobs: kubernetes-dependencies/40fdea1f8d3818418c9bd3216cc633a583f0537b30ec2b9957f24ab5a32b2971 (00:00:05)
Task 614 | 08:12:51 | Creating new jobs: kubernetes-roles/1a2882b6abb4abfa60a118cf8268e8518312a5b3f367787e6aab72286e2c4ea7 (00:00:01)
Task 614 | 08:12:52 | Creating new jobs: kubo-dns-aliases/0b18a6e6006651877e1df15d8c8f3b2e1e5a8ebf33f24622d5bad47bf2d91979 (00:00:00)
Task 614 | 08:12:52 | Creating new jobs: prometheus/a71ed7b138391f2a69e4f64126bef2a04e918567126720bb24c9da014a41d106 (00:00:00)
Task 614 | 08:12:52 | Creating new jobs: smoke-tests/9b7bcb34e0a2c16d40a61af1f76d68ced53b9abd9db4e50d2310d5419389679d (00:00:00)
Task 614 | 08:12:52 | Release has been created: kubo/0.34.1 (00:00:00)

Task 614 Started  Fri Nov 22 08:12:26 UTC 2019
Task 614 Finished Fri Nov 22 08:12:52 UTC 2019
Task 614 Duration 00:00:26
Task 614 done
####################################################### 100.00% 104.13 MiB/s 10s

Task 615

Task 615 | 08:13:18 | Extracting release: Extracting release (00:00:08)
Task 615 | 08:13:26 | Verifying manifest: Verifying manifest (00:00:00)
Task 615 | 08:13:26 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 615 | 08:13:26 | Creating new packages: container-jenkins-broker/61402977c04a852d4fc225647de0552311ca93d5af34623b5dbb11f270f6955c (00:00:03)
Task 615 | 08:13:29 | Creating new packages: container-service-api/799d2307a495ac31a2814a117caf6654f8a3c97b9a737fe0f28b82b1cf9424d1 (00:00:01)
Task 615 | 08:13:30 | Creating new packages: container-service-broker/dec15d1e9a681abd3028dbc6178e03502318945bdf2569677dec9f903ef4fac4 (00:00:04)
Task 615 | 08:13:34 | Creating new packages: container-service-common-api/d4bed1a591fdc156ed6b382ae29bd4c78e4aa7dc611d250e8d118ad8b6f98462 (00:00:00)
Task 615 | 08:13:34 | Creating new packages: container-service-dashboard/fddb96e48b6ccd9e31fbcaa2bf9f1c3c3d1183e9c10f1c3bb1bcb27119fe32c7 (00:00:01)
Task 615 | 08:13:35 | Creating new packages: docker-images/6569c8e4d1dcbfa24ebdeefdca566812ed973836f38b4caa5adeced5a3ccf259 (00:00:17)
Task 615 | 08:13:52 | Creating new packages: docker-repository-setting/a12df48ea6f42617b66ff0f009ac777ad624b072187e53015ee09ef1b75c3fbd (00:00:00)
Task 615 | 08:13:52 | Creating new packages: private-image-repository/afe545b792d56af9fb744a7b123b8cd53d394567ea73d58b6a590a9626dc9e17 (00:00:00)
Task 615 | 08:13:52 | Processing 3 existing packages: Processing 3 existing packages (00:00:00)
Task 615 | 08:13:52 | Creating new jobs: container-jenkins-broker/7836667a306cf2ae27d8d815db4ede086b5006339d785bbf90bf546d56336e2a (00:00:00)
Task 615 | 08:13:52 | Creating new jobs: container-service-api/1ecc773f9a717baefb637a2339a6ae5612908e388788fb3bf2025c94e5e1284c (00:00:01)
Task 615 | 08:13:53 | Creating new jobs: container-service-broker/b3e5bc10e34861f964e9bcedc7d4bc0e67906c4bf0d05f8b564e58589c623624 (00:00:00)
Task 615 | 08:13:53 | Creating new jobs: container-service-common-api/393810cc14247d14f2b1094306189c95a6bbb9b2ddbd4d222ee0e2fe05fa348b (00:00:00)
Task 615 | 08:13:53 | Creating new jobs: container-service-dashboard/cbe4393d6939f633f7664932a2bbf0aab213b9fad43d0f09cb64267d03178674 (00:00:00)
Task 615 | 08:13:53 | Creating new jobs: docker-images/5da3804d51358c1d2b5a57c4b85f678424c2585f493cabe7c9fd5b657f02b13b (00:00:00)
Task 615 | 08:13:53 | Creating new jobs: docker-repository-setting/24a4331a89f7443f22f7de69f3ccce6c58d10913fd53d3f727a6049d53620934 (00:00:01)
Task 615 | 08:13:55 | Creating new jobs: haproxy/5ca9c27b4c0732f6d9aac1312f5e978d265e3cc0b3a6f6d2d193e769f5bffe1f (00:00:00)
Task 615 | 08:13:55 | Creating new jobs: mariadb/c10857a8792cf9eb095a3548ba63f1905f2e5537351213e6b3858d8a5b878be2 (00:00:00)
Task 615 | 08:13:55 | Creating new jobs: private-image-repository/85821934521b807641d6ce64b357ad4b381c324b7b066035dd300f137c1b922e (00:00:00)
Task 615 | 08:13:55 | Release has been created: paasta-container-service-projects-release/2.0 (00:00:01)

Task 615 Started  Fri Nov 22 08:13:18 UTC 2019
Task 615 Finished Fri Nov 22 08:13:56 UTC 2019
Task 615 Duration 00:00:38
Task 615 done
+ azs:
+ - cloud_properties:
+     availability_zone: nova
+   name: z1
+ - cloud_properties:
+     availability_zone: nova
+   name: z2
+ - cloud_properties:
+     availability_zone: nova
+   name: z3
+ - cloud_properties:
+     availability_zone: nova
+   name: z4
+ - cloud_properties:
+     availability_zone: nova
+   name: z5
+ - cloud_properties:
+     availability_zone: nova
+   name: z6
+ - cloud_properties:
+     availability_zone: nova
+   name: z7

+ vm_types:
+ - cloud_properties:
+     instance_type: m1.tiny
+   name: minimal
+ - cloud_properties:
+     instance_type: m1.medium
+   name: default
+ - cloud_properties:
+     instance_type: m1.small
+   name: small
+ - cloud_properties:
+     instance_type: m1.medium
+   name: medium
+ - cloud_properties:
+     instance_type: m1.medium
+   name: medium-memory-8GB
+ - cloud_properties:
+     instance_type: m1.large
+   name: large
+ - cloud_properties:
+     instance_type: m1.xlarge
+   name: xlarge
+ - cloud_properties:
+     instance_type: m1.medium
+   name: small-50GB
+ - cloud_properties:
+     instance_type: m1.medium
+   name: small-50GB-ephemeral-disk
+ - cloud_properties:
+     instance_type: m1.large
+   name: small-100GB-ephemeral-disk
+ - cloud_properties:
+     instance_type: m1.large
+   name: small-highmem-100GB-ephemeral-disk
+ - cloud_properties:
+     instance_type: m1.large
+   name: small-highmem-16GB
+ - cloud_properties:
+     instance_type: m1.medium
+   name: service_medium
+ - cloud_properties:
+     instance_type: m1.medium
+   name: service_medium_2G
+ - cloud_properties:
+     instance_type: m1.tiny
+   name: portal_small
+ - cloud_properties:
+     instance_type: m1.small
+   name: portal_medium
+ - cloud_properties:
+     instance_type: m1.small
+   name: portal_large

+ vm_extensions:
+ - cloud_properties:
+     ports:
+     - host: 3306
+   name: mysql-proxy-lb
+ - name: cf-router-network-properties
+ - name: cf-tcp-router-network-properties
+ - name: diego-ssh-proxy-network-properties
+ - name: cf-haproxy-network-properties
+ - cloud_properties:
+     ephemeral_disk:
+       size: 51200
+       type: gp2
+   name: small-50GB
+ - cloud_properties:
+     ephemeral_disk:
+       size: 102400
+       type: gp2
+   name: small-highmem-100GB

+ compilation:
+   az: z3
+   network: default
+   reuse_compilation_vms: true
+   vm_type: large
+   workers: 5

+ networks:
+ - name: default
+   subnets:
+   - az: z1
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.1.1
+     range: 10.0.1.0/24
+     reserved:
+     - 10.0.1.1 - 10.0.1.9
+     static:
+     - 10.0.1.10 - 10.0.1.120
+   - az: z2
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.41.1
+     range: 10.0.41.0/24
+     reserved:
+     - 10.0.41.1 - 10.0.41.9
+     static:
+     - 10.0.41.10 - 10.0.41.120
+   - az: z3
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.81.1
+     range: 10.0.81.0/24
+     reserved:
+     - 10.0.81.1 - 10.0.81.9
+     static:
+     - 10.0.81.10 - 10.0.81.120
+   - az: z4
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.121.1
+     range: 10.0.121.0/24
+     reserved:
+     - 10.0.121.1 - 10.0.121.9
+     static:
+     - 10.0.121.10 - 10.0.121.120
+   - az: z5
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.161.1
+     range: 10.0.161.0/24
+     reserved:
+     - 10.0.161.1 - 10.0.161.9
+     static:
+     - 10.0.161.10 - 10.0.161.120
+   - az: z6
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.201.1
+     range: 10.0.201.0/24
+     reserved:
+     - 10.0.201.1 - 10.0.201.9
+     static:
+     - 10.0.201.10 - 10.0.201.120
+   - az: z7
+     cloud_properties:
+       name: random
+       net_id: 9950af59-daf2-43d6-967c-ad445bfe2cb2
+       security_groups:
+       - paasta-v50-security
+     dns:
+     - 8.8.8.8
+     gateway: 10.0.0.1
+     range: 10.0.0.0/24
+     reserved:
+     - 10.0.0.1 - 10.0.0.9
+     static:
+     - 10.0.0.10 - 10.0.0.120
+ - name: vip
+   type: vip

+ disk_types:
+ - disk_size: 1024
+   name: default
+ - disk_size: 1024
+   name: 1GB
+ - disk_size: 2048
+   name: 2GB
+ - disk_size: 4096
+   name: 4GB
+ - disk_size: 5120
+   name: 5GB
+ - disk_size: 8192
+   name: 8GB
+ - disk_size: 10240
+   name: 10GB
+ - disk_size: 20480
+   name: 20GB
+ - disk_size: 30720
+   name: 30GB
+ - disk_size: 51200
+   name: 50GB
+ - disk_size: 102400
+   name: 100GB
+ - disk_size: 1048576
+   name: 1TBB
+ - cloud_properties:
+     type: SSD1
+   disk_size: 2000
+   name: 2GB_GP2
+ - cloud_properties:
+     type: SSD1
+   disk_size: 5000
+   name: 5GB_GP2
+ - cloud_properties:
+     type: SSD1
+   disk_size: 10000
+   name: 10GB_GP2
+ - cloud_properties:
+     type: SSD1
+   disk_size: 50000
+   name: 50GB_GP2

+ stemcells:
+ - alias: xenial
+   os: ubuntu-xenial
+   version: '315.64'

+ releases:
+ - name: kubo
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/kubo-release-0.34.1.tgz
+   version: 0.34.1
+ - name: cfcr-etcd
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/cfcr-etcd-1.11.1.tgz
+   version: 1.11.1
+ - name: docker
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/docker-35.2.1.tgz
+   version: 35.2.1
+ - name: bpm
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/bpm-1.0.4.tgz
+   version: 1.0.4
+ - name: bosh-dns
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/bosh-dns-release-1.12.0.tgz
+   version: 1.12.0
+ - name: paasta-container-service-projects-release
+   url: file:///home/ubuntu/workspace/paasta-5.0/release/service/paasta-container-service-projects-release-2.0.tgz
+   version: '2.0'

+ update:
+   canaries: 1
+   canary_watch_time: 10000-300000
+   max_in_flight: 100%
+   update_watch_time: 10000-300000

+ addons:
+ - include:
+     stemcells:
+     - os: ubuntu-xenial
+   jobs:
+   - name: bosh-dns
+     properties:
+       api:
+         client:
+           tls: "((/dns_api_client_tls))"
+         server:
+           tls: "((/dns_api_server_tls))"
+       cache:
+         enabled: true
+       health:
+         client:
+           tls: "((/dns_healthcheck_client_tls))"
+         enabled: true
+         server:
+           tls: "((/dns_healthcheck_server_tls))"
+     release: bosh-dns
+   name: bosh-dns
+ - jobs:
+   - name: kubo-dns-aliases
+     release: kubo
+   name: bosh-dns-aliases

+ variables:
+ - name: kubo-admin-password
+   type: password
+ - name: kubelet-password
+   type: password
+ - name: kubelet-drain-password
+   type: password
+ - name: kube-proxy-password
+   type: password
+ - name: kube-controller-manager-password
+   type: password
+ - name: kube-scheduler-password
+   type: password
+ - name: etcd_user_root_password
+   type: password
+ - name: etcd_user_flanneld_password
+   type: password
+ - name: kubo_ca
+   options:
+     common_name: ca
+     is_ca: true
+   type: certificate
+ - name: tls-kubelet
+   options:
+     alternative_names: []
+     ca: kubo_ca
+     common_name: kubelet.cfcr.internal
+     organization: system:nodes
+   type: certificate
+ - name: tls-kubelet-client
+   options:
+     ca: kubo_ca
+     common_name: kube-apiserver.cfcr.internal
+     extended_key_usage:
+     - client_auth
+     organization: system:masters
+   type: certificate
+ - name: tls-kubernetes
+   options:
+     alternative_names:
+     - xxx.xxx.xxx.xxx
+     - 10.100.200.1
+     - localhost
+     - kubernetes
+     - kubernetes.default
+     - kubernetes.default.svc
+     - kubernetes.default.svc.cluster.local
+     - master.cfcr.internal
+     ca: kubo_ca
+     common_name: master.cfcr.internal
+     organization: system:masters
+   type: certificate
+ - name: service-account-key
+   type: rsa
+ - name: tls-kube-controller-manager
+   options:
+     alternative_names:
+     - localhost
+     - 127.0.0.1
+     ca: kubo_ca
+     common_name: kube-controller-manager
+     extended_key_usage:
+     - server_auth
+     key_usage:
+     - digital_signature
+     - key_encipherment
+   type: certificate
+ - name: etcd_ca
+   options:
+     common_name: etcd.ca
+     is_ca: true
+   type: certificate
+ - name: tls-etcd-v0-29-0
+   options:
+     ca: etcd_ca
+     common_name: "*.etcd.cfcr.internal"
+     extended_key_usage:
+     - client_auth
+     - server_auth
+   type: certificate
+ - name: tls-etcdctl-v0-29-0
+   options:
+     ca: etcd_ca
+     common_name: etcdClient
+     extended_key_usage:
+     - client_auth
+   type: certificate
+ - name: tls-etcdctl-root
+   options:
+     ca: etcd_ca
+     common_name: root
+     extended_key_usage:
+     - client_auth
+   type: certificate
+ - name: tls-etcdctl-flanneld
+   options:
+     ca: etcd_ca
+     common_name: flanneld
+     extended_key_usage:
+     - client_auth
+   type: certificate
+ - name: tls-metrics-server
+   options:
+     alternative_names:
+     - metrics-server.kube-system.svc
+     ca: kubo_ca
+     common_name: metrics-server
+   type: certificate
+ - name: kubernetes-dashboard-ca
+   options:
+     common_name: ca
+     is_ca: true
+   type: certificate
+ - name: tls-kubernetes-dashboard
+   options:
+     alternative_names: []
+     ca: kubernetes-dashboard-ca
+     common_name: kubernetesdashboard.n
+   type: certificate

+ features:
+   use_dns_addresses: true

+ instance_groups:
+ - azs:
+   - z7
+   instances: 1
+   jobs:
+   - consumes:
+       cloud-provider:
+         from: master-cloud-provider
+     name: apply-specs
+     properties:
+       addons:
+       - coredns
+       - metrics-server
+       - kubernetes-dashboard
+       admin-password: "((kubo-admin-password))"
+       admin-username: admin
+       api-token: "((kubelet-password))"
+       tls:
+         kubernetes: "((tls-kubernetes))"
+         kubernetes-dashboard: "((tls-kubernetes-dashboard))"
+         metrics-server: "((tls-metrics-server))"
+     release: kubo
+   lifecycle: errand
+   name: apply-addons
+   networks:
+   - name: default
+   stemcell: xenial
+   vm_type: small
+ - azs:
+   - z7
+   instances: 1
+   jobs:
+   - name: docker
+     properties:
+       bridge: cni0
+       default_ulimits:
+       - nofile=1048576
+       env: {}
+       flannel: true
+       ip_masq: false
+       iptables: false
+       live_restore: true
+       log_level: error
+       log_options:
+       - max-size=128m
+       - max-file=2
+       storage_driver: overlay2
+       store_dir: "/var/vcap/data"
+     release: docker
+   - name: docker-images
+     release: paasta-container-service-projects-release
+   - name: bpm
+     release: bpm
+   - name: flanneld
+     properties:
+       tls:
+         etcdctl:
+           ca: "((tls-etcdctl-flanneld.ca))"
+           certificate: "((tls-etcdctl-flanneld.certificate))"
+           private_key: "((tls-etcdctl-flanneld.private_key))"
+     release: kubo
+   - name: kube-proxy
+     properties:
+       api-token: "((kube-proxy-password))"
+       kube-proxy-configuration:
+         apiVersion: kubeproxy.config.k8s.io/v1alpha1
+         clientConnection:
+           kubeconfig: "/var/vcap/jobs/kube-proxy/config/kubeconfig"
+         clusterCIDR: 10.200.0.0/16
+         iptables:
+           masqueradeAll: false
+           masqueradeBit: 14
+           minSyncPeriod: 0s
+           syncPeriod: 30s
+         kind: KubeProxyConfiguration
+         mode: iptables
+         portRange: ''
+       tls:
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - consumes:
+       cloud-provider:
+         from: master-cloud-provider
+     name: kube-apiserver
+     properties:
+       admin-password: "((kubo-admin-password))"
+       admin-username: admin
+       audit-policy:
+         apiVersion: audit.k8s.io/v1beta1
+         kind: Policy
+         rules:
+         - level: None
+           resources:
+           - group: ''
+             resources:
+             - endpoints
+             - services
+             - services/status
+           users:
+           - system:kube-proxy
+           verbs:
+           - watch
+         - level: None
+           resources:
+           - group: ''
+             resources:
+             - nodes
+             - nodes/status
+           users:
+           - kubelet
+           verbs:
+           - get
+         - level: None
+           resources:
+           - group: ''
+             resources:
+             - nodes
+             - nodes/status
+           userGroups:
+           - system:nodes
+           verbs:
+           - get
+         - level: None
+           namespaces:
+           - kube-system
+           resources:
+           - group: ''
+             resources:
+             - endpoints
+           users:
+           - system:kube-controller-manager
+           - system:kube-scheduler
+           - system:serviceaccount:kube-system:endpoint-controller
+           verbs:
+           - get
+           - update
+         - level: None
+           resources:
+           - group: ''
+             resources:
+             - namespaces
+             - namespaces/status
+             - namespaces/finalize
+           users:
+           - system:apiserver
+           verbs:
+           - get
+         - level: None
+           resources:
+           - group: metrics.k8s.io
+           users:
+           - system:kube-controller-manager
+           verbs:
+           - get
+           - list
+         - level: None
+           nonResourceURLs:
+           - "/healthz*"
+           - "/version"
+           - "/swagger*"
+         - level: None
+           resources:
+           - group: ''
+             resources:
+             - events
+         - level: Request
+           omitStages:
+           - RequestReceived
+           resources:
+           - group: ''
+             resources:
+             - nodes/status
+             - pods/status
+           userGroups:
+           - system:nodes
+           verbs:
+           - update
+           - patch
+         - level: Request
+           omitStages:
+           - RequestReceived
+           users:
+           - system:serviceaccount:kube-system:namespace-controller
+           verbs:
+           - deletecollection
+         - level: Metadata
+           omitStages:
+           - RequestReceived
+           resources:
+           - group: ''
+             resources:
+             - secrets
+             - configmaps
+           - group: authentication.k8s.io
+             resources:
+             - tokenreviews
+         - level: Request
+           omitStages:
+           - RequestReceived
+           resources:
+           - group: ''
+           - group: admissionregistration.k8s.io
+           - group: apiextensions.k8s.io
+           - group: apiregistration.k8s.io
+           - group: apps
+           - group: authentication.k8s.io
+           - group: authorization.k8s.io
+           - group: autoscaling
+           - group: batch
+           - group: certificates.k8s.io
+           - group: extensions
+           - group: metrics.k8s.io
+           - group: networking.k8s.io
+           - group: policy
+           - group: rbac.authorization.k8s.io
+           - group: settings.k8s.io
+           - group: storage.k8s.io
+           verbs:
+           - get
+           - list
+           - watch
+         - level: RequestResponse
+           omitStages:
+           - RequestReceived
+           resources:
+           - group: ''
+           - group: admissionregistration.k8s.io
+           - group: apiextensions.k8s.io
+           - group: apiregistration.k8s.io
+           - group: apps
+           - group: authentication.k8s.io
+           - group: authorization.k8s.io
+           - group: autoscaling
+           - group: batch
+           - group: certificates.k8s.io
+           - group: extensions
+           - group: metrics.k8s.io
+           - group: networking.k8s.io
+           - group: policy
+           - group: rbac.authorization.k8s.io
+           - group: settings.k8s.io
+           - group: storage.k8s.io
+         - level: Metadata
+           omitStages:
+           - RequestReceived
+       k8s-args:
+         audit-log-maxage: 0
+         audit-log-maxbackup: 7
+         audit-log-maxsize: 49
+         audit-log-path: "/var/vcap/sys/log/kube-apiserver/audit.log"
+         audit-policy-file: "/var/vcap/jobs/kube-apiserver/config/audit_policy.yml"
+         authorization-mode: RBAC
+         client-ca-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes-ca.pem"
+         disable-admission-plugins: []
+         enable-admission-plugins: []
+         enable-aggregator-routing: true
+         enable-bootstrap-token-auth: true
+         enable-swagger-ui: true
+         etcd-cafile: "/var/vcap/jobs/kube-apiserver/config/etcd-ca.crt"
+         etcd-certfile: "/var/vcap/jobs/kube-apiserver/config/etcd-client.crt"
+         etcd-keyfile: "/var/vcap/jobs/kube-apiserver/config/etcd-client.key"
+         kubelet-client-certificate: "/var/vcap/jobs/kube-apiserver/config/kubelet-client-cert.pem"
+         kubelet-client-key: "/var/vcap/jobs/kube-apiserver/config/kubelet-client-key.pem"
+         proxy-client-cert-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes.pem"
+         proxy-client-key-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes-key.pem"
+         requestheader-allowed-names: aggregator
+         requestheader-client-ca-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes-ca.pem"
+         requestheader-extra-headers-prefix: X-Remote-Extra-
+         requestheader-group-headers: X-Remote-Group
+         requestheader-username-headers: X-Remote-User
+         runtime-config: api/v1
+         secure-port: 8443
+         service-account-key-file: "/var/vcap/jobs/kube-apiserver/config/service-account-public-key.pem"
+         service-cluster-ip-range: 10.100.200.0/24
+         storage-media-type: application/json
+         tls-cert-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes.pem"
+         tls-private-key-file: "/var/vcap/jobs/kube-apiserver/config/kubernetes-key.pem"
+         token-auth-file: "/var/vcap/jobs/kube-apiserver/config/tokens.csv"
+         v: 2
+       kube-controller-manager-password: "((kube-controller-manager-password))"
+       kube-proxy-password: "((kube-proxy-password))"
+       kube-scheduler-password: "((kube-scheduler-password))"
+       kubelet-drain-password: "((kubelet-drain-password))"
+       kubelet-password: "((kubelet-password))"
+       service-account-public-key: "((service-account-key.public_key))"
+       tls:
+         kubelet-client: "((tls-kubelet-client))"
+         kubernetes:
+           ca: "((tls-kubernetes.ca))"
+           certificate: "((tls-kubernetes.certificate))((tls-kubernetes.ca))"
+           private_key: "((tls-kubernetes.private_key))"
+     release: kubo
+   - consumes:
+       cloud-provider:
+         from: master-cloud-provider
+     name: kube-controller-manager
+     properties:
+       api-token: "((kube-controller-manager-password))"
+       cluster-signing: "((kubo_ca))"
+       k8s-args:
+         cluster-signing-cert-file: "/var/vcap/jobs/kube-controller-manager/config/cluster-signing-ca.pem"
+         cluster-signing-key-file: "/var/vcap/jobs/kube-controller-manager/config/cluster-signing-key.pem"
+         kubeconfig: "/var/vcap/jobs/kube-controller-manager/config/kubeconfig"
+         root-ca-file: "/var/vcap/jobs/kube-controller-manager/config/ca.pem"
+         service-account-private-key-file: "/var/vcap/jobs/kube-controller-manager/config/service-account-private-key.pem"
+         terminated-pod-gc-threshold: 100
+         tls-cert-file: "/var/vcap/jobs/kube-controller-manager/config/kube-controller-manager-cert.pem"
+         tls-private-key-file: "/var/vcap/jobs/kube-controller-manager/config/kube-controller-manager-private-key.pem"
+         use-service-account-credentials: true
+         v: 2
+       service-account-private-key: "((service-account-key.private_key))"
+       tls:
+         kube-controller-manager: "((tls-kube-controller-manager))"
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - name: kube-scheduler
+     properties:
+       api-token: "((kube-scheduler-password))"
+       kube-scheduler-configuration:
+         apiVersion: kubescheduler.config.k8s.io/v1alpha1
+         clientConnection:
+           kubeconfig: "/var/vcap/jobs/kube-scheduler/config/kubeconfig"
+         disablePreemption: false
+         kind: KubeSchedulerConfiguration
+       tls:
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - consumes:
+       cloud-provider:
+         from: master-cloud-provider
+     name: kubernetes-roles
+     properties:
+       admin-password: "((kubo-admin-password))"
+       admin-username: admin
+       tls:
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - name: etcd
+     properties:
+       etcd:
+         dns_suffix: etcd.cfcr.internal
+       tls:
+         etcd:
+           ca: "((etcd_ca.certificate))"
+           certificate: "((tls-etcd-v0-29-0.certificate))"
+           private_key: "((tls-etcd-v0-29-0.private_key))"
+         etcdctl:
+           ca: "((tls-etcdctl-v0-29-0.ca))"
+           certificate: "((tls-etcdctl-v0-29-0.certificate))"
+           private_key: "((tls-etcdctl-v0-29-0.private_key))"
+         etcdctl-root:
+           ca: "((tls-etcdctl-v0-29-0.ca))"
+           certificate: "((tls-etcdctl-root.certificate))"
+           private_key: "((tls-etcdctl-root.private_key))"
+         peer:
+           ca: "((tls-etcd-v0-29-0.ca))"
+           certificate: "((tls-etcd-v0-29-0.certificate))"
+           private_key: "((tls-etcd-v0-29-0.private_key))"
+       users:
+       - name: root
+         password: "((etcd_user_root_password))"
+         versions:
+         - v2
+       - name: flanneld
+         password: "((etcd_user_flanneld_password))"
+         permissions:
+           read:
+           - "/coreos.com/network/*"
+           write:
+           - "/coreos.com/network/*"
+         versions:
+         - v2
+     release: cfcr-etcd
+   - name: prometheus
+     release: kubo
+   - name: smoke-tests
+     release: kubo
+   - name: cloud-provider
+     properties:
+       cloud-config:
+         Global:
+           auth-url: http://172.31.30.11:5000/v3/
+           domain-name: default
+           password: crossent1234
+           region: RegionOne
+           tenant-id: d6afa09b629d484db8520d2a33d7a432
+           username: paasta
+       cloud-provider:
+         type: openstack
+     provides:
+       cloud-provider:
+         as: master-cloud-provider
+     release: kubo
+   name: master
+   networks:
+   - default:
+     - dns
+     - gateway
+     name: default
+   - name: vip
+     static_ips: xxx.xxx.xxx.xxx
+   persistent_disk: 51200
+   stemcell: xenial
+   vm_type: small
+ - azs:
+   - z5
+   - z6
+   - z7
+   instances: 3
+   jobs:
+   - name: flanneld
+     properties:
+       tls:
+         etcdctl:
+           ca: "((tls-etcdctl-flanneld.ca))"
+           certificate: "((tls-etcdctl-flanneld.certificate))"
+           private_key: "((tls-etcdctl-flanneld.private_key))"
+     release: kubo
+   - name: docker
+     properties:
+       bridge: cni0
+       default_ulimits:
+       - nofile=1048576
+       env: {}
+       flannel: true
+       ip_masq: false
+       iptables: false
+       live_restore: true
+       log_level: error
+       log_options:
+       - max-size=128m
+       - max-file=2
+       storage_driver: overlay2
+     release: docker
+   - name: docker-repository-setting
+     properties:
+       caas_master_public_url: xxx.xxx.xxx.xxx
+     release: paasta-container-service-projects-release
+   - name: kubernetes-dependencies
+     release: kubo
+   - consumes:
+       cloud-provider:
+         from: worker-cloud-provider
+     name: kubelet
+     properties:
+       api-token: "((kubelet-password))"
+       cloud-provider: openstack
+       drain-api-token: "((kubelet-drain-password))"
+       k8s-args:
+         cni-bin-dir: "/var/vcap/jobs/kubelet/packages/cni/bin"
+         container-runtime: docker
+         docker: unix:///var/vcap/sys/run/docker/docker.sock
+         docker-endpoint: unix:///var/vcap/sys/run/docker/docker.sock
+         kubeconfig: "/var/vcap/jobs/kubelet/config/kubeconfig"
+         network-plugin: cni
+         root-dir: "/var/vcap/data/kubelet"
+       kubelet-configuration:
+         apiVersion: kubelet.config.k8s.io/v1beta1
+         authentication:
+           anonymous:
+             enabled: true
+           x509:
+             clientCAFile: "/var/vcap/jobs/kubelet/config/kubelet-client-ca.pem"
+         authorization:
+           mode: Webhook
+         clusterDNS:
+         - 169.254.0.2
+         clusterDomain: cluster.local
+         failSwapOn: false
+         kind: KubeletConfiguration
+         serializeImagePulls: false
+         tlsCertFile: "/var/vcap/jobs/kubelet/config/kubelet.pem"
+         tlsPrivateKeyFile: "/var/vcap/jobs/kubelet/config/kubelet-key.pem"
+       tls:
+         kubelet:
+           ca: "((tls-kubelet.ca))"
+           certificate: "((tls-kubelet.certificate))((tls-kubelet.ca))"
+           private_key: "((tls-kubelet.private_key))"
+         kubelet-client-ca:
+           certificate: "((tls-kubelet-client.ca))"
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - name: kube-proxy
+     properties:
+       api-token: "((kube-proxy-password))"
+       cloud-provider: openstack
+       kube-proxy-configuration:
+         apiVersion: kubeproxy.config.k8s.io/v1alpha1
+         clientConnection:
+           kubeconfig: "/var/vcap/jobs/kube-proxy/config/kubeconfig"
+         clusterCIDR: 10.200.0.0/16
+         iptables:
+           masqueradeAll: false
+           masqueradeBit: 14
+           minSyncPeriod: 0s
+           syncPeriod: 30s
+         kind: KubeProxyConfiguration
+         mode: iptables
+         portRange: ''
+       tls:
+         kubernetes: "((tls-kubernetes))"
+     release: kubo
+   - name: cloud-provider
+     properties:
+       cloud-config:
+         Global:
+           auth-url: http://172.31.30.11:5000/v3/
+           domain-name: default
+           password: crossent1234
+           region: RegionOne
+           tenant-id: d6afa09b629d484db8520d2a33d7a432
+           username: paasta
+       cloud-provider:
+         type: openstack
+     provides:
+       cloud-provider:
+         as: worker-cloud-provider
+     release: kubo
+   name: worker
+   networks:
+   - name: default
+   persistent_disk_type: 100GB
+   stemcell: xenial
+   vm_type: small-highmem-16GB
+ - azs:
+   - z7
+   instances: 1
+   jobs:
+   - name: haproxy
+     properties:
+       http_port: 8080
+       public_ip: xxx.xxx.xxx.xxx
+     release: paasta-container-service-projects-release
+   name: haproxy
+   networks:
+   - name: vip
+     static_ips: xxx.xxx.xxx.xxx
+   - default:
+     - dns
+     - gateway
+     name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: mariadb
+     properties:
+       admin_user:
+         id: root
+         password: Paasta@2019
+       port: '3306'
+       role_set:
+         administrator_code: RS0001
+         administrator_code_name: Administrator
+         init_user_code: RS0003
+         init_user_code_name: Init User
+         regular_user_code: RS0002
+         regular_user_code_name: Regular User
+     release: paasta-container-service-projects-release
+   name: mariadb
+   networks:
+   - name: default
+   persistent_disk_type: 10GB
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z6
+   instances: 1
+   jobs:
+   - name: container-service-dashboard
+     properties:
+       cf:
+         api:
+           url: https://api.xxx.xxx.xxx.xxx.xip.io
+         uaa:
+           oauth:
+             authorization:
+               uri: https://uaa.xxx.xxx.xxx.xxx.xip.io/oauth/authorize
+             client:
+               id: caasclient
+               secret: clientsecret
+             info:
+               uri: https://uaa.xxx.xxx.xxx.xxx.xip.io/userinfo
+             logout:
+               url: https://uaa.xxx.xxx.xxx.xxx.xip.io/logout
+             token:
+               access:
+                 uri: https://uaa.xxx.xxx.xxx.xxx.xip.io/oauth/token
+               check:
+                 uri: https://uaa.xxx.xxx.xxx.xxx.xip.io/check_token
+       java_opts: "-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K
+         -Xmx681574K"
+       logging:
+         file: logs/application.log
+         level:
+           ROOT: INFO
+         path: classpath:logback-spring.xml
+       management:
+         security:
+           enabled: false
+       private:
+         registry:
+           url: xxx.xxx.xxx.xxx
+       server:
+         port: 8091
+       spring:
+         freemarker:
+           template-loader-path: classpath:/templates/
+     release: paasta-container-service-projects-release
+   name: container-service-dashboard
+   networks:
+   - name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z7
+   instances: 1
+   jobs:
+   - name: container-service-api
+     properties:
+       authorization:
+         id: admin
+         password: PaaS-TA
+       java_opts: "-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K
+         -Xmx681574K"
+       logging:
+         file: logs/application.log
+         level:
+           ROOT: INFO
+         path: classpath:logback-spring.xml
+       management:
+         security:
+           enabled: false
+       server:
+         port: 3333
+     release: paasta-container-service-projects-release
+   name: container-service-api
+   networks:
+   - name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: container-service-common-api
+     properties:
+       authorization:
+         id: admin
+         password: PaaS-TA
+       java_opts: "-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K
+         -Xmx681574K"
+       logging:
+         file: logs/application.log
+         level:
+           ROOT: INFO
+         path: classpath:logback-spring.xml
+       server:
+         port: 3334
+       spring:
+         datasource:
+           driver_class_name: com.mysql.cj.jdbc.Driver
+           password: Paasta@2019
+           username: root
+           validationQuery: SELECT 1
+         jpa:
+           database: mysql
+           generate-ddl: false
+           hibernate:
+             ddl-auto: none
+             naming:
+               strategy: org.hibernate.cfg.EJB3NamingStrategy
+           properties:
+             hibernate:
+               dialect: org.hibernate.dialect.MySQLInnoDBDialect
+               format_sql: true
+               show_sql: true
+               use_sql_comments: true
+     release: paasta-container-service-projects-release
+   name: container-service-common-api
+   networks:
+   - name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z6
+   instances: 1
+   jobs:
+   - name: container-service-broker
+     properties:
+       auth:
+         id: admin
+         password: cloudfoundry
+       caas:
+         api_server_url: https://xxx.xxx.xxx.xxx:8443
+         cluster_name: micro-bosh/paasta-container-service
+         exit_code: caas_exit
+         init_command: "/var/vcap/jobs/container-service-broker/script/set_caas_service_info.sh"
+         service_broker_auth_secret: YWRtaW46Y2xvdWRmb3VuZHJ5
+       credhub:
+         admin_client_secret: lowazgvly850yflgzwe9
+         server_url: 10.0.1.6:8844
+       dashboard:
+         url: http://xxx.xxx.xxx.xxx:8091/caas/intro/overview/
+       datasource:
+         driver_class_name: com.mysql.jdbc.Driver
+         password: Paasta@2019
+         username: root
+       freemarker:
+         template-loader-path: classpath:/templates/
+       java_opts: "-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K
+         -Xmx681574K"
+       jpa:
+         database_platform: org.hibernate.dialect.MySQL5InnoDBDialect
+         hibernate_ddl_auto: none
+         show_sql: true
+       logging:
+         config: classpath:logback.xml
+         level:
+           org:
+             hibernate: info
+             openpaas:
+               servicebroker: INFO
+       server:
+         port: '8888'
+       serviceDefinition:
+         bindable: false
+         desc: For Container Service Plans, You can choose plan about CPU, Memory,
+           disk.
+         id: 8a3f2d14-5283-487f-b6c8-6663639ad8b1_test
+         image_url: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAC/VBMVEVHcEwxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQxbOQ1/RrDAAAA/nRSTlMAA/wI/SAC/gHfBvoEBwsJ6BD3GPUK+QXt7vMS4fIT+A3wFOQl+93sGhUb8Tnr6sX2Dir0g+Dm2+fXDBa23JQXuxEPzx8dVrpH4lfl7zJEOhnpn4U7LrBOPL50YCMiuVK8lSlz2SthQSHQhEtYzdNcLBzakzE2aItmUcs1ddWnZMnAzI6btDDISFuzx5jewkZpnj8mcnder5FMSTNwscrBkHldZVmteIpCgJmX2D0tvXtKbB4+KHrWX2tqOGNnRaFTrpZ2pCdAT5Krqay/N39Qgm6dL+MkjMajflR9Q4nRjW3UNKCBhs5N0pxiqrhVpqK3xJqycaiHiLV8WqWPbxxkzEYAAAs9SURBVHjaxZl1XBvJF8BfhOySA0IIwYMX9+LuFIdSoDgUSt3d26u7u/u1V3e59tzd3d397qf5/DKTTbKbzECg7ef3/YvNvJk3b57NLtBH5KrmFpUc7iXqafEvJE0++8ocBdwrUk9PCRqg1TEg6JmhqXAPYHMrlhSLtRxir98+iGXvtgrPMU8kSrU8pInvjMlh76aK0Eeej2K0ZjBRzz4SerfUyKpWrnJjtAQYt1UrVTK4c0QFC7L9sAqiGr+ihyaJ4M6wG3lhnYe2Rzz2Xx9pB/3H9cnGhc7aXnFe3rjZFfqH/cT385y0VuGU98+J9tB3JOU181y0VuMyr6Zc0tf6EbF48n3aPnHf5MURDmA9vpsesx2gJaPZv19DGRpg+9gmXyszT7l+Y4CYevo1ISE1VE+JAwYPUrK9q/Cu/8lRqqViGwcw3JY+LnWcX+/dsxpZWuGjkYy2B1IKAApSepJgIrcXpsnoKkK2pbtjFXS84gCGefUsw7inXwuhqHEobA/nVNAJvg1wO7I3KSa8vdCBqKPR0aiCjschgEMevcsxjo0ELbISR6uy4b8Ae6zKIMdCyxNTtTPWTJUeBDgotUaSaVeBOYMitdbg0Q3w0ECrRCPXW5zW1gFWGbIoH8BmkdSqk32cBSGp7/Rqviao6LFzK+QA8l3vL3nBa2Cvx/uwuesnfdXzhIEfZR6J85dwe2MVacu6N57qpRHcHwZChjoKwjxSEEBMWfqCZvNCzjoM32PWNX2qy/jmJQ8BIdN5u2Jmr6yYUc3rfEVH0mTk/j99tY9JLjH+9I/LeVpibpl1wUyGt+hMGaTeMGiRJj0+iVqKRIFfBhhmlj6kBtktZ95mpwi7ZdoifphuYwEc5gbrW94PT8mN3TJrmArn1JNpxsNT10fr47L6ggKAFYR3Qyjwed2L74JVgSyAb2MUUrikhXO24nLTg9Fdh0DHhFPrMicEcnpkZ55zQg541QFAFtfK8KtpLfAZqxE07NbzvgCpt+aVuf+VxjXLEZkpuqD1mICVeGgZj/FvDVEDgi1YownOu6Z7ULYtEmSbZqzgejVamF5McsfrdiCfOKs7BxCuc04GYAm/NvQ4yw+3wYT/1NoBQrVhV6CrTmiwWS+SjhaBCeVei36ddy0VgNV73PP6VTFX6Qeh5/XBnNBXTbH6I2MBcqfPs2jadUow8eYprQVR110Bw9p0+BlL61DQMcSYVMHHQ0CPvNON0EebwcQugoA2+k3AeL5myoXSqaBjWakpF56JBcyw2YQl3FbwkncuqUNE7eTCqmm82Bgvm0HHZmMsiseVcLlQ6E6qkXNZU1N8mFRwnw01hMW07w3Rn5QPOvInc4/hPy8zuLZqKdNzjQy7nzCeOIg1Wqo6lqBfYlQYlh/F1YI9/mCUeTqq5xo5JJlgyOex+E1Rrs/1FWddsJ+y0FPWr/ielz5CPyjHbsn5k2BKciUYmBlD6Gtj0Ij/jm59xsmaF6PWme6JQyEdpdKXF/Wmpk6foUT7aSN4JeawsTo+Q9hDayiaONY9eUssl/MTxt3n/K4cTzgx0Gf1e9xx51yJiqpH6lQvEDrdDkONDG0gvArMFaEtb2e07vHcwYtqG6erAKNacOGyiPtzhp+W+XcuGj9HiNGzhug5k2A5WBqBRh5AWafJnGRwLgtmsDbfotr+Bpa+RLhUJZwBPSXhloP7kYdd48XYw08EskCEjXvWB+fDFWRXVbTWgvBC7hjiCZePTHvk9mwup5YuI7Yt2bQiruou9UQhuIYQpK/oj1X5KMElr6KRWkNmi9cNJWgRfbDasL2gYciuLQSnPKoERAvhTaDsZa6kc0jfnsjVmMrz5ysVgCkfZ4xKd1yCHvEj1MgW/d0xmHCRxZ581cXU97/TV5h/Bbm5ZRyx06eXk+meckNQnTH85sB2EowsxuZ/YdwpEzQCy16ahx7GD8WB8NRkqXH8JfRLXDGhRnaiEYfBpLe2kWjbMziPBI9bc16CD+tBvKy0Q4FzsuLA6mpuhzOQcSNJ73mDUdKG7CMpsTEoifFKf2nFRc4LdjV6JfEirlaEjDi2PcNDZ/Bi1OFsSEr2obYWkUgY8QpEEfqF26jXZk715jXqIxoc/CW8MFYO39axLwp38+YEUjVH7l0QQxgp3Q065oyxUQvTcHO2M7pRBoIASVjFZ7hjBhCWilkAYH+AIdS1hEtARGRzo6FhQ74IiFQGkdY6YA9Z7YRU7FqgBAqirCwRUPDddtXJUk17FpQLnOVsuzD7zx1/VMqFN+Wcgjn1L0pAgMOmwtMt/grBccp33/pr495FXR6CICqHbn51fKMzrsrfV86aZiknlbd1Tlk1PtE9aKxMULeaisOru7KXnFtZaeMtYU2WqpWhb97gR0B4N0zh3cjEb+l3y6p99Qva1NSNKvXjUuFBgSmKJdwcD8eU1gOX8TRRDjfP/m/eqtJMiOZn51YZABs79fprP52LQJu7uJw3eFAk8M1WF9PYRzjcbsbvnT/3JvqOKzvIvxNHg6Axv71JtfnQfFsn3QZxoroe8zEd7RwuL5T63ZYHmfSPtjeUA5eA7TOHh60XJHgZCHqJuPjtLo0+PjLwXfFJ42WJ+TwV63jg6NEHsBaHb42BNO910DE8xRA8ecnC79TgRvve964rqiMbNIZi3oadm9/AMPtHAqI+2BCSj8uR6Fwf2vcYKGIoQ6Pi8CVjPufChipcvLboMt5pK9IPWUXcRn/HN7jmhVoyzA/wHdWU0Sia2PLZDG4YW7Db4/LQw/hafHKfOOE1PsWFX37QiWZIE3ifpH2OWbsJTRbtTEJaUnBnlNS4YEcfV+CL/Ke49YzFLezFFNqHiTXeAIFFUvKodHsIoAgryWC00il42YgMLtJOY5WLdUcZcBinj/8TYsoqrSi82aHjKW5xPuGAs/7pPGn1elybTnIriTfmoucRyUzXIQnW16mhOOSbISx25thE2ierJjnOu5t1z3mj7ewyClZ/jabmzM+ucMUSbbQvhqUldoBRH9NQRDJexiJsyDCUGt7Pm3r+3jT0+0QbVp8831AOI3yrAji8T7pQjL36tKupJK7kVQe/Jpmpwjw1W0qJUOR0A82/UKSYyRPUwKF+pdjw+YlxDjjuABzynXm00ElvARNsxChaTiZeSWM5Szx3X4vfWNfaWjd4dPc0f4MludMzKHOZvAhWUFN/DKB+EJz/oiu/W3h7K9Ui0w9xHW60mW+8JwIBikY/mqx49hmgEthA/bTq1ykBMzw7fGjSXsOBSlwCbZZPpidYMHKplFZfdEpiS25X2QMP19DKtlyAy0mUSdJVNmAJO20cQxYfHAuqGseo6CmHRwSGhHp6+qtahmz7MLvU8e8qSP1NTHb6uGksEBDNKibKB10Cuz0D0cSYqLX3n/3H0uyFGY4DkdnOW+ygkmyK1ywREJH8UUYQd3pJAlXrtER+DQP7K6QbaNkeCVDI2WHpfOaXiwA7KWHq/jLApN+llk7foQQq+XUWJ5y8iwX5W7SUPmAPbIVFionr8oEO+9lsc+fv9QQIidZSWFgAoHze3Ph9u1noAVG9edz/nArsLGpSl5Wwlm9Rtl+LoEfsP3EXzjhV4bk7m/4P5kU3/Qd1mTnqgj30Qu7HTsJjD0q/OkBLRZzUniAVRuPHudArBUfF2jtAfLQAeoedupzpvw5m+VQWrEA2Zm3/lawdIwOrkG9w668Otw1ysJLYD2P6pyPmeCxYTdhz4n45/fswsB62Nprph9Oja1noA7JBSX1XkrRCBn1CfjiyrzoiZ8qhj/jGa/qmQxPvC33G+0SA1HoV0oAT/tAP1Lc7FgbZWkXG6swKNfQPhSrfxiryVQr4f/M/qiJl37zLCR8AAAAASUVORK5CYII=
+         name: container-service
+         plan1:
+           cpu: 2
+           desc: 2 CPUs, 2GB Memory (free)
+           disk: 10GB
+           id: f02690d6-6965-4756-820e-3858111ed674test
+           memory: 2GB
+           name: Micro
+           type: A
+           weight: 1
+         plan2:
+           cpu: 4
+           desc: 4 CPUs, 6GB Memory (free)
+           disk: 20GB
+           id: a5213929-885f-414a-801f-c66ddb5e48f1test
+           memory: 6GB
+           name: Small
+           type: B
+           weight: 2
+         plan3:
+           cpu: 8
+           desc: 8 CPUs, 12GB Memory (free)
+           disk: 40GB
+           id: 056d05b6-4039-40ec-8619-e68490b79255test
+           memory: 12GB
+           name: Advanced
+           type: C
+           weight: 3
+         planupdatable: 'true'
+         tags: Container Service,Containers as a Service
+     release: paasta-container-service-projects-release
+   name: container-service-broker
+   networks:
+   - name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z2
+   instances: 1
+   jobs:
+   - name: container-jenkins-broker
+     properties:
+       caas:
+         master_ip: xxx.xxx.xxx.xxx
+         repository:
+           ip: xxx.xxx.xxx.xxx
+           port: 5000
+       datasource:
+         password: Paasta@2019
+         username: root
+       jenkins:
+         namespace: paasta-jenkins
+         namespace_file_path: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"
+         secret_file_path: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
+         serviceDefinition:
+           bullet:
+             desc: 100
+             name: 100
+           desc: Installing Jenkins in Docker in a Container 50GB
+           id: 0ef99f90-0077-11ea-aaef-0800200c9a66
+           name: jenkins_20GB
+           plan1:
+             desc: Installing Jenkins in Docker in a Container
+             id: 1653cb80-0077-11ea-aaef-0800200c9a66
+             name: container-jenkins-service
+             type: A
+       jpa:
+         hibernate_ddl_auto: none
+         show_sql: true
+       logging:
+         file: logs/application.log
+         level:
+           ROOT: INFO
+         path: classpath:logback-spring.xml
+       server:
+         port: 8787
+     release: paasta-container-service-projects-release
+   name: container-jenkins-broker
+   networks:
+   - name: default
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small
+ - azs:
+   - z7
+   instances: 1
+   jobs:
+   - instances: 1
+     name: private-image-repository
+     properties:
+       image_repository:
+         auth:
+           enabled: true
+           username: admin
+         http:
+           http2_disabled: false
+         port: 5000
+         storage:
+           delete_enabled: true
+           filesystem:
+             rootdirectory: "/var/vcap/data/private-image-repository"
+     release: paasta-container-service-projects-release
+   name: private-image-repository
+   networks:
+   - default:
+     - dns
+     - gateway
+     name: default
+   - name: vip
+     static_ips: xxx.xxx.xxx.xxx
+   persistent_disk_type: 10GB
+   stemcell: xenial
+   update:
+     max_in_flight: 1
+     serial: true
+   vm_type: small

+ name: paasta-container-service

Task 695

Task 695 | 09:06:02 | Preparing deployment: Preparing deployment (00:00:14)
Task 695 | 09:06:16 | Preparing deployment: Rendering templates (00:00:07)
Task 695 | 09:06:23 | Preparing package compilation: Finding packages to compile (00:00:01)
Task 695 | 09:06:24 | Creating missing vms: master/5e48f5f0-11ed-490f-b70f-88242ac4b882 (0)
Task 695 | 09:06:24 | Creating missing vms: worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b (1)
Task 695 | 09:06:24 | Creating missing vms: mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb (0)
Task 695 | 09:06:24 | Creating missing vms: worker/81477953-c9d3-4ad5-b499-25fdab86f9f9 (2)
Task 695 | 09:06:24 | Creating missing vms: worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1 (0)
Task 695 | 09:06:24 | Creating missing vms: container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21 (0)
Task 695 | 09:06:24 | Creating missing vms: haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2 (0)
Task 695 | 09:06:24 | Creating missing vms: container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8 (0)
Task 695 | 09:06:24 | Creating missing vms: private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad (0)
Task 695 | 09:06:24 | Creating missing vms: container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249 (0)
Task 695 | 09:06:24 | Creating missing vms: container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf (0)
Task 695 | 09:06:24 | Creating missing vms: container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37 (0) (00:04:37)
Task 695 | 09:11:45 | Creating missing vms: master/5e48f5f0-11ed-490f-b70f-88242ac4b882 (0) (00:05:21)
Task 695 | 09:12:02 | Creating missing vms: worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1 (0) (00:05:38)
Task 695 | 09:12:02 | Creating missing vms: mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb (0) (00:05:38)
Task 695 | 09:12:13 | Creating missing vms: container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21 (0) (00:05:49)
Task 695 | 09:12:13 | Creating missing vms: haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2 (0) (00:05:49)
Task 695 | 09:12:20 | Creating missing vms: container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249 (0) (00:05:56)
Task 695 | 09:12:21 | Creating missing vms: worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b (1) (00:05:57)
Task 695 | 09:12:21 | Creating missing vms: private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad (0) (00:05:57)
Task 695 | 09:12:23 | Creating missing vms: container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8 (0) (00:05:59)
Task 695 | 09:12:23 | Creating missing vms: worker/81477953-c9d3-4ad5-b499-25fdab86f9f9 (2) (00:05:59)
Task 695 | 09:12:25 | Creating missing vms: container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf (0) (00:06:01)
Task 695 | 09:12:29 | Updating instance master: master/5e48f5f0-11ed-490f-b70f-88242ac4b882 (0) (canary) (00:05:20)
Task 695 | 09:17:49 | Updating instance worker: worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1 (0) (canary) (00:05:53)
Task 695 | 09:23:42 | Updating instance worker: worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b (1) (00:05:44)
Task 695 | 09:29:27 | Updating instance worker: worker/81477953-c9d3-4ad5-b499-25fdab86f9f9 (2) (00:04:45)
Task 695 | 09:34:12 | Updating instance haproxy: haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2 (0) (canary) (00:00:27)
Task 695 | 09:34:39 | Updating instance mariadb: mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb (0) (canary) (00:01:52)
Task 695 | 09:36:31 | Updating instance container-service-dashboard: container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37 (0) (canary) (00:00:28)
Task 695 | 09:36:59 | Updating instance container-service-api: container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21 (0) (canary) (00:00:26)
Task 695 | 09:37:25 | Updating instance container-service-common-api: container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf (0) (canary) (00:00:31)
Task 695 | 09:37:56 | Updating instance container-service-broker: container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8 (0) (canary) (00:00:35)
Task 695 | 09:38:31 | Updating instance container-jenkins-broker: container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249 (0) (canary) (00:00:34)
Task 695 | 09:39:05 | Updating instance private-image-repository: private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad (0) (canary) (00:05:00)

Task 695 Started  Fri Nov 22 09:06:02 UTC 2019
Task 695 Finished Fri Nov 22 09:44:05 UTC 2019
Task 695 Duration 00:38:03
Task 695 done

Succeeded

```


- 업로드된 Container 서비스 릴리즈를 확인한다.

```
Name                                       Version    Commit Hash  
binary-buildpack                           1.0.32*    2399a07  
bosh-dns                                   1.12.0*    5d607ed  
bosh-dns-aliases                           0.0.3*     eca9c5a  
bpm                                        1.1.0*     27e1c8f  
~                                          1.0.4*     420dc51  
capi                                       1.83.0*    6b3cd37  
cf-cli                                     1.16.0*    05d9348  
cf-networking                              2.23.0*    eb7f9459  
cf-smoke-tests                             40.0.112*  627f266  
cf-syslog-drain                            10.2*      684147e  
cfcr-etcd                                  1.11.1*    d398cd0  
cflinuxfs3                                 0.113.0*   567e67d  
credhub                                    2.4.0*     7d6110b+  
diego                                      2.34.0*    c91f86b  
docker                                     35.2.1*    0b69b44  
dotnet-core-buildpack                      2.2.12*    668dfe2  
garden-runc                                1.19.3*    a560db3+  
go-buildpack                               1.8.40*    b4dedb6  
haproxy                                    9.6.1*     5754ced  
java-buildpack                             4.19.1*    180acdd  
kubo                                       0.34.1*    non-git  
log-cache                                  2.2.2*     0a03032  
loggregator                                105.5*     d5153da3  
loggregator-agent                          3.9*       d344140  
nats                                       27*        bf8cb86  
nginx-buildpack                            1.0.13*    cf17b33  
nodejs-buildpack                           1.6.51*    7cc80a9  
paasta-container-service-projects-release  2.0*       ced4610+  
~                                          1.0        ced4610+  
paasta-mysql                               2.0*       0a2f21d+  
paasta-portal-api-release                  2.0*       c4da869+  
paasta-portal-ui-release                   2.0*       3d1096b+  
php-buildpack                              4.3.77*    ca96e60  
postgres                                   38*        b4926da  
pxc                                        0.18.0*    acdf39f  
python-buildpack                           1.6.34*    e7b7e15  
r-buildpack                                1.0.10*    a9a0a9f  
routing                                    0.188.0*   db449e4  
ruby-buildpack                             1.7.40*    fa9e7c5  
silk                                       2.23.0*    cdb44d5  
staticfile-buildpack                       1.4.43*    aeef141  
statsd-injector                            1.10.0*    b81ab23  
uaa                                        72.0*      804589c  

(*) Currently deployed
(+) Uncommitted changes

43 releases

Succeeded
```


- 배포된 Container 서비스팩을 확인한다.


```
$ bosh -e micro-bosh -d paasta-container-service vms
Using environment '10.0.1.6' as client 'admin'

Task 706 done

Deployment 'paasta-container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  
container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249      running        z2  10.0.41.135    cc4f197e-4cc4-4b3c-8110-f705d18b38db  small               true  
container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21         running        z7  10.0.0.125     1296c711-6ace-44d0-9105-f2f6f9d08cb2  small               true  
container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8      running        z6  10.0.201.123   c9679528-a3c5-476e-b411-871b89fb9b68  small               true  
container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf  running        z5  10.0.161.123   5b5eea1c-d58d-479c-a0ec-fc5aaa8e1772  small               true  
container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37   running        z6  10.0.201.122   3dc335e0-79cf-482e-b3d8-b44eba531e91  small               true  
haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2                       running        z7  10.0.0.124     c873d1f5-63ba-468d-83a6-8512e8403352  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb                       running        z5  10.0.161.122   212d1137-3439-4178-9f47-543fd0ff60a6  small               true  
master/5e48f5f0-11ed-490f-b70f-88242ac4b882                        running        z7  10.0.0.122     8178c5e9-f054-4d38-bd0c-2bbb4f882534  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad      running        z7  10.0.0.127     c5c43e4a-369e-41f4-9ea8-e6474c5e6fe0  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
worker/81477953-c9d3-4ad5-b499-25fdab86f9f9                        running        z7  10.0.0.123     24304523-a646-4ff9-9b49-8f6ad41da8ce  small-highmem-16GB  true  
worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b                        running        z6  10.0.201.121   b7135d9a-5144-49b7-add1-6291d84c2904  small-highmem-16GB  true  
worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1                        running        z5  10.0.161.121   bcc140f5-2b1f-43bd-b600-bc70450465ee  small-highmem-16GB  true  

12 vms

Succeeded
```


### <div id='24'/> 2.4. Container 서비스 브로커 등록
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


### <div id='25'/> 2.5. Container 서비스 UAA Client Id 등록
UAA 포털 계정 등록 절차에 대한 순서를 확인한다.

- Container 서비스 대시보드에 접근이 가능한 IP를 알기 위해 **haproxy IP** 를 확인한다.

```
$ bosh -e micro-bosh -d paasta-container-service vms
Using environment '10.0.1.6' as client 'admin'

Task 902428. Done

Deployment 'paasta-container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  
container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249      running        z2  10.0.41.135    cc4f197e-4cc4-4b3c-8110-f705d18b38db  small               true  
container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21         running        z7  10.0.0.125     1296c711-6ace-44d0-9105-f2f6f9d08cb2  small               true  
container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8      running        z6  10.0.201.123   c9679528-a3c5-476e-b411-871b89fb9b68  small               true  
container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf  running        z5  10.0.161.123   5b5eea1c-d58d-479c-a0ec-fc5aaa8e1772  small               true  
container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37   running        z6  10.0.201.122   3dc335e0-79cf-482e-b3d8-b44eba531e91  small               true  
haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2                       running        z7  10.0.0.124     c873d1f5-63ba-468d-83a6-8512e8403352  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb                       running        z5  10.0.161.122   212d1137-3439-4178-9f47-543fd0ff60a6  small               true  
master/5e48f5f0-11ed-490f-b70f-88242ac4b882                        running        z7  10.0.0.122     8178c5e9-f054-4d38-bd0c-2bbb4f882534  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad      running        z7  10.0.0.127     c5c43e4a-369e-41f4-9ea8-e6474c5e6fe0  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
worker/81477953-c9d3-4ad5-b499-25fdab86f9f9                        running        z7  10.0.0.123     24304523-a646-4ff9-9b49-8f6ad41da8ce  small-highmem-16GB  true  
worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b                        running        z6  10.0.201.121   b7135d9a-5144-49b7-add1-6291d84c2904  small-highmem-16GB  true  
worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1                        running        z5  10.0.161.121   bcc140f5-2b1f-43bd-b600-bc70450465ee  small-highmem-16GB  true  

12 vms


Succeeded
```

- uaac server의 endpoint를 설정한다.

```
$ uaac target

Target: https://uaa.xxx.xxx.xxx.xxx.xip.io
Context: admin, from client admin
```

- URL을 변경하고 싶을 경우 아래와 같이 입력하여 변경 가능하다. <br>
```
uaac target https://uaa.<DOMAIN>
```

- UAAC 로그인을 한다.

```
$ uaac token client get
Client ID: ****************
Client secret: ****************

Successfully fetched token via client credentials grant.
Target: https://uaa.<DOMAIN>
Context: admin, from client admin
```

- Container 서비스 계정 생성을 한다.

> $ uaac client add caasclient -s {클라이언트 비밀번호} --redirect_uri {컨테이너 서비스 대시보드 URI} --scope {퍼미션 범위} --authorized_grant_types {권한 타입} --authorities={권한 퍼미션} --autoapprove={자동승인권한}
> - 클라이언트 비밀번호 : uaac 클라이언트 비밀번호를 입력한다.
> - 컨테이너 서비스 대시보드 URI : 성공적으로 리다이렉션 할 컨테이너 서비스 대시보드 URI를 입력한다.
> - 퍼미션 범위: 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록을 입력한다.
> - 권한 타입 : 서비스팩이 제공하는 API를 사용할 수 있는 권한 목록을 입력한다.
> - 권한 퍼미션 : 클라이언트에 부여 된 권한 목록을 입력한다.
> - 자동승인권한: 사용자 승인이 필요하지 않은 권한 목록을 입력한다.

```
$ uaac client add caasclient -s clientsecret --redirect_uri "http://localhost:8091, http://xxx.xxx.xxx.xxx:8091" --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"
```


- Container 서비스 계정 수정을 한다. (이미 uaac client가 등록되어 있는 경우)

> $ uaac client update caasclient --redirect_uri={컨테이너 서비스 대시보드 URI}
>
> - 컨테이너 서비스 대시보드 URI : 성공적으로 리다이렉션 할 컨테이너 서비스 대시보드 URI를 입력한다.

```
$ uaac client update caasclient --redirect_uri="http://13.124.44.34:8091 http://localhost:8091 http://<IP>:8091 http://<IP>:8091"
```
<br>

### <div id='26'/> 2.6. PaaS-TA 포탈에서 Container 서비스 조회 설정

해당 설정은 PaaS-TA 포탈에 Container 서비스 상의 자원들을 간략하게 조회하기 위한 설정이다.

1) PaaS-TA 어드민 포탈에 접속한다.
![Portal_CaaS_01]
<br>

2) 왼쪽 네비게이션 바에서 [설정]-[설정정보] 를 클릭한 후 나타나는 페이지의 오른쪽 상단 [인프라 등록] 버튼을 클릭하여 해당 정보들을 입력한다.


- 해당 정보를 입력하기 위해 필요한 값들을 찾는다.
> $ bosh -e micro-bosh -d paasta-portal-api vms
>> haproxy 의 IP 를 찾아 Portal_Api_Uri 에 입력한다.
```
Deployment 'paasta-portal-api'

Instance                                                          Process State  AZ  IPs            VM CID                                VM Type        Active  
binary_storage/b1aab492-c00b-46e3-b3b2-d12d58489fe8               running        z6  10.0.201.126   77b53e51-d2d8-4555-a9ae-a55f8816ba9a  portal_small   true  
haproxy/d9eda4c6-53a7-4752-a8e5-a47fb0864b81                      running        z6  10.0.201.125   f1808480-1d9a-40c1-a677-34b050fdb603  small          true  
                                                                                     xxx.xxx.xxx.xxx                                                         
mariadb/503444e9-670e-4910-af71-672c91b42648                      running        z6  10.0.201.124   15d163cf-f87d-472b-a551-1ca8edae172f  portal_small   true  
paas-ta-portal-api/e31e5395-c61f-481e-9ab1-0a9ab2a46770           running        z6  10.0.201.129   5fb60706-32cc-4167-a356-4aebb5ab4a6e  portal_medium  true  
paas-ta-portal-common-api/1500065b-6c6c-4a43-a541-cec6c252d4f5    running        z6  10.0.201.130   cb0890a9-3536-400d-88ca-c979e0408a42  portal_small   true  
paas-ta-portal-gateway/5891368a-3031-405d-9390-dae77fa3f2aa       running        z6  10.0.201.127   ff16fe91-16fa-4726-a26b-d4702f533ede  portal_small   true  
paas-ta-portal-log-api/6ca5f092-d95e-42a9-90fb-f4692a08db76       running        z6  10.0.201.132   9f7f1e5d-a84f-4179-9c7d-4d5c23ff2dc3  portal_small   true  
paas-ta-portal-registration/af10b1d1-1e42-489e-bbd7-9fe332072066  running        z6  10.0.201.128   927366d9-65ea-44be-b554-351e691fcb56  portal_small   true  
paas-ta-portal-storage-api/3c2ef1cf-2316-4593-b1d7-d602bb3b4247   running        z6  10.0.201.131   dc5d9c5b-82f0-4328-984d-376b5be2b7e1  portal_small   true  

9 vms
```


<br>

> $ bosh -e micro-bosh -d paasta-container-service vms
>> haproxy 의 IP 를 찾아 CaaS_Api_Uri 에 입력한다.

```
Deployment 'paasta-container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  
container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249      running        z2  10.0.41.135    cc4f197e-4cc4-4b3c-8110-f705d18b38db  small               true  
container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21         running        z7  10.0.0.125     1296c711-6ace-44d0-9105-f2f6f9d08cb2  small               true  
container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8      running        z6  10.0.201.123   c9679528-a3c5-476e-b411-871b89fb9b68  small               true  
container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf  running        z5  10.0.161.123   5b5eea1c-d58d-479c-a0ec-fc5aaa8e1772  small               true  
container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37   running        z6  10.0.201.122   3dc335e0-79cf-482e-b3d8-b44eba531e91  small               true  
haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2                       running        z7  10.0.0.124     c873d1f5-63ba-468d-83a6-8512e8403352  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb                       running        z5  10.0.161.122   212d1137-3439-4178-9f47-543fd0ff60a6  small               true  
master/5e48f5f0-11ed-490f-b70f-88242ac4b882                        running        z7  10.0.0.122     8178c5e9-f054-4d38-bd0c-2bbb4f882534  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad      running        z7  10.0.0.127     c5c43e4a-369e-41f4-9ea8-e6474c5e6fe0  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
worker/81477953-c9d3-4ad5-b499-25fdab86f9f9                        running        z7  10.0.0.123     24304523-a646-4ff9-9b49-8f6ad41da8ce  small-highmem-16GB  true  
worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b                        running        z6  10.0.201.121   b7135d9a-5144-49b7-add1-6291d84c2904  small-highmem-16GB  true  
worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1                        running        z5  10.0.161.121   bcc140f5-2b1f-43bd-b600-bc70450465ee  small-highmem-16GB  true  

12 vms
```


```
ex)
- NAME : PaaS-TA 5.0 (Openstack)
- Portal_Api_Uri : http://<poral_haproxy_IP>:2225
- UAA_Uri : https://api.<CF DOMAIN>.xip.io
- Authorization : Basic YWRtaW46b3BlbnBhYXN0YQ==
- 설명 : PaaS-TA 5.0 install infra
- CaaS_Api_Uri : http://<container_service_haproxy_IP>
- CaaS_Authorization : Basic YWRtaW46UGFhUy1UQQ==
```

![Portal_CaaS_02]

<br>

### <div id='27'/> 2.7. Jenkins 서비스 설정 (Optional)
해당 설정은 Jenkins 서비스에서 설치된 Jenkins 서비스를 이용하기 위한 설정이다.

1) 배포된 Jenkins 서비스 VM 목록을 확인한다.
> $ bosh -e micro-bosh -d paasta-container-service vms

```
Deployment 'paasta-container-service'

Instance                                                           Process State  AZ  IPs            VM CID                                VM Type             Active  
container-jenkins-broker/9283865a-bd0c-4ab1-aede-d8d51295c249      running        z2  10.0.41.135    cc4f197e-4cc4-4b3c-8110-f705d18b38db  small               true  
container-service-api/a0d62210-51e5-45f5-a67d-c4e52824eb21         running        z7  10.0.0.125     1296c711-6ace-44d0-9105-f2f6f9d08cb2  small               true  
container-service-broker/c596e534-194c-40fc-880c-0bca0cd19ca8      running        z6  10.0.201.123   c9679528-a3c5-476e-b411-871b89fb9b68  small               true  
container-service-common-api/e32fe88e-aa93-4f1e-9026-fc9294a428bf  running        z5  10.0.161.123   5b5eea1c-d58d-479c-a0ec-fc5aaa8e1772  small               true  
container-service-dashboard/4c9525e6-c2bf-4ae6-8413-5d2943b80c37   running        z6  10.0.201.122   3dc335e0-79cf-482e-b3d8-b44eba531e91  small               true  
haproxy/1028c7c2-484f-493b-8c1e-1abbcdd479e2                       running        z7  10.0.0.124     c873d1f5-63ba-468d-83a6-8512e8403352  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
mariadb/3f4285a0-c216-4975-9a12-c90382a0bbeb                       running        z5  10.0.161.122   212d1137-3439-4178-9f47-543fd0ff60a6  small               true  
master/5e48f5f0-11ed-490f-b70f-88242ac4b882                        running        z7  10.0.0.122     8178c5e9-f054-4d38-bd0c-2bbb4f882534  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
private-image-repository/c2889c92-f95e-4333-a898-c2f00e78f1ad      running        z7  10.0.0.127     c5c43e4a-369e-41f4-9ea8-e6474c5e6fe0  small               true  
                                                                                      xxx.xxx.xxx.xxx                                                              
worker/81477953-c9d3-4ad5-b499-25fdab86f9f9                        running        z7  10.0.0.123     24304523-a646-4ff9-9b49-8f6ad41da8ce  small-highmem-16GB  true  
worker/b3ee8f8c-9b9f-4f6a-a311-6042790e486b                        running        z6  10.0.201.121   b7135d9a-5144-49b7-add1-6291d84c2904  small-highmem-16GB  true  
worker/ea1b0826-aef1-4fe1-9304-517e8d306fd1                        running        z5  10.0.161.121   bcc140f5-2b1f-43bd-b600-bc70450465ee  small-highmem-16GB  true  

12 vms
```
<br>




### <div id='27_1'/> 2.7.1 Jenkins 서비스 브로커 등록
먼저 Jenkins 서비스 브로커를 등록해 주어야 한다. 서비스 브로커 등록 시 개방형 클라우드 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

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

### <div id='28'/> 2.8. 쿠버네티스 마스터 노드 IP 변경 시 인증서 갱신 (Optional)
쿠버네티스 마스터 노드의 IP가 변경되어 재설치를 하는 경우 해당 IP를 포함한 인증서를 삭제해주어야 신규 인증서가 생성되므로 이 경우 설치 스크립트는 자동으로 인증서를 삭제 후 배포를 진행한다. 만약 CredHub에 로그인이 되어 있지 않으면 아래와 같은 메세지가 나타나며 CredHub 로그인 이후 다시 시도해야 한다.

```
$ ./deploy-vsphere.sh
You are not currently authenticated to CredHub. Please log in to continue.
$
```

- CredHub 로그인
CredHub에 로그인이 되어있지 않은 경우 아래 링크의 가이드를 참조한다.
https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/master/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md#1029


[Architecture]:../images/container-service/Container_Service_Architecture.png
[Portal_CaaS_01]:../images/container-service/portal-admin.png
[Portal_CaaS_02]:../images/container-service/portal-infra-setting.png
