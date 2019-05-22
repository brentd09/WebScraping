[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://talosintelligence.com/reputation_center/lookup?search=8.8.8.8'
$htmlObj = Invoke-WebRequest -UseBasicParsing -Uri $url

[int[]]$TableStarts = @()
[int[]]$TableEnds = @()
[int[]]$TableLengths = @()

$singleString = $htmlObj.Content -replace "`n",''
$indexStart = $singleString.IndexOf("<table")
$indexEnd   = $singleString.indexof("</table")
$firstPass = $true
do {
  if ($firstPass -eq $true) {$firstPass = $false}
  else {
    $indexStart = $NextTablestart
    $indexEnd   = $NextTableend
  }
  $NextTablestart = $singleString.IndexOf("<table",$indexEnd)
  $NextTableend   = $singleString.IndexOf("</table",($indexEnd+8)) + 8
  $TableLength = $NextTableend - $NextTablestart
  $TableStarts += $NextTablestart
  $TableEnds   += $NextTableend
  $TableLengths += $TableLength
} until ($NextTablestart -eq -1)
