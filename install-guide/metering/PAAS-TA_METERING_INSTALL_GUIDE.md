
# Table of Contents
[1. 문서 개요](#)
- [1.1 목적](#1)
 

[2. Abacus 배포](#)    

- [2.1 배포 전제 조건](#2)
- [2.2 필수 프로그램 설치](#3)  
- [2.3 MogoDB,RabbitMQ](#4)  
- [2.4 UAA 계정 등록](#7)  
- [2.5 Abacus 베포를 위한 조직 및 영역 설정](#8)  
- [2.6 cf-abacus 배포](#9)  


[3. API 호출](#)

- [3.1 Token 생성](#10)  
- [3.2 paasta-usage-repoting 데이터 추출](#11)  

<br><br>
# <div id='#'/>1.  문서 개요
<br>		
본 문서(node.js API 서비스 미터링 애플리케이션 개발 가이드)는 파스-타 플랫폼 프로젝트의 미터링 플러그인과 Node.js API 애플리케이션과 연동하여 API 서비스를 미터링하는 방법에 대해 기술 하였다. 

## <div id='1'/>1.1 범위  
본 문서의 범위는 파스-타 플랫폼 프로젝트의 Node.js API 서비스 애플리케이션 개발과 CF-Abacus 연동에 대한 내용으로 한정되어 있다. (CF-Abacus 1.1.5 작성됨)
```
참고 자료  
- https://github.com/cloudfoundry-incubator/cf-abacus  
```
# 2. Abacus 배포

## <div id='2'/>2.1 배포 전제 조건
이 가이드는 ubuntu16.04 및 로컬 설치를 기준으로 작성되어 있다.   
	- Paas-TA가 로컬에 설치 되어 있어야 한다.  
	- CF가 로컬에 설치 되어 있어야 한다.  
	- CF-Cli 가 로컬에 설치 되어 있어야 한다.  
	- 설치 패키지가 로컬에 설치 되어 있어야 한다.  

## <div id='3'/>2.2 필수 프로그램 설치
</br>
- Node.js와 npm은 같이 설치된다  

* CF-Abacus 1.1.5 기준으로 node =>8.1.0 이상  

| 이름 | 버전 |
|--------|-------|
| NPM |8.10.0 이상, 9.0.0 이하|  
| Node.js | 5.0.0 이하 |  
| Yarn | 1.2.1 이상 | 

</br>

## <div id='4'/>2.3 Cf-Abacus 다운로드  
<br>    

```
$ wget https://github.com/cloudfoundry-incubator/cf-abacus/archive/v1.1.5.tar.gz  
$ tar -xvf v1.1.5.tar.gz  
```

## <div id='5'/>2.4 Node.js 설치 순서  
<br>  

```
$ sudo apt-get install curl   
```

```
## Node.js version 8.x를 설치할 경우
## Source Repository 등록
$ curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
```

```
## Node.js & Npm 설치
$ sudo apt-get install -y nodejs
$ sudo npm install -g npm@4
```

```
## Yarn Source Repository
$ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```

```
# Yarn 설치
$ sudo apt-get update && sudo apt-get install yarn
```
 
## <div id='6'/>2.3  MongoDB,RabbitMQ 설치
※ abacus 데이터 저장소로 MongoDB를 사용하며, RabbitMQ를 통하여, 메시지 분산처리를 지원한다.  
※ abacus 데모를 실행하기 위해서는 MongoDB, RabbitMQ를 설치 해야 한다.  
※ CF-Abacus 1.1.5부터는 Docker를 사용하여, 별도의 설정없이 MongoDB, RabbitMQ 설치를 지원한다.   

Docker 설치
```
## Docker Engine 설치  
$ curl -fsSL https://get.docker.com/ | sudo sh  
$ sudo addgroup --system docker  
$ sudo adduser $USER docker  
$ newgrp docker  
$ docker info  

## 다음과 같이 동작시 정상설치됨
```
![METERING_1]  



```
## Docker-Compose 설치
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  
$ sudo chmod +x /usr/local/bin/docker-compose  
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose  
$ docker-compose –version  
## 다음과 같이 동작시 정상설치됨
```
![METERING_2]  

MongoDB , RabbitMQ 실행
```
## docker-compose.yml 위치로 이동
$ cd cf-abacus-1.1.5
## Docker 실행
$ docker-compose up 
## 다음과 같이 실행 될 경우 정상 동작됨
```  
![METERING_3]  
 
## <div id='7'/>2.4 UAA 계정 등록
CF 설치한 abacus에서 CF의 앱 사용량 정보를 수집하기 위해서 CF 접근을 위한 계정 및 토큰을발급 받아야 한다.  
또한 보안 모드로 abacus를 배포한 경우, abacus 컴포넌트간의 데이터 전송을 위한 계정을 등록해야 한다.  

UAA 클라이언트 설치
```
$ gem install cf-uaac
```

CF-Abacus 설치를 위한 Token 추출
```
## CF target 설정
$ uaac target uaa.<CF 도메인> --skip-ssl-validation

예) $ uaac target uaa.bosh-lite.com --skip-ssl-validation
예) $ uaac target https://api.54.180.192.54.xip.io--skip-ssl-validation

## uaac client 토큰 취득
$ uaac token client get <uaac user id> -s <uaac user password>
예) $ uaac token client get admin -s admin-secret
##UAA JWTKEY 추출
$ uaac signing key
kty: RSA
  e: AQAB
  use: sig
  kid: key-1
  alg: RS256
  value: -----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvSCv3ZJDcGovLS5PPk1+
YvAzDMOi0ULBrI/3g59XxgHGaRW1kF9nf1+RUnBYbO0rVw0HyENIz1JBt3Bo0pSc
gyiwG94kpjx5v0qVQ4qYxK3fxN+/UrY09w8Zny/uW/Bh/oKfY/5J0EPyJxs6fSwX
dmfEvu7aohzKypsRBRLy0Vusx3/XO8noA21n8o08g2rbekpMJW+C8CbAXXM0AxQ3
9Oz/fem9/TF0NlacPxJQc+WMCYRLt9BHl16TnZiR/yze08s2CFxfFPWJNvNrmpuW
INRpfDg6CIXczsav1LBBinrjWOTEQqgK+FPxu1iEwUu1/cYCEo4H7F1gHuUOqgQ5
5wIDAQAB
-----END PUBLIC KEY-----
  n: AL0gr92SQ3BqLy0uTz5NfmLwMwzDotFCwayP94OfV8YBxmkVtZBfZ39fkVJwWGztK1cNB8hDSM9SQbdwaNKUnIMosBveJKY8eb9KlUOKmMSt38Tfv1K2NPcPGZ8v7lvwYf6Cn2P-SdBD8icbOn0sF3ZnxL7u2qIcysqbEQUS8tFbrMd_1zvJ6ANtZ_
      KNPINq23pKTCVvgvAmwF1zNAMUN_Ts_33pvf0xdDZWnD8SUHPljAmES7fQR5dek52Ykf8s3tPLNghcXxT1iTbza5qbliDUaXw4OgiF3M7Gr9SwQYp641jkxEKoCvhT8btYhMFLtf3GAhKOB-xdYB7lDqoEOec

Value에 있는값을 추출하여, 별도의 파일에 저장한다.  

## 파일 생성 및 저장 방법
$ cd cf-abacus-1.1.5
$ vim jwtkey.pem
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvSCv3ZJDcGovLS5PPk1+
YvAzDMOi0ULBrI/3g59XxgHGaRW1kF9nf1+RUnBYbO0rVw0HyENIz1JBt3Bo0pSc
gyiwG94kpjx5v0qVQ4qYxK3fxN+/UrY09w8Zny/uW/Bh/oKfY/5J0EPyJxs6fSwX
dmfEvu7aohzKypsRBRLy0Vusx3/XO8noA21n8o08g2rbekpMJW+C8CbAXXM0AxQ3
9Oz/fem9/TF0NlacPxJQc+WMCYRLt9BHl16TnZiR/yze08s2CFxfFPWJNvNrmpuW
INRpfDg6CIXczsav1LBBinrjWOTEQqgK+FPxu1iEwUu1/cYCEo4H7F1gHuUOqgQ5
5wIDAQAB
-----END PUBLIC KEY-----
:wq
저장한다.
```

CF-Abacus 설치를 위한 UAA 클라이언트 
```
## 미터링 자원 사용량 정보에 대한 abacus 접근 권한을 UAA에 등록
$ uaac client add abacus --name <ClientID> --secret <ClientSecret> \
--authorized_grant_types client_credentials \ 
--authorities abacus.usage.write,abacus.usage.read,abacus.usage.linux-container.write,abacus.usage.linux-container.read,abacus.system.read,openid,coud_controller_service_permissions.read,cloud_controller.read,cloud_controller.admin,abacus.usage.sampler.write,reporting.agent.write,clients.admin \ 
--scope abacus.usage.write,abacus.usage.read,abacus.usage.linux-container.write,abacus.usage.linux-container.read,abacus.system.read,openid,cloud_controller_service_permissions.read,cloud_controller.read,cloud_controller.admin,abacus.usage.sampler.write,reporting.agent.write,clients.admin 
예) 
$ uaac client add abacus --name abacus --secret abacus-secret \
--authorized_grant_types client_credentials \ 
--authorities abacus.usage.write,abacus.usage.read,abacus.usage.linux-container.write,abacus.usage.linux-container.read,abacus.system.read,openid,cloud_controller_service_permissions.read,cloud_controller.read,cloud_controller.admin,abacus.usage.sampler.write,reporting.agent.write,clients.admin \ 
--scope abacus.usage.write,abacus.usage.read,abacus.usage.linux-container.write,abacus.usage.linux-container.read,abacus.system.read,openid,cloud_controller_service_permissions.read,cloud_controller.read,cloud_controller.admin,abacus.usage.sampler.write,reporting.agent.write,clients.admin

## Abacus Broker 권한을 UAA에 등록
$ uaac client add <ClientID> -s <ClientSecret> \ 
--authorities reporting.agent.write,abacus.usage.write,clients.admin \ 
--scope reporting.agent.write,abacus.usage.write,clients.admin \ 
--authorized_grant_types client_credentials 
예) 
$uaac client add abacus-broker -s abacus-secret \
--authorities reporting.agent.write,abacus.usage.write,clients.admin \ 
--scope reporting.agent.write,abacus.usage.write,clients.admin \
--authorized_grant_types client_credentials 

## Abacus-Service-Dashboard용 클라이언트 등록
uaac client add <ClientID> -s <ClientSecret> #
--authorized_grant_types authorization_code,refresh_token --redirect_uri ‘<DashboardURL>/manage/instance/*’
--authorities abacus.usage.read,abacus.usage.write,uaa.none 
--scope openid,cloud_controller_service_permissions.read,cloud_controller.read,abacus.usage.read,abacus.usage.write
예)
$ uaac client add abacus-service-dashboard -s abacus-secret --authorized_grant_types authorization_code,refresh_token --redirect_uri 'http://abacus-service-dashboard.115.68.46.188.xip.io/manage/instances/* https://abacus-service-dashboard.115.68.46.188.xip.io/manage/instances/*' --authorities abacus.usage.read,abacus.usage.write,uaa.none --scope openid,cloud_controller_service_permissions.read,cloud_controller.read,abacus.usage.read,abacus.usage.write
```

## <div id='8'/>2.5. Abacus 배포를 위한 조직 및 영역 설정

```
## CF target 설정

$ cf api https://api.<CF 도메인> --skip-ssl-validation
예) $ cf api https://api.bosh-lite.com --skip-ssl-validation
```

```
## CF 로그인

$ cf login
```
```
## 조직 생성 및 설정

$ cf create-org <조직>
$ cf target -o <조직>

```
```
## 영역 생성 및 설정

$ cf create-space <영역>
$ cf target -o <조직> -s <영역>

```

## <div id='9'/>2.6.	cf-abacus 배포

Abacus 기능 개요

| 형상 | 설명 |
|--------|-------|
| abacus-usage-collector |CF 앱 사용량 수집기|  
| abacus-usage-reporting | Abacus가 수집/집계한 미터링 정보에 사용자의 요청에 맞게 보고한다. |  
| abacus-usage-meter | 수집한 CF 앱 사용량의 집계를 위해 미터링 정보를 가공한다.  | 
| abacus-usage-accumulator |수집한 CF 앱 사용량 정보를 계정/조직/영역/앱 별로 누적한다.|  
| abacus-usage-aggregator |누적한 CF 앱 사용량 정보를 계정/조직/영역/앱 별로 집계한다.|  
| abacus-service-bridge |CF와 연동하여 서비스 사용량 정보를 수집한다.|  
| abacus-application-bridge |CF와 연동하여 앱의Container 사용량 정보를 수집한다.|  
| abacus-provisioning-plugin |Abacus의 각 기능에서 수집/누적/집계에 필요한 메타 정보를 제공한다.|  
| abacus-account-plugin |앱의 계정 정보 조회 및 유효성 체크를 수행한다.|  
| abacus-eureka-plugin |Netflix의 Eureka 시스템과 연동하여 Abacus 앱의 분산 처리 서비스를 제공한다.|  
| abacus-cf-renewer |수집된 데이터를 날짜 유형으로 데이터를 이관한다.|  
| abacus-broker |수집/누적/집계에 필요한 메타 정보를 입력할 수 UI 서비스를 제공하는 브로커이다.|  
| abacus-services-dashboard |수집/누적/집계에 필요한 메타 정보를 입력할 수 UI 서비스이다.|  
| abacus-healthchecker |Abacus 서비스들의 상태를 체크한다.|  
| abacus-housekeeper |Abacus 서비스들의 상태를 관리한다.|  

wget을 통해 CF-Abacus를 다운 받는다.
```
$ wget https://github.com/cloudfoundry-incubator/cf-abacus/archive/v1.1.5.tar.gz
$ tar -xvf v1.1.5.tar.gz
## Abacus를 빌드하기 위해서는 Node.js 및 Npm을 사전에 설치해야 한다. 
```

Abacus와 연동할 DB 및 Secure 정보 설정
```
Abacus 설정정보를 리눅스 export 기능을 설정한다.

## Export
# Common 
export ABACUS_PREFIX="" #abacus를 설치할때 설치명에 추가적으로 이름을 붙여 배포할수 있다.
export CF_SYS_DOMAIN=<도메인 #CF의 도메인
export AUTH_SERVER=https://api.<도메인> #CF API 주소
export XSUAA_URL=https://uaa.<도메인> #CF UAA 주소 
export HYSTRIX_CLIENT_ID="abacus"  #abacus hytrix  계정 (임의값 설정)
export HYSTRIX_CLIENT_SECRET="abacus-secret" #abacus hytrix 패스워드 (임의값 설정)
export SYSTEM_CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export SYSTEM_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export CLIENT_SECRET="abacus-secret" #abacus에서 #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)export RENEWER_CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export RENEWER_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export BRIDGE_CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export BRIDGE_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export SERVICE_BRIDGE_CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export SERVICE_BRIDGE_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export XSUAA_CLIENT_ID="abacus" #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export XSUAA_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export XSUAA_TENANT_BACKEND= 
export SECURED=true #기본설정
export SKIP_SSL_VALIDATION=true #SSL을 사용할경우 설정
export JWTALGO=RS256 #
export JWTKEY=$(cat jwtkey.pem) #2.4.2에서 저장한 JWTKEY 위치 지정
export RABBIT_URI=amqp://<docker서버 IP>:5672 # 2.3.2를 실행한 서버 IP주소 
export DB_BRIDGE_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export DB_ACCUMULATOR_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export DB_AGGREGATOR_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export DB_COLLECTOR_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export DB_METER_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export DB_PLUGINS_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소
export REPORTING_EVAL_VMTYPE=vm export APPLICATION_GROUPS=7 export EVAL_TIMEOUT=100 
export APPLICATIONS_LAST_RECORDED_GUID= 
export SERVICES_LAST_RECORDED_GUID= #공백
export COLLECTOR_RATE_LIMIT=   #공백

#Service Bridge 
export METERING_SERVICES='{"Mysql-DB":{"plans":["Mysql-Plan1-10con","Mysql-Plan2-100con"]}}'  # 모니터링할 서비스 등록
기본. JSON
{"Mysql-DB": 서비스명
{
"plans": 서비스 플랜
[ "Mysql-Plan1-10con",
"Mysql-Plan2-100con"]
}
}

# Dashbaord 
export CF_API_URI=https://api.<도메인> 
export UAA_URL=https://uaa.<도메인>
export DASHBOARD_DB_URI=mongodb://<docker서버 IP>:27017 # 2.3.2를 실행한 서버 IP주소

# Abacus Service Broker 
export UAA_URL=https://uaa.<도메인> 
export MAPPING_API="abacus-provisioning-plugin" 
export BROKER_USER=”abacus” " #abacus에서 CF와 통신을 위한 Client ID (2.4.2 설정한 미터링 Client)
export BROKER_PASSWORD="abacus-secret"  #abacus에서 CF와 통신을 위한 Client 패스워드 (2.4.2 설정한 미터링 Client 패스워드)
export METERING_BROKER_CLIENT_ID="abacus-broker" #abacus에서 CF와 통신을 위한 Client ID(2.4.2 설정한 브로커 Client)
export METERING_BROKER_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드(2.4.2 설정한 브로커 Client 패스워드)
export METERING_BROKER_DASHBOARD_CLIENT_ID="abacus-service-dashboard" #abacus에서 CF와 통신을 위한 Client ID(2.4.2 설정한 Dashboard Client)
export METERING_BROKER_DASHBOARD_CLIENT_SECRET="abacus-secret" #abacus에서 CF와 통신을 위한 Client 패스워드(2.4.2 설정한 Dashboard Client 패스워드)
export DASHBOARD_REDIRECT_URI="http://abacus-service-dashboard.<도메인>/manage/instances/*" # Service Dashbaord가 설치된 URI정보 /manage/instances/*" 변경불가
export DASHBOARD_URI=http://abacus-service-dashboard.<도메인>/manage/instances/ # Service Dashbaord가 설치된 URI정보 /manage/instances/ 변경불가
```

Abacus 빌드
```
$ cd cf-abacus-1.1.5
$ yarn install	
```

Abacus 배포 전 불필요 서비스 설치 제한
```
$ cd cf-abacus-1.1.5
$ vim bin/cfpush

![METERING_5]

빨간 네모삭제의 내용을 삭제 후 아래의 내용으로 바꾼다.

if [ "$APPNAME" != "abacus-healthchecker" -a "$APPNAME" != "abacus-service-dashboard" -a "$APPNAME" != "abacus-broker" -a "$APPNAME" !=  "abacus-housekeeper" ]; then
  if [ "$APPS" == "0" ]; then
    COMMANDS+=("(cfpush -n $APPNAME -p $MODULE -i $INSTANCES -s -r $PUSH_RETRIES $CF_STACK_OPTION)")
  else
    for I in $(seq 0 $APPS); do
      COMMANDS+=("(cfpush -n $APPNAME-$I -p $MODULE -i $INSTANCES -s -r $PUSH_RETRIES $CF_STACK_OPTION)")
    done
  fi
fi


불필요 서비스 
abacus-healthchecker, abacus-service-dashboard, abacus-broker, abacus-housekeeper 에 대한 설치를 제한하는 설정이다.
```


Abacus 배포
```
$ cd cf-abacus-1.1.5

## abacus 설치를 위한 CF 타겟 지정 Security 그룹을 설정해야한다.
$ bin/cfsetup 

Enter your API URL [https://api.bosh-lite.com]: https://api.bosh-lite.com ## CF API EndPoint
Enter your user name [admin]: admin       ## <계정 ID>
Enter your organization [abacus]: abacus  ## <조직>
Enter your space [dev]: dev               ## <영역>
API endpoint: https://api.bosh-lite.com

Password>                                 ## <계정 비밀번호>
Authenticating...
OK

Targeted org abacus

Targeted space dev
                   
API endpoint:   https://api.bosh-lite.com (API version: 2.62.0)   
User:           admin   
Org:            abacus   
Space:          dev   
Creating security group abacus as admin
OK
Assigning security group abacus to space dev in org abacus as admin...
OK


TIP: Changes will not apply to existing running applications until they are restarted.

## 타겟으로 지정한 조직 / 영역에 대해 abacus앱을 배포한다.
※ 주의: CF의 Nodejs Build Pack 버전이 낮을 경우 cfpush는 실패한다. CF의 Nodejs build pack 버전이 낮을 경우, 반드시 Nodejs build pack을 업그레이드 한다.
$ yarn run cfpush

## abacus 설치 형상 확인
$ cf a



*abacus-service-dashboard,healthchecker, housekeeper는 필수사항이 아님, 필요시 설치 메타데이터 설정을 진행후 재시작해야 정상적으로 서비스가 시작됨

abacus-meta-data 설정
배포한 abacus는 데이터 수집을 하지만, 메타데이터가 없는 관계로 정상적으로 저장이 되지 않는다. 따라서 기본 메타데이터를 입력하는 절차를 진행해야 한다. 
$ cd <abacus 경로>/lib/plugins/provisioning

## yarn install
$ yarn install

## 데이터 연동을 위한 Meta-data 설정
$ yarn run store-defaults

## 전체 앱을 재시작해야한다.

```


# <div id='#'/>3.	API 호출  
설치된 CF-ABACUS에 대한 데이터 호출 방법을 설명한다.  
## <div id='10'/>3.1	Token 생성  

```
$curl -X POST   'https://uaa.115.68.46.188.xip.io/oauth/token?client_id=abacus&client_secret=abacus-secret&grant_type=client_credentials&scopre=reporting.agent.write%20,%20abacus.usage.write'   -H 'Content-Type: application/x-www-form-urlencoded' -H 'cache-control: no-cache' -k
다음과같이 출력되면

{
"access_token":"eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vdWFhLjExNS42OC40Ni4xODgueGlwLmlvL3Rva2VuX2tleXMiLCJraWQiOiJrZXktMSIsInR5cCI6IkpXVCIsImN0eSI6bnVsbH0.eyJqdGkiOiI0ZDdjZmQ4Y2JkZGI0NGMxYjkyYWFlYmVmYzFiNzlmYiIsInN1YiI6ImFiYWN1cyIsImF1dGhvcml0aWVzIjpbImNvdWRfY29udHJvbGxlcl9zZXJ2aWNlX3Blcm1pc3Npb25zLnJlYWQiLCJjbG91ZF9jb250cm9sbGVyLnJlYWQiLCJhYmFjdXMudXNhZ2Uuc2FtcGxlci53cml0ZSIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIucmVhZCIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIud3JpdGUiLCJhYmFjdXMuc3lzdGVtLnJlYWQiLCJvcGVuaWQiLCJhYmFjdXMudXNhZ2Uud3JpdGUiLCJhYmFjdXMudXNhZ2UucmVhZCIsInJlcG9ydGluZy5hZ2VudC53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIuYWRtaW4iXSwic2NvcGUiOlsiY291ZF9jb250cm9sbGVyX3NlcnZpY2VfcGVybWlzc2lvbnMucmVhZCIsImNsb3VkX2NvbnRyb2xsZXIucmVhZCIsImFiYWN1cy51c2FnZS5zYW1wbGVyLndyaXRlIiwiYWJhY3VzLnVzYWdlLmxpbnV4LWNvbnRhaW5lci5yZWFkIiwiYWJhY3VzLnVzYWdlLmxpbnV4LWNvbnRhaW5lci53cml0ZSIsImFiYWN1cy5zeXN0ZW0ucmVhZCIsIm9wZW5pZCIsImFiYWN1cy51c2FnZS53cml0ZSIsImFiYWN1cy51c2FnZS5yZWFkIiwicmVwb3J0aW5nLmFnZW50LndyaXRlIiwiY2xvdWRfY29udHJvbGxlci5hZG1pbiJdLCJjbGllbnRfaWQiOiJhYmFjdXMiLCJjaWQiOiJhYmFjdXMiLCJhenAiOiJhYmFjdXMiLCJncmFudF90eXBlIjoiY2xpZW50X2NyZWRlbnRpYWxzIiwicmV2X3NpZyI6ImI0NTc4NmVjIiwiaWF0IjoxNTU0MzQyOTU3LCJleHAiOjE1NTQzODYxNTcsImlzcyI6Imh0dHBzOi8vdWFhLjExNS42OC40Ni4xODgueGlwLmlvL29hdXRoL3Rva2VuIiwiemlkIjoidWFhIiwiYXVkIjpbImNsb3VkX2NvbnRyb2xsZXIiLCJhYmFjdXMuc3lzdGVtIiwiY291ZF9jb250cm9sbGVyX3NlcnZpY2VfcGVybWlzc2lvbnMiLCJvcGVuaWQiLCJhYmFjdXMudXNhZ2UiLCJhYmFjdXMudXNhZ2Uuc2FtcGxlciIsImFiYWN1cyIsInJlcG9ydGluZy5hZ2VudCIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIiXX0.MuSJ0cNfQxzqKJ7DBfroF4cJJu-GIu7e-fR-nwt6vuSXAozS4H7-0jML_D9WVP6yp71pRp7MDMOPAjLofwInYtuvlaIFYbvAvVRvofkA4Jhnuqi_YCX6nqX932c2rYCXTomRPEtElruxgM8iWBoqNGzENtO3paop9aETRbqiEm5eRTzwtjnz9dyysWL7mPEi7yUqW4UDbApYsAlqIkK5LHIzymVlpxXYMeey6_5aACwtvBverYC713SRFQwQStnkn1bv7XWkYTcH3cIAOjlpUQmbuyCc6hIRjZpvXBS73q_xNtzjr5SOWoYoB7pLh-p-9niQ2n8IK0tWj0gkG0giLQ",
"token_type":"bearer",
"expires_in":43199,
"scope":"coud_controller_service_permissions.read cloud_controller.read abacus.usage.sampler.write abacus.usage.linux-container.read abacus.usage.linux-container.write abacus.system.read openid abacus.usage.write abacus.usage.read reporting.agent.write cloud_controller.admin",
"jti":"4d7cfd8cbddb44c1b92aaebefc1b79fb"
}

access_token 을 추출한다.
```

## <div id='11'/>3.2 paasta-usage-repoting 데이터 추출
```
## org guid 추출
$ cf org <org명> --guid

## Repoting 데이터 추출
curl -X GET \
https://abacus-usage-reporting.<DOMAIN주소>/v1/metering/organizations/<ORG_GUID>/aggregated/usage/ \
-H 'Authorization: bearer <-- 3.1에서 추출한 Token값으로 변경
eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vdWFhLjExNS42OC40Ni4xODgueGlwLmlvL3Rva2VuX2tleXMiLCJraWQiOiJrZXktMSIsInR5cCI6IkpXVCIsImN0eSI6bnVsbH0.eyJqdGkiOiI4OWQwOWY2ZmFiM2E0NTVjYjllZGNlZjgwNTk1OTAyZiIsInN1YiI6ImFiYWN1cyIsImF1dGhvcml0aWVzIjpbImNvdWRfY29udHJvbGxlcl9zZXJ2aWNlX3Blcm1pc3Npb25zLnJlYWQiLCJjbG91ZF9jb250cm9sbGVyLnJlYWQiLCJhYmFjdXMudXNhZ2Uuc2FtcGxlci53cml0ZSIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIucmVhZCIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIud3JpdGUiLCJhYmFjdXMuc3lzdGVtLnJlYWQiLCJvcGVuaWQiLCJhYmFjdXMudXNhZ2Uud3JpdGUiLCJhYmFjdXMudXNhZ2UucmVhZCIsInJlcG9ydGluZy5hZ2VudC53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIuYWRtaW4iXSwic2NvcGUiOlsiY291ZF9jb250cm9sbGVyX3NlcnZpY2VfcGVybWlzc2lvbnMucmVhZCIsImNsb3VkX2NvbnRyb2xsZXIucmVhZCIsImFiYWN1cy51c2FnZS5zYW1wbGVyLndyaXRlIiwiYWJhY3VzLnVzYWdlLmxpbnV4LWNvbnRhaW5lci5yZWFkIiwiYWJhY3VzLnVzYWdlLmxpbnV4LWNvbnRhaW5lci53cml0ZSIsImFiYWN1cy5zeXN0ZW0ucmVhZCIsIm9wZW5pZCIsImFiYWN1cy51c2FnZS53cml0ZSIsImFiYWN1cy51c2FnZS5yZWFkIiwicmVwb3J0aW5nLmFnZW50LndyaXRlIiwiY2xvdWRfY29udHJvbGxlci5hZG1pbiJdLCJjbGllbnRfaWQiOiJhYmFjdXMiLCJjaWQiOiJhYmFjdXMiLCJhenAiOiJhYmFjdXMiLCJncmFudF90eXBlIjoiY2xpZW50X2NyZWRlbnRpYWxzIiwicmV2X3NpZyI6ImI0NTc4NmVjIiwiaWF0IjoxNTU0MzQyODA1LCJleHAiOjE1NTQzODYwMDUsImlzcyI6Imh0dHBzOi8vdWFhLjExNS42OC40Ni4xODgueGlwLmlvL29hdXRoL3Rva2VuIiwiemlkIjoidWFhIiwiYXVkIjpbImNsb3VkX2NvbnRyb2xsZXIiLCJhYmFjdXMuc3lzdGVtIiwiY291ZF9jb250cm9sbGVyX3NlcnZpY2VfcGVybWlzc2lvbnMiLCJvcGVuaWQiLCJhYmFjdXMudXNhZ2UiLCJhYmFjdXMudXNhZ2Uuc2FtcGxlciIsImFiYWN1cyIsInJlcG9ydGluZy5hZ2VudCIsImFiYWN1cy51c2FnZS5saW51eC1jb250YWluZXIiXX0.RHGtFgQU4O_Z12y4Sgoqg7QZhEEs34SSaDa7qwrJ2s7pKZ0C8g2KBCCHb-ROUOKtjvttLcPUclmG13j3hEXW8coGWrzm7kHUk15O4X636Cvz4Xk4oMq-ykoAy0ODuqQ4OQXhv_SuGKCF-ondQQmSkUfwhvYa_-KokXTl_JeFR4KH3aCGniitCXzTPFLUblDDe6UY1--jF44i4dZhDirS5Ptf4ZF8RD1oz64RbjIqmPfIQnensdpdyRgCYQQUTPp0StXij0qeAv64T9o9NUg-8ZTPXOyoi6AX-Wc9UQx4tR3gH9sRng-Gjq24iucRZmoGBZOb6OiIO7RtqB_EXJ5e7A' \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache,no-cache'

다음과 같이 출력되면, 정상적으로 설치가 완료됨
{
  "start": 1435622400000,
  "end": 1435708799999,
  "processed": 1435708800000,
  "organization_id": "us-south:a3d7fe4d-3cb1-4cc3-a831-ffe98e20cf27",
  "windows": [
    [{
      "charge": 46.09
    }],
    [{
      "charge": 46.09
    }],
    [{
      "charge": 46.09
    }],
    [{
      "charge": 46.09
    }],
    [{
      "charge": 46.09
    }]
  ],
  "id": "k-a3d7fe4d-3cb1-4cc3-a831-ffe98e20cf27-t-0001435622400000",
  "spaces": [
    {
      "space_id": "aaeae239-f3f8-483c-9dd0-de5d41c38b6a",
      "windows": [
        [{
          "charge": 46.09
        }],
        [{
          "charge": 46.09
        }],
        [{
          "charge": 46.09
        }],
        [{
          "charge": 46.09
        }],
        [{
          "charge": 46.09
        }]
      ],
      "consumers": [
        {
          "consumer_id": "app:d98b5916-3c77-44b9-ac12-045678edabae",
          "windows": [
            [{
              "charge": 46.09
            }],
            [{
              "charge": 46.09
            }],
            [{
              "charge": 46.09
            }],
            [{
              "charge": 46.09
            }],
            [{
              "charge": 46.09
            }]
          ],
          "resources": [
            {
              "resource_id": "object-storage",
              "charge": 46.09,
              "aggregated_usage": [
                {
                  "metric": "storage",
                  "windows": [
                    [{
                      "quantity": 1,
                      "summary": 1,
                      "charge": 1
                    }],
                    [{
                      "quantity": 1,
                      "summary": 1,
                      "charge": 1
                    }],
                    [{
                      "quantity": 1,
                      "summary": 1,
                      "charge": 1
                    }],
                    [{
                      "quantity": 1,
                      "summary": 1,
                      "charge": 1
                    }],
                    [{
                      "quantity": 1,
                      "summary": 1,
                      "charge": 1
                    }]
                  ]
                },
                {
                  "metric": "thousand_light_api_calls",
…………………………
```

추가적인 정보를 취득하기 위해서는,  
참조 : https://github.com/cloudfoundry-incubator/cf-abacus  
API : https://github.com/cloudfoundry-incubator/cf-abacus/blob/master/doc/api.md  


[METERING_1]:/install-guide/metering/images/IMAGE1.png
[METERING_2]:/install-guide/metering/images/IMAGE2.png
[METERING_3]:/install-guide/metering/images/IMAGE3.png
[METERING_4]:/install-guide/metering/images/IMAGE4.png
[METERING_5]:/install-guide/metering/images/IMAGE5.png

