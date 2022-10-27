
<#PSScriptInfo

.VERSION 1.0

.GUID f659f288-ab9e-4d68-a25f-9c087058de8b

.AUTHOR Sangho Cho (cho.sangho@outlook.com)

.COMPANYNAME 

.COPYRIGHT 

.TAGS Microsoft365,AuditLog

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES ExchangeOnlineManagement

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Export audit logs on Microsoft 365 as CSV. If result exceeds 5,000 limitation, it queries again recursivly , split query date by parameter bins number. 

.EXAMPLE
   Export-Auditlogs -StartDate "2022-10-10 08:00" -EndDate "2022-10-20 08:00" -Operations FileDownloaded,FileAccessesd
.PARAMETER StartDate
   Query start datetime, as local time "yyyy-MM-dd hh:mm:ss"
.PARAMETER EndDate
   Query end datetime, as local time "yyyy-MM-dd hh:mm:ss"
.PARAMETER operations
    specify operation for audit log, comma seperated for multiple operations
.PARAMETER Path (optional)
    Path of result file, defualt is current path
.PARAMETER rawdata (optional)
    Export audit log data as raw form, same form with result of Search-UnifiedAuditLog 
.PARAMETER porgress (optional)
    Show query progress (starttime, endtime, depth of recursive query, bin number)
.PARAMETER bins (optional)
    When Search-UnifiedAuditLog result exceeds 5,000 it used as divitor for query date. default value is 2 
.PARAMETER delay (optional)
    to prevent hits throttling limit in Exchange Online PowerShell, make delay between recursive call, in seconds 

#> 


param(
    [parameter(Mandatory=$true)][datetime]$StartDate,
    [parameter(Mandatory=$true)][datetime]$EndDate,
    [parameter(Mandatory=$true)][array]$operations,
    [string][string]$Path=".",
    [switch]$rawdata,
    [switch]$progress, 
    [int]$bins = 2,
    [int]$delay =1    
)



Function Get-AuditLogs{

    Param (
        [datetime]$StartDate,[datetime]$EndDate,[string]$operation
        )
    start-sleep $delay

    $auditLogs = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -ResultSize 5000 -Operation $operation

    $depth ++

    if($progress){
        Write-Host $StartDate.ToString("yyyy-MM-dd HH:mm:ss"),"/",$EndDate.ToString("yyyy-MM-dd HH:mm:ss"),(" {0,4}" -f $auditLogs.Length) -NoNewline
        Write-Host (" {0,2}" -F $depth) -ForegroundColor Green -NoNewline
        Write-Host " $bin " -ForegroundColor Yellow -NoNewline
        Write-Host $operation
    }

    if( $auditLogs.Length -lt 5000 ){
        if($auditLogs.Length){
            
            if($rawdata){
                $auditLogs | Export-Csv -Encoding Utf8 -NTI -Append -Path "$Path/$operation.csv" -Force

            }

            else{
                $auditData = $auditLogs.auditdata | ConvertFrom-Json
                $auditData | Export-Csv -Encoding Utf8 -NTI -Append -Path "$Path/$operation.csv" -Force
            }
            $depth --
            $bin = 0
        }



    }
    else{
        # split bins
        $delta = ($EndDate - $StartDate).TotalSeconds / $bins
        
        for( $n = 0;  $n -lt $bins ;$n++ ){
            $bin = $n+1            
            $newStartDate = $StartDate.AddSeconds($n*$delta)
            $newEndDate = $StartDate.AddSeconds(($n+1)*$delta)
            Get-AuditLogs -StartDate $newStartDate -EndDate $newEndDate -Operation $operation
        }
    }
}

$StartDate = $StartDate.ToUniversalTime()
$EndDate = $EndDate.ToUniversalTime()

try{
    Get-Command "Connect-ExchangeOnline" -ErrorAction Stop | Out-Null
}
catch [System.Exception] {
    Write-Host -ForegroundColor y "Modue required."

    Start-Process powershell.exe -Verb runAs{
    Install-Module ExchangeOnlineManagement
    }
    Read-Host "After finish install module, press enter key to continue... "
}

try{
    Connect-ExchangeOnline -ErrorAction Stop
}
catch {
    Write-Host "Login failure" -ForegroundColor Red
    Exit
}


$operations | %{
    Get-AuditLogs -StartDate $StartDate -EndDate $EndDate -operation $_
    }
Disconnect-ExchangeOnline -Confirm:$false

$operations | % {
    
    $fullname = "$Path/$_.csv" -replace "\\","/"
    $data = Import-Csv $fullname -Encoding Utf8

    if($rawdata){
        $data | Sort-Object -Property Identity -Unique| Export-Csv $fullname -Encoding Utf8 -NTI
    }
    else{
        $data | Sort-Object -Property Id -Unique| Export-Csv $fullname -Encoding Utf8 -NTI
    }
}
