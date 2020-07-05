#uniquest group creation
<#
#Sample
No,Type,PrimarySmtpAddress,DisplayName,RequireSenderAuthenticationEnabled,Language,Owner,Members
1,UnifiedGroup,mgt5@contoso.kr,UNIQUEST - Planning,1,ko-KR,mis@fabrikam.kr,"harry@contoso.kr, yuri@contoso.kr, arnoldc@contoso.kr, jonathan@contoso.kr, bernard@contoso.kr, jeremyk@contoso.kr, rainakim@contoso.kr, kevin@contoso.kr, simonum@contoso.kr, lily@contoso.kr, olivia@contoso.kr, bella@contoso.kr, jadeseo@contoso.kr"
2,UnifiedGroup,acct@contoso.kr,UNIQUEST - Accounting,0,ko-KR,mis@fabrikam.kr,"jadeseo@contoso.kr, arnoldc@contoso.kr, bernard@contoso.kr, bella@contoso.kr, jeremyk@contoso.kr"

#>


$groupList = "./Groups - Copy.csv"
$csv = Import-Csv $groupList
$logfile = "./gc2_"+(Get-Date -Format MMdd_hhmmss)+".log"


#Create Group
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
        New-DistributionGroup -DisplayName $record.displayname -PrimarySmtpAddress $record.primarySmtpAddress -RequireSenderAuthenticationEnabled $reqSender -alias $alias -Name $alias -managedby "mis@fabrikam.kr"
    }


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


Get-MsolUser | ? { ($_.userprincipalname -ne "mis@fabrikam.kr") -and ($_.userprincipalname -ne "jonathan@contoso.kr") -and ($_.userprincipalname -ne "kevin@contoso.kr") -and ($_.userprincipalname -notlike "*#EXT*")}