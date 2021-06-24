# 1NF / ADUser info
#
# Reference: https://www.netwrix.com/how_to_get_sharepoint_permissions_report.html
#
#
# CSV file example: list of site collection, column name as url
# Url
# https://sp.hoin.shop/sites/main
# https://sp.hoin.shop/sites/customers
# https://sp.hoin.shop/sites/operations
#
#

Add-PSSnapin Microsoft.SharePoint.PowerShell

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$csv = "~\desktop\sitelist.csv"
$resultCSV = "~\desktop\result.csv"
$SPsiteURLs = Import-csv $csv
$result = [System.Collections.ArrayList]@()

#Get ACL of each site
foreach($SPSiteUrl in $SPsiteURLs.Url){

    $SPSite = New-Object Microsoft.SharePoint.SPSite($SPSiteUrl);

    foreach ($WebPath in $SPSite.AllWebs){
        write-host $WebPath ">>" $WebPath.Url -f y
        
        if ($WebPath.HasUniqueRoleAssignments){
            
            $SPRoles = $WebPath.RoleAssignments;
            foreach ($SPRole in $SPRoles){

                foreach ($SPRoleDefinition in $SPRole.RoleDefinitionBindings){

                    if($SPRole.Member.Users){

                        foreach($user in $SPRole.Member.Users){

                            $sAMAccountName = ($user.UserLogin -Split "\\")[1]
                            $aduserFilter = 'sAMAccountName -eq "'+$sAMAccountName+'"'
                            $aduser = Get-ADUser -Filter $aduserFilter -Properties mail

                            $data = New-Object PSObject -Property [orderd]@{
                                'Title' = $WebPath.Title 
                                'Url' = $WebPath.Url 
                                'ListName' = "N/A"
                                'Principal' = $SPRole.Member.Name
                                'Permission' = $SPRoleDefinition.Name
                                'SiteCollection' = $SPSiteUrl
                                'Member' = $user.displayname
                                'LoginName' = $user.UserLogin -replace "i:0#.w\|",""
                                'Email' = $aduser.mail
                                'UserPrincipalName' = $aduser.UserPrincipalName
                            }
                            $result += $data
                        }
                    }
                    else {

                        $aduserFilter = 'Displayname -eq "'+$SPRole.Member.displayname+'"'
                        $aduser = Get-ADUser -Filter $aduserFilter -Properties mail

                        $data = New-Object PSObject -Property [orderd]@{
                            'Title' = $WebPath.Title 
                            'Url' = $WebPath.Url 
                            'ListName' = "N/A"
                            'Principal' = $SPRole.Member.Name
                            'Permission' = $SPRoleDefinition.Name
                            'SiteCollection' = $SPSiteUrl
                            'Member' = "N/A"
                            'LoginName' = "N/A"
                            'Email' = $aduser.mail
                            'UserPrincipalName' = $aduser.UserPrincipalName
                        }
                        $result += $data
                    }
                }
            }
        }           
            
        foreach ($List in $WebPath.Lists){
            write-host $WebPath ">>" $WebPath.Url ":" $list.Title -f y
            if ($List.HasUniqueRoleAssignments){
                $SPRoles = $List.RoleAssignments;
                foreach ($SPRole in $SPRoles){

                    foreach ($SPRoleDefinition in $SPRole.RoleDefinitionBindings){
                        
                        if($SPRole.Member.Users){

                            foreach($user in $SPRole.Member.Users){

                                $sAMAccountName = ($user.UserLogin -Split "\\")[1]
                                $aduserFilter = 'sAMAccountName -eq "'+$sAMAccountName+'"'
                                $aduser = Get-ADUser -Filter $aduserFilter -Properties mail


                                $data = New-Object PSObject -Property [orderd]@{
                                    'Title' = $WebPath.Title 
                                    'Url' = $WebPath.Url 
                                    'ListName' = $list.Title
                                    'Principal' = $SPRole.Member.Name
                                    'Permission' = $SPRoleDefinition.Name
                                    'SiteCollection' = $SPSiteUrl
                                    'Member' = $user.displayname
                                    'LoginName' = $user.UserLogin -replace "i:0#.w\|",""
                                    'Email' = $aduser.mail
                                    'UserPrincipalName' = $aduser.UserPrincipalName

                                }
                                $result += $data
                            }
                        }

                        else{

                            
                            $aduserFilter = 'Displayname -eq "'+$SPRole.Member.displayname+'"'
                            $aduser = Get-ADUser -Filter $aduserFilter -Properties mail

                            $data = New-Object PSObject -Property [orderd]@{
                                'Title' = $WebPath.Title 
                                'Url' = $WebPath.Url 
                                'ListName' = $list.Title
                                'Principal' = $SPRole.Member.Name
                                'Permission' = $SPRoleDefinition.Name
                                'SiteCollection' = $SPSiteUrl
                                'Member' = "N/A"
                                'LoginName' = "N/A"
                                'Email' = $aduser.mail
                                'UserPrincipalName' = $aduser.UserPrincipalName
                            }
                            $result += $data
                        }

                    }
                }
            }
        }
    }
    $SPSite.Dispose()
}

$result | select `
    SiteCollection,Url,Title,ListName,Principal,Permission,Member,LoginName,UserPrincipalName,Email|
     Export-Csv $resultCSV -NoTypeInformation
