#uniquest group creation
<#
#Sample
No,Type,PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members
1,UnifiedGroup,mgt5@contoso.kr,UNIQUEST - Planning,1,ko-KR,mis@fabrikam.kr.co.kr,"harry@contoso.kr, yuri@contoso.kr, arnoldc@contoso.kr, jonathan@contoso.kr, bernard@contoso.kr, jeremyk@contoso.kr, rainakim@contoso.kr, kevin@contoso.kr, simonum@contoso.kr, lily@contoso.kr, olivia@contoso.kr, bella@contoso.kr, jadeseo@contoso.kr"
2,UnifiedGroup,acct@contoso.kr,UNIQUEST - Accounting,0,ko-KR,mis@fabrikam.kr.co.kr,"jadeseo@contoso.kr, arnoldc@contoso.kr, bernard@contoso.kr, bella@contoso.kr, jeremyk@contoso.kr"
#>

#파일 경로 설정 및 CSV import
$groupList = "./Groups - Copy.csv"
$csv = Import-Csv $groupList
$logfile = "./gc2_"+(Get-Date -Format MMdd_hhmmss)+".log"


#Create Group 
foreach($record in $csv){
    $oldErrCount = $error.Count
    
    #members 리스트 작성
    $expression = "`$members="+  '"'+($record.members.Split(",").trim() -join '","') +'"'
    Invoke-Expression $expression

    #외부 사용자 메일 발송 차단 여부 $True 면 차단 / $false 면 허용
    if ($record.RequireSenderAuthenticationEnabled -eq "1") {
        $reqSender = $true            
    }
    else {
        $reqSender = $false
    }

    #name and alias에 사용할 변수 
    $alias = ($record.PrimarySmtpAddress -split "@")[0]
    

    # Office 365 그룹 추가 및 구성원 추가
    if ($record.type -eq "UnifiedGroup") {
        #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members 
        New-UnifiedGroup -DisplayName $record.displayname -PrimarySmtpAddress $record.PrimarySmtpAddress -Owner $record.Owner -RequireSenderAuthenticationEnabled $reqSender -Language $record.Language -alias $alias

       
    }
    
    #메일그룹 생성 및ㅣ 구성원 추가
    elseif ($record.type -eq "DistributionList") {
        #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members  
        New-DistributionGroup -DisplayName $record.displayname -PrimarySmtpAddress $record.primarySmtpAddress -RequireSenderAuthenticationEnabled $reqSender -alias $alias -Name $alias -managedby "mis@fabrikam.kr.co.kr"
    }

    #에러 발생한 경우 파일에 기록
    if($oldErrCount -ne $error.Count){
        Write-Host ($record.no+" : "+$error[0]) -ForegroundColor Green
        $logmessage = $record.no+":"+$record.primarySmtpAddress+" : "+$error[0]
        Add-Content -Path $logfile -Value $logmessage
    }

}



<#
#Add members
foreach($record in $csv){
    $oldErrCount = $error.Count
    
    #members
    $expression = "`$members="+  '"'+($record.members.Split(",").trim() -join '","') +'"'
    Invoke-Expression $expression

    if ($record.RequireSenderAuthenticationEnabled -eq "1") {
        $reqSender = $true            
    }
    else {
        $reqSender = $false
    }

    #name and alias
    $alias = ($record.PrimarySmtpAddress -split "@")[0]
    

    if ($record.type -eq "UnifiedGroup") {
        #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members 
        New-UnifiedGroup -DisplayName $record.displayname -PrimarySmtpAddress $record.PrimarySmtpAddress -Owner $record.Owner -RequireSenderAuthenticationEnabled $reqSender -Language $record.Language -alias $alias

       
    }
    
    elseif ($record.type -eq "DistributionList") {
        #PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members  
        New-DistributionGroup -DisplayName $record.displayname -PrimarySmtpAddress $record.primarySmtpAddress -RequireSenderAuthenticationEnabled $reqSender -alias $alias -Name $alias
    }


    if($oldErrCount -ne $error.Count){
        Write-Host ($record.no+" : "+$error[0]) -ForegroundColor Green
        $logmessage = $record.no+":"+$record.primarySmtpAddress+" : "+$error[0]
        Add-Content -Path $logfile -Value $logmessage
    }

}
#>
