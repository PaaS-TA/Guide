# PaaS-TA 5.0.1 가이드 문서

## 플랫폼 설치 가이드
- [설치 파일 다운로드 받기](https://paas-ta.kr/download/package)
- 운영 환경 설치
  - PaaS-TA 플랫폼 자동화 설치
    - [플랫폼 설치 자동화  설치](./use-guide//platform/PAAS-TA_PLATFORM_INSTALL_AUTOMATION_INSTALL_GUIDE_v1.0.md)
    - [플랫폼 설치 자동화 사용 메뉴얼](./use-guide/platform/PAAS-TA_PLATFORM_INSTALL_AUTOMATION_USE_MANUAL_v1.0.md)
  - PaaS-TA 플랫폼 수동 설치
    - [BOSH 설치(AWS, OpenStack, VMWare vSphere, GCP, MS Azure)](./install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)
    - [PaaS-TA 수동 설치(AWS, OpenStack, VMWare vSphere, GCP, MS Azure)](./install-guide/paasta/PAAS-TA_CORE_INSTALL_GUIDE_V5.0.md)
    - [BOSH 및 PaaS-TA 설치(CLOUDit)](./use-guide/platform/PAAS-TA_PLATFORM_INSTALL_AUTOMATION_CLOUDIT_v1.0.md)
    - [PaaS-TA 포털 수동 설치(CLOUDit)](./use-guide/platform/PAAS-TA_PLATFORM_INSTALL_AUTOMATION_CLOUDIT_PORTAL_v1.0.md)

##  가이드
- [CF Migration 가이드 (3.1 to 4.0)](../../../Guide-4.0-ROTELLE/blob/master/PaaS_TA_4.0_migration.md)
  
## 포털 설치 가이드
- [PaaS-TA 포털 UI](./install-guide/portal/PAAS-TA_PORTAL_UI_SERVICE_INSTALL_GUIDE_V1.0.md)
- [PaaS-TA 포털 API](./install-guide/portal/PAAS-TA_PORTAL_API_SERVICE_INSTALL_GUIDE_V1.0.md)

## 서비스 설치 가이드
**아래 서비스 설치 전에 BOSH, PaaS-TA, PaaS-TA 포털이 설치되어 있어야 한다.**

- DBMS 설치
  - [Cubrid](./service-guide/dbms/PAAS-TA_CUBRID_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [MySQL](./service-guide/dbms/PAAS-TA_MYSQL_SERVICE_INSTALL_GUIDE_V1.0.md)
- NOSQL 설치
  - [MongoDB](./service-guide/nosql/PAAS-TA_MONGODB_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [Redis](./service-guide/nosql/PAAS-TA_ON_DEMAND_REDIS_SERVICE_INSTALL_GUIDE_V1.0.md)
- Storage 설치
  - [GlusterFS](./service-guide/storage/PAAS-TA_GLUSTERFS_SERVICE_INSTALL_GUIDE_V1.0.md)
- MessageQueue 설치
  - [RabbitMQ](./service-guide/messagequeue/PAAS-TA_RABBITMQ_SERVICE_INSTALL_GUIDE_V1.0.md)
- Web IDE 설치
  - [Web IDE](./service-guide/webide/PAAS-TA_WEB_IDE_INSTALL_GUIDE_V1.0.md)
- Pinpoint APM 설치
  - [Pinpoint APM](./service-guide/etc/PAAS-TA_PINPOINT_SERVICE_INSTALL_GUIDE_V1.0.md)  
- 통합 개발 도구 설치
  - [배포파이프라인](./service-guide/tools/PAAS-TA_DELIVERY_PIPELINE_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [형상관리](./service-guide/tools/PAAS-TA_SOURCE_CONTROL_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [Container 서비스](./service-guide/tools/PAAS-TA_CONTAINER_SERVICE_INSTALL_GUIDE_V2.0.md)
  - [Logging 서비스](./service-guide/tools/PAAS-TA_LOGGING_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [애플리케이션 Gateway 서비스](./service-guide/tools/PAAS-TA_APPLICATION_GATEWAY_SERVICE_INSTALL_GUIDE_V1.0.md)
  - [라이프사이클 관리 서비스](./service-guide/tools/PAAS-TA_LIFECYCLE_MANAGEMENT_SERVICE_INSTALL_GUIDE_V1.0.md)
- 미터링
  - [CF-Abacus](./install-guide/metering/PAAS-TA_METERING_INSTALL_GUIDE.md)

## 마켓플레이스 설치 가이드
**마켓플레이스 설치 전에 BOSH, PaaS-TA, PaaS-TA 포털이 설치되어 있어야 한다.**

- [PaaS-TA 마켓플레이스](./service-guide/marketplace/PAAS-TA_MARKETPLACE_INSTALL_GUIDE_V1.0.md)

## 모니터링 설치 가이드
- [PaaS-TA 모니터링](./service-guide/monitoring/PAAS-TA_MONITORING_INSTALL_GUIDE_V5.0.md)

## 활용 가이드
- [BOSH CLI V2(Command Line Interface) 사용](../../../Guide-4.0-ROTELLE/blob/master/Use-Guide/Bosh/PaaS-TA_BOSH_CLI_V2_사용자_가이드v1.0.md)
- [CF CLI(Command Line Interface) 사용](../../../Guide-1.0-Spaghetti-/blob/master/Use-Guide/OpenPaas%20CLi%20가이드.md)
- [Eclipse plugin 개발도구 사용](../../../Guide-1.0-Spaghetti-/blob/master/Use-Guide/Open%20PaaS%20개발환경%20사용%20가이드.md)
- [PaaS-TA 사용자 포털 가이드](./use-guide/portal/PAAS-TA_USER_PORTAL_USE_GUIDE_V1.1.md)
- [PaaS-TA 운영자 포털 가이드](./use-guide/portal/PAAS-TA_ADMIN_PORTAL_USE_GUIDE_V1.1.md)
- [PaaS-TA 배포 파이프라인 사용자 가이드](./use-guide/tools/PAAS-TA_DELIVERY_PIPELINE_SERVICE_USE_GUIDE_V1.0.md)
- [PaaS-TA 형상관리 서비스 사용자 가이드](./use-guide/tools/PAAS-TA_SOURCE_CONTROL_SERVICE_USE_GUIDE_V1.0.md)
- [PaaS-TA Container 서비스 사용자 가이드](./use-guide/tools/PAAS-TA_CONTAINER_SERVICE_USE_GUIDE_V2.0.md)
- [PaaS-TA Logging 서비스 사용자 가이드](./use-guide/tools/PAAS-TA_LOGGING_SERVICE_USE_GUIDE_V1.0.md)
- [PaaS-TA Jenkins 서비스](./use-guide/tools/PAAS-TA_JENKINS_SERVICE_USER_GUIDE.md)
- [PaaS-TA 마켓플레이스 가이드](./use-guide/marketplace/PAAS-TA_MARKETPLACE_USE_GUIDE_V1.0.md)
## 개발 언어별 애플리케이션 가이드
- [Node.js](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_Nodejs_develope_guide.md)
- [PHP](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_PHP_develope_guide.md)
- [Python](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_Python_develope_guide.md)
- [Ruby](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_Ruby_develope_guide.md)
- [Java](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_Java_develope_guide.md)
- [Go](../../../Guide-1.0-Spaghetti-/blob/master/Sample-App-Guide/OpenPaaS_PaaSTA_Application_Go_develope_guide.md)

## 플랫폼 개발 가이드
- [스템셀 개발 가이드](../../../Guide-1.0-Spaghetti-/blob/master/Development-Guide/OpenPaaS_PaaSTA_Build_Stemcell_guide.md)
- [서비스팩 개발 가이드](../../../Guide-1.0-Spaghetti-/blob/master/Development-Guide/ServicePack_develope_guide.md)
- [빌드팩 개발 가이드](../../../Guide-1.0-Spaghetti-/blob/master/Development-Guide/Buildpack_develope_guide.md)
- [애플리케이션 APIPlatform 도로주소 개발 가이드](../../../Guide-1.0-Spaghetti-/blob/master/Development-Guide/Application_APIPlatform_dorojuso_devlope_guide.md)
- [퍼블릭 API 개발 가이드](../../../Guide-1.0-Spaghetti-/blob/master/Development-Guide/PublicAPI_devlope_guide.md)
- [Java API 서비스 미터링 개발 가이드](../../../Guide-2.0-Linguine-/blob/master/Development-Guide/PaaS-TA_Java_API_서비스_미터링_개발_가이드.md)
- [Java 서비스 미터링 개발 가이드](../../../Guide-2.0-Linguine-/blob/master/Development-Guide/PaaS-TA_Java_서비스_미터링_개발_가이드.md)
- [Nodejs API 서비스 미터링 개발 가이드](../../../Guide-2.0-Linguine-/blob/master/Development-Guide/PaaS-TA_Node.js_API_미터링_개발_가이드.md)
- [On-Demand 서비스 개발 가이드](./deployment-guide/on-demand/ON_DEMAND_DEPLOYMENT_GUIDE.md)
