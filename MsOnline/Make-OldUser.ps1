###
#1. Block credential
#2. Change displayName,mailbox name,UPN,alias.. etc
#
#


$csvPath = './list.csv'
#csv는 UPN과 DisplayName 속성 사용
#csv example
#UserPrincipalName,DisplayName
#a@test.com,testa
#b@test.com,testb

$list = Import-Csv $csvPath -Encoding UTF8
$prefix = "Old_"
$onmicrosoftDomain = "@hanatour0.onmicrosoft.com"


$list |  % {
    Write-Host $_.UserPrincipalName -ForegroundColor Green

    $mailNickname = ($_.UserPrincipalName -split '@')[0]
    
    $new_name = $prefix+$mailNickname
    $new_UPN = $prefix+$mailNickname+$onmicrosoftDomain
    $new_DisplayName = $prefix+$_.DisplayName
    $onmicrosoftAddress = $mailNickname+$onmicrosoftDomain


    #Change UPN
    Set-MsolUser -UserPrincipalName $_.UserPrincipalName -BlockCredential $True
    Set-MsolUserPrincipalName -UserPrincipalName $_.UserPrincipalName -NewUserPrincipalName $new_UPN

}  

#필요한 경우, UPN 변경 후 메일 사서함 설정 적용되기까지 딜레이 / 초단위
#200명 정도 사용자 대상으로 진행 시 딜레이 없이 진행해도 문제 없었음.
#Start-Sleep 600


$list |  % {
    Set-Mailbox -Identity $new_UPN -Name $new_name -Alias $new_name -EmailAddresses @{remove=$_.UserPrincipalName,$onmicrosoftAddress} -HiddenFromAddressListsEnabled $true -Type Shared -DisplayName $new_DisplayName
    Set-User -Identity $new_UPN -FirstName "" -LastName "" ##검색 방지
} 
