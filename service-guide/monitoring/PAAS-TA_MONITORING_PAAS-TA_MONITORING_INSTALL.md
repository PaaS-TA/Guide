## Table of Contents
1\. [개요](#1)  
2\. [PaaS-TA Monitoring 설치](#2)  
　2.1\. [Prerequisite](#3)  
　2.2\. [설치 파일 다운로드](#4)  
　2.3\. [PaaS-TA Monitoring 설치 환경설정](#5)  
　　● [common_vars.yml](#6)  
　　● [paasta-monitoring-vars.yml](#7)  
　　● [deploy-paasta-monitoring.sh](#8)  
　2.4\. [PaaS-TA Monitoring 설치](#9)  
　2.5\. [PaaS-TA Monitoring 설치 - 다운로드 된 Relases 파일 이용 방식](#10)  
　2.6\. [서비스 설치 확인](#11)  
3\. [PaaS-TA Monitoring Dashboard 접속](#12)  


## <div id='1'/>1. 개요

본 문서(PaaS-TA Monitoring 설치 가이드)는 전자정부프레임워크 기반의 PaaS-TA 5.0 환경 기준으로 BOSH 2.0을 이용하여 PaaS-TA Monitoring 설치를 위한 가이드를 제공한다.

## <div id='2'/>2. PaaS-TA Monitoring 설치
### <div id='3'/>2.1. Prerequisite

1. BOSH 설치가 되어있으며, BOSH Login이 되어 있어야 한다.
2. cloud-config와 runtime-config가 업데이트 되어있는지 확인한다.
3. Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell(ubuntu xenial 315.36)이 업로드 되어 있는 것을 확인한다.
4. PaaS-TA 5.0이 설치되어 있어야 하며, BOSH와 PaaS-TA를 설치하는 과정에서 Monitoring 옵션을 포함하여 설치되어 있어야 한다.
5. PaaS(logsearch), IaaS(Monasca), SaaS(PaaS-TA Pinpoint Monitoring), CaaS(PaaS-TA CaaS Service)등 Monitoring을 하고 싶은 환경에 해당되는 서비스가 설치되어 있어야 한다. (logsearch 설치 필수)

> cloud-config 확인  
> $ bosh -e {director-name} cloud-config  

> runtime-config 확인  
> $ bosh -e {director-name} runtime-config  

> stemcell 확인  
> $ bosh -e {director-name} stemcells  


### <div id='4'/>2.2. 설치 파일 다운로드

- PaaS-TA Monitoring을 설치하기 위한 deployment가 존재하지 않는다면 다운로드 받는다
```
$ cd ${HOME}/workspace/paasta-5.0/deployment
$ git clone https://github.com/PaaS-TA/common.git 
$ git clone https://github.com/PaaS-TA/monitoring-deployment.git
```

![PaaSTa_release_dir_5.0]

### <div id='5'/>2.3. PaaS-TA Monitoring 설치 환경설정

${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring 이하 디렉터리에는 PaaS-TA Monitoring 설치를 위한 Shell Script 파일이 존재한다.

### <div id='6'/>● common_vars.yml
common 폴더에 있는 common_vars.yml PaaS-TA 및 각종 Service 설치시 적용하는 공통 변수 설정 파일이 존재한다.
PaaS-TA Monitoring을 설치할 때는 paasta_admin_username, paasta_admin_password, metric_url, monitoring_api_url, saas_monitoring_url 값을 변경 하여 설치 할 수 있다.
paasta_admin_username, paasta_admin_password는 PaaS-TA를 설치할 때의 변수값과 같은 값을 주어 설치를 한다
metric_url는 Monitoring 옵션을 포함한 BOSH와 PaaS-TA를 설치할 때의 변수값과 같은 값을 주어 설치를 한다.
saas_monitoring_url는 Pinpoint Monitoring을 설치할 때의 변수값과 같은 값을 주어 설치를 한다.
```
# BOSH
bosh_url: "10.0.1.6"				# BOSH URL ('bosh env' 명령어를 통해 확인 가능)
bosh_client_admin_id: "admin"			# BOSH Client Admin ID
bosh_client_admin_secret: "ert7na4jpewscztsxz48"	# BOSH Client Admin Secret

# PAAS-TA
system_domain: "61.252.53.246.xip.io"		# Domain (xip.io를 사용하는 경우 HAProxy Public IP와 동일)
paasta_admin_username: "admin"			# PaaS-TA Admin Username
paasta_admin_password: "admin"			# PaaS-TA Admin Password
uaa_client_admin_secret: "admin-secret"		# UAAC Admin Client에 접근하기 위한 Secret 변수
uaa_client_portal_secret: "clientsecret"	# UAAC Portal Client에 접근하기 위한 Secret 변수

# MONITORING
metric_url: "10.0.161.101"			# Monitoring InfluxDB IP
syslog_address: "10.0.121.100"			# Logsearch의 ls-router IP
syslog_port: "2514"				# Logsearch의 ls-router Port
syslog_transport: "relp"			# Logsearch Protocol
monitoring_api_url: "61.252.53.241"		# Monitoring-WEB의 Public IP
saas_monitoring_url: "61.252.53.248"		# Pinpoint HAProxy WEBUI의 Public IP
```

### <div id='7'/>● paasta-monitoring-vars.yml
```
# SERVICE VARIABLE
inception_os_user_name: "ubuntu"
mariadb_ip: "10.0.161.100"		# MariaDB VM Private IP
mariadb_port: "3306"			# MariaDB Port
mariadb_username: "root"		# MariaDB Root 계정 Username
mariadb_password: "password"		# MariaDB Root 계정 Password
director_name: "micro-bosh"		# BOSH Director 명
resource_url: "resource_url"		# TBD
paasta_deploy_name: "paasta"		# PaaS-TA Deployment 명
paasta_cell_prefix: "cell"		# PaaS-TA Cell 명
smtp_url: "smtp.naver.com"		# SMTP Server URL
smtp_port: "587"			# SMTP Server Port
mail_sender: "aaa@naver.com"		# SMTP Server Admin ID
mail_password: "aaaa"			# SMTP Server Admin Password
mail_enable: "true"			# Alarm 발생시 Mail전송 여부
mail_tls_enable: "true"			# SMTP 서버 인증시 TLS모드인경우 true
redis_ip: "10.0.121.101"		# Redis Private IP
redis_password: "password"		# Redis 인증 Password
utc_time_gap: "9"			# UTC Time Zone과 Client Time Zone과의 시간 차이
public_network_name: "vip"		# Monitoring-WEB Public Network Name
system_type: "PaaS,CaaS,SaaS"		# 모니터링 할 환경 선택
prometheus_ip: "10.0.121.122"		# Kubernates의 prometheus-prometheus-prometheus-oper-prometheus-0 Pod의 Node IP
kubernetes_ip: "10.0.0.124"		# Kubernates의 서비스 API IP
pinpoint_was_ip: "10.0.0.122"		# Pinpoint HAProxy WEBUI Private IP
cassbroker_ip: "52.141.6.113"		# CaaS 서비스 로그인 인증 처리를 위한 API IP
kubernetes_token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtb25pdG9yaW5nLWFkbWluLXRva2VuLWQ0OXc3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im1vbml0b3JpbmctYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4MDkwNTU5Yy0wYzE2LTExZWEtYjZiYi0wMDIyNDgwNTk4NzciLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06bW9uaXRvcmluZy1hZG1pbiJ9.ZKPWJLo0LFXY9ZpW7nGlTBLJYDNL7MFB9X1i4JoEn8jPLsCQhG3lvzTjh7420lvoP5hWdV0SpsMMfZnV2WFFUWaQkYcnKhB2qsVX_xOd45gm2IfI-f1QmxcAspoGY_r8kC-vX9L4oTLA5sJTI5m_RIiuckVGcVR0OeWB5NtUFz0-iCpQRfuy9LYH0NCEEopfDji-T0Pxta8S1n8YyxVwYKpZE0PvT9H9ZVNUUAt2Z_l4B0akP6G3O6t53Xvp_l8DXzxRFXTw3sHPvvea_Uv3QbGcFkH-gNHBeG9-F8C8NMcSlCUeyAGfxZlpsdRFMB01Wh6RZzvUqeS8Kc-8Csp_jw"	# Kubernetes 서비스 API Request 호출시 Header(Authorization) 인증을 위한 Token값 

# STEMCELL
stemcell_os: "ubuntu-xenial"		# Stemcell OS
stemcell_version: "315.36"		# Stemcell Version


# REDIS
redis_azs: ["z4"]			# Redis 가용 존
redis_instances: 1			# Redis 인스턴스 수
redis_vm_type: "small"			# Redis VM 종류
redis_network: "default"		# Redis 네트워크

# SANITY-TEST
sanity_tests_azs: ["z4"]		# Sanity-Test 가용 존
sanity_tests_instances: 1		# Sanity-Test 인스턴스 수
sanity_tests_vm_type: "small"		# Sanity-Test VM 종류
sanity_tests_network: "default"		# Sanity-Test 네트워크

# INFLUXDB
influxdb_azs: ["z5"]			# InfluxDB 가용 존
influxdb_instances: 1			# InfluxDB 인스턴스 수
influxdb_vm_type: "large"		# InfluxDB VM 종류
influxdb_network: "default"		# InfluxDB 네트워크
influxdb_persistent_disk_type: "10GB"	# InfluxDB 영구 Disk 종류

# MARIADB
mariadb_azs: ["z5"]			# MariaDB 가용 존
mariadb_instances: 1			# MariaDB 인스턴스 수
mariadb_vm_type: "medium"		# MariaDB VM 종류
mariadb_network: "default"		# MariaDB 네트워크
mariadb_persistent_disk_type: "5GB"	# MariaDB 영구 Disk 종류

# MONITORING-BATCH
monitoring_batch_azs: ["z6"]		# Monitoring-Batch 가용 존
monitoring_batch_instances: 1		# Monitoring-Batch 인스턴스 수
monitoring_batch_vm_type: "small"	# Monitoring-Batch VM 종류
monitoring_batch_network: "default"	# Monitoring-Batch 네트워크

# CAAS-MONITORING-BATCH
caas_monitoring_batch_azs: ["z6"]	# CAAS-Monitoring-Batch 가용 존
caas_monitoring_batch_instances: 1	# CAAS-Monitoring-Batch 인스턴스 수
caas_monitoring_batch_vm_type: "small"	# CAAS-Monitoring-Batch VM 종류
caas_monitoring_batch_network: "default"	# CAAS-Monitoring-Batch 네트워크

# SAAS-MONITORING-BATCH
saas_monitoring_batch_azs: ["z6"]	# SAAS-Monitoring-Batch 가용 존
saas_monitoring_batch_instances: 1	# SAAS-Monitoring-Batch 인스턴스 수
saas_monitoring_batch_vm_type: "small"	# SAAS-Monitoring-Batch VM 종류
saas_monitoring_batch_network: "default"	# SAAS-Monitoring-Batch 네트워크

# MONITORING-WEB
monitoring_web_azs: ["z7"]		# Monitoring-WEB 가용 존
monitoring_web_instances: 1		# Monitoring-WEB 인스턴스 수
monitoring_web_vm_type: "small"		# Monitoring-WEB VM 종류
monitoring_web_network: "default"	# Monitoring-WEB 네트워크
```

#### <div id='8'/>●	deploy-paasta-monitoring.sh
```
bosh -e {director_name} -n -d paasta-monitoring deploy paasta-monitoring.yml  \
	-o use-public-network-openstack.yml \
	-o use-compiled-releases-paasta-monitoring.yml \
	-l paasta-monitoring-vars.yml \
	-l ../../common/common_vars.yml
```

### <div id='9'/>2.4. PaaS-TA Monitoring 설치

- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring/deploy-paasta-monitoring.sh

```
bosh -e {director_name} -n -d paasta-monitoring deploy paasta-monitoring.yml  \
	-o use-public-network-openstack.yml \
	-l paasta-monitoring-vars.yml \
	-l ../../common/common_vars.yml
```

- PaaS-TA Monitoring 설치 Shell Script 파일 실행 (BOSH 로그인 필요)
```
$ cd ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring
$ sh deploy-paasta-monitoring.sh
```

### <div id='10'/>2.5. PaaS-TA Monitoring 설치 - 다운로드 된 Relases 파일 이용 방식


- 서비스 설치에 필요한 릴리즈 파일을 다운로드 받아 Local machine의 작업 경로로 위치시킨다.  
  
  - 설치 파일 다운로드 위치 : https://paas-ta.kr/download/package    

```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.0/release/paasta-monitoring

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ cd ${HOME}/workspace/paasta-5.0/release/paasta-monitoring
$ ls
..................
bpm-1.1.0-ubuntu-xenial-315.36-20190605-202629-386782261.tgz			paasta-monitoring-release.tgz
redis-14.0.1.tgz								influxdb.tgz
..................
```

- 서버 환경에 맞추어 Deploy 스크립트 파일의 설정을 수정한다. 

> $ vi ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring/deploy-paasta-monitoring.sh

```
bosh -e {director_name} -n -d paasta-monitoring deploy paasta-monitoring.yml  \
	-o use-public-network-openstack.yml \
	-o use-compiled-releases-paasta-monitoring.yml \
	-l paasta-monitoring-vars.yml \
	-l ../../common/common_vars.yml
```

- PaaS-TA Monitoring 설치 Shell Script 파일 실행 (BOSH 로그인 필요)
```
$ cd ${HOME}/workspace/paasta-5.0/deployment/monitoring-deployment/paasta-monitoring
$ sh deploy-paasta-monitoring.sh
```

### <div id='11'/>2.6. PaaS-TA Monitoring 설치

PaaS-TA Monitoring이 설치 완료 되었음을 확인한다.
```
$ bosh –e {director_name} vms
```
![PaaSTa_monitoring_vms_5.0]


## <div id='12'/>3. PaaS-TA Monitoring Dashboard 접속
 
 http://{monitoring_api_url}:8080/public/login.html 에 접속하여 회원 가입 후 Main Dashboard에 접속한다.

 Login 화면에서 회원 가입 버튼을 클릭한다.

 ![PaaSTa_monitoring_login_5.0]


member_info에는 사용자가 사용할 ID/PWD를 입력하고 하단 paas-info에는 PaaS-TA admin 권한의 계정을 입력한다.  
PaaS-TA deploy시 입력한 admin/pwd를 입력해야 한다.  
입력후 [인증수행]를 실행후 Join버튼을 클릭하면 회원가입이 완료된다.  

 ![PaaSTa_monitoring_join_5.0]

PaaS-TA Monitoring Main Dashboard 화면

 ![PaaSTa_monitoring_main_dashboard_5.0]


[PaaSTa_release_dir_5.0]:./images/paasta-release_5.0.png
[PaaSTa_logsearch_vms_5.0]:./images/logsearch_5.0.png
[PaaSTa_monitoring_vms_5.0]:./images/paasta-monitoring_5.0.png

[PaaSTa_monitoring_login_5.0]:./images/monit_login_5.0.png
[PaaSTa_monitoring_join_5.0]:./images/member_join_5.0.png
[PaaSTa_monitoring_main_dashboard_5.0]:./images/monit_main_5.0.png

[PaaSTa_paasta_container_service_vms]:./images/paasta-container-service-vms.png
[PaaSTa_paasta_container_service_pods]:./images/paasta-container-service-pods.png
[PaaSTa_paasta_container_service_nodes]:./images/paasta-container-service-nodes.png
[PaaSTa_paasta_container_service_kubernetes_api]:./images/paasta-container-service-kubernetes-api.png
[PaaSTa_paasta_container_service_kubernetes_token]:./images/paasta-container-service-kubernetes-token.png

