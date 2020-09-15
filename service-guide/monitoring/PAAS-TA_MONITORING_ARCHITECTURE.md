## Table of Contents

- 1\. [문서개요](#1)
  * [목적](#2)
  * [참고자료](#3)
- 2\. [PaaS-TA Monitoring Architecture](#5)    
    * [PaaS Monitoring Architecture](#6)
    * [PaaS 자원정보 수집 Architecture](#7)
    * [CaaS Monitoring Architecture](#8)
    * [CaaS 자원정보 수집 Architecture](#9)
    * [SaaS Monitoring Architecture](#10)
    * [SaaS 자원정보 수집 Architecture](#11)
    * [IaaS Monitoring Architecture](#11-1) 

# <div id='1'/>1.  문서 개요 

## <div id='2'/>1.1.  목적
본 문서(PaaS-TA Monitoring Architecture)는 PaaS-TA Monitoring의 Architecture를 제공한다.

## <div id='3'/>1.2.  참고자료

본 문서는 Cloud Foundry의 BOSH Document와 Cloud Foundry Document를 참고로 작성하였다.

BOSH Document: [http://bosh.io](http://bosh.io)

Cloud Foundry Document: [https://docs.cloudfoundry.org/](https://docs.cloudfoundry.org/)

BOSH DEPLOYMENT: [https://github.com/cloudfoundry/bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)

CF DEPLOYMENT: [https://github.com/cloudfoundry/cf-deployment](https://github.com/cloudfoundry/cf-deployment)



# <div id='5'/>2. PaaS-TA Monitoring Architecture

## <div id='6'/>2.1. PaaS Monitoring Architecture
PaaS Monitoring 운영환경에서는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.  
Batch 프로세스는 PaaS-TA Portal에서 등록한 임계치 정보와 AutoScale 대상 정보를 기준으로 주기적으로 시스템 Metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송하며, 임계치를 초과한 컨테이너 리스트 중에서 AutoScale 대상의 컨테이너 존재시 AutoScale Server 서비스에 관련 정보를 전송하여 자동으로 AutoScaling 기능이 수행되도록 처리한다.  
PaaS-TA Monitoring 시스템은 TSDB(InfluxDB)로부터 시스템 환경 정보 데이터를 조회하고, Lucene(Elasticsearch)을 통해 로그 정보를 조회한다.  
조회된 정보로 PaaS-TA Monitoring 시스템의 현재 자원 사용 현황을 조회하고, PaaS-TA Monitoring Dashboard를 통해 로그 정보를 조회할 수 있도록 한다.  
PaaS-TA Monitoring Dashboard는 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, 컨테이너 배치 현황과 장애 발생 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다.  

![PaaSTa_Monit_architecure_Image]

## <div id='7'/>2.2. PaaS 자원정보 수집 Architecture
PaaS는 내부적으로 메트릭스 정보를 수집 및 전달하는 Metric Agent와 로그 정보를 수집 및 전달하는 Syslog 모듈을 제공한다.  
Metric Agent는 시스템 관련 메트릭스를 수집하여 InfluxDB에 정보를 저장한다.  
Syslog는 PaaS-TA를 Deploy 하기 위한 manfiest 파일의 설정으로도 로그 정보를 ELK 서비스에 전달할 수 있으며, 로그 정보를 전달하기 위해서는 RELP 프로토콜(Reliable Event Logging Protocol)을 사용한다.

![PaaSTa_Monit_collect_architecure_Image]

## <div id='8'/>2.3. CaaS Monitoring Architecture
CaaS Monitoring 운영환경에는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.  
Batch 프로세스는 CaaS에서 등록한 임계치 정보를 기준으로 주기적으로 시스템 metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송한다.  
PaaS-TA Monitoring 시스템은 K8s(Prometheus Agent)로부터 시스템 메트릭 데이터를 조회하고, 조회된 정보로 CaaS Monitoring 시스템의 현재 자원 사용 현황을 조회한다.  
PaaS-TA Monitoring Dashboard는 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, kubernetes Pod 현황 및 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다.  

![Caas_Monit_architecure_Image]

## <div id='9'/>2.4. CaaS 자원정보 수집 Architecture
CaaS는 내부적으로 메트릭스 정보를 수집 하는 Prometheus Metric Agent(Node Exporter, cAdvisor) 제공한다.  
Prometheus 기본 제공되는 로컬 디지스 Time-Series Database 정보를 저장한다. 해당 정보를 조회하기 위해서는 Prometheus 제공하는 API를 통하여 조회할 수 있다.

![Caas_Monit_collect_architecure_Image]

## <div id='10'/>2.5. SaaS Monitoring Architecture
Saas Monitoring 운영환경에는 크게 Backend 환경에서 실행되는 Batch 프로세스 영역과 Frontend 환경에서 실행되는 Monitoring 시스템 영역으로 나누어진다.  
Batch 프로세스는 PaaS-TA Portal SaaS 서비스에서 등록한 임계치 정보를 기준으로 주기적으로 시스템 metrics 정보를 조회 및 분석하여, 임계치를 초과한 서비스 발견시 관리자에게 Alarm을 전송한다.  
Monitoring 시스템 은 Pinpoint APM Server 로부터 시스템 메트 데이터를 조회하고, 조회된 정보는 SaaS Monitoring 시스템의 현재 자원 사용 현황을 조회한다.  
Monitoring Portal은 관리자 화면으로 알람이 발생된 이벤트 현황 정보를 조회하고, Application 현황 및 서비스에 대한 통계 정보를 조회할 수 있으며, 이벤트 관련 처리정보를 이력관리할 수 있는 화면을 제공한다.

![Saas_Monit_architecure_Image]

## <div id='11'/>2.6. SaaS 자원정보 수집 Architecture
PaaS-TA SaaS는 내부적으로 메트릭스 정보를 수집 하는 Pinpoint Metric Agent 제공한다.  
Metric Agent는 Application JVM 관련 메트릭스를 수집하여 Hbase DB에 정보를 저장한다.  
해당 정보는 Pinpoint APM 서버의 API를 통하여 조회할 수 있다.

![Saas_Monit_collect_architecure_Image]

## <div id='11-1'/>2.7. IaaS  Monitoring Architecture
IaaS 서비스 모니터링 운영환경은 IaaS는 Openstack과 Monasca를 기반으로 구성되어 있다.  
IaaS는 Openstack Node에 monasca Agent가 설치되어 Metric Data를 Monasca에 전송하여 InfluxDB에 저장한다.  
PaaS는 PaaS-TA에 모니터링 Agent가 설치되어 InfluxDB에 전송 저장한다.  
Log Agent도 IaaS/PaaS에 설치되어 Log Data를 각각의 Log Repository에 전송한다.

![IaaSTa_Monit_architecure_Image]


[IaaSTa_Monit_architecure_Image]:./images/iaas-archi.png
[PaaSTa_Monit_architecure_Image]:./images/monit_architecture.png
[Caas_Monit_architecure_Image]:./images/caas_monitoring_architecture.png
[Saas_Monit_architecure_Image]:./images/saas_monitoring_architecture.png
[PaaSTa_Monit_collect_architecure_Image]:./images/collect_architecture.png
[CaaS_Monit_collect_architecure_Image]:./images/caas_collect_architecture.png
[SaaS_Monit_collect_architecure_Image]:./images/saas_collect_architecture.png
