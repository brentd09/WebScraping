function Find-TablesInHtml {
  Param (
    [string]$url = 'https://talosintelligence.com/reputation_center/lookup?search=8.8.8.8',
    [string]$HTMLTagName = 'table'

  )
  $TagNameCloseLength = $HtmlTagClose.Length + 3
  $HtmlTagOpen = '<'+$HTMLTagName
  $HtmlTagClose = '</'+$HTMLTagName
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $htmlObj = Invoke-WebRequest -UseBasicParsing -Uri $url
  
  $SingleString = $htmlObj.Content -replace "`n",'' 
  $SingleStringNoGaps = $SingleString -replace '\s{2,}',''
  $FirstPass = $true
  do {
    if ($FirstPass -eq $true) {
      $FirstPass = $false
      $NextTableStart = $SingleStringNoGaps.IndexOf($HtmlTagOpen)
      $NextTableEnd   = $SingleStringNoGaps.indexof($HtmlTagClose) + $TagNameCloseLength
      $TableLength = $NextTableEnd - $NextTableStart
    }
    else {
      $IndexEnd   = $NextTableEnd
      $NextTableStart = $SingleStringNoGaps.IndexOf($HtmlTagOpen,$IndexEnd)
      $NextTableEnd   = $SingleStringNoGaps.IndexOf($HtmlTagClose,($IndexEnd)) + $TagNameCloseLength
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