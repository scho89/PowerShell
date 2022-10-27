# Export-Auditlogs.ps1  
Microsoft 365 감사로그 다운로드 스크립트.  
5,000개 임계값을 초과하는 경우, 재귀함수를 호출하여 쿼리 범위를 나눠 다시 조회함.  

사용 예:  
`Export-Auditlogs -StartDate "2022-10-10 08:00" -EndDate "2022-10-20 08:00" -Operations FileDownloaded,FileAccessesd`  

파라미터 설명:  
`StartDate`: 조회 시작 일시, 현지 시각으로 입력.  "yyyy-MM-dd hh:mm:ss"  
`EndDate`:  조회 종료 일시, 현지 시각으로 입력.  "yyyy-MM-dd hh:mm:ss"  
`operations`: 조회할 감사로그 항목, 여러 항목은 쉼표로 구분.  
`Path`: 내보낼 파일이 생성될 경로, 기본값은 현재 경로 (Optional)  
`rawdata`: 감사로그 원본 데이터를 원하는 경우 스위치로 사용 (Optional)  
`porgress`: 진행 상황 표시 여부 (스위치) (optional), (starttime, endtime, depth of reculsive query, bin number 순)  
`bins`: 결과가 5,000개 초과 시 `StartDate`과 `EndDate`를 몇개의 구간으로 나눠서 조회할 지 결정 (optional), 기본값 2  
`delay`: Throttling 제한을 피하기 위해 재귀 함수 호출 시 지연시간을 줄 수 있음. 기본값 1, 단위는 초 (optional)  
