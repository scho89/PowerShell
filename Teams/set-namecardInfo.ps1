$csvpath = '~/contoso.csv'
$csv = Import-Csv $csvpath -Encoding UTF8
$logpath = '~/contosolog.log'

#
#CSV file example
#
#userprincipalname,email,title,department,office,phonenumber,manager
#hong@contoso.org,hong@contoso.org,사원,영업지원,서울사무소,070-1234-5678,jh@contoso.org
#jh@contoso.org,jh@contoso.org,사원,영업지원,서울사무소,070-1233-5673,lee@contoso.org
#A15365@contoso.org,gelee@contoso.org,대리,경영지원,부산사무소,070-1124-5555,ko@contoso.org
#A26466@contoso.org,ko@contoso.org,과장,영업지원,서울사무소,070-1234-5678,ho@contoso.org
#A13521@contoso.org,ho@contoso.org,사원,영업지원,서울사무소,070-1234-5111,lee@contoso.org
#lee@contoso.org,lee@contoso.org,사장,사장실,강남사무소,070-1111-2222,
#
#

#connect service
Write-Host "Connect service..." -f y
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
Connect-MsolService -Credential $UserCredential

#get user list
Write-Host "Get user list..." -f y
$msolusers = Get-MsolUser -All

#set user property
# "%" means "ForEach-Object" cmdlet
$csv | % {
    Write-Host "Set user property of "$_ -ForegroundColor Yellow
    $upn = $Null

    #check if userprincipal value exists in user list:
    if($msolusers.userprincipalname -contains $_.userprincipalname){$upn = $_.userprincipalname}

    #else, check email value exists in user list:
    elseif ($msoluesrs.userprincipalname -contains $_.email) {$upn = $_.email}
    
    #if not exist in user list, write log
    else { Add-Content -Path $logpath -Value ((Get-Date -Format "MM-dd hh:mm:ss")+";User "+$_.userprincipalname+" is not found.")}
    
    #if upn is found in user list, set user property.
    if($upn -ne $null){
        #Set-Msoluser -> modify Department, Office, title, PhoneNumber
        Set-MsolUser -UserPrincipalName $upn -Department $_.department -Title $_.title -Office $_.office -PhoneNumber $_.phonenumber

        #Set-User -> Modify Manager
        if($_.manager){Set-User -Identity $upn -Manager $_.manager}
    }

}
