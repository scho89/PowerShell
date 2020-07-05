$list = @()

$Groups = Get-UnifiedGroup -ResultSize Unlimited
$Groups | ForEach-Object {
    $group = $_

    Get-UnifiedGroupLinks -Identity $group.Name -LinkType Owner -ResultSize Unlimited | ForEach-Object {
        $record = New-Object -TypeName PSObject -Property @{
        Group = $group.DisplayName
        Member = $_.Name
        EmailAddress = $_.PrimarySMTPAddress
        RecipientType= $_.RecipientType
        Role = "Owner"
        }
        $list += $record
    }


    Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members -ResultSize Unlimited | ForEach-Object {
        $record = New-Object -TypeName PSObject -Property @{
        Group = $group.DisplayName
        Member = $_.Name
        EmailAddress = $_.PrimarySMTPAddress
        RecipientType= $_.RecipientType
        Role = "Member"
        }
        $list += $record
    }



} 

$list | Export-CSV ".\Office365GroupMembers.csv" -NoTypeInformation -Encoding UTF8
