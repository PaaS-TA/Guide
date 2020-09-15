## Table of Contents

1. [PaaS-TA Monitoring IaaS 설치](#1)  
  1.1 [Pre-requsite](#1-1)  
  1.2 [Monasca 설치](#1-2)  
    * [Monasca Server 설치](#1-2-1)
    * [Monasca Client(agent) 설치](#1-2-2)



## <div id='1'/>1.	PaaS-TA Monitoring IaaS 설치

### <div id='1-1'/>1.1. Pre-requsite
 1. Openstack Queens version 이상
 2. PaaS-TA가 Openstack에 설치 되어 있어야 한다.
 3. 설치된 Openstack위에 PaaS-TA에 설치 되어 있어야 한다.(PaaS-TA Agent설치 되어 있어야 한다)
 4. IaaS-PaaS-Monitoring 시스템에는 선행작업(Prerequisites)으로 Monasca Server가 설치 되어 있어야 한다. Monasca Client(agent)는 openstack controller, compute node에 설치되어 있어야 한다. 아래 Monasca Server/Client를 먼저 설치 후 IaaS-PaaS-Monitoring을 설치 해야 한다.
 
### <div id='1-2'/>1.2.	Monasca 설치
Monasca는 Server와 Client로 구성되어 있다. Openstack controller/compute Node에 Monasca-Client(Agent)를 설치 하여 Monasca 상태정보를 Monasca-Server에 전송한다. 수집된 Data를 기반으로 IaaS 모니터링을 수행한다.
Monasca-Server는 Openstack에서 VM을 수동 생성하여 설치를 진행한다.

#### <div id='1-2-1'/>1.2.1.	Monasca Server 설치

> **[Monasca - Server](./monasca-server.md)**

#### <div id='1-2-2'/>1.2.2.	Monasca Client(agent) 설치

> **[Monasca - Client](./monasca-client.md)** 
