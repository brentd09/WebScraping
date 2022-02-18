function Get-SeqDamLevels {
  [CmdletBinding()]
  Param ($SEQDamUrl = 'https://www.seqwater.com.au/dam-levels')
  $RawWebContent = (Invoke-WebRequest -Uri $SEQDamUrl).Content
  $RawNoWhiteSpace = $RawWebContent -replace '\s{2,}','' 
  $TableStartIndex = $RawNoWhiteSpace.IndexOf('<table')
  $TableEndIndex = $RawNoWhiteSpace.IndexOf('</table')
  $TableCharCount = $TableEndIndex - $TableStartIndex + 8
  $Table = $RawNoWhiteSpace.Substring($TableStartIndex,$TableCharCount)
  $TableArray = $Table -split '</tr>'
  [System.Collections.ArrayList]$RowArray = @()
  
  $DamCsv = foreach ($tableRow in $TableArray) {
    [System.Collections.ArrayList]$RowArray = $tableRow -split '\<\/t[hd]\>'  -replace '(\<\/a\>.*?)?View historical dam levels','' -replace '\<p\>.*?\<\/p\>','' -replace '<.*?>',''
    $RowArray[0] = $RowArray[0].Trim()
    if ($RowArray.count -gt 1) {
      $RowArray[1] = $RowArray[1] -replace '\D',''
      $RowArray[2] = $RowArray[2] -replace '\D',''
      $RowArray[3] = $RowArray[3] -replace '\%',''
      $RowArray.RemoveAt(6)
      $RowArray -join ','
    }
  }
  $DamCsv | 
    Select-Object -Skip 1 | 
    ConvertFrom-Csv -Header "Dam","Full","Current","Percent","Date","Comment" |
    Select-Object -Property Dam,
                            @{n='FullCapacity';e={$_.Full -as [int]}},
                            @{n='CurrentCapacity';e={$_.Current -as [int]}},
                            @{n='PercentFull';e={$_.Percent -as [double]}},
                            @{n='DateMeasured';e={$_.Date -as [datetime]}},
                            Comment 
}
