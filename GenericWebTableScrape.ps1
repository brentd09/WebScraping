[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://talosintelligence.com/reputation_center/lookup?search=8.8.8.8'
$htmlObj = Invoke-WebRequest -UseBasicParsing -Uri $url

$singleString = $htmlObj.Content -replace "`n",''
$indexStart = $singleString.IndexOf("<table")
$indexEnd   = $singleString.indexof("</table")
$firstPass = $true
do {
  if ($firstPass -eq $true) {
    $firstPass = $false
    $NextTablestart = $indexStart
    $NextTableend   = $indexEnd + 8
    $TableLength = $NextTableend - $NextTablestart
  }
  else {
    $indexStart = $NextTablestart
    $indexEnd   = $NextTableend
    $NextTablestart = $singleString.IndexOf("<table",$indexEnd)
    $NextTableend   = $singleString.IndexOf("</table",($indexEnd+8)) + 8
    $TableLength = $NextTableend - $NextTablestart
  }
  $Hash = [ordered]@{
  TableStart = $NextTablestart
  TableEnd   = $NextTableend
  TableLength = $TableLength
  }
  if ($NextTablestart -gt 0) {New-Object -TypeName psobject -Property $Hash}} until ($NextTablestart -eq -1)
