$filePath = "./duplicatedDL.csv"
$dl1 = get-distributionGroup -ResultSize Unlimited
$dl2 = get-distributionGroup Room* -ResultSize Unlimited

$list=@()

foreach($dl_a in $dl1){
    foreach($dl_b in $dl2){
        if($dl_a.PrimarySmtpAddress -eq $dl_b.PrimarySmtpAddress){
            $record = New-Object -TypeName PSObject -Property @{
                    PrimarySmtpAddress = $dl_a.PrimarySmtpAddress.local + "@" +$dl_a.PrimarySmtpAddress.domain

                    Name_A = $dl_a.Name
                    DisplayName_A = $dl_a.DisplayName
                    GUID_A = $dl_a.GUID
                    DN_A = $dl_a.DistinguishedName
                    Alias_A = $dl_a.Alias

                    Name_B = $dl_b.Name
                    DisplayName_B = $dl_b.DisplayName
                    GUID_B = $dl_b.GUID
                    DN_B = $dl_b.DistinguishedName
                    Alias_B = $dl_b.Alias

                }
            $list += $record
        }
    }
}


$list

$list | Export-CSV $filePath -NoTypeInformation -Encoding UTF8

