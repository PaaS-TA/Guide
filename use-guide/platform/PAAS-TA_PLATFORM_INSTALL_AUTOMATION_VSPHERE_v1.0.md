# Table of Contents
1. [문서 개요](#1)
	* [목적](#2)
	* [범위](#3)
2. [플랫폼 설치 가이드](#4)
    * [플랫폼 설치 자동화 관리](#5)
	* [로그인 계정 관리](#6)
	* [인프라 관리](#7)
	* [스템셀과 릴리즈](#8)
	* [BOOTSTRAP 설치하기](#9)
	  * [인프라 환경 설정 관리](#10)
	  * [스템셀 다운로드](#11)
	  * [릴리즈 다운로드](#12)
	  * [디렉터 인증서 생성](#13)
	  * [BOOTSTRAP 설치](#14)
	* [CF-Deployment 설치하기](#15)
	  * [스템셀 업로드](#16)
	  * [PaaS-TA 릴리즈 사용](#17)
	  * [CF-Deployment 설치](#18)
	* [서비스팩 설치하기](#19)
	  * [릴리즈 업로드](#20)
	  * [Manifest 업로드](#21)
	  * [서비스팩 설치](#22)

# <div id='1'/>1.  문서 개요

## <div id='2'/>1.1.  목적

본 문서는 플랫폼 설치 자동화 시스템의 사용 절차에 대해 기술하였다.

## <div id='3'/>1.2.  범위

본 문서에서는 vSphere 인프라 환경을 기준으로 플랫폼 설치 자동화를 사용하여 PaaS-TA를 설치하는 방법에 대해 작성되었다.

# <div id='4'/>2.  플랫폼 설치 가이드

BOSH는 클라우드 환경에 서비스를 배포하고 소프트웨어 릴리즈를 관리해주는 오픈 소스로 Bootstrap은 하나의 VM에 디렉터의 모든 컴포넌트를 설치한 것으로 PaaS-TA 설치를 위한 관리자 기능을 담당한다.

플랫폼 설치 자동화를 이용해서 클라우드 환경에 PaaS-TA를 설치하기 위해서는 인프라 설정, 스템셀 소프트웨어 릴리즈, Manifest 파일, 인증서 파일 5가지 요소가 필요하다. 스템셀은 클라우드 환경에 VM을 생성하기 위해 사용할 기본 이미지이고, 소프트웨어 릴리즈는 VM에 설치할 소프트웨어 패키지들을 묶어 놓은 파일이고, Manifest파일은 스템셀과 소프트웨어 릴리즈를 이용해서 서비스를 어떤 식으로 구성할지를 정의해 놓은 명세서이다. 다음 그림은 BOOTSTRAP을 이용하여 PaaS-TA를 설치하는 절차이다.

![PaaSTa_Platform_Use_Guide_Image01]

## <div id='5'/>2.1  플랫폼 설치 자동화 관리

플랫폼 디렉터의 코드/권한/사용자 관리를 통해 전체 사용자의 생성 및 사용 권한과 공통 Manifest 버전/신규 스템셀 확장 등의 공통 코드를 사용할 수 있다.

## <div id='6'/>2.2.  로그인 계정 관리

플랫폼 설치 자동화 웹 화면에서 “플랫폼 관리자 관리” -> “로그인 계정 관리” 메뉴로 이동한다. 플랫폼 설치 자동화는 “로그인 계정 관리” 메뉴에서 기본적으로 플랫폼 설치 자동화 관리자 정보(admin/admin)를 제공한다.

### 1. *로그인 계정 등록*

1.	사용자 “등록” 버튼을 클릭 후 사용자 정보 입력 및 해당 사용자의 권한을 선택하여 “확인” 버튼을 클릭한다.
2.	사용자 등록 후 초기 비밀번호는 “1234” 이며, 최초 로그인 후 비밀번호를 변경할 수 있다.

![PaaSTa_Platform_Use_Guide_Image02]

### 2. *로그인 계정 수정*

1.	사용자 “수정” 버튼을 클릭 후 사용자 정보 및 해당 권한을 수정하여 “확인” 버튼을 클릭한다.
2.	관리자는 선택한 사용자의 아이디는 수정할 수 없지만 비밀번호를 변경할 수 있다.

![PaaSTa_Platform_Use_Guide_Image03]

## <div id='7'/>2.3  인프라 설정

BOOTSTRAP & PaaS-TA를 설치하기 위해서는 사전에 인프라 계정 등록이 필요하다. 다음은 플랫폼 설치 자동화에서 PaaS-TA 설치에 필요한 인프라 환경 설정에 대한 가이드이다.

### 1. *vSphere 계정 설정*

1.	“인프라 환경 관리” -> “인프라 계정 관리” 화면으로 이동한다
2.	전체 인프라 계정 관리 화면에서 “vSphere 계정 관리” 화면으로 이동한다.
3.	vSphere계정 관리 화면에서는 “등록” 버튼을 클릭한다
4.	vSphere계정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 계정 정보를 입력하고 “확인” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image04]
![PaaSTa_Platform_Use_Guide_Image50]

※ vSphere 계정 등록 정보

  - 계정 별칭: 생성할 vSphere 계정의 별칭
  - vCenter Address: vSphere vCenter의 IP 주소
  - vCenter User ID: vCenter 접속 아이디
  - vCenter Password: vCenter 접속 아이디의 패스워드

## <div id='8'/>2.4  스템셀과 릴리즈

플랫폼 설치 자동화를 통해 배포 가능한 BOOTSTRAP 버전은 아래와 같으며, 아래의 지원 가능한 버전을 이용하지 않을 경우 에러가 발생할 수 있다. 따라서 아래의 릴리즈 버전으로 다운로드 및 설치한다.

<table>
    <tr>
        <td>BOSH 릴리즈</td>
        <td>CPI 릴리즈</td>
        <td>BPM</td>
        <td>스템셀</td>
    </tr>
    <tr>
        <td>bosh/267.8.0</td>
        <td>bosh-vsphere-cpi/50</td>
        <td>bpm/0.9.0</td>
        <td>bosh-vsphere-esxi-ubuntu-trusty-go_agent/3586.24</td>
    </tr>
    <tr>
        <td>bosh/268.2.0</td>
        <td>bosh-vsphere-cpi/51</td>
        <td>bpm/0.12.3</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/97.12</td>
    </tr>
		<tr>
        <td>bosh/270.2.0</td>
        <td>bosh-vsphere-cpi/53</td>
        <td>bpm/1.1.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/315.64</td>
    </tr>
</table>

플랫폼 설치 자동화를 통해 배포 가능한 CF-Deployment 버전은 아래와 같으며, 아래의 릴리즈 버전으로 다운로드&업로드 및 설치한다.

<table>
    <tr>
        <td>BOSH 릴리즈</td>
        <td>CPI 릴리즈</td>
    </tr>
    <tr>
        <td>cf-deployment/2.7.0</td>
        <td>bosh-vsphere-esxi-ubuntu-trusty-go_agent/3586.25</td>
    </tr>
    <tr>
        <td>cf-deployment/3.2.0</td>
        <td>bosh-vsphere-esxi-ubuntu-trusty-go_agent/3586.27</td>
    </tr>
    <tr>
        <td>cf-deployment/4.0.0</td>
        <td>bosh-vsphere-esxi-ubuntu-trusty-go_agent/3586.40</td>
    </tr>
    <tr>
        <td>cf-deployment/5.0.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/97.18</td>
    </tr>
		<tr>
        <td>cf-deployment/5.5.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/97.28</td>
    </tr>
    <tr>
        <td>cf-deployment/9.3.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/315.36</td>
    </tr>
		<tr>
        <td>cf-deployment/9.5.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/315.64</td>
    </tr>
		<tr>
        <td>paasta/4.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/97.28</td>
    </tr>
		<tr>
        <td>paasta/4.6</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/315.36</td>
    </tr>
		<tr>
        <td>paasta/5.0</td>
        <td>bosh-vsphere-esxi-ubuntu-xenial-go_agent/315.64</td>
    </tr>
</table>

## <div id='9'/>2.5  BOOTSTRAP 설치하기

플랫폼 설치 자동화를 이용하여 인프라 환경 설정 및 BOOTSTRAP을 설치하고, 디렉터로 등록하는 절차는 다음과 같다.

![PaaSTa_Platform_Use_Guide_Image05]

### <div id='10'/>2.5.1. *인프라 환경 설정 관리*

BOOTSTRAP을 설치하기 위해서는 설치할 인프라의 환경 설정 정보를 등록해야 한다.
PaaS-TA를 설치하기 위해 “PaaS-TA 설치 자동화” 메뉴를 클릭하여 플랫폼 설치 자동화 대시보드화면으로 이동한다.
플랫폼 설치 자동화 웹 화면에서 “환경 설정 및 관리” -> “인프라 환경 설정 관리” 메뉴로 이동한다. “인프라 환경 설정 관리” 메뉴에서는 AWS/OPENSTACK/vSphere/GOOGLE/Azure 등 5개 인프라의 전체 환경 설정 목록 조회 기능과 관리 화면으로 이동하는 기능을 제공한다.

환경 설정 관리 화면 이동 컨테이너를 클릭하여 플랫폼 설치에 필요한 각 계정 정보를 등록한다.

![PaaSTa_Platform_Use_Guide_Image06]



#### 1. *vSphere 환경 설정 등록*

1.	vSphere 환경 설정 관리 화면에서는 “등록” 버튼을 클릭한다.
2.	vSphere 환경 설정 등록 팝업 화면에서 플랫폼 설치에 필요한 인프라 환경 설정 정보를 입력하고 “확인” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image07]

※	vSphere 환경 설정 등록 정보

  - vSphere 환경 설정 별칭: 생성할 환경 설정 vSphere 별칭
  - 계정 별칭: 인프라 관리에서 등록한 vSphere 계정 정보 선택
  - vSphere Data Center 명: VM을 생성할 vSphere 데이터센터 명
  - vSphere VM Folder: VM의 Template Folder (BOOTSTRAP 설치 시 Folder가 vCenter의 DataCenter에 자동생성 된다)
  - vSphere VM Template Folder: Stemcell의 Template Folder (BOOTSTRAP 설치 시 해당 Folder가 vCenter의 DataCenter에 자동 생성된다.)
  - vSphere VM DataStore: vShpere Data Center의 Datastore 명
  - vSphere Persistant DataStore: vShpere Data Center의 Datastore 명
  - vSphere Disk Path: Disk의 Template Folder (BOOTSTRAP 설치 시 Folder가 vCenter DataStore에 자동생성 된다)
  - vSphere Cluster: vCenter의 Cluster 명

### <div id='11'/>2.5.2. *스템셀 다운로드*

플랫폼 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “스템셀 관리” 메뉴로 이동한다. “스템셀 관리” 메뉴에서는 Cloud Foundry에서 제공하는 공개 스템셀을 다운로드할 수 있는 기능을 제공한다.
스템셀 다운로드 유형은 총 3가지이며 Version유형으로 다운로드가 안될 경우 로컬에서 다운로드 후 로컬에서 선택 유형/스템셀 다운로드 URL을 통해 다운로드 받는 유형을 이용한다.
상단에 위치한 “등록” 버튼을 클릭 후 스템셀 정보를 입력하고 “확인” 버튼을 클릭한다.


	https://bosh.io/stemcells/bosh-vsphere-esxi-ubuntu-xenial-go_agent



**※	본 가이드에서는 버전 Ubuntu Xenial 315.64 다운로드 하였다.**

![PaaSTa_Platform_Use_Guide_Image08]

※	스템셀 등록 입력 정보

  - 스템셀 명: 등록할 스템셀 명
  - IaaS 유형: PaaS-TA 설치 인프라를 선택
  - OS 유형: 스템셀 OS 유형 선택 현재 vSphere에서는 Ubuntu/Windows를 지원한다.
  - OS 버전: OS의 버전 선택
  - 스템셀 다운 유형: 다운로드 유형 선택

### <div id='12'/>2.5.3. *릴리즈 다운로드*

BOOTSTRAP을 설치하기 위해서는 BOSH 릴리즈와 BOSH CPI 릴리즈, BPM 릴리즈, OS CONF 4개의 릴리즈가 필요하다.
릴리즈 다운로드 유형은 총 3가지이며 Version유형으로 다운로드가 안될 경우 로컬에서 다운로드 후 로컬에서 선택 유형/릴리즈 다운로드 URL을 통해 다운로드 받는 유형을 이용한다.
릴리즈를 다운로드하기 위해 플랫폼 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “릴리즈 관리” 메뉴로 이동 후 상단에 위치한 “등록” 버튼을 클릭하고, 릴리즈 등록 팝업 화면에서 릴리즈 정보 입력 후 “등록” 버튼을 클릭한다.

#### 1. *BOSH 릴리즈*

1.	릴리즈 등록 팝업 화면에서BOSH 릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BOSH 릴리즈 참조 사이트

    [http://bosh.io/releases/github.com/cloudfoundry/bosh?all=1](http://bosh.io/releases/github.com/cloudfoundry/bosh?all=1)

![PaaSTa_Platform_Use_Guide_Image09]

**본 가이드에서는 v270.2.0을 다운로드 하였다.**

※	릴리즈 등록 입력 정보

  - 릴리즈 명: 등록할 릴리즈 명
  - 릴리즈 유형: PaaS-TA를 설치하기 위해 필요한 릴리즈 유형
  - IaaS 유형: PaaS-TA 설치 인프라를 선택
  - 릴리즈 다운 유형: 다운로드 유형 선택

#### 2. *BOSH CPI 릴리즈*

1.	릴리즈 등록 팝업화면에서 BOSH CPI릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BOSH-CPI 릴리즈 참조 사이트

<table>
    <tr>
        <td>인프라 환경</td>
        <td>참조 사이트</td>
    </tr>
    <tr>
        <td>vSphere</td>
        <td>https://bosh.io/releases/github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release?all=1</td>
    </tr>
</table>

![PaaSTa_Platform_Use_Guide_Image10]

**본 가이드에서는 v53을 다운로드 하였다.**

#### 3. *BPM 릴리즈*

1.	릴리즈 등록 팝업화면에서 BPM릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	BPM 릴리즈 참조 사이트

<table>
    <tr>
        <td>릴리즈 명</td>
        <td>참조 사이트</td>
    </tr>
    <tr>
        <td>BPM</td>
        <td>https://bosh.io/releases/github.com/cloudfoundry-incubator/bpm-release?all=1</td>
    </tr>
</table>

![PaaSTa_Platform_Use_Guide_Image11]

**본 가이드에서는 v1.1.0을 다운로드 하였다.**

#### 3. *OS CONF 릴리즈*

1.	릴리즈 등록 팝업화면에서 OS CONF 릴리즈 정보를 입력하고, “등록” 버튼 클릭한다.
2.	OS CONF 릴리즈 참조 사이트

<table>
    <tr>
        <td>릴리즈 명</td>
        <td>참조 사이트</td>
    </tr>
    <tr>
        <td>OS CONF</td>
        <td>https://bosh.io/releases/github.com/cloudfoundry/os-conf-release?all=1</td>
    </tr>
</table>

![PaaSTa_Platform_Use_Guide_Image12]

**본 가이드에서는 v21.0.0을 다운로드 하였다.**

### <div id='13'/>2.5.4. *디렉터 인증서*

BOOTSTRAP을 설치하기 위해서는 Nats/Director 컴포넌트를 사용하기 위한 인증서 정보, 디렉터 인증서가 필요하며 디렉터 인증서를 생성하기 위해 플랫폼 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “디렉터 인증서 관리” 메뉴로 이동 후 상단에 위치한 “등록” 버튼을 클릭하고, 디렉터 인증서 팝업 화면에서 디렉터 인증서 정보 입력 후 “등록” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image13]

※	디렉터 인증서 등록 정보

  - 디렉터 인증서 명: 등록할 디렉터 인증서 명
  - BOOTSTRAP 공인 IPs: BOOTSTRAP 설치 시 사용할 vSphere External 아이피
  - BOOTSTRAP 내부 IPs: BOOTSTRAP 설치 시 사용할 vSphere Internal Subnet 대역의 아이피
  -	BOOTSTRAP 공인 IPs 입력항목은 사용자의 설정에 따라 사용시 값을 입력할 수 있고, 사용하지 않을 경우 이를 제외한 항목만 채워 넣어도 디렉터 인증서 생성이 가능하다.

### <div id='14'/>2.5.5. *BOOTSTRAP 설치*

BOOTSTRAP 설치하기 위해 플랫폼 설치 자동화 웹 화면에서 “플랫폼 설치” -> “BOOTSTRAP 설치” 메뉴로 이동 후 상단에 위치한 “설치” 버튼을 클릭한다.

#### 1. *클라우드 환경 선택*

1.	설치할 클라우드 환경을 선택하는 팝업화면에서 vSphere를 선택한다.
2.	“확인” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image14]

#### 2. *BOOTSTRAP 설치 – 선택한 클라우드 환경 정보*

1.	vSphere 정보 화면에서 인프라 환경 별칭을 선택 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image15]

※	BOOTSTRAP 설치 vSphere 정보 입력 정보

  - 인프라 환경 별칭: 등록한 인프라 환경 설정 정보 선택
  - vCenter IP: 인프라 계정 관리에서 등록한 vSphere의 vCenter 주소 (자동 입력)
  - vCenter ID 인프라 계정 관리에서 등록한 vSphere의 vCenter 접속 아이디 (자동 입력)
  - vCenter Password: 인프라 계정 관리에서 등록한 vSphere의 vCenter 접속 패스워드 (자동 입력)
  - vCenter DataCenter: 인프라 환경 설정에서 등록한 Datacenter 명 (자동 입력)
  - DataCenter VM Folder Name: 인프라 환경 설정에서 등록한 VM Folder 명 (자동 입력)
  - DataCenter VM Stemcell Folder Name: 인프라 환경 설정에서 등록한 Stemcell Folder 명 (자동 입력)
  - DataCenter DataStore: 인프라 환경 설정에서 등록한 Data Store 명 (자동 입력)
  - vCenter Persistent Datatastore: 인프라 환경 설정에서 등록한 Persistent Data Store 명 (자동 입력)
  - vCenter Disk Path: 인프라 환경 설정에서 등록한 Disk Path 명 (자동 입력)
  - vCenter Cluster: 인프라 환경 설정에서 등록한 Cluster 명 (자동 입력)


#### 3. *BOOTSTRAP 설치 – 기본 정보*

1.	아래의 기본 정보 입력 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image16]

※	BOOTSTRAP 기본 정보 입력 정보

  - 배포 명: 등록할 BOOTSTRAP 배포 명
  - 디렉터 명: 등록할 BOOTSTRAP의 디렉터 명 설치 후 실제 디렉터의 Alias 명칭이 된다.
  - 디렉터 접속 인증서: 디렉터 인증서 관리에서 등록 한 디렉터 인증서 선택
  - NTP: NTP 서버 시간
  - BOSH 릴리즈: 설치할 BOSH 릴리즈를 선택
  - BOSH-CPI 릴리즈: 설치할 BOSH-CPI 릴리즈를 선택
  - OS-CONF 릴리즈: 설치할 OS-CONF 릴리즈를 선택
  - BOSH-BPM 릴리즈: 설치할 BPM 릴리즈 선택, 특정 BOSH 버전 이상일 경우 사용
  - 스냅샷기능 사용 여부: 스냅샷 사용 여부 (특정 인프라에서만 사용 가능)
  - 스냅샷 스케쥴: 스냅샷 생성 스케쥴
  - PaaS-TA 모니터링 정보: PaaS-TA 모니터링을 이용하려면 BOSH Release v270.2.0를 선택하고 PaaS-TA 모니터링 사용을 선택한다.

**BOOTSTRAP 릴리즈 Name Tag의 “?” 아이콘을 통해 현재 플랫폼 설치 자동화에서 설치 가능한 BOSH의 버전을 확인한다.**

#### 4. *BOOTSTRAP 설치 – 클라우드 환경 별 네트워크 정보*

1.	vSphere 네트워크 정보 입력 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image17]

※	BOOTSTRAP 설치 네트워크 정보 입력 정보

  - External 디렉터 공인 IP: vSphere External IP 입력, 디렉터 인증서 생성 정보와 같아야 한다. 실제 디렉터 Target IP가 된다. 공인 IP를 사용하지 않을 경우 값을 입력하지 않는다.
  - External 포트 그룹 명: External 네트워크의 포트 그룹 명
  - External 서브넷 범위: External 네트워크의 서브넷 주소 범위
  - External 게이트웨이: External 네트워크의 게이트웨이 주소
  - External DNS: 도메인 네임 서버
  - Internal 디렉터 내부 IP: vSphere Internal Subnet 대역의 아이피, 디렉터 인증서 생성 정보와 같아야 한다.
  - Internal 포트 그룹 명: Internal 네트워크의 포트 그룹 명
  - Internal 서브넷 범위: Internal 네트워크의 서브넷 주소 범위
  - Internal 게이트웨이: Internal 네트워크의 게이트웨이 주소
  - Internal DNS: 도메인 네임 서버

#### 5. *BOOTSTRAP 설치 – 리소스 정보*

1.	vSphere 리소스 정보 입력 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image35]

※	BOOTSTRAP 설치 리소스 정보 입력 정보

  - 스템셀: 스템셀 관리에서 다운로드 한 스템셀 선택s
  - 리소스 풀 CPU: BOOTSTRAP VM의 CPU 수
  - 리소스 풀 RAM: BOOTSTRAP VM의 Memory 할당량
  - 리소스 풀 DISK: BOOTSTRAP VM의 DISK 할당량


#### 6. *BOOTSTRAP 설치 – 설치*

1.	생성된 배포 Manifest파일 정보를 이용하여 BOOTSTRAP설치를 실행하고 설치 진행 과정에 대한 로그를 확인한다
2.	설치가 완료되면 “닫기” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image19]

### <div id='15'/>2.5.6 *디렉터 설정*

BOOTSTRAP설치가 완료되면 BOOTSTRAP 디렉터 정보를 이용해서 플랫폼 설치 자동화의 디렉터로 설정한다.
디렉터를 등록 위해서는 플랫폼 설치 자동화 웹 화면에서 “환경설정 및 관리” -> “디렉터 설정” 메뉴로 이동 후 상단에 위치한 “등록” 버튼을 클릭하고, 디렉터 등록 팝업 화면에서 디렉터 정보 입력 후 “등록” 버튼을 클릭한다.
이미 디렉터가 존재할 경우 디렉터를 선택하고 “기본 디렉터로 설정” 버튼을 클릭한다.

계정 및 비밀번호, 포트번호는 “admin/admin/25555”이다.

![PaaSTa_Platform_Use_Guide_Image20]

※	디렉터 설정 등록 정보

  - 디렉터 IP: BOOTSTRAP 설치 vSphere IP 정보를 입력
  - 포트번호: BOOTSTRAP 설치 Manifest의 Director Port 번호 입력(default 25555)
  - 계정: BOOTSTRAP 설치 Manifest의 user_management 아래 Director User 입력
  - 비밀번호: BOOTSTRAP 설치 Manifest의 user_management아래 Director Password 입력

## <div id='16'/>2.6. *CF-Deployment 설치하기*

BOSH를 설치하고 플랫폼 설치 자동화의 디렉터로 설정이 완료되면 CF-Deployment를 설치할 준비가 된 상태로 PaaS-TA를 설치하는 절차는 다음과 같다.

![PaaSTa_Platform_Use_Guide_Image21]

### <div id='17'/>2.6.1 *스템셀 업로드*

플랫폼 설치 자동화에서 다운받은 스템셀을 “스템셀 업로드” 화면을 통해 디렉터에 315.64 버전의 스템셀을 업로드 한다.

![PaaSTa_Platform_Use_Guide_Image22]

### 2.6.2 *PaaS-TA 릴리즈 사용*

※	해당 절차는 PaaS-TA를 설치하기 위해 반드시 필요한 Compiled Local 릴리즈를 다운로드하는 절차이다. PaaS-TA를 설치하기 위해 필요한 절차이다.

※	플랫폼 설치 자동화를 통해 배포 가능한 PaaS-TA 버전에 맞는 릴리즈와 스템셀을 PaaS-TA 공식 홈페이지 https://paas-ta.kr/download/package에서 다운로드 받는다.

1.	PaaS-TA 릴리즈 사용

	1.1.	다운로드 한 paasta 릴리즈 압축 파일을 scp 명령어를 통해 플랫폼 설치 자동화가 동작하고 있는 Inception 서버로 이동시킨다.

		ex) $ scp -i {inception.key} ubuntu@172.xxx.xxx.xx {릴리즈 압축 일 명} # Key Pair를 사용할 경우
		ex) $ scp ubuntu@172.xxx.xxx.xx {릴리즈 압축 일 명} # Password를 사용할 경우

	1.2.	릴리즈 디렉토리를 생성하고 릴리즈 디렉토리에서 해당 릴리즈 파일의 압축을 해제한다.
	릴리즈 디렉토리의 위치는 반드시 {home}/workspace/paasta-5.0/release/paasta여야 한다.

		-	디렉토리 생성
		ex) $ mkdir -p workspace/paasta-5.0/release/paasta
		-	릴리즈 압축 파일 이동
		ex) $ mv {릴리즈 압축 파일 명} workspace/paasta-5.0/release/paasta/
		-	릴리즈 파일 압축 해제
		ex) $ tar xvf {릴리즈 압축 파일 명} # 릴리즈 파일 확장자가 tar인 경우
		ex) $ unzip {릴리즈 압축 파일 명} # 릴리즈 파일 확장자가 zip인 경우
	1.3.	아래는 릴리즈 디렉토리의 PaaS-TA 릴리즈 형상 예시 그림이다.

![PaaSTa_Platform_Use_Guide_Image34]

### <div id='18'/>2.6.3 *CF-Deployment 설치*

CF-Deployment를 설치하기 위해 플랫폼 설치 자동화 웹 화면에서 “플랫폼 설치” -> “CF-Deployment설치” 메뉴로 이동 후 상단의 “설치” 버튼을 클릭한다.

#### 1.	*CF-Deployment설치 – 기본 정보 입력*

1.	배포에 필요한 기본정보와 도메인 / 로그인 비밀번호를 입력 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image36]

**본 가이드에서는 CF-Deployement 버전으로 Paasta 5.0을 사용하였다.**

※	CF-Deployment 기본 정보 입력 정보

  - 설치 관리자 UUID: 기본 디렉터의 UUID (자동 입력)
  - 배포 명: CF-Deployment 설치 배포 명 입력
  - CF-Deployment 버전: 플랫폼 설치 자동화에서 지원하는 CF Deployment 버전 선택
  - CF Database 유형: CF Database 컴포넌트의 유형, Mysql로 설치 시 컴파일 시간이 오래 걸릴 수 있음
  - Inception User Name: Inception 서버의 계정 명 ex) vcap
  - CF Admin Password: CF Login 패스워드 입력
  - 도메인: CF 설치에 사용 할 도메인 입력 ex) {public IP}.xip.io
  - PaaS-TA 모니터링 정보: PaaS-TA 모니터링을 이용하려면 paasta/5.0을 선택하고 PaaS-TA 모니터링 사용을 선택한다.
  - Portal 도메인: PaaS-TA 포털을 설치할 때 사용할 도메인을 입력한다.

#### 2.	*CF-Deployment설치 – 클라우드 환경 별 네트워크 정보 등록*

1.	vSphere의 네트워크 정보 입력 후 “다음” 버튼을 클릭한다.
2.	추가” 버튼을 클릭하여 네트워크를 추가하여 AZ를 분산 배치할 수 있다.

![PaaSTa_Platform_Use_Guide_Image25]

※	CF-Deployment 설치 네트워크 정보 입력 정보

  - External 포트 그룹 명: External 네트워크의 포트 그룹 명
  - External 서브넷 범위: External 네트워크의 서브넷 주소 범위
  - External 게이트웨이: External 네트워크의 게이트웨이 주소
  - External DNS: 도메인 네임 서버
  - External IP 할당 대역: vSphere External IP 실제 CF API Target IP
  - Internal 포트 그룹 명: Internal 네트워크의 포트 그룹 명
  - Internal 서브넷 범위: Internal 네트워크의 서브넷 주소 범위
  - Internal 게이트웨이: Internal 네트워크의 게이트웨이 주소
  - Internal DNS: 도메인 네임 서버
  - IP 할당 제외 대역: CF Deployment VM을 배치하지 않을 IP 주소 시작/끝 입력
  - IP 할당 대역: CF Deployment VM을 배치할 IP 주소 시작/끝 입력

#### 3.	*CF-Deployment설치 – Key 생성*

1.	Key 생성 정보 입력 후 “Key 생성” 버튼을 클릭한다.
2.	Key 생성 확인 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image26]

※	CF-Deployment Key 정보 입력 정보

-	도메인: CF Deployment 도메인 주소 (자동 입력)
-	국가 코드: 국가 코드 선택
-	시/도: 시/도 입력
-	시/구/군: 시/구/군 입력
-	회사명: 회사명 입력
-	부서명: 부서 명 입력
-	Email: 이메일 주소 입력

#### 4.	*CF-Deployment설치 – 리소스 정보*

1.	CF-Deployment 설치에 필요한 리소스 정보를 입력 후 “다음” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image27]

※	CF-Deployment 설치 리소스 생성 등록 정보

  - Stemcell: 기본 디렉터에 업로드 한 스템셀 선택
  - Small Type Ram: Small Type의 Memory 할당량
  - Small Type Disk: Small Type의 Disk 할당량
  - Small Type Cpu: Small Type의 Cpu 할당량
  - Medium Type Ram: Medium Type의 Memory 할당량
  - Medium Type Disk: Medium Type의 Disk 할당량
  - Medium Type Cpu: Medium Type의 Cpu 할당량
  - Large Type Ram: Large Type의 Memory 할당량
  - Large Type Disk: Large Type의 Disk 할당량
  - Large Type: Cpu: Large Type의 Cpu 할당량

#### 5.	*CF-Deployment설치 – 인스턴스 정보*

1.	인스턴스 정보를 입력 후 “다음” 버튼을 클릭한다.
2.	인스턴스 수가 늘어나게 되면 해당 수만큼 네트워크 대역이 필요해 네트워크 할당 대역을 늘려줄 필요가 있다.

![PaaSTa_Platform_Use_Guide_Image28]

※	CF-Deployment 설치 인스턴스 정보 입력 정보

-	인스턴스 수: VM에 할당할 인스턴스 수

#### 6.	*CF-Deployment설치 – 설치*

1.	생성된 배포 Manifest파일 정보를 이용하여 CF-Deployment설치를 실행하고 설치 진행 과정에 대한 로그를 확인한다.

![PaaSTa_Platform_Use_Guide_Image29]

##	<div id='19'/>2.7. *서비스팩 설치*

BOSH 및 CF-Deployment 설치가 성공적으로 완료되고 배포할 Manifest를 업로드하면 서비스팩을 설치할 준비가 된 상태로 서비스팩을 설치하는 절차는 다음과 같다.

![PaaSTa_Platform_Use_Guide_Image30]

### <div id='20'/>2.7.1. *릴리즈 업로드*

PaaS-TA개발팀에서 제공하는 PaaS-TA 서비스 릴리즈에서 “릴리즈 다운로드”를 통해 다운 받는다. 그리고 “릴리즈 업로드”와 동일하게 디렉터로 업로드한다.

### <div id='21'/>2.7.2. *Manifest 업로드*

Manifest를 업로드 하기 위해 플랫폼 설치 자동화 웹 화면에서 “배포 정보 조회 및 관리” -> “Manifest 관리” 메뉴로 이동 후 상단의 “업로드” 버튼을 클릭한다.

#### 1. *Manifest 업로드 – 업로드*

1.	서비스팩 설치를 위해서는 배포 정보를 가지고 있는 Manifest 파일이 필요하다. 서비스팩 설치에 필요한 Manifest를 작성하여 플랫폼 설치 자동화에 업로드 한다.

![PaaSTa_Platform_Use_Guide_Image31]

**본 가이드에서는 PaaS-TA 서비스 influxdb-grafana Manifest를 업로드 하였다.**
**업로드 할 Manifest는 모든 정보가 입력되어 있는 Pull Manifest여야 한다.**

### <div id='22'/>2.7.3. *서비스팩 설치*

서비스팩을 설치하기 위해 플랫폼 설치 자동화 웹 화면에서 “플랫폼 설치” -> “서비스팩 설치” 메뉴로 이동 후 상단의 “설치” 버튼을 클릭한다.

#### 1.	*서비스팩 설치 – Manifest 등록*

1.	배포에 필요한 Manifest 파일을 선택하고 “설치” 버튼을 클릭 한다

![PaaSTa_Platform_Use_Guide_Image32]

#### 2.	*서비스팩 설치 – 설치*

2.  생성된 배포 Manifest파일 정보를 이용하여 서비스팩 설치를 실행하고 설치 진행 과정에 대한 로그를 확인한다.

![PaaSTa_Platform_Use_Guide_Image33]

[PaaSTa_Platform_Use_Guide_Image01]:./images/install-guide/vsphere/install_flow.png
[PaaSTa_Platform_Use_Guide_Image02]:./images/install-guide/vsphere/management/user_add.png
[PaaSTa_Platform_Use_Guide_Image03]:./images/install-guide/vsphere/management/user_modify.png
[PaaSTa_Platform_Use_Guide_Image04]:./images/install-guide/vsphere/infra/infar_account.png
[PaaSTa_Platform_Use_Guide_Image50]:./images/install-guide/vsphere/infra/account_add.png
[PaaSTa_Platform_Use_Guide_Image05]:./images/install-guide/vsphere/bootstrap/bootstrap_flow.png
[PaaSTa_Platform_Use_Guide_Image06]:./images/install-guide/vsphere/bootstrap/all_infra_config.png
[PaaSTa_Platform_Use_Guide_Image07]:./images/install-guide/vsphere/bootstrap/infra_config_add.png
[PaaSTa_Platform_Use_Guide_Image08]:./images/install-guide/vsphere/bootstrap/stemcell_add.png
[PaaSTa_Platform_Use_Guide_Image09]:./images/install-guide/vsphere/bootstrap/bosh_release_add.png
[PaaSTa_Platform_Use_Guide_Image10]:./images/install-guide/vsphere/bootstrap/bosh_cpi_release_add.png
[PaaSTa_Platform_Use_Guide_Image11]:./images/install-guide/vsphere/bootstrap/bpm_release_add.png
[PaaSTa_Platform_Use_Guide_Image12]:./images/install-guide/vsphere/bootstrap/os_release_add.png
[PaaSTa_Platform_Use_Guide_Image13]:./images/install-guide/vsphere/bootstrap/credential_add.png
[PaaSTa_Platform_Use_Guide_Image14]:./images/install-guide/vsphere/bootstrap/iaas_select.png
[PaaSTa_Platform_Use_Guide_Image15]:./images/install-guide/vsphere/bootstrap/bootstrap_vSphere.png
[PaaSTa_Platform_Use_Guide_Image16]:./images/install-guide/vsphere/bootstrap/bootstrap_default.png
[PaaSTa_Platform_Use_Guide_Image17]:./images/install-guide/vsphere/bootstrap/bootstrap_network.png
[PaaSTa_Platform_Use_Guide_Image18]:./images/install-guide/vsphere/bootstrap/bootstrap_resource.png
[PaaSTa_Platform_Use_Guide_Image19]:./images/install-guide/vsphere/bootstrap/bootstrap_install.png
[PaaSTa_Platform_Use_Guide_Image20]:./images/install-guide/vsphere/bootstrap/director_add.png
[PaaSTa_Platform_Use_Guide_Image21]:./images/install-guide/vsphere/cf/cf_flow.png
[PaaSTa_Platform_Use_Guide_Image22]:./images/install-guide/vsphere/cf/stemcell_upload.png
[PaaSTa_Platform_Use_Guide_Image23]:./images/install-guide/vsphere/cf/paasta_release.png
[PaaSTa_Platform_Use_Guide_Image24]:./images/install-guide/vsphere/cf/cf_default.png
[PaaSTa_Platform_Use_Guide_Image25]:./images/install-guide/vsphere/cf/cf_network.png
[PaaSTa_Platform_Use_Guide_Image26]:./images/install-guide/vsphere/cf/cf_key.png
[PaaSTa_Platform_Use_Guide_Image27]:./images/install-guide/vsphere/cf/cf_resource.png
[PaaSTa_Platform_Use_Guide_Image28]:./images/install-guide/vsphere/cf/cf_instance.png
[PaaSTa_Platform_Use_Guide_Image29]:./images/install-guide/vsphere/cf/cf_install.png
[PaaSTa_Platform_Use_Guide_Image30]:./images/install-guide/vsphere/servicepack/servicepack_flow.png
[PaaSTa_Platform_Use_Guide_Image31]:./images/install-guide/vsphere/servicepack/manifest_upload.png
[PaaSTa_Platform_Use_Guide_Image32]:./images/install-guide/vsphere/servicepack/manifest_add.png
[PaaSTa_Platform_Use_Guide_Image33]:./images/install-guide/vsphere/servicepack/servicepack_install.pngs
[PaaSTa_Platform_Use_Guide_Image34]:./images/install-guide/vsphere/cf/paasta_release_5.0.png
[PaaSTa_Platform_Use_Guide_Image35]:./images/install-guide/vsphere/bootstrap/bootstrap_resource_4.6.png
[PaaSTa_Platform_Use_Guide_Image36]:./images/install-guide/vsphere/cf/cf_default_version.png
