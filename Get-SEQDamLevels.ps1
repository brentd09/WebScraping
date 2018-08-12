<#
.SYNOPSIS
   Gets the current dam levels in SEQ
.DESCRIPTION
   This script invokes a web request and then from the raw data it
   strips out the actual data from the html code and produces an
   object collection of the the dam levels in South East QLD
.EXAMPLE
   Get-SEQDamLevels
.NOTES
   Created by:   Brent Denny 
   Created date: 31-Oct-2017
   Last Modified: BD 01-Nov-2017
#>
[CmdletBinding(SupportsShouldProcess=$true, 
               PositionalBinding=$false,
               ConfirmImpact='Low')]
Param (

)
#These RegEx strings are to be used in converting the html tags into nothing,commas,newlines
$RegExToBlank = "^.*?dam\dNam\'\>|\<\/td\>\<\/tr\>.+?(\'TableDataContent\'|\<\/table\>)"
$RegExToComma = "</td><td class='TableDataContent.*?' id='dam\d+(Max|Vol|Per|Read|Comment)\'\>"
$RegExToNewline = "id\=\'dam\d+Nam\'\>"

$rawWebdata = Invoke-WebRequest -UseBasicParsing -Uri http://www.seqwater.com.au/water-supply/dam-levels 
$Webcontent = $rawWebdata.RawContent
#remove multiple spaces and newlines to create one block of string
$WebBlock = $Webcontent -replace "\s{2,}|\n",''
#Extracting the tables from the web data only
$matched = $WebBlock | Select-String -Pattern '\<table.+?\<\/table\>' -AllMatches| ForEach-Object {$_.matches}
#Converting the table I want to a CSV type data
$DamsToCSV = $Matched[1].Value -replace "(\d+)\,(\d{3})\,?(\d{3})?",'$1$2$3' -replace $RegExToBlank,''  -replace $RegExToNewline,"`n" -replace $RegExToComma,','
#Converting the CSV data into a PS object
$SEQDamsObj = $DamsToCSV | ConvertFrom-Csv -Header DamName,MaxCapacity,CurrentCapacity,PercentFull,DateMeasured,Comment
#Convert the properties to be their correct types
$CompleteObj = $SEQDamsObj | Select-Object @{n='DamName';e={$_.DamName -as [string]}},
                                           @{n='MaxCapacity';e={$_.MaxCapacity -as [double]}},
                                           @{n='CurrentCapacity';e={$_.CurrentCapacity -as [double]}},
                                           @{n='PercentFull';e={$_.PercentFull -as [double]}},
                                           @{n='DateMeasured';e={get-date -date $_.DateMeasured }}, #Need to do date this was as the [datetime] only uses USA date format
                                           @{n='Comment';e={$_.Comment -as [string]}}
$CompleteObj                                         