#basic information
$cn = "CN=contoso.kr"
$to = "cho.sangho@outlook.com"
$from = "cho@kor1.onmicrosoft.com" # SMTP client authentication sender
$pass = "Password"
$smtp = "smtp.office365.com" # SMTP Server
$port = 587

#create credential
$secpass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($from, $secpass)

#get certificate
$list = Get-ChildItem Cert:\LocalMachine\my
$certi = $list | ? {$_.Subject -eq $cn}

#calculate expiration date
$exp = ($certi.NotAfter - (Get-Date)).Days 
$comment = ("Domain "+$cn.Split("=")[1] +" will expire in "+$exp+" day(s).")

#send notification email if certi will expire in 10 days.
if ($exp -lt 10){
    Send-MailMessage -Subject $comment -Body $comment -SmtpServer $smtp -From $from -To $to -UseSsl -Credential $cred -Port $port
}
