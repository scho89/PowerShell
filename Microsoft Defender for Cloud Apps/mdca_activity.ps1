$start_datetime = "2022-03-01 0:00:00"
$end_datetime = "2022-03-31 0:00:00"


$ClientId = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
$ClientSecret = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
$TenantId = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$resourceAppIdUri = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$oAuthUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$tenantName = "TestTenant"

$authBody = [Ordered] @{
    resource = "$resourceAppIdUri"
    client_id = "$ClientId"
    client_secret = "$ClientSecret"
    grant_type = 'client_credentials'
}




$csv = './activities_report'+(Get-Date -Format MMddHHmmss)+'.csv' 
$log = $csv -replace "csv","log"

$start = Get-Date
$graph = "https://$tenantName.us3.portal.cloudappsecurity.com/api"
$uri = "$graph/v1/activities/"

$counter = 1
$total= 0
$page = 0


$start_timestamp = (New-TimeSpan -Start (Get-Date "1970-01-01 0:00:00") -End $start_datetime).TotalSeconds*1000
$end_timestamp = (New-TimeSpan -Start (Get-Date "1970-01-01 0:00:00") -End $end_datetime).TotalSeconds*1000


$body=@{
  filters= (@{
    "activity.eventType"= @{
      "eq"= @("EVENT_CATEGORY_DOWNLOAD_FILE","EVENT_CATEGORY_UPLOAD_FILE")
    }
    "date"=@{
        "gte"= $start_timestamp
        "lte"= $end_timestamp
    }
  }|convertto-json)
  "isScan"= "True"
}

Add-Content ((Get-Date -Format "yy/MM/dd HH:mm:ss" )+"|"+[string]$start_datetime+"~"+[string]$end_datetime) -path $log -Encoding UTF8

do {

    $res = $null
   
    if ($counter % 100 -eq 1 ) {
        $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
        $token = $authResponse.access_token
        $authToken = @{'Authorization'='Bearer '+$token}
    }

    try {
        $res = Invoke-RestMethod -Uri $uri -Headers $authToken -Body $body -Method post
        $res.data | Select-Object _id,@{name="DateTime";Expression={(Get-Date "1970-01-01 0:00:00")+[timespan]::FromMilliseconds($_.timestamp)}},@{name="userprincipalname";Expression={$_.user.username}},eventTypeName,eventTypeValue,description | Export-Csv $csv -Encoding utf8 -Append -NoTypeInformation
        $total += $res.data.Length         

        if($res.hasNext){
            
            $body =  @{
                filters= (@{
                    "activity.eventType"= @{
                    "eq"= @("EVENT_CATEGORY_DOWNLOAD_FILE","EVENT_CATEGORY_UPLOAD_FILE")
                    }
                    "date"=@{
                        "gte"= $res.nextQueryFilters.date.gte
                        "lte"= $res.nextQueryFilters.date.lte
                    }
                }|convertto-json)
                "isScan"= "True"
            }

        }

        $page ++
        Write-Host (get-date)"|Page"$page.ToString("#,#")"; Total" $total.ToString("#,#") "records."
    }

    catch {
        $logMessage = (Get-Date -Format "yy/MM/dd HH:mm:ss") + "| An error occurred while loading timestamp between "+ $res.nextQueryFilters.date.gte + ";"+ $res.nextQueryFilters.date.gte +" (milliseconds from 1970/01/01 00:00) | " + $Error[0]
        Add-Content $log -value $logMessage -Encoding utf8
        Write-Host  (get-date)"|[Error]"($uri+":"+$error[0]) -ForegroundColor Red
        Write-Host (get-date)"|[Info] Retrying page"$page.ToString("#,#")" in 30 seconds... : $uri" -ForegroundColor Yellow
        Start-Sleep -Seconds 35
    }
    finally{
        $counter ++
        Start-Sleep -Milliseconds 1500
    }

} while ($res.hasNext)

Write-host (((get-date)-$start).Totalseconds).ToString("#,#") "seconds for querying"$total.ToString("#,#")" lines of data" -f y 
