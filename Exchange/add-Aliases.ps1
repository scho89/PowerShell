#add-aliases.ps1

#사용자 사서함 리스트 저장
$mbxlist = Get-Mailbox | ? {$_.windowsemailaddress -notlike "*onmicrosoft.com*"}

foreach($mbx in $mbxlist){
    #별칭 리스트 작성
    $aliasDomains=@("contoso.kr","adatum.kr","fabrikam.kr")
    $addresses = @()

    foreach($domain in $aliasDomains){
        $addresses += ($mbx.alias+"@"+$domain).trim()
    }
    
    #디버깅 메시지
    Write-Host "Adding aliases for"$mbx.userprincipalname -ForegroundColor Green
    Write-Host $addresses
    
    #사서함에 별칭 추가
    Set-Mailbox -identity $mbx.userprincipalname -EmailAddresses @{add=$addresses}

}