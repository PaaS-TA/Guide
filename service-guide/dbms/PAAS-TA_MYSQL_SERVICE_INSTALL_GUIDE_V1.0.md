## Table of Contents
1. [문서 개요](#1)
  - 1.1. [목적](#11)
  - 1.2. [범위](#12)
  - 1.3. [시스템 구성도](#13)
  - 1.4. [참고자료](#14)
2. [MySQL 서비스팩 설치](#2)
  - 2.1. [설치전 준비사항](#21)
  - 2.2. [MySQL 서비스 릴리즈 업로드](#22)
  - 2.3. [MySQL 서비스 Deployment 파일 수정 및 배포](#23)
  - 2.4. [MySQL 서비스 브로커 등록](#24)
3. [MySQL 연동 Sample Web App 설명](#3)
  - 3.1. [Sample Web App 구조](#31)
  - 3.2. [PaaS-TA에서 서비스 신청](#32)
  - 3.3. [Sample Web App 배포 및 MySQL바인드 확인](#33)
4. [MySQL Client 툴 접속](#4)
  - 4.1. [HeidiSQL 설치 및 연결](#41)

# <div id='1'> 1. 문서 개요
### <div id='11'> 1.1. 목적

본 문서(MySQL 서비스팩 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 MySQL 서비스팩을 Bosh2.0을 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application 에서 MySQL 서비스를 사용하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='12'> 1.2. 범위
설치 범위는 MySQL 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='13'> 1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다. MySQL Server, MySQL 서비스 브로커, Proxy로 최소사항을 구성하였다.

![시스템구성도][mysql_vsphere_1.3.01]
* 설치할때 cloud config에서 사용하는 VM_Tpye명과 스펙

| VM_Type | 스펙 |
|--------|-------|
|minimal| 1vCPU / 1GB RAM / 8GB Disk|

* 각 Instance의 Resource Pool과 스펙

| 구분 | Resource Pool | 스펙 |
|--------|-------|-------|
| paasta-mysql-broker | minimal | 1vCPU / 1GB RAM / 8GB Disk |
| proxy | minimal | 1vCPU / 1GB RAM / 8GB Disk |
| mysql | minimal | 1vCPU / 1GB RAM / 8GB Disk +8GB(영구적 Disk) |

### <div id='14'> 1.4. 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

# <div id='2'> 2. MySQL 서비스팩 설치

### <div id='21'> 2.1. 설치전 준비사항

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

- PaaS-TA에서 제공하는 압축된 릴리즈 파일들을 다운받는다. (PaaSTA-Deployment.zip, PaaSTA-Sample-Apps.zip, PaaSTA-Services.zip)

- 설치 파일 다운로드 위치
>Download : **<https://paas-ta.kr/download/package>**  
```  
# Deployment 다운로드 파일 위치 경로
~/workspace/paasta-5.0/deployment/service-deployment/paasta-mysql-service

# 릴리즈 다운로드 파일 위치 경로
~/workspace/paasta-5.0/release/service
```  

### <div id='22'> 2.2. MySQL 서비스 릴리즈 업로드

-	업로드 되어 있는 릴리즈 목록을 확인한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh releases
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Name                              Version   Commit Hash  
binary-buildpack                  1.0.21*   d714741  
bpm                               0.9.0*    c9b7136  
caas-release                      1.0*      empty+  
capi                              1.62.0*   22a608c  
cf-networking                     2.8.0*    479f4a66  
cf-smoke-tests                    40.0.5*   d6aaf1f  
cf-syslog-drain                   7.0*      71b995a  
cflinuxfs2                        1.227.0*  60128e1  
consul                            195*      67cdbcd  
diego                             2.13.0*   b5644d9  
dotnet-core-buildpack             2.1.3*    46a41cd  
garden-runc                       1.15.1*   75107e7+  
go-buildpack                      1.8.25*   40c60a0  
haproxy                           8.8.0*    9292573  
java-buildpack                    4.13*     c2749d3  
loggregator                       103.0*    05da4e3d  
loggregator-agent                 2.0*      2382c90  
nats                              24*       30e7a82  
nodejs-buildpack                  1.6.28*   4cfdb7b  
paas-ta-portal-release            2.0*      non-git  
paasta-delivery-pipeline-release  1.0*      b3ee8f48+  
paasta-pinpoint                   2.0*      2dbb8bf3+  
php-buildpack                     4.3.57*   efc48f3  
postgres                          29*       5de4d63d+  
python-buildpack                  1.6.18*   bcc4f26  
routing                           0.179.0*  18155a5  
ruby-buildpack                    1.7.21*   9d69600  
silk                              2.9.0*    eebed55  
staticfile-buildpack              1.4.29*   8a82e63  
statsd-injector                   1.3.0*    39e5179  
uaa                               60.2*     ebb5895  

(*) Currently deployed
(+) Uncommitted changes

31 releases

Succeeded
```  

-	Mysql 서비스 릴리즈가 업로드 되어 있지 않은 것을 확인

-	MySQL 서비스 릴리즈 파일을 업로드한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh upload-release paasta-mysql-2.0.tgz
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

######################################################## 100.00% 160.75 MiB/s 2s
Task 633

Task 633 | 02:08:55 | Extracting release: Extracting release (00:00:10)
Task 633 | 02:09:05 | Verifying manifest: Verifying manifest (00:00:00)
Task 633 | 02:09:05 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 633 | 02:09:05 | Creating new packages: acceptance-tests/5e5d15ad19905671f9e67eb080bb30d2191c35f7aef655a1c00025940b1668b3 (00:00:00)
Task 633 | 02:09:05 | Creating new packages: boost/ed69dfe0165f6a5ad28652ef734d052e27aa333ff4be437643d730bff0cfd923 (00:00:03)
Task 633 | 02:09:08 | Creating new packages: cf-mysql-broker/36766edf41b43715f89dbce7537c78ae756d6c909c6abe8cadc289dbf050db07 (00:00:00)
Task 633 | 02:09:08 | Creating new packages: check/f2562662971b499f8f6b5c6509c580d2700de0a49ac94c7f2ad3a170f9de9a55 (00:00:00)
Task 633 | 02:09:08 | Creating new packages: cli/9c848d641661cc572b627c0b51fb740f41b28c1f4d6a175647766fdd0cee417c (00:00:01)
Task 633 | 02:09:09 | Creating new packages: common/691f9ff06229ad62cfe5a87fecd9ee68deb61f8184d52ef6cf1117255470169a (00:00:00)
Task 633 | 02:09:09 | Creating new packages: galera/8bb1b700ae2b63079c619cb59addd0f3aa743bd611eb617ef62cf5e59ca3197a (00:00:00)
Task 633 | 02:09:09 | Creating new packages: galera-healthcheck/542fc53953b15f54b0730f3ee8eebcb47e6e2a1759ddd6189eb3321b245421aa (00:00:00)
Task 633 | 02:09:09 | Creating new packages: golang/b26395ff27dc8d3961def575744f7772fa44c5a2216bb224d081ccb73f3ee6d1 (00:00:02)
Task 633 | 02:09:11 | Creating new packages: gra-log-purger/f6cfe0d469dddf90526b1a6b68409a5e2861883a0f68c0eaa9898f33e0caebdf (00:00:00)
Task 633 | 02:09:11 | Creating new packages: mariadb/2d2ea7f6f66fdd898e0bb4295f0ae57fb0670e84841dd8142a937bf5f2f72367 (00:00:01)
Task 633 | 02:09:12 | Creating new packages: mariadb_ctrl/e472986aab37124e95a3b15ef4bfc9be7a7eece0d7730f4520024622e06ec9d7 (00:00:00)
Task 633 | 02:09:12 | Creating new packages: mysqlclient/772cd6cc894bc8af2fb4e5901c1881175c925c8c2ff97fcde771550c3579f1ca (00:00:00)
Task 633 | 02:09:12 | Creating new packages: op-mysql-java-broker/66f3e532f66cfa380eab59ba1dd01942779ef18024e4e7ade2d2b6794417a8fa (00:00:02)
Task 633 | 02:09:14 | Creating new packages: openjdk-1.8.0_45/11383874a3651322ceea5f245a50fa794add1db38bba8a936a82a256dbb2a2b9 (00:00:01)
Task 633 | 02:09:15 | Creating new packages: python/e2726ca2ef9033bcf5f60247fb53bfe04a09912dfb5bb4bd6eefc80883b642c3 (00:00:00)
Task 633 | 02:09:15 | Creating new packages: quota-enforcer/4b79c6c759465db4c550655ce8fca068c3a373f17e715801eff2446efef4af6d (00:00:00)
Task 633 | 02:09:15 | Creating new packages: route-registrar/bc81f4947d0f83caa323f4dfa4001df8dfdff755439cfbc6ee4953edaa2e6c48 (00:00:00)
Task 633 | 02:09:15 | Creating new packages: ruby/e3c4472d43614f527fd64ad993da8a006ed181f840d9f424f54e08c85c1deac8 (00:00:01)
Task 633 | 02:09:16 | Creating new packages: scons/103d103d7b24229be4865f0324beea95f1cc0779bfbddf9352245733871a4044 (00:00:00)
Task 633 | 02:09:16 | Creating new packages: switchboard/69ff1c2a143be3dcbeea9629c2cd73b3336d44ca2b54791b15f0ef04bfb0af2c (00:00:00)
Task 633 | 02:09:16 | Creating new packages: syslog_aggregator/e742e38c9e36fd7f844aaaa4b576ea41436f7c18f80fc15e7fa0b81699f544ac (00:00:00)
Task 633 | 02:09:16 | Creating new packages: xtrabackup/f4b3185825ffd1a41b5cebf92b003d8af0451d4bdc03a1b4945b83bcf8f1b21e (00:00:01)
Task 633 | 02:09:17 | Creating new jobs: acceptance-tests/d13c69b4a8d1f998b303d1e49ac7a083c6a84649bdcb93785735b53c463f4beb (00:00:01)
Task 633 | 02:09:18 | Creating new jobs: broker-deregistrar/c767c1c48d4dbed2f0f8221485f02d917b8838e8d52e00a0731d5f2ca014119c (00:00:00)
Task 633 | 02:09:18 | Creating new jobs: broker-registrar/f6da78f82549767bf9ea26b9fdebf16af56eb32e02bcd80a1514a081d459f3c6 (00:00:00)
Task 633 | 02:09:18 | Creating new jobs: cf-mysql-broker/568b8d60ae6adb8ee78f997708ab0485867c6af6c358e190de6de24ca3edd316 (00:00:00)
Task 633 | 02:09:18 | Creating new jobs: mysql/774d0f2b710b6253dae6577f25e72101171c2e0fefa08c89823dd1493082bf1a (00:00:00)
Task 633 | 02:09:18 | Creating new jobs: op-mysql-java-broker/1aec648fef2e0c51d80b7c6e3626da3b6f23f72094acb0df904923db413b0844 (00:00:00)
Task 633 | 02:09:18 | Creating new jobs: proxy/c0167a7ecbf7b170b8e9478ee97127f82c55b8d262a17f8e121769dca83c6d09 (00:00:00)
Task 633 | 02:09:18 | Release has been created: paasta-mysql/2.0 (00:00:00)

Task 633 Started  Wed Nov 20 02:08:55 UTC 2019
Task 633 Finished Wed Nov 20 02:09:18 UTC 2019
Task 633 Duration 00:00:23
Task 633 done

Succeeded
```  

-	업로드 된 MySQL 릴리즈를 확인한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh releases
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Name                              Version   Commit Hash  
binary-buildpack                  1.0.21*   d714741  
bpm                               0.9.0*    c9b7136  
caas-release                      1.0*      empty+  
capi                              1.62.0*   22a608c  
cf-networking                     2.8.0*    479f4a66  
cf-smoke-tests                    40.0.5*   d6aaf1f  
cf-syslog-drain                   7.0*      71b995a  
cflinuxfs2                        1.227.0*  60128e1  
consul                            195*      67cdbcd  
diego                             2.13.0*   b5644d9  
dotnet-core-buildpack             2.1.3*    46a41cd  
garden-runc                       1.15.1*   75107e7+  
go-buildpack                      1.8.25*   40c60a0  
haproxy                           8.8.0*    9292573  
java-buildpack                    4.13*     c2749d3  
loggregator                       103.0*    05da4e3d  
loggregator-agent                 2.0*      2382c90  
nats                              24*       30e7a82  
nodejs-buildpack                  1.6.28*   4cfdb7b  
paas-ta-portal-release            2.0*      non-git  
paasta-delivery-pipeline-release  1.0*      b3ee8f48+  
paasta-mysql                      2.0       0a2f21d+ 
paasta-pinpoint                   2.0*      2dbb8bf3+  
php-buildpack                     4.3.57*   efc48f3  
postgres                          29*       5de4d63d+  
python-buildpack                  1.6.18*   bcc4f26  
routing                           0.179.0*  18155a5  
ruby-buildpack                    1.7.21*   9d69600  
silk                              2.9.0*    eebed55  
staticfile-buildpack              1.4.29*   8a82e63  
statsd-injector                   1.3.0*    39e5179  
uaa                               60.2*     ebb5895  

(*) Currently deployed
(+) Uncommitted changes

32 releases

Succeeded
```  

-	Mysql 서비스 릴리즈가 업로드 되어 있는 것을 확인

-	Deploy시 사용할 Stemcell을 확인한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh stemcells
Name                                       Version  OS             CPI  CID  
bosh-openstack-kvm-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    240752b1-b1f9-43ed-8e96-7f3e4f269d71   

(*) Currently deployed

1 stemcells

Succeeded
```  
>Stemcell 목록이 존재 하지 않을 경우 BOSH 설치 가이드 문서를 참고 하여 Stemcell을 업로드를 해야 한다.

### <div id='23'> 2.3. MySQL 서비스 Deployment 파일 및 deploy-mysql-bosh2.0.sh 수정 및 배포

BOSH Deployment manifest 는 components 요소 및 배포의 속성을 정의한 YAML 파일이다.
Deployment manifest 에는 sotfware를 설치 하기 위해서 어떤 Stemcell (OS, BOSH agent) 을 사용할것이며 Release (Software packages, Config templates, Scripts) 이름과 버전, VMs 용량, Jobs params 등을 정의가 되어 있다.

deployment 파일에서 사용하는 network, vm_type 등은 cloud config 를 활용하고 해당 가이드는 Bosh2.0 가이드를 참고한다.

-	cloud config 내용 조회

- **사용 예시**  
```  
$ bosh -e micro-bosh cloud-config
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

azs:
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z1
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z2
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z3
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z4
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z5
- cloud_properties:
    datacenters:
    - clusters:
      - BD-HA:
	  resource_pool: CF_BOSH2_Pool
      name: BD-HA
  name: z6
compilation:
  az: z1
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
  name: 1TB
networks:
- name: default
  subnets:
  - azs:
    - z1
    - z2
    - z3
    - z4
    - z5
    - z6
    cloud_properties:
      name: Internal
    dns:
    - 8.8.8.8
    gateway: 10.30.20.23
    range: 10.30.0.0/16
    reserved:
    - 10.30.0.0 - 10.30.111.40
- name: public
  subnets:
  - azs:
    - z1
    - z2
    - z3
    - z4
    - z5
    - z6
    cloud_properties:
      name: External
    dns:
    - 8.8.8.8
    gateway: 115.68.46.177
    range: 115.68.46.176/28
    reserved:
    - 115.68.46.176 - 115.68.46.188
    static:
    - 115.68.46.189 - 115.68.46.190
  type: manual
- name: service_private
  subnets:
  - azs:
    - z1
    - z2
    - z3
    - z4
    - z5
    - z6
    cloud_properties:
      name: Internal
    dns:
    - 8.8.8.8
    gateway: 10.30.20.23
    range: 10.30.0.0/16
    reserved:
    - 10.30.0.0 - 10.30.106.255
    static:
    - 10.30.107.1 - 10.30.107.255
- name: service_public
  subnets:
  - azs:
    - z1
    - z2
    - z3
    - z4
    - z5
    - z6
    cloud_properties:
      name: External
    dns:
    - 8.8.8.8
    gateway: 115.68.47.161
    range: 115.68.47.160/24
    reserved:
    - 115.68.47.161 - 115.68.47.174
    static:
    - 115.68.47.175 - 115.68.47.185
  type: manual
- name: portal_service_public
  subnets:
  - azs:
    - z1
    - z2
    - z3
    - z4
    - z5
    - z6
    cloud_properties:
      name: External
    dns:
    - 8.8.8.8
    gateway: 115.68.46.209
    range: 115.68.46.208/28
    reserved:
    - 115.68.46.216 - 115.68.46.222
    static:
    - 115.68.46.214
  type: manual
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
    disk: 51200
  name: small-50GB
- cloud_properties:
    disk: 102400
  name: small-highmem-100GB
vm_types:
- cloud_properties:
    cpu: 1
    disk: 8192
    ram: 1024
  name: minimal
- cloud_properties:
    cpu: 1
    disk: 10240
    ram: 2048
  name: default
- cloud_properties:
    cpu: 1
    disk: 30720
    ram: 4096
  name: small
- cloud_properties:
    cpu: 2
    disk: 20480
    ram: 4096
  name: medium
- cloud_properties:
    cpu: 2
    disk: 20480
    ram: 8192
  name: medium-memory-8GB
- cloud_properties:
    cpu: 4
    disk: 20480
    ram: 8192
  name: large
- cloud_properties:
    cpu: 8
    disk: 20480
    ram: 16384
  name: xlarge
- cloud_properties:
    cpu: 2
    disk: 51200
    ram: 4096
  name: small-50GB
- cloud_properties:
    cpu: 2
    disk: 51200
    ram: 4096
  name: small-50GB-ephemeral-disk
- cloud_properties:
    cpu: 4
    disk: 102400
    ram: 8192
  name: small-100GB-ephemeral-disk
- cloud_properties:
    cpu: 4
    disk: 102400
    ram: 8192
  name: small-highmem-100GB-ephemeral-disk
- cloud_properties:
    cpu: 8
    disk: 20480
    ram: 16384
  name: small-highmem-16GB
- cloud_properties:
    cpu: 1
    disk: 4096
    ram: 2048
  name: caas_small
- cloud_properties:
    cpu: 1
    disk: 4096
    ram: 1024
  name: caas_small_api
- cloud_properties:
    cpu: 1
    disk: 4096
    ram: 4096
  name: caas_medium
- cloud_properties:
    cpu: 2
    disk: 8192
    ram: 4096
  name: service_medium
- cloud_properties:
    cpu: 2
    disk: 10240
    ram: 2048
  name: service_medium_2G

Succeeded
```  

-	Deployment 파일을 서버 환경에 맞게 수정한다.

```yml
# paasta-mysql-service 설정 파일 내용
name: paasta-mysql-service                              # 서비스 배포이름(필수)

releases:
- name: paasta-mysql                                    # 서비스 릴리즈 이름(필수)
  version: "2.0"                                        # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

stemcells:
- alias: default
  os: ((stemcell_os))
  version: "((stemcell_version))"

update:
  canaries: 1                                           # canary 인스턴스 수(필수)
  canary_watch_time: 30000-600000                       # canary 인스턴스가 수행하기 위한 대기 시간(필수)
  max_in_flight: 1                                      # non-canary 인스턴스가 병렬로 update 하는 최대 개수(필수)
  update_watch_time: 30000-600000                       # non-canary 인스턴스가 수행하기 위한 대기 시간(필수)

instance_groups:
- name: mysql
  azs:
  - z4
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  persistent_disk_type: 8GB
  networks:
  - name: ((default_network_name))
    static_ips:
    - xx.x.xxx.01
  jobs:
  - name: mysql
    release: paasta-mysql  
    properties:
      admin_password: {mariadb_admin_password}         # MySQL 어드민 패스워드 (변경 시, op-mysql-java-broker job properties의 jdbc_pwd 변숫값과 동일 적용) 
      cluster_ips:                                     # 클러스터 구성시 IPs(필수)
      - xx.x.xxx.01
      network_name: ((default_network_name))
      seeded_databases: null
      syslog_aggregator: null
      collation_server: utf8_unicode_ci                # Mysql CharSet
      character_set_server: utf8

- name: proxy
  azs:
  - z4
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - xx.x.xxx.02
  jobs:
  - name: proxy
    release: paasta-mysql
    properties:
      cluster_ips:
      - xx.x.xxx.01
      external_host: xx.x.xxx.04.xip.io               # PaaS-TA 설치시 설정한 외부 호스트 정보(필수)
      nats:                                           # PaaS-TA 설치시 설치한 nats 정보 (필수)
        machines:
        - xx.x.xxx.05
        password: "((nats_password))"
        port: 4222
        user: nats
      network_name: ((default_network_name))
      proxy:                                          # proxy 정보 (필수)
        api_password: admin
        api_username: api
        api_force_https: false
      syslog_aggregator: null

- name: paasta-mysql-java-broker
  azs:
  - z4
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - xx.x.xxx.03
  jobs:
  - name: op-mysql-java-broker
    release: paasta-mysql
    properties:                                       # Mysql 정보
      jdbc_ip: xx.x.xxx.02
      jdbc_pwd: {mariadb_admin_password}              # JDBC 패스워드 (변경 시, mysql job properties의 admin_password 변숫값과 동일 적용) 
      jdbc_port: 3306
      log_dir: paasta-mysql-java-broker
      log_file: paasta-mysql-java-broker
      log_level: INFO

- name: broker-registrar
  lifecycle: errand                                   # bosh deploy시 vm에 생성되어 설치 되지 않고 bosh errand 로 실행할때 설정, 주로 테스트 용도에 쓰임
  azs:
  - z4
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
  jobs:
  - name: broker-registrar
    release: paasta-mysql
    properties:
      broker:
        host: xx.x.xxx.03
        name: mysql-service-broker
        password: cloudfoundry
        username: admin
        protocol: http
        port: 8080
      cf:
        admin_password: admin
        admin_username: admin
        api_url: https://api.xx.x.xxx.04.xip.io
        skip_ssl_validation: true

- name: broker-deregistrar
  lifecycle: errand                                  # bosh deploy시 vm에 생성되어 설치 되지 않고 bosh errand 로 실행할때 설정, 주로 테스트 용도에 쓰임
  azs:
  - z4
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
  jobs:
  - name: broker-deregistrar
    release: paasta-mysql
    properties:
      broker:
        name: mysql-service-broker
      cf:
        admin_password: admin
        admin_username: admin
        api_url: https://api.xx.x.xxx.04.xip.io
        skip_ssl_validation: true

meta:
  apps_domain: xx.x.xxx.04.xip.io
  environment: null
  external_domain: xx.x.xxx.04.xip.io
  nats:
    machines:
    - xx.x.xxx.05                                   # PaaSTA nats IP
    password: "((nats_password))"                   # PaaSTA nats password
    port: 4222
    user: nats
  syslog_aggregator: null

```

-	deploy-mysql-bosh2.0.sh 파일을 서버 환경에 맞게 수정한다.

```sh
#!/bin/bash

bosh -e micro-bosh -d paasta-mysql-service deploy paasta_mysql_bosh2.0.yml \
   -v default_network_name=default \
   -v stemcell_os=ubuntu-xenial \
   -v stemcell_version="315.64" \
   -v nats_password=229yq707p0tfaq32gkhs \
   -v vm_type_small=minimal
```

```
- nats_password(paasta_nats_password) 입력방법

## CREDHUB LOGIN
$ credhub login --client-name=credhub-admin --client-secret=`bosh int ${PAASTA_BOSH_WORKSPACE}/bosh-deployment/${PAASTA_BOSH_IAAS}/creds.yml --path /credhub_admin_client_secret`

## CREDHUB GET NATS PASSWORD
$ credhub get -n /micro-bosh/paasta/nats_password

```
-	MySQL 서비스팩을 배포한다.

- **사용 예시**  
```  
$ sh deploy-mysql-bosh2.0.sh
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Using deployment 'paasta-mysql-service'

+ azs:
+ - cloud_properties:
+     datacenters:
+     - clusters:
+       - BD-HA:
+           resource_pool: CF_BOSH2_Pool
+       name: BD-HA
+   name: z1

... ((생략)) ...

+ compilation:
+   az: z1
+   network: default
+   reuse_compilation_vms: true
+   vm_type: large
+   workers: 5

+ networks:
+ - name: default
+   subnets:
+   - azs:
+     - z1
+     - z2
+     - z3
+     - z4
+     - z5
+     - z6
+     cloud_properties:
+       name: Internal
+     dns:
+     - 8.8.8.8
+     gateway: 10.30.20.23
+     range: 10.30.0.0/16
+     reserved:
+     - 10.30.0.0 - 10.30.111.40

... ((생략)) ...

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
+   name: 1TB

+ stemcells:
+ - alias: default
+   os: ubuntu-xenial
+   version: '315.64'
  
+ releases:
+ - name: paasta-mysql
+   version: '2.0'
  
+ update:
+   canaries: 1
+   canary_watch_time: 30000-600000
+   max_in_flight: 1
+   update_watch_time: 30000-600000

... ((생략)) ...

+ instance_groups:
+ - azs:
+   - z5
+   instances: 3
+   name: mysql
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.107.166
+     - 10.30.107.165
+     - 10.30.107.164
+   persistent_disk_type: 8GB
+   properties:
+     admin_password: "<redacted>"
+     character_set_server: "<redacted>"
+     cluster_ips:
+     - "<redacted>"
+     - "<redacted>"
+     - "<redacted>"
+     collation_server: "<redacted>"
+     network_name: "<redacted>"
+     seeded_databases: "<redacted>"
+     syslog_aggregator: "<redacted>"
+   release: paasta-mysql
+   stemcell: default
+   template: mysql
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   name: proxy
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.107.168
+   properties:
+     cluster_ips:
+     - "<redacted>"
+     - "<redacted>"
+     - "<redacted>"
+     external_host: "<redacted>"
+     nats:
+       machines:
+       - "<redacted>"
+       password: "<redacted>"
+       port: "<redacted>"
+       user: "<redacted>"
+     network_name: "<redacted>"
+     proxy:
+       api_force_https: "<redacted>"
+       api_password: "<redacted>"
+       api_username: "<redacted>"
+     syslog_aggregator: "<redacted>"
+   release: paasta-mysql
+   stemcell: default
+   template: proxy
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   name: paasta-mysql-java-broker
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.107.167
+   properties:
+     jdbc_ip: "<redacted>"
+     jdbc_port: "<redacted>"
+     jdbc_pwd: "<redacted>"
+     log_dir: "<redacted>"
+     log_file: "<redacted>"
+     log_level: "<redacted>"
+   release: paasta-mysql
+   stemcell: default
+   template: op-mysql-java-broker
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   lifecycle: errand
+   name: broker-registrar
+   networks:
+   - name: service_private
+   properties:
+     broker:
+       host: "<redacted>"
+       name: "<redacted>"
+       password: "<redacted>"
+       port: "<redacted>"
+       protocol: "<redacted>"
+       username: "<redacted>"
+     cf:
+       admin_password: "<redacted>"
+       admin_username: "<redacted>"
+       api_url: "<redacted>"
+       skip_ssl_validation: "<redacted>"
+   release: paasta-mysql
+   stemcell: default
+   template: broker-registrar
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   lifecycle: errand
+   name: broker-deregistrar
+   networks:
+   - name: service_private
+   properties:
+     broker:
+       name: "<redacted>"
+     cf:
+       admin_password: "<redacted>"
+       admin_username: "<redacted>"
+       api_url: "<redacted>"
+       skip_ssl_validation: "<redacted>"
+   release: paasta-mysql
+   stemcell: default
+   template: broker-deregistrar
+   vm_type: minimal

+ meta:
+   apps_domain: 115.68.46.189.xip.io
+   environment:
+   external_domain: 115.68.46.189.xip.io
+   nats:
+     machines:
+     - 10.30.112.2
+     password: fxaqRErYZ1TD8296u9HdMg8ol8dJ0G
+     port: 4222
+     user: nats
+   syslog_aggregator:

+ name: paasta-mysql-service

Continue? [yN]: y

Task 4506

Task 4506 | 06:04:10 | Preparing deployment: Preparing deployment (00:00:01)
Task 4506 | 06:04:12 | Preparing package compilation: Finding packages to compile (00:00:00)
Task 4506 | 06:04:12 | Compiling packages: cli/24305e50a638ece2cace4ef4803746c0c9fe4bb0
Task 4506 | 06:04:12 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a
Task 4506 | 06:04:12 | Compiling packages: op-mysql-java-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482
Task 4506 | 06:04:12 | Compiling packages: syslog_aggregator/078da6dcb999c1e6f5398a6eb739182ccb4aba25
Task 4506 | 06:04:12 | Compiling packages: common/ba480a46c4b2aa9484fb24ed01a8649453573e6f
Task 4506 | 06:06:53 | Compiling packages: syslog_aggregator/078da6dcb999c1e6f5398a6eb739182ccb4aba25 (00:02:41)
Task 4506 | 06:06:53 | Compiling packages: golang/f57ddbc8d55d7a0f08775bf76bb6a27dc98c7ea7
Task 4506 | 06:06:55 | Compiling packages: common/ba480a46c4b2aa9484fb24ed01a8649453573e6f (00:02:43)
Task 4506 | 06:06:55 | Compiling packages: python/4e255efa754d91b825476b57e111345f200944e1
Task 4506 | 06:06:55 | Compiling packages: cli/24305e50a638ece2cace4ef4803746c0c9fe4bb0 (00:02:43)
Task 4506 | 06:06:55 | Compiling packages: check/d6811f25e9d56428a9b942631c27c9b24f5064dc
Task 4506 | 06:07:05 | Compiling packages: op-mysql-java-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482 (00:02:53)
Task 4506 | 06:07:05 | Compiling packages: boost/3eb8bdb1abb7eff5b63c4c5bdb41c0a778925c31
Task 4506 | 06:07:10 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a (00:02:58)
Task 4506 | 06:07:53 | Compiling packages: golang/f57ddbc8d55d7a0f08775bf76bb6a27dc98c7ea7 (00:01:00)
Task 4506 | 06:07:53 | Compiling packages: switchboard/fad565dadbb37470771801952001c7071e55a364
Task 4506 | 06:07:53 | Compiling packages: route-registrar/f3fdfb8c940e7227a96c06e413ae6827aba8eeda
Task 4506 | 06:07:55 | Compiling packages: check/d6811f25e9d56428a9b942631c27c9b24f5064dc (00:01:00)
Task 4506 | 06:07:55 | Compiling packages: gra-log-purger/f02fa5774ab54dbb1b1c3702d03cb929b85d60e6
Task 4506 | 06:08:30 | Compiling packages: route-registrar/f3fdfb8c940e7227a96c06e413ae6827aba8eeda (00:00:37)
Task 4506 | 06:08:30 | Compiling packages: galera-healthcheck/3da4dedbcd7d9f404a19e7720e226fd472002266
Task 4506 | 06:08:31 | Compiling packages: gra-log-purger/f02fa5774ab54dbb1b1c3702d03cb929b85d60e6 (00:00:36)
Task 4506 | 06:08:31 | Compiling packages: mariadb_ctrl/7658290da98e2cad209456f174d3b9fa143c87fc
Task 4506 | 06:08:32 | Compiling packages: switchboard/fad565dadbb37470771801952001c7071e55a364 (00:00:39)
Task 4506 | 06:08:58 | Compiling packages: galera-healthcheck/3da4dedbcd7d9f404a19e7720e226fd472002266 (00:00:28)
Task 4506 | 06:08:59 | Compiling packages: mariadb_ctrl/7658290da98e2cad209456f174d3b9fa143c87fc (00:00:28)
Task 4506 | 06:09:42 | Compiling packages: boost/3eb8bdb1abb7eff5b63c4c5bdb41c0a778925c31 (00:02:37)
Task 4506 | 06:11:27 | Compiling packages: python/4e255efa754d91b825476b57e111345f200944e1 (00:04:32)
Task 4506 | 06:11:27 | Compiling packages: scons/11e7ad3b28b43a96de3df7aa41afddde582fcc38 (00:00:22)
Task 4506 | 06:11:49 | Compiling packages: galera/d15a1d2d15e5e7417278d4aa1b908566022b9623 (00:13:18)
Task 4506 | 06:25:07 | Compiling packages: mariadb/43aa3547bc5a01dd51f1501e6b93c215dd7255e9 (00:18:49)
Task 4506 | 06:43:56 | Compiling packages: xtrabackup/2e701e7a9e4241b28052d984733de36aae152275 (00:10:26)
Task 4506 | 06:55:22 | Creating missing vms: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0)
Task 4506 | 06:55:22 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2)
Task 4506 | 06:55:22 | Creating missing vms: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0)
Task 4506 | 06:55:22 | Creating missing vms: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1)
Task 4506 | 06:55:22 | Creating missing vms: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0)
Task 4506 | 06:57:18 | Creating missing vms: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (00:01:56)
Task 4506 | 06:57:23 | Creating missing vms: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:02:01)
Task 4506 | 06:57:24 | Updating instance mysql: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (canary) (00:02:32)
Task 4506 | 06:59:56 | Updating instance mysql: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:03:03)
Task 4506 | 07:02:59 | Updating instance mysql: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:03:04)
Task 4506 | 07:06:03 | Updating instance proxy: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0) (canary) (00:01:01)
Task 4506 | 07:07:04 | Updating instance paasta-mysql-java-broker: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (canary) (00:01:02)

Task 4506 Started  Fri Aug 31 06:04:10 UTC 2018
Task 4506 Finished Fri Aug 31 07:08:06 UTC 2018
Task 4506 Duration 01:03:56
Task 4506 done

Succeeded

```  

-	배포된 MySQL 서비스팩을 확인한다.

- **사용 예시**  
``` 
$ bosh -e micro-bosh -d paasta-mysql-service vms
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Task 4525. Done

Deployment 'paasta-mysql-service'

Instance                                                       Process State  AZ  IPs            VM CID                                   VM Type  Active  
mysql/8a830154-25b6-432a-ad39-9ff09d015760                     running        z5  10.30.107.165  vm-214663a8-fcbc-4ae4-9aae-92027b9725a9  minimal  true  
mysql/e8c52bf2-cd48-45d0-9553-f6367942a634                     running        z5  10.30.107.164  vm-81ecdc43-03d2-44f5-9b89-c6cdaa443d8b  minimal  true  
mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5                     running        z5  10.30.107.166  vm-bee33ffa-3f65-456c-9250-1e74c7c97f64  minimal  true  
paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78  running        z5  10.30.107.167  vm-7c3edc00-3074-4e98-9c89-9e9ba83b47e4  minimal  true  
proxy/023edddd-418e-46e4-8d40-db452c694e16                     running        z5  10.30.107.168  vm-e447eb75-1119-451f-adc9-71b0a6ef1a6a  minimal  true  

5 vms

Succeeded
```  

### <div id='24'> 2.4. MySQL 서비스 브로커 등록
Mysql 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 MySQL 서비스 브로커를 등록해 주어야 한다.  
서비스 브로커 등록시 PaaS-TA에서 서비스브로커를 등록할 수 있는 사용자로 로그인이 되어 있어야 한다.

##### 서비스 브로커 목록을 확인한다.

>`$ cf service-brokers`  
```  
Getting service brokers as admin...

name   url
No service brokers found
```   

##### MySQL 서비스 브로커를 등록한다.

>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL(IP)}`

  서비스팩 이름 : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.  
  서비스팩 사용자ID / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID로, 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.  
  서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.  

>`$ cf create-service-broker mysql-service-broker admin cloudfoundry http://10.30.107.167:8080`
```  
cf create-service-broker mysql-service-broker admin cloudfoundry http://10.30.107.167:8080
Creating service broker mysql-service-broker as admin...
OK
```  

##### 등록된 MySQL 서비스 브로커를 확인한다.

>`$ cf service-brokers`
```  
$ cf service-brokers
Getting service brokers as admin...

name                      url
mysql-service-broker      http://10.30.107.167:8080
```  

##### 접근 가능한 서비스 목록을 확인한다.

>`$ cf service-access`
```  
$ cf service-access
Getting service access as admin...
broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    none
   Mysql-DB   Mysql-Plan2-100con   none
```  
>서비스 브로커 생성시 디폴트로 접근을 허용하지 않는다.

##### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)

>`$ cf enable-service-access Mysql-DB`  
>`$ cf service-access`  
```  
$ cf enable-service-access Mysql-DB
Enabling access to all plans of service Mysql-DB for all orgs as admin...
OK

$ cf service-access
Getting service access as admin...
broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    all
   Mysql-DB   Mysql-Plan2-100con   all
```  

# <div id='3'> 3. MySQL 연동 Sample Web App 설명  
본 Sample App은 MySQL의 서비스를 Provision한 상태에서 PaaS-TA에 배포하면 MySQL서비스와 bind되어 사용할 수 있다.  

### <div id='31'> 3.1. Sample Web App 구조  

Sample App은 PaaS-TA에 App으로 배포되며 App구동시 Bind 된 MySQL 서비스 연결 정보로 접속하여 초기 데이터를 생성하게 된다.    
브라우져를 통해 App에 접속 후 "MYSQL 데이터 가져오기"를 통해 초기 생성된 데이터를 조회 할 수 있다.  

Sample App 구조는 다음과 같다.  

| 이름 | 설명  
| ---- | ------------  
| manifest.yml | PaaS-TA에 app 배포시 필요한 설정을 저장하는 파일  
| mysql-sample-app.war | mysql sample app war 파일  

- Sample App 다운로드
> $ wget -O mysql-sample-app.zip http://45.248.73.44/index.php/s/nKQAM3SiRdEdZTf/download  
> $ unzip mysql-sample-app.zip  
> $ cd mysql-sample-app  

>`$ ls -all`  
```   
$ ls -all  
drwxr-xr-x 1 demo 197121        0 Nov 20 20:14 ./
drwxr-xr-x 1 demo 197121        0 Nov 20 19:40 ../
-rw-r--r-- 1 demo 197121      523 Nov 20 20:05 manifest.yml
-rw-r--r-- 1 demo 197121 38043286 Nov 20 19:46 mysql-sample-app.war
```  

### <div id='32'> 3.2. PaaS-TA에서 서비스 신청  
Sample App에서 MySQL 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.  

*참고: 서비스 신청시 PaaS-TA에서 서비스를 신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.  

##### 먼저 PaaS-TA Marketplace에서 서비스가 있는지 확인을 한다.  

>`$ cf marketplace`  
```  
$ cf marketplace
Getting services from marketplace in org demo / space dev as demo...
OK

service      plans                                    description
Mysql-DB     Mysql-Plan1-10con, Mysql-Plan2-100con*   A simple mysql implementation

TIP:  Use 'cf marketplace -s SERVICE' to view descriptions of individual plans of a given service.
```  

##### Marketplace에서 원하는 서비스가 있으면 서비스 신청(Provision)을 한다.  

>`$ cf create-service {서비스명} {서비스플랜} {내서비스명}`  

>서비스명 : Mysql-DB로 Marketplace에서 보여지는 서비스 명칭이다.  
>서비스플랜 : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. MySQL 서비스는 10 connection, 100 connection 를 지원한다.  
>내 서비스명 : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경설정정보를 가져온다.  

>`$ cf create-service Mysql-DB Mysql-Plan2-100con mysql-service-instance`  
```  
$ cf create-service Mysql-DB Mysql-Plan2-100con mysql-service-instance
Creating service instance mysql-service-instance in org demo / space dev as demo...
OK

Attention: The plan `Mysql-Plan2-100con` of service `Mysql-DB` is not free.  The instance `mysql-service-instance` will incur a cost.  Contact your administrator if you think this is in error.
```  

##### 생성된 MySQL 서비스 인스턴스를 확인한다.  

>`$ cf services`
```  
$ cf services
Getting services in org demo / space dev as demo...
OK

name                      service    plan                 bound apps            last operation
mysql-service-instance    Mysql-DB   Mysql-Plan2-100con                         create succeeded
```  

### <div id='33'> 3.3. Sample Web App 배포 및 MySQL바인드 확인   
서비스 신청이 완료되었으면 Sample Web App 에서는 생성된 서비스 인스턴스를 Bind 하여 App에서 MySQL 서비스를 이용한다.  
*참고: 서비스 Bind 신청시 PaaS-TA에서 서비스 Bind신청 할 수 있는 사용자로 로그인이 되어 있어야 한다.  

##### Sample App 디렉토리로 이동하여 manifest 파일을 확인한다.  

>`$ cd mysql-sample-app`  
>`$ vi manifest.yml`  

```yml
---
applications:
- name: mysql-sample-app                     # 배포할 App 이름
  memory: 1024M                              # 배포시 메모리 사이즈
  instances: 1                               # 배포 인스턴스 수
  buildpack: java_buildpack
  path: ./mysql-sample-app.war               # 배포하는 App 파일 PATH
  services:
  - mysql-service-instance
  env:
    mysql_datasource_driver-class-name: com.mysql.cj.jdbc.Driver
    mysql_datasource_jdbc-url: jdbc:\${vcap.services.mysql-service-instance.credentials.uri}
    mysql_datasource_username: \${vcap.services.mysql-service-instance.credentials.username}
    mysql_datasource_password: \${vcap.services.mysql-service-instance.credentials.password}
```

##### App을 배포한다.  
```  
$ cf push
Using manifest file D:\mysql-sample-app\manifest.yml

Updating app mysql-sample-app in org demo / space dev as demo...
OK

Uploading mysql-sample-app...
Uploading app files from: C:\Users\demo\AppData\Local\Temp\unzipped-app577458739
Uploading 32M, 177 files
Done uploading
OK
Binding service mysql-service-instance to app mysql-sample-app in org demo / space dev as demo...
OK

Starting app mysql-sample-app in org demo / space dev as demo...
Downloading java_buildpack...
Downloaded java_buildpack
Cell 26b27641-f601-4ec5-9b3c-28a0d3517573 creating container for instance 36836a8a-94d7-4096-a916-f547bd472058
Cell 26b27641-f601-4ec5-9b3c-28a0d3517573 successfully created container for instance 36836a8a-94d7-4096-a916-f547bd472058
Downloading app package...
Downloaded app package (33M)
-----> Java Buildpack v4.19.1 | https://github.com/cloudfoundry/java-buildpack.git#3f4eee2
-----> Downloading Jvmkill Agent 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/jvmkill/bionic/x86_64/jvmkill-1.16.0-RELEASE.so (5.1s)
-----> Downloading Open Jdk JRE 1.8.0_212 from https://java-buildpack.cloudfoundry.org/openjdk/bionic/x86_64/openjdk-jre-1.8.0_212-bionic.tar.gz (0.9s)
       Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (1.3s)
       JVM DNS caching disabled in lieu of BOSH DNS caching
-----> Downloading Open JDK Like Memory Calculator 3.13.0_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/bionic/x86_64/memory-calculator-3.13.0-RELEASE.tar.gz (0.1s)
       Loaded Classes: 15660, Threads: 250
-----> Downloading Client Certificate Mapper 1.8.0_RELEASE from https://java-buildpack.cloudfoundry.org/client-certificate-mapper/client-certificate-mapper-1.8.0-RELEASE.jar (0.1s)
-----> Downloading Container Customizer 2.6.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-customizer/container-customizer-2.6.0-RELEASE.jar (0.1s)
-----> Downloading Container Security Provider 1.16.0_RELEASE from https://java-buildpack.cloudfoundry.org/container-security-provider/container-security-provider-1.16.0-RELEASE.jar (5.1s)
-----> Downloading Spring Auto Reconfiguration 2.7.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-2.7.0-RELEASE.jar (0.1s)
Exit status 0
Uploading droplet, build artifacts cache...
Uploading droplet...
Uploading build artifacts cache...
Uploaded build artifacts cache (43.3M)
Uploaded droplet (76.4M)
Uploading complete
Cell 26b27641-f601-4ec5-9b3c-28a0d3517573 stopping instance 36836a8a-94d7-4096-a916-f547bd472058
Cell 26b27641-f601-4ec5-9b3c-28a0d3517573 destroying container for instance 36836a8a-94d7-4096-a916-f547bd472058
Cell 26b27641-f601-4ec5-9b3c-28a0d3517573 successfully destroyed container for instance 36836a8a-94d7-4096-a916-f547bd472058

0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
1 of 1 instances running

App started


OK

App mysql-sample-app was started using this command `JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc) -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=16963 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.WarLauncher`

Showing health and status for app mysql-sample-app in org demo / space dev as demo...
OK

requested state: started
instances: 1/1
usage: 1G x 1 instances
urls: mysql-sample-app.115.68.47.178.xip.io
last uploaded: Wed Nov 20 11:05:39 UTC 2019
stack: cflinuxfs3
buildpack: java_buildpack

     state     since                    cpu      memory         disk           details
#0   running   2019-11-20 08:07:15 PM   200.1%   165.4M of 1G   147.3M of 1G
```  

>(참고) App구동시 Mysql 서비스 접속 에러로 App 구동이 안될 경우 보안 그룹을 추가한다.  

##### rule.json 화일을 만들고 아래와 같이 내용을 넣는다.  
>`$ vi rule.json`   
destination ips : mysql 인스턴스 ips.
```json
[
  {
    "protocol": "tcp",
    "destination": "10.30.107.164 - 10.30.107.166",
    "ports": "3306"
  }
]
```
<br>

##### 보안 그룹을 생성한다.  

>`$ cf create-security-group p-mysql rule.json`  

>![update_mysql_vsphere_30]  

<br>

##### 모든 App에 Mysql 서비스를 사용할수 있도록 생성한 보안 그룹을 적용한 후, App을 리부팅 한다.  

>`$ cf bind-staging-security-group p-mysql`
>`$ cf bind-running-security-group p-mysql`  
>`$ cf restart mysql-sample-app`  
>![update_mysql_vsphere_31] 
```  
$ cf restart mysql-sample-app  
Stopping app mysql-sample-app in org demo / space dev as demo...
OK

Starting app mysql-sample-app in org demo / space dev as demo...

0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
1 of 1 instances running

App started


OK

App mysql-sample-app was started using this command `JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc) -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=16963 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.WarLauncher`

Showing health and status for app mysql-sample-app in org demo / space dev as demo...
OK

requested state: started
instances: 1/1
usage: 1G x 1 instances
urls: mysql-sample-app.115.68.47.178.xip.io
last uploaded: Wed Nov 20 11:05:39 UTC 2019
stack: cflinuxfs3
buildpack: java_buildpack

     state     since                    cpu      memory         disk           details
#0   running   2019-11-20 08:33:16 PM   297.9%   229.4M of 1G   147.3M of 1G
```  

##### App이 정상적으로 MySQL 서비스를 사용하는지 확인한다.  

> 브라우져에서 확인  
>![update_mysql_vsphere_34]  

# <div id='4'> 4. MySQL Client 툴 접속  

Application에 바인딩 된 MySQL 서비스 연결정보는 Private IP로 구성되어 있기 때문에 MySQL Client 툴에서 직접 연결할수 없다. 따라서 MySQL Client 툴에서 SSH 터널, Proxy 터널 등을 제공하는 툴을 사용해서 연결하여야 한다. 본 가이드는 SSH 터널을 이용하여 연결 하는 방법을 제공하며 MySQL Client 툴로써는 오픈 소스인 HeidiSQL로 가이드한다. HeidiSQL 에서 접속하기 위해서 먼저 SSH 터널링 할수 있는 VM 인스턴스를 생성해야한다. 이 인스턴스는 SSH로 접속이 가능해야 하고 접속 후 Open PaaS 에 설치한 서비스팩에 Private IP 와 해당 포트로 접근이 가능하도록 시큐리티 그룹을 구성해야 한다. 이 부분은 vSphere관리자 및 OpenPaaS 운영자에게 문의하여 구성한다.  

### <div id='41'> 4.1. HeidiSQL 설치 및 연결  

HeidiSQL 프로그램은 무료로 사용할 수 있는 오픈소스 소프트웨어이다.  

##### HeidiSQL을 다운로드 하기 위해 아래 URL로 이동하여 설치파일을 다운로드 한다.  

>[http://www.heidisql.com/download.php](http://www.heidisql.com/download.php)

>![mysql_vsphere_4.1.01]

<br>

##### 다운로드한 설치파일을 실행한다.

>![mysql_vsphere_4.1.02]

<br>

##### HeidSQL 설치를 위한 안내사항이다. Next 버튼을 클릭한다.

>![mysql_vsphere_4.1.03]

<br>

##### 프로그램 라이선스에 관련된 내용이다. 동의(I accept the agreement)에 체크 후 Next 버튼을 클릭한다.

>![mysql_vsphere_4.1.04]

<br>

##### HeidiSQL을 설치할 경로를 설정 후 Next 버튼을 클릭한다.

>별도의 경로 설정이 필요 없을 경우 default로 C드라이브 Program Files 폴더에 설치가 된다.

>![mysql_vsphere_4.1.05]

<br>

##### 설치 완료 후 시작메뉴에 HeidiSQL 바로가기 아이콘의 이름을 설정하는 과정이다.  
>Next 버튼을 클릭하여 다음 과정을 진행한다.

>![mysql_vsphere_4.1.06]

<br>

##### 체크박스가 4개가 있다. 아래의 경우를 고려하여 체크 및 해제를 한다.
>
  바탕화면에 바로가기 아이콘을 생성할 경우  
  sql확장자를 HeidiSQL 프로그램으로 실행할 경우  
  heidisql 공식 홈페이지를 통해 자동으로 update check를 할 경우  
  heidisql 공식 홈페이지로 자동으로 버전을 전송할 경우

> 체크박스에 체크 설정/해제를 완료했다면 Next 버튼을 클릭한다.

>![mysql_vsphere_4.1.07]

<br>

##### 설치를 위한 모든 설정이 한번에 출력된다. 확인 후 Install 버튼을 클릭하여 설치를 진행한다.

>![mysql_vsphere_4.1.08]

<br>

##### Finish 버튼 클릭으로 설치를 완료한다.

>![mysql_vsphere_4.1.09]

<br>

##### HeidiSQL을 실행했을 때 처음 뜨는 화면이다. 이 화면에서 Server에 접속하기 위한 profile을 설정/저장하여 접속할 수 있다. 신규 버튼을 클릭한다.

>![mysql_vsphere_4.1.10]

<br>

##### 어떤 Server에 접속하기 위한 Connection 정보인지 별칭을 입력한다.

>![mysql_vsphere_4.1.11]

<br>

##### 네트워크 유형의 목록에서 MySQL(SSH tunel)을 선택한다.

>![mysql_vsphere_4.1.12]

<br>

##### 아래 붉은색 영역에 접속하려는 서버 정보를 모두 입력한다.

>![mysql_vsphere_4.1.13]

>서버 정보는 Application에 바인드되어 있는 서버 정보를 입력한다. cf env <app_name> 명령어로 이용하여 확인한다.

>**예)** $cf env hello-spring-mysql

>![mysql_vsphere_4.1.14]

<br>

##### - SSH 터널 탭을 클릭하고 OpenPaaS 운영 관리자에게 제공받은 SSH 터널링 가능한 서버 정보를 입력한다. plink.exe 위치 입력은 Putty에서 제공하는 plink.exe 실행 위치를 넣어주고 만일 해당 파일이 없을 경우 plink.exe 내려받기 링크를 클릭하여 다운받는다. 로컬 포트 정보는 임의로 넣고 열기 버튼을 클릭하면 Mysql 데이터베이스에 접속한다.

>(참고) 만일 개인 키로 접속이 가능한 경우에는 openstack용 Open PaaS Mysql 서비스팩 설치 가이드를 참고한다.

>![mysql_vsphere_4.1.15]

<br>

##### 접속이 완료되면 좌측에 스키마 정보가 나타난다. 하지만 초기설정은 테이블, 뷰, 프로시져, 함수, 트리거, 이벤트 등 모두 섞여 있어서 한눈에 구분하기가 힘들어서 접속한 DB 별칭에 마우스 오른쪽 클릭 후 "트리 방식 옵션" - "객체를 유형별로 묶기"를 클릭하면 아래 화면과 같이 각 유형별로 구분이된다.

>![mysql_vsphere_4.1.16]

<br>

##### 우측 화면에 쿼리 탭을 클릭하여 Query문을 작성한 후 실행 버튼(삼각형)을 클릭한다.  

>쿼리문에 이상이 없다면 정상적으로 결과를 얻을 수 있을 것이다.

>![mysql_vsphere_4.1.17]


[mysql_vsphere_1.3.01]:/service-guide/images/mysql/mysql_vsphere_1.3.01.png
[mysql_vsphere_2.2.01]:/service-guide/images/mysql/mysql_vsphere_2.2.01.png
[mysql_vsphere_2.2.02]:/service-guide/images/mysql/mysql_vsphere_2.2.02.png
[mysql_vsphere_2.2.03]:/service-guide/images/mysql/mysql_vsphere_2.2.03.png
[mysql_vsphere_2.2.04]:/service-guide/images/mysql/mysql_vsphere_2.2.04.png
[mysql_vsphere_2.2.05]:/service-guide/images/mysql/mysql_vsphere_2.2.05.png
[mysql_vsphere_2.2.06]:/service-guide/images/mysql/mysql_vsphere_2.2.06.png
[mysql_vsphere_2.2.07]:/service-guide/images/mysql/mysql_vsphere_2.2.07.png
[mysql_vsphere_2.2.08]:/service-guide/images/mysql/mysql_vsphere_2.2.08.png
[mysql_vsphere_2.3.01]:/service-guide/images/mysql/mysql_vsphere_2.3.01.png
[mysql_vsphere_2.3.02]:/service-guide/images/mysql/mysql_vsphere_2.3.02.png
[mysql_vsphere_2.3.03]:/service-guide/images/mysql/mysql_vsphere_2.3.03.png
[mysql_vsphere_2.3.04]:/service-guide/images/mysql/mysql_vsphere_2.3.04.png
[mysql_vsphere_2.3.05]:/service-guide/images/mysql/mysql_vsphere_2.3.05.png
[mysql_vsphere_2.3.06]:/service-guide/images/mysql/mysql_vsphere_2.3.06.png
[mysql_vsphere_2.3.07]:/service-guide/images/mysql/mysql_vsphere_2.3.07.png

[mysql_vsphere_2.4.01]:/service-guide/images/mysql/mysql_vsphere_2.4.01.png
[mysql_vsphere_2.4.02]:/service-guide/images/mysql/mysql_vsphere_2.4.02.png
[mysql_vsphere_2.4.03]:/service-guide/images/mysql/mysql_vsphere_2.4.03.png
[mysql_vsphere_2.4.04]:/service-guide/images/mysql/mysql_vsphere_2.4.04.png
[mysql_vsphere_2.4.05]:/service-guide/images/mysql/mysql_vsphere_2.4.05.png
[mysql_vsphere_3.1.01]:/service-guide/images/mysql/mysql_vsphere_3.1.01.png
[mysql_vsphere_3.2.01]:/service-guide/images/mysql/mysql_vsphere_3.2.01.png
[mysql_vsphere_3.2.02]:/service-guide/images/mysql/mysql_vsphere_3.2.02.png
[mysql_vsphere_3.2.03]:/service-guide/images/mysql/mysql_vsphere_3.2.03.png
[mysql_vsphere_3.3.01]:/service-guide/images/mysql/mysql_vsphere_3.3.01.png
[mysql_vsphere_3.3.02]:/service-guide/images/mysql/mysql_vsphere_3.3.02.png
[mysql_vsphere_3.3.03]:/service-guide/images/mysql/mysql_vsphere_3.3.03.png
[mysql_vsphere_3.3.04]:/service-guide/images/mysql/mysql_vsphere_3.3.04.png
[mysql_vsphere_3.3.05]:/service-guide/images/mysql/mysql_vsphere_3.3.05.png
[mysql_vsphere_3.3.06]:/service-guide/images/mysql/mysql_vsphere_3.3.06.png
[mysql_vsphere_3.3.07]:/service-guide/images/mysql/mysql_vsphere_3.3.07.png
[mysql_vsphere_3.3.08]:/service-guide/images/mysql/mysql_vsphere_3.3.08.png
[mysql_vsphere_3.3.09]:/service-guide/images/mysql/mysql_vsphere_3.3.09.png
[mysql_vsphere_4.1.01]:/service-guide/images/mysql/mysql_vsphere_4.1.01.png
[mysql_vsphere_4.1.02]:/service-guide/images/mysql/mysql_vsphere_4.1.02.png
[mysql_vsphere_4.1.03]:/service-guide/images/mysql/mysql_vsphere_4.1.03.png
[mysql_vsphere_4.1.04]:/service-guide/images/mysql/mysql_vsphere_4.1.04.png
[mysql_vsphere_4.1.05]:/service-guide/images/mysql/mysql_vsphere_4.1.05.png
[mysql_vsphere_4.1.06]:/service-guide/images/mysql/mysql_vsphere_4.1.06.png
[mysql_vsphere_4.1.07]:/service-guide/images/mysql/mysql_vsphere_4.1.07.png
[mysql_vsphere_4.1.08]:/service-guide/images/mysql/mysql_vsphere_4.1.08.png
[mysql_vsphere_4.1.09]:/service-guide/images/mysql/mysql_vsphere_4.1.09.png
[mysql_vsphere_4.1.10]:/service-guide/images/mysql/mysql_vsphere_4.1.10.png
[mysql_vsphere_4.1.11]:/service-guide/images/mysql/mysql_vsphere_4.1.11.png
[mysql_vsphere_4.1.12]:/service-guide/images/mysql/mysql_vsphere_4.1.12.png
[mysql_vsphere_4.1.13]:/service-guide/images/mysql/mysql_vsphere_4.1.13.png
[mysql_vsphere_4.1.14]:/service-guide/images/mysql/mysql_vsphere_4.1.14.png
[mysql_vsphere_4.1.15]:/service-guide/images/mysql/mysql_vsphere_4.1.15.png
[mysql_vsphere_4.1.16]:/service-guide/images/mysql/mysql_vsphere_4.1.16.png
[mysql_vsphere_4.1.17]:/service-guide/images/mysql/mysql_vsphere_4.1.17.png



[update_mysql_vsphere_01]:/service-guide/images/mysql/update_mysql_vsphere_01.png
[update_mysql_vsphere_02]:/service-guide/images/mysql/update_mysql_vsphere_02.png
[update_mysql_vsphere_03]:/service-guide/images/mysql/update_mysql_vsphere_03.png
[update_mysql_vsphere_04]:/service-guide/images/mysql/update_mysql_vsphere_04.png
[update_mysql_vsphere_05]:/service-guide/images/mysql/update_mysql_vsphere_05.png
[update_mysql_vsphere_06]:/service-guide/images/mysql/update_mysql_vsphere_06.png
[update_mysql_vsphere_07]:/service-guide/images/mysql/update_mysql_vsphere_07.png
[update_mysql_vsphere_08]:/service-guide/images/mysql/update_mysql_vsphere_08.png
[update_mysql_vsphere_09]:/service-guide/images/mysql/update_mysql_vsphere_09.png
[update_mysql_vsphere_10]:/service-guide/images/mysql/update_mysql_vsphere_10.png
[update_mysql_vsphere_11]:/service-guide/images/mysql/update_mysql_vsphere_11.png
[update_mysql_vsphere_12]:/service-guide/images/mysql/update_mysql_vsphere_12.png
[update_mysql_vsphere_13]:/service-guide/images/mysql/update_mysql_vsphere_13.png
[update_mysql_vsphere_14]:/service-guide/images/mysql/update_mysql_vsphere_14.png
[update_mysql_vsphere_15]:/service-guide/images/mysql/update_mysql_vsphere_15.png

[update_mysql_vsphere_25]:/service-guide/images/mysql/update_mysql_vsphere_25.png
[update_mysql_vsphere_30]:/service-guide/images/mysql/update_mysql_vsphere_30.png
[update_mysql_vsphere_31]:/service-guide/images/mysql/update_mysql_vsphere_31.png
[update_mysql_vsphere_34]:/service-guide/images/mysql/update_mysql_vsphere_34.png

[update_mysql_vsphere_35]:/service-guide/images/mysql/update_mysql_vsphere_35.png
[update_mysql_vsphere_36]:/service-guide/images/mysql/update_mysql_vsphere_36.png
[update_mysql_vsphere_37]:/service-guide/images/mysql/update_mysql_vsphere_37.png
[update_mysql_vsphere_38]:/service-guide/images/mysql/update_mysql_vsphere_38.png
[update_mysql_vsphere_39]:/service-guide/images/mysql/update_mysql_vsphere_39.png
[update_mysql_vsphere_40]:/service-guide/images/mysql/update_mysql_vsphere_40.png
[update_mysql_vsphere_41]:/service-guide/images/mysql/update_mysql_vsphere_41.png
[update_mysql_vsphere_42]:/service-guide/images/mysql/update_mysql_vsphere_42.png
[update_mysql_vsphere_43]:/service-guide/images/mysql/update_mysql_vsphere_43.png
[update_mysql_vsphere_44]:/service-guide/images/mysql/update_mysql_vsphere_44.png
[update_mysql_vsphere_45]:/service-guide/images/mysql/update_mysql_vsphere_45.png
[update_mysql_vsphere_46]:/service-guide/images/mysql/update_mysql_vsphere_46.png
[update_mysql_vsphere_47]:/service-guide/images/mysql/update_mysql_vsphere_47.png
[update_mysql_vsphere_48]:/service-guide/images/mysql/update_mysql_vsphere_48.png
[update_mysql_vsphere_49]:/service-guide/images/mysql/update_mysql_vsphere_49.png
[update_mysql_vsphere_50]:/service-guide/images/mysql/update_mysql_vsphere_50.png
