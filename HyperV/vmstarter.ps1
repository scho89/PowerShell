#VM starter
$state = @("Saved","Off")
$VMlist = "Adatum.kr-AADC1
Adatum.kr-AADC2
Adatum.kr-DC00
Adatum.kr-DC02
Adatum.kr-EX10CAS
Adatum.kr-EX10MBX01
Adatum.kr-EX10MBX02
Adatum.kr-EX10MBX03
Contoso.kr-DC3
Contoso.kr-DC4
Contoso.kr-EX19MBX1
Contoso.kr-EX19MBX2
Contoso.kr-EX19MBX3
Contoso.kr-EXWit
Contoso.kr-FS01
Contoso.kr-LY19FE
Contoso.kr-LYEDGE1
Contoso.kr-PSWA
Contoso.kr-Untangle
Contoso.kr-WAP
Ho.GraphAPI.Ubuntu (140)
Ho.Scho.kr.AADC (13)
Ho.Scho.kr.DC (10)
Ho.Scho.kr.FS (11)
Ho.Scho.kr.WAP (12)
Ho.schoRedirect
Ho.TestServer
Ho.ubt(150)
limcmfz.com-NS00"

$VMforOn = $VMlist -split "`n"

$VMs = get-vm

foreach ($vm in $VMforOn ) {

    if ( $state -contains (get-vm -name $vm).state ) {
        start-vm $vm
        Write-Host 'Turn on' $vm        
    }
    
}
