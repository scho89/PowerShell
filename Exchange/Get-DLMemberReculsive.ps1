
function Get-DnMember{
    param (
        [string]$DN#,
        #[array]$result
    )
    $DN = ($DN -split ' ')[0]
    $members = Get-DistributionGroupMember -Identity $DN


    foreach($member in $members){

        if ($member.RecipientType -like "*group*") {
            
            Get-DnMember($member.DisplayName)
            
        }

        else {

            $record = New-Object -TypeName PSObject -Property @{
                #ParentDisplayName = $DN.DisplayName
                ParentEmailAddress = $DN
                DisplayName = $member.DisplayName
                Department = $member.Department
                Email = $member.PrimarySmtpAddress
            }
            $record
            $global:result += $record
            
        }

    }

}
$global:result = @()

$dn = Get-DistributionGroupMember -Identity "ZN_all"
Get-DnMember('ZN_all')


