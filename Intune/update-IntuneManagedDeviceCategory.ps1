<#
###required permission
DeviceManagementConfiguration.Read.All,application,Read Microsoft Intune device configuration and policies
DeviceManagementConfiguration.ReadWrite.All,application,Read and write Microsoft Intune device configuration and policies
DeviceManagementManagedDevices.Read.All,application,Read Microsoft Intune devices
DeviceManagementManagedDevices.ReadWrite.All,application,Read and write Microsoft Intune devices
#>

### Variables #########
$TenantId = "023ef17e-xxxx-xxxx-xxxx-e0b9e89627bf"
$ClientId = "42d9f147-xxxx-xxxx-xxxx-ce21e8c9b11a"
$ClientSecret = "113rCrxxxxxxxxxxxxxxxxxxxxxxxxxx"
$deviceCsvPath = "~\intuneDevice.csv"
$categoryCsvPath = "~\intuneDeviceCategory.csv"


$BodyClientID = @{
    'tenant' = $TenantId
    'client_id' = $ClientId
    'scope' = 'https://graph.microsoft.com/.default'
    'client_secret' = $ClientSecret
    'grant_type' = 'client_credentials'
}

# Assemble a hashtable for splatting parameters, for readability
# The tenant id is used in the uri of the request as well as the body
$Params = @{
    'Uri' = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    'Method' = 'Post'
    'Body' = $BodyClientID
    'ContentType' = 'application/x-www-form-urlencoded'
}

#Create authToken
$AuthResponse = Invoke-RestMethod @Params
$token = $AuthResponse.access_token
$authToken = @{'Authorization'='Bearer '+$token}

#if category list is exist:
if ((Test-Path $categoryCsvPath) -and (Test-Path $deviceCsvPath)){
    $deviceCsv = Import-Csv $deviceCsvPath
    $deviceCsv | %{
        Write-Host "Setting category for"$_.deviceName    
        $update_uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('"+$_.id+"')/deviceCategory/" +'$ref'
        $JSON = @{ "@odata.id" = "https://graph.microsoft.com/beta/deviceManagement/deviceCategories/"+$_.CategoryID } | ConvertTo-Json
        Invoke-RestMethod -Uri $update_uri -Headers $authToken -Method Put -Body $JSON -ContentType "application/json"
    }
}

#if category list is not exist => create category list
if ( !(Test-Path $categoryCsvPath)){
    
    $categoryUri = "https://graph.microsoft.com/beta/deviceManagement/deviceCategories"
    $categories = Invoke-RestMethod -Uri $categoryUri -Headers $authToken -ContentType "application/json"
    $categories.value | Export-Csv $categoryCsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Device category list is created. :" $categoryCsvPath -f y

}

#if device list is not exist => create device list
if ( !(Test-Path $deviceCsvPath)){
    $managedDeviceList =@()    
    $nextPage = $false
    $deviceUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
    $devicelist = Invoke-RestMethod -Uri $deviceUri -Headers $authToken -ContentType "application/json"
    $managedDeviceList += $devicelist.value
    
    #get next page devices if it's possible
    if ($devicelist."@odata.nextLink") {
        $nextPageUri = $devicelist."@odata.nextLink"
        $nextPage = $true
        while ($nextPage) {
            $nextPageDevice = Invoke-RestMethod -Uri $nextPageUri -Headers $authToken -ContentType "application/json"
            $managedDeviceList += $nextPageDevice.value
            if ($nextPageDevice."@odata.nextLink"){
                $nextPageUri = $nextPageDevice."@odata.nextLink"
            }

            else {
                $nextPage =$false
            }
        }
    }
    $managedDeviceList | Export-Csv $deviceCsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Device list is created. :" $deviceCsvPath -f y
}