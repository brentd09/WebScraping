﻿<#
.Synopsis
   QLD River levels
.DESCRIPTION
   This was a test to see how to extract data from a website table, All QLD River Water levels 
.NOTES
   General notes
   Created
   By: Brent Denny
   On: Feb 2019
#>
$webResponse = Invoke-WebRequest  "http://www.bom.gov.au/cgi-bin/wrap_fwo.pl?IDQ60005.html" -UseBasicParsing
$tableData = $webResponse.RawContent -split "`n" | Select-String -Pattern '(?=^\s*\<t[rdh]\>.*)(?!.*\<a\s*href).*'
$blockData = $tableData -join ''  -replace '(?:<tr>)+','<tr>'  -replace '\s*</td>\s*<td>\s*',',' -replace '&nbsp;','NoData' -replace '\s*</th>\s*<th>\s*',','
$riverCsv = $blockData -replace '\s*</td>\s*<tr>\s*<td>\s*',"`n" -replace '\s*<tr>\s*<td>\s*',''-replace '</td>','' -replace '\s*<tr>\s*<th>\s*','' -replace '</th>',"`n"
$riverObj = $riverCsv | ConvertFrom-Csv 
$riverObj