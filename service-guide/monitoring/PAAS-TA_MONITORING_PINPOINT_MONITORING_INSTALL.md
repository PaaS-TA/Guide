## Table of Contents
1\. [문서 개요](#1)  
　● [목적](#11)  
　● [범위](#12)  
　● [시스템 구성도](#13)  
　● [참고자료](#14)  
2\. [Pinpoint 서비스팩 설치](#2)  
　2.1 [Prerequisite](#21)  
　2.2 [설치 파일 다운로드](#22)  
　2.3 [Pinpoint Monitoring 설치 환경설정](#23)  
　　● [common_vars.yml](#231)  
　　● [pinpoint-vars.yml](#232)  
　　● [deploy-pinpoint.sh](#233)  
　　● [deploy-pinpoint-vsphere.sh](#234)  
　2.4. [Pinpoint Monitoring 설치](#24)  
　2.5. [Pinpoint Monitoring 설치 - 다운로드 된 Release 파일 이용 방식](#25)  
　2.6. [서비스 설치 확인](#26)  
　2.7. [Security-Group 등록](#27)  
　2.8. [Pinpoint User-Provided Service 등록](#28)  
3\. [Sample Web App 연동 Pinpoint 연동](#3)  
　● [Sample Web App 구조](#31)  
　● [Sample Web App에 서비스 바인드 신청 및 App 확인](#32)  

# <div id='1'> 1. 문서 개요
## <div id='11'> ● 목적

본 문서(SaaS Monitoring Pinpoint 서비스팩 설치 가이드)는 전자정부표준프레임워크 기반의 PaaS-TA에서 제공되는 서비스팩인 Pinpoint 서비스팩을 BOSH 2.0을 이용하여 설치 하는 방법과 PaaS-TA의 SaaS 형태로 제공하는 Application 에서 Pinpoint 서비스를 사용하는 방법을 기술하였다.  
PaaS-TA 3.5 버전부터는 BOSH 2.0 기반으로 deploy를 진행하며 기존 BOSH 1.0 기반으로 설치를 원할경우에는 PaaS-TA 3.1 이하 버전의 문서를 참고한다.

## <div id='12'> ● 범위
설치 범위는 Pinpoint 서비스팩을 검증하기 위한 기본 설치를 기준으로 작성하였다.

## <div id='13'> ● 시스템 구성도

본 문서의 설치된 시스템 구성도이다.  
Pinpoint Server, HBase의 HBase Master, Collector , WebUI2로 최소사항을 구성하였다. 

![시스템구성도][pinpoint_image_01]

<table>
  <tr>
    <th>구분</th>
    <th>Resource Pool</th>
    <th>스펙</th>
  </tr>
  <tr>
  <td>collector      </td><td>pinpoint_medium</td><td>2vCPU / 2GB RAM / 8GB Disk</td>
  </tr>
  <td>h_master      </td><td>pinpoint_medium</td><td>2vCPU / 2GB RAM / 8GB Disk</td>
  </tr>
  <tr>
  <td>haproxy_webui </td><td>services-small</td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
  <tr>
  <td>pinpoint_web          </0><td>services-small	</td><td>1vCPU / 1GB RAM / 4GB Disk</td>
  </tr>
</table>

## <div id='14'> ● 참고자료
[**http://bosh.io/docs**](http://bosh.io/docs)  
[**http://docs.cloudfoundry.org/**](http://docs.cloudfoundry.org/)

## <div id='2'> 2. Pinpoint 서비스팩 설치

### <div id='21'> 2.1. Prerequisite

1. BOSH 설치가 되어있으며, BOSH Login이 되어 있어야 한다.
2. cloud-config와 runtime-config가 업데이트 되어있는지 확인한다.
3. Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell(ubuntu xenial 315.36)이 업로드 되어 있는 것을 확인한다.


> cloud-config 확인  
> $ bosh -e {director-name} cloud-config  

> runtime-config 확인  
> $ bosh -e {director-name} runtime-config  

> stemcell 확인  
> $ bosh -e {director-name} stemcells  



## <div id='22'/>2.2.  설치 파일 다운로드

- PaaS-TA를 설치하기 위한 deployment가 존재하지 않는다면 다운로드 받는다
```
$ cd ${HOME}/workspace/paasta-5.0/deployment
$ git clone https://github.com/PaaS-TA/common.git
$ git clone https://github.com/PaaS-TA/monitoring-deployment.git
```



## <div id='23'> 2.3. Pinpoint Monitoring 설치 환경설정

${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/pinpoint-monitoring 이하 디렉터리에는 Pinpoint Monitoring 설치를 위한 Shell Script 파일이 존재한다.
	
### <div id='231'/>● common_vars.yml
common 폴더에 있는 common_vars.yml PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일이 존재한다.  
Pinpoint-Monitoring을 설치할 때는 saas_monitoring_url 값을 변경 하여 설치 할 수 있다.  

```
# BOSH INFO
bosh_url: "http://10.0.1.6"			# BOSH URL (e.g. "https://00.000.0.0")
bosh_client_admin_id: "admin"			# BOSH Client Admin ID
bosh_client_admin_secret: "ert7na4jpewscztsxz48"	# BOSH Client Admin Secret('echo $(bosh int ~/workspace/paasta-5.0/deployment/paasta-deployment/bosh/{iaas}/creds.yml --path /admin_password)' 명령어를 통해 확인 가능)
bosh_director_port: 25555			# BOSH Director Port
bosh_oauth_port: 8443				# BOSH OAuth Port

# PAAS-TA INFO
system_domain: "61.252.53.246.xip.io"		# Domain (xip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"			# PaaS-TA Admin Username
paasta_admin_password: "admin"			# PaaS-TA Admin Password
paasta_nats_ip: "10.0.1.121"
paasta_nats_port: 4222
paasta_nats_user: "nats"
paasta_nats_password: "7EZB5ZkMLMqT73h2JtxPv1fvh3UsqO"	# PaaS-TA Nats Password (CredHub 로그인후 'credhub get -n /micro-bosh/paasta/nats_password' 명령어를 통해 확인 가능)
paasta_nats_private_networks_name: "default"	# PaaS-TA Nats 의 Network 이름
paasta_database_ips: "10.0.1.123"		# PaaS-TA Database IP(e.g. "10.0.1.123")
paasta_database_port: 5524			# PaaS-TA Database Port(e.g. 5524)
paasta_cc_db_id: "cloud_controller"		# CCDB ID(e.g. "cloud_controller")
paasta_cc_db_password: "cc_admin"		# CCDB Password(e.g. "cc_admin")
paasta_uaa_db_id: "uaa"				# UAADB ID(e.g. "uaa")
paasta_uaa_db_password: "uaa_admin"		# UAADB Password(e.g. "uaa_admin")
paasta_api_version: "v3"


# UAAC INFO
uaa_client_admin_id: "admin"			# UAAC Admin Client Admin ID
uaa_client_admin_secret: "admin-secret"		# UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"	# UAAC Portal Client에 접근하기 위한 Secret 변수

# Monitoring INFO
metric_url: "10.0.161.101"			# Monitoring InfluxDB IP
syslog_address: "10.0.121.100"            	# Logsearch의 ls-router IP
syslog_port: "2514"                          	# Logsearch의 ls-router Port
syslog_transport: "relp"                        # Logsearch Protocol
saas_monitoring_url: "61.252.53.248"	   	# Pinpoint HAProxy WEBUI의 Public IP
monitoring_api_url: "61.252.53.241"        	# Monitoring-WEB의 Public IP

### Portal INFO
portal_web_user_ip: "52.78.88.252"
portal_web_user_url: "http://portal-web-user.52.78.88.252.xip.io" 

### ETC INFO
abacus_url: "http://abacus.61.252.53.248.xip.io"	# Abacus URL (e.g. "http://abacus.xxx.xxx.xxx.xxx.xip.io")
```


### <div id='232'>● pinpoint-vars.yml
	
모니터링 하려는 VM에 접근을 하기 위해 PemSSH의 값을 true로 한다면 BOSH를 설치할때 IaaS의 VM을 만들 수 있는 권한을 주었던 Key를 같은 폴더에 있는 pem.yml에 같은 형식으로 복사하여야 한다.

```
### On-Demand Bosh Deployment Name Setting ###
deployment_name: "pinpoint-monitoring"			# On-Demand Deployment Name
#### Main Stemcells Setting ###
stemcell_os: "ubuntu-xenial"				# Deployment Main Stemcell OS
stemcell_version: "315.36"				# Main Stemcell Version
stemcell_alias: "default"   				# Main Stemcell Alias
#### On-Demand Release Deployment Setting ### 
releases_name:  "paasta-pinpoint-monitoring-release"	# On-Demand Release Name
public_networks_name: "vip"				# Pinpoint Public Network Name
PemSSH: "true"						# h_master에서 모니터링 하려는 VM에 SSH접근시 사용하는 Key File 지정 여부(default:false) 


# H-Master
h_master_azs: ["z3"]					# H-Master 가용 존
h_master_instances: 1					# H-Master 인스턴스 수
h_master_vm_type: "small-highmem-16GB"			# H-Master VM 종류
h_master_network: "default"				# H-Master 네트워크
h_master_persistent_disk_type: "30GB"			# H-Master 영구 Disk 종류

# COLLECTOR
collector_azs: ["z3"]					# Collector 가용 존
collector_instances: 1					# Collector 인스턴스 수
collector_vm_type: "small-highmem-16GB"			# Collector VM 종류
collector_network: "default"				# Collector 네트워크
collector_persistent_disk_type: "30GB"			# Collector 영구 Disk 종류

# PINPOINT-WEB
pinpoint_web_azs: ["z3"]				# Pinpoint-WEB 가용 존
pinpoint_web_instances: 1				# Pinpoint-WEB 인스턴스 수
pinpoint_web_vm_type: "small-highmem-16GB"		# Pinpoint-WEB VM 종류
pinpoint_web_network: "default"				# Pinpoint-WEB 네트워크
pinpoint_web_persistent_disk_type: "30GB"		# Pinpoint-WEB 영구 Disk 종류

# HAPROXY-WEBUI
haproxy_webui_azs: ["z7"]				# HAProxy-WEBUI 가용 존
haproxy_webui_instances: 1				# HAProxy-WEBUI 인스턴스 수
haproxy_webui_vm_type: "small-highmem-16GB"		# HAProxy-WEBUI VM 종류
haproxy_webui_network: "default"			# HAProxy-WEBUI 네트워크
haproxy_webui_persistent_disk_type: "30GB"		# HAProxy-WEBUI 영구 Disk 종류
```

### <div id='233'>● deploy-pinpoint.sh
```
echo 'y' | bosh -e micro-bosh -d pinpoint-monitoring deploy paasta-pinpoint.yml \
	-o use-public-network.yml \
	-l pinpoint-vars.yml \
	-l ../../common/common_vars.yml \
	-l pem.yml
```

### <div id='234'>● deploy-pinpoint-vsphere.sh
```
echo 'y' | bosh -e micro-bosh -d pinpoint-monitoring deploy paasta-pinpoint.yml \
	-o use-public-network-vsphere.yml \
	-l pinpoint-vars.yml \
	-l ../../common/common_vars.yml \
	-l pem.yml
```

## <div id='24'> 2.4. Pinpoint Monitoring 설치
	
- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/pinpoint-monitoring/deploy-pinpoint.sh

```
echo 'y' | bosh -e {director_name} -d pinpoint-monitoring deploy paasta-pinpoint.yml \
	-o use-public-network.yml \
	-l pinpoint-vars.yml \
	-l ../../common/common_vars.yml \
	-l pem.yml
```

- Pinpoint Monitoring 설치 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ~/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring
$ sh deploy-pinpoint.sh
```

## <div id='25'/>2.5. Pinpoint Monitoring 설치 - 다운로드 된 Release 파일 이용 방식

- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 작업 경로로 위치시킨다.  
  
  - 설치 파일 다운로드 위치 : https://paas-ta.kr/download/package    

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/paasta-monitoring

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ cd ${HOME}/workspace/paasta-5.0/release/paasta-monitoring
$ ls
..................
paasta-pinpoint-monitoring-release.tgz
..................
```

- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/pinpoint-monitoring/deploy-pinpoint.sh

```
echo 'y' | bosh -e {director_name} -d pinpoint-monitoring deploy paasta-pinpoint.yml \
	-o use-compiled-releases-logsearch.yml \
	-o use-public-network.yml \
	-l pinpoint-vars.yml \
	-l ../../common/common_vars.yml \
	-l pem.yml
```

- Pinpoint Monitoring 설치 Shell Script 파일 실행 (BOSH 로그인 필요)

```
$ cd ~/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring
$ sh deploy-pinpoint.sh
```

## <div id='26'/>2.6. 서비스 설치 확인
Pinpoint Monitoring이 설치 완료 되었음을 확인한다.
```
$ bosh –e {director_name} vms


$ bosh -e micro-bosh -d paasta-pinpoint-monitoring vms
Deployment 'paasta-pinpoint-monitoring'

Instance                                            Process State  AZ  IPs           VM CID               VM Type             Active  
collector/a7932462-5a55-4ad6-9a50-6d9775d8391a      running        z3  10.0.81.122   i-0104012f0c4cf1051  caas_small_highmem  true  
h_master/7024f1d8-7911-4cc6-ac5c-8d9295221efa       running        z3  10.0.81.121   i-02b1cd70c35117d8d  caas_small_highmem  true  
haproxy_webui/b30b856c-ad74-4ff5-a9ee-32e2ef641ffa  running        z7  10.0.0.122    i-046052aa5360f6b6f  caas_small_highmem  true  
								       15.165.3.150                                             
pinpoint_web/c23b79cf-ef55-42f5-9c2a-b8102b6e5ca8   running        z3  10.0.81.123   i-02a82ab6f02784317  caas_small_highmem  true 
```

## <div id='27'> 2.7. security-group 등록
Pinpoint collector와 배포 app간 통신을 위한  처리.

```
$ vi pinpoint-asg.json

[
  {
    "protocol": "all",
    "destination": "xx.x.xx.0/24",
    "log": true,
    "description": "Allow tcp traffic to Z3"
  }
]
```

```
$ cf create-security-group pinpoint pinpoint-asg.json
```

```
$ cf bind-staging-security-group pinpoint
```

```
$ cf bind-running-security-group pinpoint
```

## <div id='28'> 2.8. Pinpoint User-Provided service 등록

Pinpoint 서비스팩 배포가 완료 되었으면 Application에서 서비스 팩을 사용하기 위해서 먼저 Pinpoint User-Provided service를 등록해 주어야 한다.

User-Provided service 등록시 PaaS-TA에서 서비스를 등록 할 수 있는 사용자로 로그인이 되어 있어야 한다.

-   서비스 목록을 확인한다.

```
$ cf services
```
```
Getting services as admin...

name   url
No service brokers found
```

-   Pinpoint User-Provided service를 등록한다.

```
$ cf cups {서비스 이름} -p '{"application_name":"{App Name}", "collector_host":"{PINOINT COLLECTOR IP}","collector_span_port":"{COLLECTOR SPAN PORT}","collector_stat_port":"{COLLECTOR START PORT}","collector_tcp_port":"{COLLECTOR TCP PORT}"}' -t 'pinpoint'
```

```
$ cf cups pinpoint_monitoring_service -p '{"application_name":"spring-music-pinpoint","collector_host":"10.0.81.122","collector_span_port":"29996","collector_stat_port":"29995","collector_tcp_port":"29994"}'  -t 'pinpoint'
```
```
Creating user provided service pinpoint_monitoring_service in  as admin...
OK
```

-   등록된 Pinpoint User-Provided service를 확인한다.

```
$ cf services
```
```
Getting services as admin...
name url
pinpoint_monitoring_service   user-provided 
```

#  <div id='3'> 3. Sample Web App 연동 Pinpoint 연동

본 Sample Web App은 개방형 클라우드 플랫폼에 배포되며 Pinpoint의 서비스를 Provision과 Bind를 한 상태에서 사용이 가능하다.

### <div id='31'> 3.1. Sample Web App 구조

Sample Web App은 PaaS-TA에 App으로 배포가 된다. 배포된 App에 Pinpoint 서비스 Bind 를 통하여 초기 데이터를 생성하게 된다.  
바인드 완료 후 연결 URL을 통하여 브라우저로 해당 App에 대한 Pinpoint 서비스 모니터링을 할 수 0있다.

-   Spring-music App을 이용하여 Pinpoint 모니터링을 테스트 하였다.
-   앱을 다운로드 후 –b 옵션을 주어 buildpack을 지정하여 Push 해 놓는다.

```
$ cf push -b java_buildpack_pinpoint --no-start
```

```
Using manifest file /home/ubuntu/workspace/user/arom/spring-music/manifest.yml

Creating app spring-music-pinpoint in org org / space space as admin...
OK

Creating route spring-music-pinpoint.monitoring.open-paas.com...
OK

Binding spring-music-pinpoint.monitoring.open-paas.com to spring-music-pinpoint...
OK

Uploading spring-music-pinpoint...
Uploading app files from: /tmp/unzipped-app175965484
Uploading 21.2M, 126 files
Done uploading               
OK
```

```
$ cf apps
```
```
Getting apps in org org / space space as admin...
OK

name                    requested state   instances   memory   disk   urls
spring-music-pinpoint   stopped           0/1         512M     1G     spring-music-pinpoint.monitoring.open-paas.com
```

### <div id='32'> 3.2. Sample Web App에 서비스 바인드 신청 및 App 확인
-------------------------------------------------

Sample Web App에서 Pinpoint 서비스를 사용하기 위해서는 서비스 신청(Provision)을 해야 한다.

```  
$ cf bind-service {App명} {서비스명}
```
```
서비스명 : p-Pinpoint로 Marketplace에서 보여지는 서비스 명칭이다.
서비스플랜 : 서비스에 대한 정책으로 plans에 있는 정보 중 하나를 선택한다. Pinpoint 서비스는 10 connection, 100 connection 를 지원한다.
내서비스명 : 내 서비스에서 보여지는 명칭이다. 이 명칭을 기준으로 환경설정정보를 가져온다.

```

```
$ cf bind-service spring-music-pinpoint pinpoint_monitoring_service
```

-   생성된 Pinpoint 서비스 인스턴스를 확인한다.

```
$ cf services
```
```
Getting services in org org / space space as admin...
OK

name             service         plan                bound apps               last operation
pinpoint_monitoring_service   user-provided                       spring-music-pinpoint                                               
```
-   바인드가 적용되기 위해서 App을 restage한다.(최초 app실행시 cf start {App명})

```
$ cf restage spring-music-pinpoint
```
```

Restaging app spring-music-pinpoint in org org / space space as admin...
Downloading binary_buildpack...
Downloading go_buildpack...
Downloading staticfile_buildpack...
Downloading java_buildpack...
Downloading ruby_buildpack...
Downloading nodejs_buildpack...
Downloading python_buildpack...
Downloading php_buildpack...
Downloaded python_buildpack
Downloaded binary_buildpack
Downloaded go_buildpack
Downloaded java_buildpack
Downloaded ruby_buildpack
Downloaded nodejs_buildpack
Downloaded staticfile_buildpack
Downloaded php_buildpack
Creating container
Successfully created container
Downloading app package...
Downloaded app package (24.5M)
Downloading build artifacts cache...
Downloaded build artifacts cache (54.1M)
Staging...
-----> Java Buildpack Version: v3.7.1 | https://github.com/cloudfoundry/java-buildpack.git#78c3d0a
-----> Downloading Open Jdk JRE 1.8.0_91-unlimited-crypto from https://java-buildpack.cloudfoundry.org/openjdk/trusty/x86_64/openjdk-1.8.0_91-unlimited-crypto.tar.gz (found in cache)
     Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (1.6s)
-----> Downloading Open JDK Like Memory Calculator 2.0.2_RELEASE from https://java-buildpack.cloudfoundry.org/memory-calculator/trusty/x86_64/memory-calculator-2.0.2_RELEASE.tar.gz (found in cache)
     Memory Settings: -XX:MaxMetaspaceSize=64M -Xss995K -Xmx382293K -Xms382293K -XX:MetaspaceSize=64M
-----> Downloading Spring Auto Reconfiguration 1.10.0_RELEASE from https://java-buildpack.cloudfoundry.org/auto-reconfiguration/auto-reconfiguration-1.10.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Instance 8.0.39 from https://java-buildpack.cloudfoundry.org/tomcat/tomcat-8.0.39.tar.gz (found in cache)
     Expanding Tomcat Instance to .java-buildpack/tomcat (0.1s)
-----> Downloading Tomcat Lifecycle Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-lifecycle-support/tomcat-lifecycle-support-2.5.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Logging Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-logging-support/tomcat-logging-support-2.5.0_RELEASE.jar (found in cache)
-----> Downloading Tomcat Access Logging Support 2.5.0_RELEASE from https://java-buildpack.cloudfoundry.org/tomcat-access-logging-support/tomcat-access-logging-support-2.5.0_RELEASE.jar (found in cache)
Exit status 0
Staging complete
Uploading droplet, build artifacts cache...
Uploading droplet...
Uploading build artifacts cache...
Uploaded build artifacts cache (54.1M)
Uploaded droplet (77.3M)
Uploading complete

0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
1 of 1 instances running

App started


OK
```
-   App이 정상적으로 Pinpoint 서비스를 사용하는지 확인한다.

![pinpoint_image_03]

-  환경변수 확인

```
$ cf env spring-music-pinpoint
```
```
Getting env variables for app spring-music-pinpoint in org org / space space as admin...
OK

System-Provided:
{
"VCAP_SERVICES": {
"user-provided": [
 {
  "credentials": {
   "application_name": "spring-music-pinpoint",
   "collector_host": "10.0.81.122",
   "collector_span_port": 29996,
   "collector_stat_port": 29995,
   "collector_tcp_port": 29994
  },
  "label": "user-provided",
  "instance_name": "pinpoint_monitoring_service",
  "name": "pinpoint_monitoring_service",
  "syslog_drain_url": null,
  "tags": [],
  "volume_mounts": []
 }
]
}
}

{
"VCAP_APPLICATION": {
"application_id": "b010e6e9-5431-4198-81f8-7d6ba9c14f40",
"application_name": "spring-music-pinpoint",
"application_uris": [
 "spring-music-pinpoint.monitoring.open-paas.com"
],
"application_version": "9a600116-97bd-45da-a33e-3b0d5592b1d0",
"limits": {
 "disk": 1024,
 "fds": 16384,
 "mem": 512
},
"name": "spring-music-pinpoint",
"space_id": "bc70b951-d870-49ca-b57d-5c7137060e5e",
"space_name": "space",
"uris": [
 "spring-music-pinpoint.monitoring.open-paas.com"
],
"users": null,
"version": "9a600116-97bd-45da-a33e-3b0d5592b1d0"
}
}

No user-defined env variables have been set

No running env variables have been set

No staging env variables have been set
```

- App 정상 구동 확인
```
$ curl http://15.165.3.150:8079/#/main/spring-music-pinpoint@TOMCAT
```

[pinpoint_image_01]:./images/pinpoint-image1.png
[pinpoint_image_03]:./images/pinpoint-image3.png
