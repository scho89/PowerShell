#addlicense.ps1


#라이선스 일괄 할당
$csv = Import-Csv ./users.csv

#외부 사용자 (UPN에 #EXT 가 들어가지 않은..) 리스트 작성
$msoluser = Get-MsolUser | ? {$_.islicensed -like "False" -and $_.userprincipalname -notlike "*#EXT*"}

foreach($user in $msoluser){

    #Business Premium 라이선스 추가
    if ($csv.userprincipalname -contains $user.userprincipalname){
        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses "contoso:O365_Business_Premium"
    }

}
