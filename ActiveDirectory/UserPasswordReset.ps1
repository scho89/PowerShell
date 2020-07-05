
#암호 재설정
Get-ADUser -Filter * -SearchBase "OU=pwdreset, DC=adatum, DC=KR" | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString "@1tour.com" -AsPlainText -Force)

#암호 만료
Get-ADUser -Filter * -SearchBase "OU=pwdreset, DC=adatum, DC=KR" | Set-ADUser -Replace @{pwdLastSet='0'}
