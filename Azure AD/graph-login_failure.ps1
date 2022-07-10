#로그인 실패TenantId
$ClientId = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
$ClientSecret = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
$TenantId = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

#https://docs.microsoft.com/en-us/azure/active-directory/develop/reference-aadsts-error-codes
#$query = '$filter=createdDateTime gt 2022-02-03T00:00:00Z and createdDateTime lt 2022-02-04T00:00:00Z and (status/errorCode ne 50126)'
# $query = '$filter=createdDateTime gt 2022-01-03T00:00:00Z and createdDateTime lt 2022-01-04T00:00:00Z and (status/errorCode eq 53003 or status/errorCode eq 53001)'
#$query = '$filter=createdDateTime gt 2022-05-25T00:00:00Z and createdDateTime lt 2022-05-25T09:00:00Z'
$query = '$filter=createdDateTime gt 2022-07-04T00:00:00Z and createdDateTime lt 2022-07-05T00:00:00Z and (status/errorCode ne 0)'

$csv = './signinreport'+(Get-Date -Format MMddHHmmss)+'.csv' 
$log = $csv -replace "csv","log"

$BodyClientID = @{
    'tenant' = $TenantId
    'client_id' = $ClientId
    'scope' = 'https://graph.microsoft.com/.default'
    'client_secret' = $ClientSecret
    'grant_type' = 'client_credentials'
}

$Params = @{
    'Uri' = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    'Method' = 'Post'
    'Body' = $BodyClientID
    'ContentType' = 'application/x-www-form-urlencoded'
}

$start = Get-Date
$graph = "https://graph.microsoft.com/v1.0"
$uri = "$graph/auditLogs/signIns?$query"

$counter = 1
$total= 0
$page = 0

Add-Content ((Get-Date -Format "yy/MM/dd HH:mm:ss" )+"|"+$query) -path $log -Encoding UTF8

do {

    $res = $null
   
    if ($counter % 100 -eq 1 ) {
        $AuthResponse = Invoke-RestMethod @Params
        $token = $AuthResponse.access_token
        $authToken = @{'Authorization'='Bearer '+$token}
    }

    try {
        $res = Invoke-RestMethod -Uri $uri -Headers $authToken
        $list = $res.value 
                
        $list | Select-Object id,createdDateTime,userprincipalname,appDisplayName,resourceDisplayName,
        @{name='failedPolicy';Expression={($_.appliedConditionalAccessPolicies | ? {$_.result -match "failure"} ).displayname -join ";" }},
        @{name='errorCode';Expression={$_.status.errorCode}},
        @{name='failureReason';Expression={$_.status.failureReason}},
        @{name='deviceOS';Expression={$_.deviceDetail.operatingSystem}},
        @{name='ipAddress';Expression={$_.ipAddress}},
        @{name='clientAppUsed';Expression={$_.clientAppUsed}},
        @{name='trustType';Expression={$_.deviceDetail.trustType}},
        @{name='isManaged';Expression={$_.deviceDetail.isManaged}},
        @{name='isCompliant';Expression={$_.deviceDetail.isCompliant}} | Export-Csv $csv -Encoding utf8 -Append -NoTypeInformation
        
        $total += $list.value.Length         
        Add-Content $log -Value $logMessage -Encoding UTF8
        $uri = $res.'@odata.nextLink'
        $page ++
        Write-Host (get-date)"|Page"$page.ToString("#,#")"; Total" $total.ToString("#,#") "records."

    }

    catch {
        $logMessage = (Get-Date -Format "yy/MM/dd HH:mm:ss") + "| An error occurred while loading $uri" + $Error[0]
        Add-Content $log -value $logMessage -Encoding utf8
        Write-Host  (get-date)"|[Error]"($uri+":"+$error[0]) -ForegroundColor Red
        Write-Host (get-date)"|[Info] Retrying page"$page.ToString("#,#")" in 30 seconds... : $uri" -ForegroundColor Yellow
        Start-Sleep -Seconds 35
    }
    finally{
        $counter ++
        Start-Sleep -Milliseconds 1500
    }

} while ($uri)

Write-host (((get-date)-$start).Totalseconds).ToString("#,#") "seconds for querying"$total.ToString("#,#")" lines of data" -f y 
