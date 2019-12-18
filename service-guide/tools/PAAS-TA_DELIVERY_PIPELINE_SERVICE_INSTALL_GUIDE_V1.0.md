## Table of Contents
1. [문서 개요](#1)
  -  [1.1. 목적](#11)
  -  [1.2. 범위](#12)
  -  [1.3. 시스템 구성도](#13)
  -  [1.4. 참고 자료](#14)
2. [배포 파이프라인 서비스팩 설치](#2)
  -  [2.1. 설치 전 준비사항](#21)  
  -  [2.2. 배포 파이프라인 서비스 릴리즈 업로드](#22)
  -  [2.3. 배포 파이프라인 서비스 릴리즈 Deployment 파일 수정 및 배포](#23)
  -  [2.4. 배포 파이프라인 서비스 브로커 등록](#24)
  -  [2.5. 배포 파이프라인 UAA Client Id 등록](#25)
  -  [2.6. 배포 파이프라인 Java Offline Buildpack 등록](#26)
3. [배포 파이프라인 서비스 관리](#3)
  -  [3.1. PaaS-TA 운영자 포탈 접속 및 확인](#31)
  -  [3.2. 배포 파이프라인 서비스 등록](#32)

# <div id='1'/> 1. 문서 개요

### <div id='11'/> 1.1 목적
본 문서(배포 파이프라인 서비스팩 설치 가이드)는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에서 제공되는 서비스팩인 배포 파이프라인 서비스팩을 Bosh를 이용하여 설치 및 서비스 등록하는 방법을 기술하였다.
PaaS-TA 3.5 버전부터는 Bosh2.0 기반으로 deploy를 진행하며 기존 Bosh1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

### <div id='12'/> 1.2 범위
설치 범위는 배포 파이프라인 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

### <div id='13'/> 1.3 시스템 구성도
본 문서의 설치된 시스템 구성도입니다. 배포 파이프라인 Server, 형상관리 서비스 브로커로 최소사항을 구성하였다.
![1-1-3]
<table>
  <tr>
    <td>VM 명</td>
    <td>인스턴스 수</td>
		<td>vCPU 수</td>
		<td>메모리(GB)</td>
		<td>디스크(GB)</td>
  </tr>
  <tr>
    <td>HAProxy</td>
    <td>1</td>
	  <td>1</td>
	  <td>2</td>
	  <td>Root 4G</td>
  </tr>
  <tr>
		<td>WEB UI</td>
		<td>N</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Service broker</td>
		<td>1</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Common API</td>
		<td>N</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>DeliveryPipeline API</td>
		<td>N</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Inspection API</td>
		<td>N</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Storage API</td>
		<td>1</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Scheduler</td>
		<td>1</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>DeliveryPipeline</td>
		<td>N</td>
		<td>1</td>
		<td>2</td>
		<td>Root 8G + 영구디스크 10G</td>
  </tr>
	<tr>
		<td>Inspection</td>
		<td>1</td>
		<td>1</td>
		<td>2</td>
		<td>Root 4G</td>
  </tr>
	<tr>
		<td>Storage</td>
		<td>1</td>
		<td>1</td>
		<td>4</td>
		<td>Root 4G + 영구디스크 50G</td>
  </tr>
	<tr>
		<td>DBMS(mariadb)</td>
		<td>1</td>
		<td>1</td>
		<td>4</td>
		<td>Root 6G + 영구디스크 4G</td>
  </tr>
	<tr>
		<td>Postgres</td>
		<td>1</td>
		<td>1</td>
		<td>2</td>
		<td>Root 6G + 영구디스크 4G</td>
  </tr>
</table>

### <div id='14'/> 1.4 참고 자료
> http://bosh.io/docs <br>
> http://docs.cloudfoundry.org/

# <div id='2'/> 2. 배포 파이프라인 서비스팩 설치

### <div id='21'/> 2.1 설치 전 준비사항

본 설치 가이드는 Linux 환경에서 설치하는 것을 기준으로 하였다.
서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.0, PaaS-TA 포털이 설치되어 있어야 한다.

- PaaS-TA에서 제공하는 압축된 릴리즈 파일들을 다운받는다. (PaaSTA-Deployment.zip, PaaSTA-Sample-Apps.zip, PaaSTA-Services.zip)

- 다운로드 위치
>Download : **<https://paas-ta.kr/download/package>**  
```  
# Deployment 다운로드 파일 위치 경로
~/workspace/paasta-5.0/deployment/service-deployment/paasta-delivery-pipeline-service

# 릴리즈 다운로드 파일 위치 경로
~/workspace/paasta-5.0/release/service
```  

### <div id='22'/> 2.2 배포 파이프라인 서비스 릴리즈 업로드

-	업로드 되어 있는 릴리즈 목록을 확인한다.

- **사용 예시**
```  
$ bosh -e micro-bosh releases
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Name                              Version    Commit Hash  
binary-buildpack                  1.0.32*    2399a07  
bosh-dns                          1.12.0*    5d607ed  
bosh-dns-aliases                  0.0.3*     eca9c5a  
bpm                               1.1.0*     27e1c8f  
capi                              1.83.0*    6b3cd37  
cf-cli                            1.16.0*    05d9348  
cf-networking                     2.23.0*    eb7f9459  
cf-smoke-tests                    40.0.112*  627f266  
cf-syslog-drain                   10.2*      684147e  
cflinuxfs3                        0.113.0*   567e67d  
credhub                           2.4.0*     7d6110b+  
diego                             2.34.0*    c91f86b  
dotnet-core-buildpack             2.2.12*    668dfe2  
garden-runc                       1.19.3*    a560db3+  
go-buildpack                      1.8.40*    b4dedb6  
haproxy                           9.6.1*     5754ced  
java-buildpack                    4.19.1*    180acdd  
log-cache                         2.2.2*     0a03032  
loggregator                       105.5*     d5153da3  
loggregator-agent                 3.9*       d344140  
nats                              27*        bf8cb86  
nginx-buildpack                   1.0.13*    cf17b33  
nodejs-buildpack                  1.6.51*    7cc80a9  
paasta-portal-api-release         2.0*       c4da869+  
paasta-portal-ui-release          2.0*       3d1096b+  
php-buildpack                     4.3.77*    ca96e60  
postgres                          38*        b4926da  
pxc                               0.18.0*    acdf39f  
python-buildpack                  1.6.34*    e7b7e15  
r-buildpack                       1.0.10*    a9a0a9f  
routing                           0.188.0*   db449e4  
ruby-buildpack                    1.7.40*    fa9e7c5  
silk                              2.23.0*    cdb44d5  
staticfile-buildpack              1.4.43*    aeef141  
statsd-injector                   1.10.0*    b81ab23  
uaa                               72.0*      804589c  

(*) Currently deployed
(+) Uncommitted changes

36 releases

Succeeded
```  

-	배포 파이프라인 서비스 릴리즈가 업로드 되어 있지 않은 것을 확인

-	배포 파이프라인 서비스 릴리즈 파일을 업로드한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh upload-release paasta-delivery-pipeline-release.tgz
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

######################################################## 100.00% 191.88 MiB/s 6s
Task 1422

Task 1422 | 01:32:50 | Extracting release: Extracting release (00:00:14)
Task 1422 | 01:33:04 | Verifying manifest: Verifying manifest (00:00:00)
Task 1422 | 01:33:05 | Resolving package dependencies: Resolving package dependencies (00:00:00)
Task 1422 | 01:33:05 | Creating new packages: cf-cli/64b4059c9661381ffa65fbebaf187beb2d40b4e047d2f331a40237c4b89ef70d (00:00:00)
Task 1422 | 01:33:05 | Creating new packages: ci-server/cbbf6f8cadc68f882b4191d3b53cd6b4d459b64f6ce4d120b19a897a290c3bfa (00:00:11)
Task 1422 | 01:33:16 | Creating new packages: delivery-pipeline-api/2be471625f419734585533258ee9d8779c73ba60aa9db2ba235415b2a068ed7a (00:00:00)
Task 1422 | 01:33:16 | Creating new packages: delivery-pipeline-binary-storage-api/f5b2bf1fd3a5ece26a3f853606af0ab5fbc6449341e9044b8d8c6ce1db920e50 (00:00:01)
Task 1422 | 01:33:17 | Creating new packages: delivery-pipeline-common-api/42028f373b0dc6c8c27aa0db430544f8793e9a5695c126f558f083d7dfb4dcfe (00:00:01)
Task 1422 | 01:33:18 | Creating new packages: delivery-pipeline-inspection-api/c938e8bcc80f61b8beb4e42cdda8207ba3cd6eeee3f4f85e4efb9c1220d3d00d (00:00:00)
Task 1422 | 01:33:18 | Creating new packages: delivery-pipeline-scheduler/f66ad1272053f4f438c9aaa95620a2e2d3a559cc4b97ccaf1e8eafe146402a07 (00:00:01)
Task 1422 | 01:33:19 | Creating new packages: delivery-pipeline-service-broker/a9e64ede4b009e670520812ceafcf15a174b0fb302c12d9fa48f86af4dcc906d (00:00:01)
Task 1422 | 01:33:20 | Creating new packages: delivery-pipeline-ui/28bab03f5f2cfab7229ba36644e3661aa6b6c555b26af333f40580a73cb88ed4 (00:00:00)
Task 1422 | 01:33:20 | Creating new packages: git/cc74c2d92a23b93ec3eec74bddc256e2e150c8c0d215c103ae7287c87091704f (00:00:01)
Task 1422 | 01:33:21 | Creating new packages: gradle-2.14.1/7b6f5313b841250951f00abd67d2d400b608818170ebd61bd1b1b1c0da954e36 (00:00:00)
Task 1422 | 01:33:21 | Creating new packages: gradle-3.5/4abbbda03f3dd5305bd9b098fc164e91d8cb56b06acac75653d1beecc1036478 (00:00:02)
Task 1422 | 01:33:23 | Creating new packages: haproxy/bb90d8f2bd0b933565b1a5e19a7be768202a96888e37ffa496aca32601914e27 (00:00:00)
Task 1422 | 01:33:23 | Creating new packages: java/3a86c4255298566216c2ffe755c72f4d9149ec407af4da5ece2c36aaa68d700c (00:00:05)
Task 1422 | 01:33:28 | Creating new packages: mariadb/467dceb9fb6dbc9df546c837c92895243c3a173d9dae773ae7ff9518ee3eac0d (00:00:25)
Task 1422 | 01:33:53 | Creating new packages: maven/d97755a5b48de92dc84bd1adeb9d0e95cc8de2852330cfcd2a07e11409d29a7f (00:00:00)
Task 1422 | 01:33:53 | Creating new packages: postgres/637cedb59d1293307ee045703ce7c29e2a7ac43ee4c2dae11cde54124c1893b1 (00:00:03)
Task 1422 | 01:33:56 | Creating new packages: python/6ecc99084b929c8382f8a81410e1b9f13728b57c684bcb13c4f5e490f4ad9620 (00:00:01)
Task 1422 | 01:33:57 | Creating new packages: sonarqube/f406d1521ae046f47ec307a55b993cdd5b92e662acae12133ec7b69ec5ebe90b (00:00:04)
Task 1422 | 01:34:01 | Creating new packages: sshpass/8827aae6cf59a494d61f7ff4242948b89399717295848b4bf9e789fe8d573ba6 (00:00:00)
Task 1422 | 01:34:01 | Creating new packages: swift-all-in-one/18bf9d0780d9c4b978424bfda05e7c8494b53af7fbd7bd1f8a3bf65ed0ae1ea1 (00:00:09)
Task 1422 | 01:34:10 | Creating new jobs: binary_storage/38577751f0371880bdaac74f0e41cbb7bd3593864a4cb59de3b99373c72c8d5e (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: ci_server/5f344680ba5ac7d9be67945cdf90b67022d015e150e5a0fffc92cb46c61b1708 (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-api/9ec74e0402ef6e85fc210a1387f24b144794a5a80939358f4116e3683bb8928c (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-binary-storage-api/049de0ae8e0fa4dc49f89ffcd6c7bf4ac010f1964c1bb1b6fb96674ab844e816 (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-common-api/a8036d1a5d0058443fb22d3fe83969dafc61b6ba16adb89bded895b138319eb3 (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-inspection-api/0268b94de5192de2b45b499fba5b9d2846a152c1579073fd4ec0892dc947c36d (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-scheduler/35b099743586f35258a4193a9f4614264bac1c24a03ed788b1b148680ac87cc0 (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-service-broker/e1c1bdc26af41e52e3b65ebb9d314b13141dc41b1ebb412c93c2d56bbe5a09c0 (00:00:00)
Task 1422 | 01:34:10 | Creating new jobs: delivery-pipeline-ui/fb3c2a669a6461dea746898103b38529caf7c5586e01b03d4fa34fc39d8da30b (00:00:01)
Task 1422 | 01:34:11 | Creating new jobs: haproxy/431ff2a761051ed514d6d9db2e0992872ec185b891b122d5a544452371199cf8 (00:00:00)
Task 1422 | 01:34:11 | Creating new jobs: inspection/0dab247603ad6559232bb3fe2e0c271825786f0e66b738cccd993c75dd9fff20 (00:00:00)
Task 1422 | 01:34:11 | Creating new jobs: mariadb/056f49979e3f6be18d4d0a599261facc99fcb9eb6a5e68c67295fcf1c2abb8fd (00:00:00)
Task 1422 | 01:34:11 | Creating new jobs: postgres/1c0feb5d550e86a1c81d56b96e40b5bb9d3f0dd085f3ed012deb21e8c55a38d5 (00:00:00)
Task 1422 | 01:34:11 | Release has been created: paasta-delivery-pipeline-release/1.0 (00:00:00)

Task 1422 Started  Fri Nov 22 01:32:50 UTC 2019
Task 1422 Finished Fri Nov 22 01:34:11 UTC 2019
Task 1422 Duration 00:01:21
Task 1422 done

Succeeded
```  

-	업로드 된 배포 파이프라인 서비스 릴리즈를 확인한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh releases
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Name                              Version    Commit Hash  
binary-buildpack                  1.0.32*    2399a07  
bosh-dns                          1.12.0*    5d607ed  
bosh-dns-aliases                  0.0.3*     eca9c5a  
bpm                               1.1.0*     27e1c8f  
capi                              1.83.0*    6b3cd37  
cf-cli                            1.16.0*    05d9348  
cf-networking                     2.23.0*    eb7f9459  
cf-smoke-tests                    40.0.112*  627f266  
cf-syslog-drain                   10.2*      684147e  
cflinuxfs3                        0.113.0*   567e67d  
credhub                           2.4.0*     7d6110b+  
diego                             2.34.0*    c91f86b  
dotnet-core-buildpack             2.2.12*    668dfe2  
garden-runc                       1.19.3*    a560db3+  
go-buildpack                      1.8.40*    b4dedb6  
haproxy                           9.6.1*     5754ced  
java-buildpack                    4.19.1*    180acdd  
log-cache                         2.2.2*     0a03032  
loggregator                       105.5*     d5153da3  
loggregator-agent                 3.9*       d344140  
nats                              27*        bf8cb86  
nginx-buildpack                   1.0.13*    cf17b33  
nodejs-buildpack                  1.6.51*    7cc80a9  
paasta-delivery-pipeline-release  1.0        2da5df3  
paasta-portal-api-release         2.0*       c4da869+  
paasta-portal-ui-release          2.0*       3d1096b+  
php-buildpack                     4.3.77*    ca96e60  
postgres                          38*        b4926da  
pxc                               0.18.0*    acdf39f  
python-buildpack                  1.6.34*    e7b7e15  
r-buildpack                       1.0.10*    a9a0a9f  
routing                           0.188.0*   db449e4  
ruby-buildpack                    1.7.40*    fa9e7c5  
silk                              2.23.0*    cdb44d5  
staticfile-buildpack              1.4.43*    aeef141  
statsd-injector                   1.10.0*    b81ab23  
uaa                               72.0*      804589c  

(*) Currently deployed
(+) Uncommitted changes

37 releases

Succeeded

```  

-	배포 파이프라인 서비스 릴리즈가 업로드 되어 있는 것을 확인

-	Deploy시 사용할 Stemcell을 확인한다.

- **사용 예시**
```  
$ bosh -e micro-bosh stemcells
Name                                      Version  OS             CPI  CID  
bosh-vsphere-esxi-ubuntu-xenial-go_agent  315.64*  ubuntu-xenial  -    sc-70ca5138-65f1-4b83-9a7a-87d959a3b5d9

(*) Currently deployed

1 stemcells

Succeeded
```  
>Stemcell 목록이 존재 하지 않을 경우 BOSH 설치 가이드 문서를 참고 하여 Stemcell을 업로드를 해야 한다.

### <div id='23'/> 2.3 배포 파이프라인 서비스 Deployment 파일 수정 및 배포

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
# paasta-delivery-pipeline-service 설정 파일 내용
name: paasta-delivery-pipeline-service                      # 서비스 배포이름(필수)

releases:
- name: paasta-delivery-pipeline-release                    # 서비스 릴리즈 이름(필수)
  version: "latest"                                        # 서비스 릴리즈 버전(필수):latest 시 업로드된 서비스 릴리즈 최신버전

stemcells:
- alias: default
  os: ((stemcell_os))
  version: "((stemcell_version))"

update:
  canaries: 1                            # canary 인스턴스 수(필수)
  canary_watch_time: 30000-120000        # canary 인스턴스가 수행하기 위한 대기 시간(필수)
  max_in_flight: 1                       # non-canary 인스턴스가 병렬로 update 하는 최대 개수(필수)
  update_watch_time: 30000-120000        # non-canary 인스턴스가 수행하기 위한 대기 시간(필수)

instance_groups:
- name: mariadb
  azs:
  - z5
  instances: 1
  persistent_disk_type: 2GB
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.68
  templates:
  - name: mariadb
    release: paasta-delivery-pipeline-release

- name: postgres
  azs:
  - z5
  instances: 1
  persistent_disk_type: 2GB
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.82
  templates:
  - name: postgres
    release: paasta-delivery-pipeline-release

- name: inspection
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.69
  templates:
  - name: inspection
    release: paasta-delivery-pipeline-release

- name: haproxy
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.70
  - name: ((public_network_name))
    static_ips:
    - 115.68.47.175
  templates:
  - name: haproxy
    release: paasta-delivery-pipeline-release

- name: ci_server
  azs:
  - z5
  instances: 2
  persistent_disk_type: 4GB
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.71
    - 10.30.107.72
  templates:
  - name: ci_server
    release: paasta-delivery-pipeline-release
  env:
    bosh:
      password: $6$4gDD3aV0rdqlrKC$2axHCxGKIObs6tAmMTqYCspcdvQXh3JJcvWOY2WGb4SrdXtnCyNaWlrf3WEqvYR2MYizEGp3kMmbpwBC6jsHt0

- name: binary_storage
  azs:
  - z5
  instances: 1
  persistent_disk_type: 4GB
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.39
  templates:
  - name: binary_storage
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-common-api
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.66
  templates:
  - name: delivery-pipeline-common-api
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-inspection-api
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.62
  templates:
  - name: delivery-pipeline-inspection-api
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-binary-storage-api
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.61
  templates:
  - name: delivery-pipeline-binary-storage-api
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-api
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.65
  templates:
  - name: delivery-pipeline-api
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-service-broker
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.64
  templates:
  - name: delivery-pipeline-service-broker
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-ui
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.67
  templates:
  - name: delivery-pipeline-ui
    release: paasta-delivery-pipeline-release

- name: delivery-pipeline-scheduler
  azs:
  - z5
  instances: 1
  vm_type: ((vm_type_small))
  stemcell: default
  networks:
  - name: ((default_network_name))
    static_ips:
    - 10.30.107.63
  templates:
  - name: delivery-pipeline-scheduler
    release: paasta-delivery-pipeline-release

properties:
  cf:                                                      # CLOUD FOUNDRY 설정 정보
    uaa:
      oauth:
        info:
          uri: https://uaa.<DOMAIN>.xip.io/userinfo
        token:
          check:
            uri: https://uaa.<DOMAIN>.xip.io/check_token
          access:
            uri: https://uaa.<DOMAIN>.xip.io/oauth/token
        logout:
          uri: https://uaa.<DOMAIN>.xip.io/logout.do
        authorization:
          uri: https://uaa.<DOMAIN>.xip.io/oauth/authorize
        client:
          id: pipeclient
          secret: clientsecret
    api:
      url: https://api.<DOMAIN>.xip.io/v2/service_instances/[SUID]/permissions

  ci_server:                                               # CI SERVER 설정 정보
    password: '!paas_ta202'
    admin_user:
      username: 'admin'
      password: '!paas_ta202'
    http_url: '10.30'                                      # CI SERVER 내부 IP 앞 두자리 입력 (e.g. 10.110.10.10 의 경우, "10.110" 입력) 
    http_port: 8088
    ajp13_port: 8009
    ssh:
      username: vcap
      password: c1oudc0w
      port: 22
      identity: "null"                                     # PERM KEY 경로
      key: "null"
    credentials:
      scope: "GLOBAL"
      url: "/credentials/store/system/domain/_"
      class_name: "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
    job:
      name: "ci_server"                                    # JOB 이름과 동일하게 설정
    shared:                                                # Shared 서비스 설정 정보
      urls:
        - http://10.30.107.71:8088
    dedicated:                                             # Dedicated 서비스 설정 정보
      urls:
        - http://10.30.107.72:8088

  mariadb:                                                 # MARIA DB SERVER 설정 정보
    port: 3306
    admin_user:
      password: "!paas_ta202"
    host: 10.30.107.68
    host_names:
    - mariadb0
    host_ips:
    - 10.30.107.68
    datasource:
      url: jdbc:mysql://10.30.107.68:3306/delivery_pipeline?autoReconnect=true&useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Seoul&useLegacyDatetimeCode=false
      username: root
      password: "!paas_ta202"
      driver_class_name: com.mysql.cj.jdbc.Driver
    jpa:
      database:
        name: mysql

  postgres:                                                # POSTGRESQL SERVER 설정 정보
    port: 5432
    host: 10.30.107.82
    vcap_password: c1oudc0w
    datasource:
      url: jdbc:postgresql://10.30.107.82:5432/sonar
      username: "sonar"
      password: "sonar"
      database: "sonar"

  inspection:                                              # INSPECTION SERVER 설정 정보
    url: 10.30.107.69
    http_url: 'http://10.30.107.69'
    http_port: 9000
    admin:
      username: admin
      password: admin

  binary_storage:                                          # BINARY STORAGE SERVER 설정 정보
    proxy_ip: 10.30.107.39                                 # 프록시 서버 IP(swift-keystone job의 static_ip, Object Storage 접속 IP)
    proxy_port: 10008                                      # 프록시 서버 Port(Object Storage 접속 Port)
    default_username: paasta-pipeline                      # 최초 생성되는 유저이름(Object Storage 접속 유저이름)
    default_password: paasta-pipeline                      # 최초 생성되는 유저 비밀번호(Object Storage 접속 유저 비밀번호)
    default_tenantname: paasta-pipeline                    # 최초 생성되는 테넌트 이름(Object Storage 접속 테넌트 이름)
    default_email: email@email.com                         # 최소 생성되는 유저의 이메일
    container: delivery-pipeline-container
    auth_port: 5000

  common_api:                                              # COMMON API 설정 정보
    url: http://10.30.107.70
    server:
      port: 8081
    authorization:
      id: admin
      password: PaaS-TA
    logging:
      level: INFO
    haproxy:
      urls:
        - 10.30.107.66
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  pipeline_api:                                            # CI API 설정 정보
    url: http://10.30.107.70
    server:
      port: 8082
    authorization:
      id: admin
      password: PaaS-TA
    http:
      multipart:
        max_file_size: 1000Mb
        max_request_size: 1000Mb
    logging:
      level: INFO
    haproxy:
      urls:
        - 10.30.107.65
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  inspection_api:                                          # INSPECTION API 설정 정보
    url: http://10.30.107.70
    server:
      port: 8083
    http:
      multipart:
        max_file_size: 1000Mb
        max_request_size: 1000Mb
    logging:
      level: INFO
    authorization:
      id: admin
      password: PaaS-TA
    haproxy:
      urls:
        - 10.30.107.62
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  binary_storage_api:                                      # BINARY STORAGE API 설정 정보
    http:
      multipart:
        max_file_size: 1000Mb
        max_request_size: 1000Mb
    server:
      port: 8080
    logging:
      level: INFO
    url: http://10.30.107.61
    authorization:
      id: admin
      password: PaaS-TA
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  pipeline_ui:                                              # UI 설정 정보
    url: http://10.30.107.70
    server:
      port: 8084
    http:
      multipart:
        max_file_size: 1000Mb
        max_request_size: 1000Mb
    logging:
      level: INFO
    haproxy:
      urls:
        - 10.30.107.67
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  pipeline_scheduler:                                      # SCHEDULER 설정 정보
    server:
      port: 8080
    logging:
      level: INFO
    quartz:
      scheduler:
        instance_name: paastaDeliveryPipelineScheduler
        instance_id: AUTO
      thread_pool:
        thread_count: 5
    job:
      start_delay: 0
      repeat_interval: 5000
      description: PaaS-TA Delivery Pipeline Scheduler
      key: StatisticsJob
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  pipeline_service_broker:                                 # SERVICE BROKER 설정 정보
    server:
      port: 8080
    logging:
      controller:
        level: INFO
      service:
        level: INFO
    dashboard:
      url: http://115.68.47.175:8084/dashboard/[SUID]/                 # DASHBOARD URL : http://<HAPROXY>:<UI-PORT>/dashboard/[SUID]/
    java_opts: '-XX:MaxMetaspaceSize=104857K -Xss349K -Xms681574K -XX:MetaspaceSize=104857K -Xmx681574K'

  haproxy:                                                 # HAPROXY 설정 정보
    url: 10.30.107.70
    http_port: 8080
```

-	deploy-delivery_pipeline-bosh2.0.sh 파일을 서버 환경에 맞게 수정한다.  
	= vSphere : -o use-public-network-vsphere.yml  
	= AWS : -o use-public-network-aws.yml   
	= OpenStack : -o use-public-network-openstack.yml  
	= Azure : -o use-public-network-azure.yml  
	= GCP : -o use-public-network-gcp.yml  

```sh
#!/bin/bash

bosh -e micro-bosh -d paasta-delivery-pipeline-service deploy paasta_delivery_pipeline_bosh2.0.yml \
   -o use-public-network-vsphere.yml \
   -v default_network_name=service_private \
   -v public_network_name=service_public \
   -v stemcell_os=ubuntu-xenial \
   -v stemcell_version=latest \
   -v vm_type_small=minimal
```

-	배포 파이프라인 서비스팩을 배포한다.

- **사용 예시**
```  
$ sh deploy_delivery_pipeline_bosh2.0.sh
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Using deployment 'paasta-delivery-pipeline-service'
Task 4506

+ azs:
+ - cloud_properties:
+     datacenters:
+     - clusters:
+       - BD-HA:
+           resource_pool: PaaS_TA_46_Pools
+       name: BD-HA
+   name: z1
+ - cloud_properties:
+     datacenters:
+     - clusters:
+       - BD-HA:
+           resource_pool: PaaS_TA_46_Pools
+       name: BD-HA

... ((생략)) ...

+ vm_types:
+ - cloud_properties:
+     cpu: 1
+     disk: 8192
+     ram: 1024
+   name: minimal
+ - cloud_properties:
+     cpu: 1
+     disk: 10240
+     ram: 2048
+   name: default
+ - cloud_properties:
+     cpu: 1
+     disk: 20480
+     ram: 4096
+   name: small
+ - cloud_properties:
+     cpu: 2
+     disk: 20480
+     ram: 4096
+   name: medium
+ - cloud_properties:
+     cpu: 2
+     disk: 20480
+     ram: 8192
+   name: medium-memory-8GB
+ - cloud_properties:
+     cpu: 4
+     disk: 20480
+     ram: 8192
+   name: large
+ - cloud_properties:
+     cpu: 8
+     disk: 20480
+     ram: 16384
+   name: xlarge
+ - cloud_properties:
+     cpu: 2
+     disk: 51200
+     ram: 4096
+   name: small-50GB
+ - cloud_properties:
+     cpu: 2
+     disk: 51200
+     ram: 4096
+   name: small-50GB-ephemeral-disk
+ - cloud_properties:
+     cpu: 4
+     disk: 102400
+     ram: 8192
+   name: small-100GB-ephemeral-disk
+ - cloud_properties:
+     cpu: 4
+     disk: 102400
+     ram: 8192
+   name: small-highmem-100GB-ephemeral-disk
+ - cloud_properties:
+     cpu: 8
+     disk: 20480
+     ram: 16384
+   name: small-highmem-16GB
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 2048
+   name: caas_small
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 1024
+   name: caas_small_api
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 4096
+   name: caas_medium
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 256
+   name: service_tiny
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 512
+   name: service_small
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 1024
+   name: service_medium
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 2048
+   name: service_medium_1CPU_2G
+ - cloud_properties:
+     cpu: 2
+     disk: 8192
+     ram: 4096
+   name: service_medium_4G
+ - cloud_properties:
+     cpu: 2
+     disk: 10240
+     ram: 2048
+   name: service_medium_2G
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 256
+   name: portal_tiny
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 512
+   name: portal_small
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 1024
+   name: portal_medium
+ - cloud_properties:
+     cpu: 1
+     disk: 4096
+     ram: 2048
+   name: portal_large

... ((생략)) ...

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
+     - z7
+     cloud_properties:
+       name: Internal
+     dns:
+     - 8.8.8.8
+     gateway: 10.30.20.23
+     range: 10.30.0.0/16
+     reserved:
+     - 10.30.0.0 - 10.30.50.10
+     - 10.30.51.0 - 10.30.54.255
+     - 10.30.56.0 - 10.30.255.255
+     static:
+     - 10.30.55.0 - 10.30.55.255
+   type: manual

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
+ - name: paasta-delivery-pipeline-release
+   version: '1.0'

+ update:
+   canaries: 1
+   canary_watch_time: 30000-120000
+   max_in_flight: 1
+   update_watch_time: 30000-120000

+ variables:
+ - name: "/dns_healthcheck_tls_ca"
+   options:
+     common_name: dns-healthcheck-tls-ca
+     is_ca: true
+   type: certificate
+ - name: "/dns_healthcheck_server_tls"
+   options:
+     ca: "/dns_healthcheck_tls_ca"
+     common_name: health.bosh-dns
+     extended_key_usage:
+     - server_auth
+   type: certificate
+ - name: "/dns_healthcheck_client_tls"
+   options:
+     ca: "/dns_healthcheck_tls_ca"
+     common_name: health.bosh-dns
+     extended_key_usage:
+     - client_auth
+   type: certificate
+ - name: "/dns_api_tls_ca"
+   options:
+     common_name: dns-api-tls-ca
+     is_ca: true
+   type: certificate
+ - name: "/dns_api_server_tls"
+   options:
+     ca: "/dns_api_tls_ca"
+     common_name: api.bosh-dns
+     extended_key_usage:
+     - server_auth
+   type: certificate
+ - name: "/dns_api_client_tls"
+   options:
+     ca: "/dns_api_tls_ca"
+     common_name: api.bosh-dns
+     extended_key_usage:
+     - client_auth
+   type: certificate

+ instance_groups:
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: mariadb
+     release: paasta-delivery-pipeline-release
+   name: mariadb
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.68
+   persistent_disk_type: 2GB
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: postgres
+     release: paasta-delivery-pipeline-release
+   name: postgres
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.82
+   persistent_disk_type: 2GB
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: inspection
+     release: paasta-delivery-pipeline-release
+   name: inspection
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.69
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: haproxy
+     release: paasta-delivery-pipeline-release
+   name: haproxy
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.70
+   - default:
+     - dns
+     - gateway
+     name: service_public
+     static_ips:
+     - 115.68.46.182
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   env:
+     bosh:
+       password: "<redacted>"
+   instances: 2
+   jobs:
+   - name: ci_server
+     release: paasta-delivery-pipeline-release
+   name: ci_server
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.71
+     - 10.30.54.72
+   persistent_disk_type: 4GB
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: binary_storage
+     release: paasta-delivery-pipeline-release
+   name: binary_storage
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.39
+   persistent_disk_type: 4GB
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-common-api
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-common-api
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.66
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-inspection-api
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-inspection-api
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.62
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-binary-storage-api
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-binary-storage-api
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.61
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-api
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-api
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.65
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-service-broker
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-service-broker
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.64
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-ui
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-ui
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.67
+   stemcell: default
+   vm_type: minimal
+ - azs:
+   - z5
+   instances: 1
+   jobs:
+   - name: delivery-pipeline-scheduler
+     release: paasta-delivery-pipeline-release
+   name: delivery-pipeline-scheduler
+   networks:
+   - name: service_private
+     static_ips:
+     - 10.30.54.63
+   stemcell: default
+   vm_type: minimal

+ name: paasta-delivery-pipeline-service

+ properties:
+   binary_storage:
+     auth_port: "<redacted>"
+     binary_desc: "<redacted>"
+     container: "<redacted>"
+     email: "<redacted>"
+     password: "<redacted>"
+     proxy_ip: "<redacted>"
+     proxy_port: "<redacted>"
+     tenantname: "<redacted>"
+     username: "<redacted>"
+   binary_storage_api:
+     authorization:
+       id: "<redacted>"
+       password: "<redacted>"
+     http:
+       multipart:
+         max_file_size: "<redacted>"
+         max_request_size: "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       level: "<redacted>"
+     server:
+       port: "<redacted>"
+     url: "<redacted>"
+   cf:
+     api:
+       url: "<redacted>"
+     uaa:
+       oauth:
+         authorization:
+           uri: "<redacted>"
+         client:
+           id: "<redacted>"
+           secret: "<redacted>"
+         info:
+           uri: "<redacted>"
+         logout:
+           uri: "<redacted>"
+         token:
+           access:
+             uri: "<redacted>"
+           check:
+             uri: "<redacted>"
+   ci_server:
+     admin_user:
+       password: "<redacted>"
+       username: "<redacted>"
+     ajp13_port: "<redacted>"
+     credentials:
+       class_name: "<redacted>"
+       scope: "<redacted>"
+       url: "<redacted>"
+     dedicated:
+       urls:
+       - "<redacted>"
+     http_port: "<redacted>"
+     http_url: "<redacted>"
+     job:
+       name: "<redacted>"
+     password: "<redacted>"
+     shared:
+       urls:
+       - "<redacted>"
+     ssh:
+       identity: "<redacted>"
+       key: "<redacted>"
+       password: "<redacted>"
+       port: "<redacted>"
+       username: "<redacted>"
+   common_api:
+     authorization:
+       id: "<redacted>"
+       password: "<redacted>"
+     haproxy:
+       urls:
+       - "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       level: "<redacted>"
+     server:
+       port: "<redacted>"
+     url: "<redacted>"
+   haproxy:
+     http_port: "<redacted>"
+     url: "<redacted>"
+   inspection:
+     admin:
+       password: "<redacted>"
+       username: "<redacted>"
+     http_port: "<redacted>"
+     http_url: "<redacted>"
+     url: "<redacted>"
+   inspection_api:
+     authorization:
+       id: "<redacted>"
+       password: "<redacted>"
+     haproxy:
+       urls:
+       - "<redacted>"
+     http:
+       multipart:
+         max_file_size: "<redacted>"
+         max_request_size: "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       level: "<redacted>"
+     server:
+       port: "<redacted>"
+     url: "<redacted>"
+   mariadb:
+     admin_user:
+       password: "<redacted>"
+     datasource:
+       driver_class_name: "<redacted>"
+       password: "<redacted>"
+       url: "<redacted>"
+       username: "<redacted>"
+     host: "<redacted>"
+     host_ips:
+     - "<redacted>"
+     host_names:
+     - "<redacted>"
+     jpa:
+       database:
+         name: "<redacted>"
+     port: "<redacted>"
+   pipeline_api:
+     authorization:
+       id: "<redacted>"
+       password: "<redacted>"
+     haproxy:
+       urls:
+       - "<redacted>"
+     http:
+       multipart:
+         max_file_size: "<redacted>"
+         max_request_size: "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       level: "<redacted>"
+     server:
+       port: "<redacted>"
+     url: "<redacted>"
+   pipeline_scheduler:
+     java_opts: "<redacted>"
+     job:
+       description: "<redacted>"
+       key: "<redacted>"
+       repeat_interval: "<redacted>"
+       start_delay: "<redacted>"
+     logging:
+       level: "<redacted>"
+     quartz:
+       scheduler:
+         instance_id: "<redacted>"
+         instance_name: "<redacted>"
+       thread_pool:
+         thread_count: "<redacted>"
+     server:
+       port: "<redacted>"
+   pipeline_service_broker:
+     dashboard:
+       url: "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       controller:
+         level: "<redacted>"
+       service:
+         level: "<redacted>"
+     server:
+       port: "<redacted>"
+   pipeline_ui:
+     haproxy:
+       urls:
+       - "<redacted>"
+     http:
+       multipart:
+         max_file_size: "<redacted>"
+         max_request_size: "<redacted>"
+     java_opts: "<redacted>"
+     logging:
+       level: "<redacted>"
+     server:
+       port: "<redacted>"
+     url: "<redacted>"
+   postgres:
+     datasource:
+       database: "<redacted>"
+       password: "<redacted>"
+       url: "<redacted>"
+       username: "<redacted>"
+     host: "<redacted>"
+     port: "<redacted>"
+     vcap_password: "<redacted>"
Continue? [yN]: Y

Task 4506 | 06:04:10 | Preparing deployment: Preparing deployment (00:00:01)
Task 4506 | 06:04:12 | Preparing package compilation: Finding packages to compile (00:00:00)
Task 4506 | 06:04:12 | Compiling packages: delivery-pipeline-scheduler/01dea40e305407b6b107a8fe230bb37dadadca87
Task 4506 | 06:04:12 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a
Task 4506 | 06:04:12 | Compiling packages: delivery-pipeline-service-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482
Task 4506 | 06:04:12 | Compiling packages: delivery-pipeline-api/078da6dcb999c1e6f5398a6eb739182ccb4aba25
Task 4506 | 06:04:12 | Compiling packages: delivery-pipeline-binary-storage-api/ba480a46c4b2aa9484fb24ed01a8649453573e6f
Task 4506 | 06:06:53 | Compiling packages: syslog_aggregator/078da6dcb999c1e6f5398a6eb739182ccb4aba25 (00:02:41)
Task 4506 | 06:06:53 | Compiling packages: golang/f57ddbc8d55d7a0f08775bf76bb6a27dc98c7ea7
Task 4506 | 06:06:55 | Compiling packages: common/ba480a46c4b2aa9484fb24ed01a8649453573e6f (00:02:43)
Task 4506 | 06:06:55 | Compiling packages: python/4e255efa754d91b825476b57e111345f200944e1
Task 4506 | 06:06:55 | Compiling packages: cli/24305e50a638ece2cace4ef4803746c0c9fe4bb0 (00:02:43)
Task 4506 | 06:06:55 | Compiling packages: check/d6811f25e9d56428a9b942631c27c9b24f5064dc
Task 4506 | 06:07:05 | Compiling packages: op-mysql-java-broker/3bf47851b2c0d3bea63a0c58452df58c14a15482 (00:02:53)
Task 4506 | 06:07:05 | Compiling packages: boost/3eb8bdb1abb7eff5b63c4c5bdb41c0a778925c31
Task 4506 | 06:07:10 | Compiling packages: openjdk-1.8.0_45/57e0ee876ea9d90f5470e3784ae1171bccee850a (00:02:58)
Task 4506 | 06:43:56 | Compiling packages: mariadb/2e701e7a9e4241b28052d984733de36aae152275 (00:10:26)
Task 4506 | 06:55:22 | Creating missing vms: mariadb/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0)
Task 4506 | 06:55:22 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2)
Task 4506 | 06:55:22 | Creating missing vms: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0)
Task 4506 | 06:55:22 | Creating missing vms: postgres/8a830154-25b6-432a-ad39-9ff09d015760 (1)
Task 4506 | 06:55:22 | Creating missing vms: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0)
Task 4506 | 06:57:18 | Creating missing vms: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (00:01:56)
Task 4506 | 06:57:23 | Creating missing vms: ci_server/023edddd-418e-46e4-8d40-db452c694e16 (0) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: delivery-pipeline-service-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (00:02:01)
Task 4506 | 06:57:23 | Creating missing vms: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:02:01)
Task 4506 | 06:57:24 | Updating instance mysql: mysql/ea075ae6-6326-478b-a1ba-7fbb0b5b0bf5 (0) (canary) (00:02:32)
Task 4506 | 06:59:56 | Updating instance mysql: mysql/8a830154-25b6-432a-ad39-9ff09d015760 (1) (00:03:03)
Task 4506 | 07:02:59 | Updating instance mysql: mysql/e8c52bf2-cd48-45d0-9553-f6367942a634 (2) (00:03:04)
Task 4506 | 07:06:03 | Updating instance proxy: proxy/023edddd-418e-46e4-8d40-db452c694e16 (0) (canary) (00:01:01)
Task 4506 | 07:07:04 | Updating instance delivery-pipeline-service-broker: paasta-mysql-java-broker/bb5676ca-efba-48fc-bc11-f464d0ae9c78 (0) (canary) (00:01:02)

Task 4506 Started  Fri Aug 31 06:04:10 UTC 2018
Task 4506 Finished Fri Aug 31 07:08:06 UTC 2018
Task 4506 Duration 01:03:56
Task 4506 done

Succeeded
```  

-	배포된 배포파이프라인 서비스팩을 확인한다.

- **사용 예시**  
```  
$ bosh -e micro-bosh -d paasta-delivery-pipeline-service vms
Using environment '10.30.40.111' as user 'admin' (openid, bosh.admin)

Task 7819. Done

Deployment 'paasta-delivery-pipeline-service'

Instance                                                                   Process State  AZ  IPs            VM CID                                   VM Type  Active  
binary_storage/4c54c4a5-9a63-4b7f-acd7-afe2937af04d                        running        z5  10.30.107.39   vm-0ea717f1-8f07-4924-bbc7-6bafbe6fbea3  minimal  true  
ci_server/24ed965d-51a0-4477-8c80-fa4e4c2502a7                             running        z5  10.30.107.72   vm-5e8639c8-3a41-4ed9-9eb1-e1e48ff17b6d  minimal  true  
ci_server/fe3e03eb-55f8-4980-9f0b-bbb396bd02cf                             running        z5  10.30.107.71   vm-cc8dd7ed-237a-4c48-b23b-ff9113c64f3d  minimal  true  
delivery-pipeline-api/de15549f-a7e4-4dd8-867d-958c7f6d8e18                 running        z5  10.30.107.65   vm-ab366342-771c-484a-8a4a-be7563f12add  minimal  true  
delivery-pipeline-binary-storage-api/dcfdeca5-8a09-4090-addf-d64f1e910063  running        z5  10.30.107.61   vm-a2042942-01e9-45b5-bc43-52354d02c8d0  minimal  true  
delivery-pipeline-common-api/700424b3-4c81-4c72-88ed-99d2f6d2d368          running        z5  10.30.107.66   vm-f65d3452-7da4-428d-8cb4-7406f20708fe  minimal  true  
delivery-pipeline-inspection-api/46f771f3-dcb6-40de-a727-52bcb4e014e5      running        z5  10.30.107.62   vm-a56941ab-2305-4a9d-96ed-4db17d84aa0b  minimal  true  
delivery-pipeline-scheduler/fd17f7c8-7bd3-4c68-8c22-542d3013a90b           running        z5  10.30.107.63   vm-4dc86c13-ab35-4424-8205-1b461325243e  minimal  true  
delivery-pipeline-service-broker/67243664-06d9-4915-9e8f-534812bd099c      running        z5  10.30.107.64   vm-06a9756a-07df-4f85-a422-fd652f61cb66  minimal  true  
delivery-pipeline-ui/a9229a2a-6d25-4755-954e-fbe97e11c3ea                  running        z5  10.30.107.67   vm-0a095d59-eb00-4a35-b93f-475d5250bca9  minimal  true  
haproxy/65081aeb-50e0-49bc-a6c1-131f74d52a44                               running        z5  10.30.107.70   vm-111c720f-e640-40f3-8c10-d252fca5b4ec  minimal  true  
											      115.68.47.175                                                      
inspection/a5789621-8615-417a-9a8a-6fccddb38b4b                            running        z5  10.30.107.69   vm-09df943c-704f-4952-b9fe-054d74d271b6  minimal  true  
mariadb/2d876573-1248-48b0-9a00-92463cc33978                               running        z5  10.30.107.68   vm-76ee37ce-e99b-4a59-b0a5-f860f284b924  minimal  true  
postgres/3226e31b-e86f-40bb-b0d8-31755b087699                              running        z5  10.30.107.82   vm-060c3a81-4a89-4370-9777-c06e280a83c6  minimal  true  

14 vms

Succeeded
```  

### <div id='24'/> 2.4 배포 파이프라인 서비스 브로커 등록

배포 파이프라인 서비스팩 배포가 완료되었으면 파스-타 포탈에서 서비스 팩을 사용하기 위해서 먼저 배포 파이프라인 서비스 브로커를 등록해 주어야 한다.
서비스 브로커 등록 시 개방형 클라우드 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

##### 서비스 브로커 목록을 확인한다.

>`$ cf service-brokers`  
```  
$ cf service-brokers
Getting service brokers as admin...

name   url
No service brokers found
```  

##### 배포 파이프라인 서비스 브로커를 등록한다.
>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}`  

  **서비스팩 이름** : 서비스 팩 관리를 위해 PaaS-TA에서 보여지는 명칭이다. 서비스 Marketplace에서는 각각의 API 서비스 명이 보여지니 여기서 명칭은 서비스팩 리스트의 명칭이다.<br>
  **서비스팩 사용자ID** / 비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID입니다. 서비스팩도 하나의 API 서버이기 때문에 아무나 접근을 허용할 수 없어 접근이 가능한 ID/비밀번호를 입력한다.<br>
  **서비스팩 URL** : 서비스팩이 제공하는 API를 사용할 수 있는 URL을 입력한다.

>`$ cf create-service-broker delivery-pipeline admin cloudfoundry http://10.30.107.64:9090`  
```  
$ cf create-service-broker delivery-pipeline-broker admin cloudfoundry http://10.30.107.64:9090
Creating service broker delivery-pipeline-broker as admin...
OK
```  

##### 등록된 배포 파이프라인 서비스 브로커를 확인한다.

>`$ cf service-brokers`  
```  
$ cf service-brokers
Getting service brokers as admin...

name                           url
delivery-pipeline-broker       http://10.30.107.64:9090
```  

##### 접근 가능한 서비스 목록을 확인한다.
>`$ cf service-access`

```
# 서비스 브로커 생성시 디폴트로 접근을 허용하지 않는다.
$ cf service-access
Getting service access as admin...
broker: delivery-pipeline-broker
   service             plan                          access   orgs
   delivery-pipeline   delivery-pipeline-shared      none
   delivery-pipeline   delivery-pipeline-dedicated   none

```

##### 특정 조직에 해당 서비스 접근 허용을 할당하고 접근 서비스 목록을 다시 확인한다. (전체 조직)  
>`$ cf enable-service-access delivery-pipeline`  
>`$ cf service-access`  
```  
$ cf enable-service-access delivery-pipeline                                         
Enabling access to all plans of service delivery-pipeline for all orgs as admin...   
OK

$ cf service-access
Getting service access as admin...
broker: delivery-pipeline-broker
   service             plan                          access   orgs
   delivery-pipeline   delivery-pipeline-shared      all
   delivery-pipeline   delivery-pipeline-dedicated   all

```

### <div id='25'/> 2.5 배포 파이프라인 UAAC Client Id 등록
UAAC Client 계정 등록 절차에 대한 순서를 확인한다.

- 배포 파이프라인 UAAC Client를 등록한다.
> $ uaac client add {클라이언트 명} -s {클라이언트 비밀번호} --redirect_URL{대시보드 URL} --scope {퍼미션 범위} --authorized_grant_types {권한 타입} --authorities={권한 퍼미션} --autoapprove={자동승인권한}  
> 클라이언트 명 : uaac 클라이언트 명 (pipeclient)  
> 클라이언트 비밀번호 : uaac 클라이언트 비밀번호  
> 대시보드 URL: 성공적으로 리다이렉션 할 대시보드 URL   
> 퍼미션 범위: 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록  
> 권한 타입 : 서비스팩이 제공하는 API를 사용할 수 있는 권한 목록  
> 권한 퍼미션 : 클라이언트에 부여 된 권한 목록  
> 자동승인권한: 사용자 승인이 필요하지 않은 권한 목록  

>$ uaac client add pipeclient -s clientsecret --redirect_uri "[DASHBOARD_URL]" /  
>--scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" /  
>--authorized_grant_types "authorization_code , client_credentials , refresh_token" /  
>--authorities="uaa.resource" /  
>--autoapprove="openid , cloud_controller_service_permissions.read"  

```  
### uaac endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

### target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

### uaac 로그인
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>

### 배포파이프라인 uaac client 등록
$ uaac client add pipeclient -s clientsecret --redirect_uri "http://115.68.47.175:8084 http://115.68.47.175:8084/dashboard" \
   --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" \
   --authorized_grant_types "authorization_code , client_credentials , refresh_token" \
   --authorities="uaa.resource" \
   --autoapprove="openid , cloud_controller_service_permissions.read"
```  

### <div id='26'/> 2.6 배포 파이프라인 Java Offline Buildpack 등록
- 배포 파이프라인 서비스 사용을 위해 Java Offline Buildpack을 등록한다.
> `$ cf create-buildpack [BUILDPACK] [PATH] [POSITION] `  
> **[BUILDPACK]** : java_buildpack_offline (buildpack 명)  
> **[PATH]** : buildpack zip 파일의 경로     
> **[POSITION]** : 우선순위  

- Java Offline Buildpack 다운로드 
> wget -O java-buildpack-offline-v4.25.zip http://45.248.73.44/index.php/s/mcaBZQCqwbyzC6a/download  

**buildpack 등록**  

>`$ cf create-buildpack java_buildpack_offline ..\buildpack\java-buildpack-offline-v4.25.zip 3`  

**buildpack 등록 확인**  

>`$ cf buildpacks`
```
$ cf buildpacks
Getting buildpacks...

buildpack                position   enabled   locked   filename
staticfile_buildpack     1          true      false    staticfile_buildpack-cflinuxfs3-v1.4.43.zip
java_buildpack           2          true      false    java-buildpack-cflinuxfs3-v4.19.1.zip
java_buildpack_offline   3          true      false    java-buildpack-offline-v4.25.zip
ruby_buildpack           4          true      false    ruby_buildpack-cflinuxfs3-v1.7.40.zip
dotnet_core_buildpack    5          true      false    dotnet-core_buildpack-cflinuxfs3-v2.2.12.zip
nodejs_buildpack         6          true      false    nodejs_buildpack-cflinuxfs3-v1.6.51.zip
go_buildpack             7          true      false    go_buildpack-cflinuxfs3-v1.8.40.zip
python_buildpack         8          true      false    python_buildpack-cflinuxfs3-v1.6.34.zip
php_buildpack            9          true      false    php_buildpack-cflinuxfs3-v4.3.77.zip
nginx_buildpack          10         true      false    nginx_buildpack-cflinuxfs3-v1.0.13.zip
r_buildpack              11         true      false    r_buildpack-cflinuxfs3-v1.0.10.zip
binary_buildpack         12         true      false    binary_buildpack-cflinuxfs3-v1.0.32.zip
```
※ 참고 URL : https://github.com/cloudfoundry/java-buildpack  

# <div id='3'/> 3. 배포 파이프라인 서비스 관리  
PaaS-TA 운영자 포탈을 통해 배포파이프라인 서비스를 등록 및 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청 하여 사용할 수 있다.  

### <div id='31'/> 3.1. PaaS-TA 운영자 포탈 접속 및 확인
1. PaaS-Ta 운영자 포탈에 접속하여 로그인한다.
![3-1-1]

2. 로그인 후 서비스 관리 > 서비스 브로커 페이지에서 배포 파이프라인 서비스 브로커를 확인한다.
![3-1-2]

3. 서비스 관리 > 서비스 제어 페이지에서 배포 파이프라인 서비스 플랜 접근 가능 권한을 확인한다.
![3-1-3]

### <div id='32'/> 3.2. 배포 파이프라인 서비스 등록
-	PaaS-TA 운영자 포탈에서 운영관리 > 카탈로그 > 앱서비스 페이지를 확인하여 "파이프라인" 서비스 이름을 클릭한다.  
![3-2-1]

- 아래의 내용을 상세 페이지에 입력한다.

> ※ 카탈로그 관리 > 앱 서비스
> - 이름 : 파이프라인
> - 분류 :  개발 지원 도구
> - 서비스 : delivery-pipeline
> - 썸네일 : [배포 파이프라인 서비스 썸네일]
> - 문서 URL : https://github.com/PaaS-TA/DELIVERY-PIPELINE-SERVICE-BROKER
> - 서비스 생성 파라미터 : owner
> - 앱 바인드 사용 : N
> - 공개 : Y
> - 대시보드 사용 : Y
> - 온디멘드 : N
> - 태그 : paasta / tag6, free / tag2
> - 요약 : 개발용으로 만들어진 파이프라인
> - 설명 :
> 개발용으로 만들어진 파이프라인
> 배포 파이프라인 Server, 배포 파이프라인 서비스 브로커로 최소사항을 구성하였다.
>  
> ![3-2-2]

[1-1-3]:/service-guide/images/pipeline/Delivery_Pipeline_Architecture.jpg
[3-1-1]:/service-guide/images/pipeline/adminPortal_login.png
[3-1-2]:/service-guide/images/pipeline/adminPortal_serviceBroker.png
[3-1-3]:/service-guide/images/pipeline/adminPortal_serviceControl.png
[3-2-1]:/service-guide/images/pipeline/adminPortal_catalog.png
[3-2-2]:/service-guide/images/pipeline/adminPortal_catalogDetail.png

