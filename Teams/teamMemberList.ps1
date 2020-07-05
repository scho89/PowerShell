$list=@()
$Groups = Get-Team
$Groups | ForEach-Object {
$group = $_
Get-TeamUser -GroupId $group.GroupId | ForEach-Object {
    $record = New-Object -TypeName PSObject -Property @{
        GroupName = $group.DisplayName
        GroupId = $group.GroupId
        Name = $_.Name
        UserId =$_.userid  
        EmailAddress = $_.User
        Role= $_.Role
        }
        $list += $record
    }
}

$list | Export-CSV ".\TeamGroupMembers.csv" -NoTypeInformation -Encoding UTF8