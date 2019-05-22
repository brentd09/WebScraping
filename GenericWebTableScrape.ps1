function Find-TablesInHtml {
  Param (
    [string]$url = 'https://talosintelligence.com/reputation_center/lookup?search=8.8.8.8'

  )
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $htmlObj = Invoke-WebRequest -UseBasicParsing -Uri $url
  
  $SingleString = $htmlObj.Content -replace "`n",'' 
  $SingleStringNoGaps = $SingleString -replace '\s{2,}',''
  $FirstPass = $true
  do {
    if ($FirstPass -eq $true) {
      $FirstPass = $false
      $NextTableStart = $SingleStringNoGaps.IndexOf("<table")
      $NextTableEnd   = $SingleStringNoGaps.indexof("</table") + 8
      $TableLength = $NextTableEnd - $NextTableStart
    }
    else {
      $IndexEnd   = $NextTableEnd
      $NextTableStart = $SingleStringNoGaps.IndexOf("<table",$IndexEnd)
      $NextTableEnd   = $SingleStringNoGaps.IndexOf("</table",($IndexEnd)) + 8
      $TableLength = $NextTableEnd - $NextTableStart
    }
    if ($NextTablestart -gt 0) {
      $Hash = [ordered]@{
        TableStart = $NextTableStart
        TableEnd   = $NextTableEnd
        TableLength = $TableLength
        TableRaw = $SingleStringNoGaps.Substring($NextTableStart,$TableLength)
      }
      New-Object -TypeName psobject -Property $Hash
    }
  } until ($NextTablestart -eq -1)
}

$Tables = Find-TablesInHtml
$Tables 