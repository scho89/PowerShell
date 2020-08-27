$file_path = "./contoso_ou.csv"
$output_path = "./contoso_ou_result.csv"
$csv = Import-Csv $file_path -Encoding UTF8

$dc = "DC=contoso,DC=CO,DC=KR"

$parents_table = @{}
$csv | % { $parents_table[$_.code] = @{'parents'=$_.Parents;'par_code'=$_.Par_code;'ou'=$_.department}}

function Create-DN($code) {

    if ($parents_table[$code]['parents'] -eq "None") {
        $dn = $dn + "OU="+$parents_table[$code]['ou']+","+$dc
        return $dn        
    }
    
    else {
        $dn = $dn + "OU="+$parents_table[$code]['ou']+","
        Create-DN($parents_table[$code]['par_code'])
    }

}
$result_table = @()

$csv | % {
    $dn = ""
    $result = Create-DN($_.code)
    $path = ($result -split ",")[1..100] -join ","
    write-host $result

    $record = New-Object -TypeName PSObject -Property @{
        OU = $_.Department
        Path = $path
        Dn = $result}
    $result_table += $record    
}

$result_table | Export-Csv -Path $output_path -NoTypeInformation -Encoding UTF8

