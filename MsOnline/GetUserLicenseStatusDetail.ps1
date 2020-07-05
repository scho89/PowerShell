#특정 라이선스의 세부 라이선스 배포 상태 확인
$SKU = "kor1:ENTERPRISEPREMIUM"
$servicename = "TEAMS1"

$msoluser = Get-MsolUser -All | ?{$_.licenses.accountskuid -contains $SKU}



$list = @()
$msoluser | % {

    $servicePlan = $_.licenses.servicestatus
    $Index = $servicePlan.ServicePlan.ServiceName.IndexOf($servicename)    
 
    if($Index -ne -1){
    $record = New-Object -TypeName PSObject -Property @{
        UserPrincipalName = $_.UserPrincipalName
        ServiceName = $servicePlan[$Index].ServicePlan.ServiceName
        ProvisioningStatus = $servicePlan[$Index].ProvisioningStatus
        DisplayName = $_.DisplayName
        licenses = $_.licenses.accountskuid 
    }
    $list += $record
    }
}

$list | ? {$_.ProvisioningStatus -eq "Success"}

