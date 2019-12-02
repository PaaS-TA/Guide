## Table of Contents

1. [개요](#1)
  * [목적](#2)
  * [범위](#3)
2. [플랫폼 설치 자동화 활용 메뉴얼](#4)
	* [배포 정보 조회 및 관리 -> 배포 정보](#5)
	* [배포 정보 조회 및 관리 -> Task 정보](#6)
	* [배포 정보 조회 및 관리 -> VM 관리](#7)
	* [배포 정보 조회 및 관리 -> 스냅샷 관리](#8)
3. [플랫폼 설치 자동화 활용](#9)
    * [배포 정보](#10)
    * [Task 정보](#11)
    * [VM 관리](#12)
    * [스냅샷 관리](#13)


## Executive Summary

본 문서는 PaaS-TA 및 PaaS-TA 서비스를 설치 후 플랫폼 설치 자동화 시스템의 활용 절차에 대해 기술하였다.

# <div id='1'/>1.  문서 개요

## <div id='2'/>1.1.  목적
본 문서는 PaaS-TA 및 PaaS-TA 서비스를 설치 후 플랫폼 설치 자동화를 통해 VM의 배치 현황/Task 이력 및 여러 유용한 기능을 활용하는 절차에 대해 기술하였다.

## <div id='3'/>1.2.  범위
본 문서에서는 Linux 환경(Ubuntu 16.04)을 기준으로 인프라 환경에 플랫폼
설치 자동화의 설치하는 방법에 대해 작성되었다.


# <div id='4'/>2.  플랫폼 설치 자동화 활용 메뉴얼

플랫폼 설치 자동화를 통해 설치한 BOOTSTRAP(디렉터)를 통해 배포한 PaaS-TA와 스템셀/릴리즈 등을 관리할 수 있는 “배포 정보 조회 및 관리”라는 메뉴가 존재한다.
다음은 플랫폼 설치 자동화에서 지원하는 메뉴들의 설명이다.


## <div id='5'/>2.1. 배포 정보 조회 및 관리 -> 배포 정보

디렉터로부터 배포된 배포 정보를 조회하는 기능을 제공하는 화면이다.

![PaaSTa_Platform_Use_Guide_Image01]

1. 디렉터 정보
	- 설정된 디렉터 정보를 보여준다.
2. 설치 목록
	- 디렉터를 이용해서 배포된 배포 목록 정보를 보여준다.

## <div id='5'/>2.2.배포 정보 조회 및 관리 -> Task 정보

디렉터가 수행한 Task 작업들에 대한 목록 조회 및 상세 로그 정보를 확인하는 기능을 제공하는 화면이다.

![PaaSTa_Platform_Use_Guide_Image02]

1.	디렉터 정보
	- 설정된 디렉터의 정보를 보여준다.
2.	Task 실행 이력 목록
	- 디렉터가 수행한 Task의 작업 목록을 보여준다.
3.	디버그 로그 다운로드
	- 선택된 Task 작업에 대한 디버그 로그파일을 다운로드 한다.
4.	이벤트 로그
	- 선택된 Task 작업에 대한 이벤트 로그를 보여준다.

## <div id='6'/>2.3.배포 정보 조회 및 관리 -> VM 관리

디렉터를 통해 배포한 VM을 조회, 관리하는 기능을 제공하는 화면이다.

![PaaSTa_Platform_Use_Guide_Image03]

1.	디렉터 정보
	- 설정된 디렉터의 정보를 보여준다.
2.	배포 명 목록
	- 디렉터가 배포한 VM의 배포 명 목록을 보여준다.
3.	배포 명 조회
	- 배포 명 목록에서 선택된 배포 명을 통해 해당 배포 명을 갖는 VM의 상세 목록을 조회하는 기능
4.	VM 목록
	- VM의 상세 명칭, 상태 값, Type, AZ, IPs, Load, Cpu 타입 등을 보여준다.
5.	로그 다운로드
	- VM 목록에서 선택된 VM의 Agent 로그, Job 로그를 선택하여 다운로드 할 수 있는 기능
6.	Job 시작
	- VM 목록에서 선택된 중지 상태 중인 VM을 시작하는 기능
7.	Job 중지
	- VM 목록에서 선택된 시작 상태 중인 VM을 중지하는 기능
8.	Job 재시작
	- VM 목록에서 선택된 VM을 재시작 하는 기능
9.	Job 재생성
	- VM 목록에서 선택된 VM을 재생성 하는 기능

## <div id='6'/>2.4.배포 정보 조회 및 관리 -> 스냅샷 관리

디렉터가 배포한 VM 정보의 스냅샷을 조회, 삭제, 전체 삭제할 수 있는 기능을 제공하는 화면

![PaaSTa_Platform_Use_Guide_Image04]

1.	디렉터 정보
	- 설정된 디렉터의 정보를 보여준다.
2.	배포 명 목록
	- 디렉터가 배포한 VM의 배포 명 목록을 보여준다.
3.	배포 명 조회 기능
	- 배포 명 목록에서 선택된 배포 명을 통해 해당 배포 명을 갖는 스냅샷의 상세 목록을 조회하는 기능
4.	스냅샷 목록
	- 배포 명을 통해 조회된 해당 배포 정보의 JobName, Uuid, SnapshotCid 등 스냅샷 상세 정보를 보여준다
5.	스냅샷 삭제
	- 선택된 스냅샷을 삭제하는 기능
6.	스냅샷 전체 삭제
	- 조회된 스냅샷을 전체 삭제하는 기능.

# <div id='7'/> 3.  플랫폼 설치 자동화 활용 메뉴얼

플랫폼 설치 자동화를 통해 설치한 BOOTSTRAP(디렉터)를 통해 배포한 PaaS-TA와 스템셀/릴리즈 등을 관리할 수 있는 “배포 정보 조회 및 관리”라는 메뉴가 존재한다.
다음은 플랫폼 설치 자동화에서 지원하는 메뉴들의 활용 설명이다.

## <div id='8'/>3.1.배포 정보 조회
배포 정보를 확인하기 위해 플랫폼 설치 자동화 웹 화면에서 “배포 정보 조회 및 관리” -> “배포 정보” 메뉴로 이동한다.


## <div id='9'/>3.2.Task 정보

Task 정보를 확인하기 위해 플랫폼 설치 자동화 웹 화면에서 “배포 정보 조회 및 관리” -> “Task 정보” 메뉴로 이동 후 배포명을 선택하고 “조회” 버튼을 클릭한다.

1.	디버그 로그 다운로드

	-	Task 실행 이력 목록에서 디버그 로그를 다운로드 받고자 하는 Task 정보를 클릭하여 선택한 후 “디버그 로그 다운로드” 버튼을 클릭한다.
	-	웹 브라우저에서 지정된 경로에 선택한 Task의 디버그 로그 파일이 다운로드 된다.

![PaaSTa_Platform_Use_Guide_Image05]

2.	이벤트 로그
	- Task 실행 이력 목록에서 이벤트 로그를 확인하고자 하는 Task 정보를 클릭하여 선택한 후 “이벤트 로그” 버튼을 클릭한다.
	- 이벤트 로그 팝업 창이 열리고, 선택한 Task의 이벤트 로그가 출력된다.

![PaaSTa_Platform_Use_Guide_Image06]

## <div id='10'/>3.3.VM 관리

VM 정보를 확인하기 위해 플랫폼 설치 자동화 웹 화면에서 “배포 정보 조회 및 관리” -> “VM 관리” 메뉴로 이동 후 배포 명을 선택하고 “조회” 버튼을 클릭한다.

1.	로그 다운로드
	- VM 목록에서 로그를 다운로드 받고자 하는 VM 정보를 클릭하여 선택한 후 “로그 다운로드” 버튼을 클릭한다.
	- 다운로드 로그 유형 선택 팝업 창이 출력되면 Agent 로그 또는 Job 로그를 받을지 선택을 한다.
	- 웹 브라우저에서 지정된 경로에 선택한 로그 파일이 다운로드 된다.

![PaaSTa_Platform_Use_Guide_Image07]

2.	Job 시작
	- VM 목록에서 정지된 VM을 클릭하여 선택한 후 “Job 시작” 버튼을 클릭한다.
	- Job 시작 팝업 로그 창이 출력된다.

![PaaSTa_Platform_Use_Guide_Image08]

3.	Job 중지
	- VM 목록에서 시작된 VM을 클릭하여 선택한 후 “Job 중지” 버튼을 클릭한다.
	- Job 중지 팝업 로그 창이 출력된다.

![PaaSTa_Platform_Use_Guide_Image09]

4.	Job 재시작
	- VM 목록에서 시작된 VM을 클릭하여 선택한 후 “Job 재시작” 버튼을 클릭한다.
	- Job 재시작 팝업 로그 창이 출력된다.

![PaaSTa_Platform_Use_Guide_Image10]

5.	Job 재생성
	- VM 목록에서 시작된 VM을 클릭하여 선택한 후 “Job 재시작” 버튼을 클릭한다.
	- Job 재생성 팝업 로그 창이 출력된다.

![PaaSTa_Platform_Use_Guide_Image11]

## <div id='11'/>3.4. 스냅샷 관리

스냅샷 정보를 확인하기 위해 플랫폼 설치 자동화 웹 화면에서 “배포 정보 조회 및 관리” -> “스냅샷 관리” 메뉴로 이동 후 배포 명을 선택하고 “조회” 버튼을 클릭한다.

1.	스냅샷 삭제
	- 스냅샷 삭제를 위해 목록에서 출력된 스냅샷을 선택하고 “스냅샷 삭제” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image12]

2.	스냅샷 전체 삭제
	- 스냅샷 전체 삭제를 위해 “스냅샷 전체 삭제” 버튼을 클릭한다.

![PaaSTa_Platform_Use_Guide_Image13]


[PaaSTa_Platform_Use_Guide_Image01]:./images/use-guide/deployments/deployments.png
[PaaSTa_Platform_Use_Guide_Image02]:./images/use-guide/taskInfo/tasks.png
[PaaSTa_Platform_Use_Guide_Image03]:./images/use-guide/vmInfo/vms.png
[PaaSTa_Platform_Use_Guide_Image04]:./images/use-guide/snapshotInfo/snapshots.png

[PaaSTa_Platform_Use_Guide_Image05]:./images/use-guide/taskInfo/debug_download.png
[PaaSTa_Platform_Use_Guide_Image06]:./images/use-guide/taskInfo/eventlog.png

[PaaSTa_Platform_Use_Guide_Image07]:./images/use-guide/vmInfo/logdownload.png
[PaaSTa_Platform_Use_Guide_Image08]:./images/use-guide/vmInfo/job_start.png
[PaaSTa_Platform_Use_Guide_Image09]:./images/use-guide/vmInfo/job_stop.png
[PaaSTa_Platform_Use_Guide_Image10]:./images/use-guide/vmInfo/job_restart.png
[PaaSTa_Platform_Use_Guide_Image11]:./images/use-guide/vmInfo/job_recreate.png

[PaaSTa_Platform_Use_Guide_Image12]:./images/use-guide/snapshotInfo/snapshot_delete.png
[PaaSTa_Platform_Use_Guide_Image13]:./images/use-guide/snapshotInfo/snapshot_delete_all.png
