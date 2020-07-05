#addMember.ps1
<#
#Sample
No,Type,PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members
1,UnifiedGroup,mgt5@contoso.kr.co.kr,contoso.kr - Planning,1,ko-KR,mis@fabrikam.kr.co.kr,"harry@contoso.kr.co.kr, yuri@contoso.kr.co.kr, arnoldc@contoso.kr.co.kr, jonathan@contoso.kr.co.kr, bernard@contoso.kr.co.kr, jeremyk@contoso.kr.co.kr, rainakim@contoso.kr.co.kr, kevin@contoso.kr.co.kr, simonum@contoso.kr.co.kr, lily@contoso.kr.co.kr, olivia@contoso.kr.co.kr, bella@contoso.kr.co.kr, jadeseo@contoso.kr.co.kr"
2,UnifiedGroup,acct@contoso.kr.co.kr,contoso.kr - Accounting,0,ko-KR,mis@fabrikam.kr.co.kr,"jadeseo@contoso.kr.co.kr, arnoldc@contoso.kr.co.kr, bernard@contoso.kr.co.kr, bella@contoso.kr.co.kr, jeremyk@contoso.kr.co.kr"
#>

#파일 설정 및 CSV import
$groupList = "./gp_members.csv"
$csv = Import-Csv $groupList
$logfile = "./addMember_"+(Get-Date -Format MMdd_hhmmss)+".log"


#Create Group
foreach($record in $csv){
    
    #members 리스트 작성
    $expression = "`$members="+  '"'+($record.members.Split(",").trim() -join '","') +'"'
    Invoke-Expression $expression
    $memberList = $record.members.Split(",").trim()

        foreach($member in $memberList){
            #로그 작성을 위해 // Add-UnifiedGroupLinks 나 Add-DistributionList cmdlet은 -ErrorAction을 정의할 수 없어 예외 처리 구문 사용 불가 (Try / Catch /Finally)
            $oldErrCount = $error.Count

            # Office 365 그룹인 경우 구성원 추가
            if ($record.type -eq "UnifiedGroup") {
                #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members 
                Add-UnifiedGroupLinks -Identity $record.PrimarySmtpAddress -LinkType "member" -Links $member
            }
       
            # 메일 그룹 (Distribution list) 구성원 추가
            elseif ($record.type -eq "DistributionList") {
                #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members  
                Add-DistributionGroupMember -Identity $record.PrimarySmtpAddress -Member $member
                
            }

            # Error 발생한 경우 로그파일에 기록
            if($oldErrCount -ne $error.Count){
                Write-Host ($record.no+" : "+$error[0]) -ForegroundColor Green
                $logmessage = $record.no+": Group : "+$record.primarySmtpAddress+" : adding "+$member+" : " +$error[0]
                Add-Content -Path $logfile -Value $logmessage
            }

        }


}

