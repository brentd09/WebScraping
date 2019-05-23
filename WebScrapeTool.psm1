function Get-TagsInHtml {
  <#
  .SYNOPSIS
    This command will scrape out HTML content from a Web page
  .DESCRIPTION
    The command will use the URL and tag names supplied and strip the content from the
    website based on the tag name provided, for example if the website has tables in 
    the page and you want the table data to be displayed; you specify the URL and the 
    name of the tag which in this case would be TABLE and this would extract each TABLE
    and setup an object collection showing the entire <table>...</table> so this can 
    be converted to XML to make the traversal of the tags and data very simple.
  .EXAMPLE
    [xml[]]$WebInfo = Get-TagsInHtml -URL 'http://website.com' -HTMLTagName 'table'
    This will extract all of the TABLES from the URL and will create a XML array.
  .NOTES
    General notes
      Created by: Brent Denny
      Created on: 23-May-2019
  #>
  [cmdletbinding()]
  Param (
    [string]$url = 'https://talosintelligence.com/reputation_center/lookup?search=8.8.8.8',
    [string]$HTMLTagName = 'table'

  )

  $HtmlTagOpen = '<'+$HTMLTagName
  $HtmlTagClose = '</'+$HTMLTagName
  $TagNameCloseLength = $HtmlTagClose.Length + 1
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $htmlObj = Invoke-WebRequest -UseBasicParsing -Uri $url
  
  $SingleString = $htmlObj.Content -replace "`n",'' 
  $SingleStringNoGaps = $SingleString -replace '\s{2,}',''
  $FirstPass = $true
  do {
    if ($FirstPass -eq $true) {
      $FirstPass = $false
      $NextTagStart = $SingleStringNoGaps.IndexOf($HtmlTagOpen)
      $NextTagEnd   = $SingleStringNoGaps.indexof($HtmlTagClose) + $TagNameCloseLength
      $TagLength = $NextTagEnd - $NextTagStart
    }
    else {
      $IndexEnd   = $NextTagEnd
      $NextTagStart = $SingleStringNoGaps.IndexOf($HtmlTagOpen,$IndexEnd)
      $NextTagEnd   = $SingleStringNoGaps.IndexOf($HtmlTagClose,($IndexEnd)) + $TagNameCloseLength
      $TagLength = $NextTagEnd - $NextTagStart
    }
    if ($NextTagstart -gt 0 -and $NextTagEnd -gt 0 -and $TagLength -gt 0) {
      $Hash = [ordered]@{
        TagStart = $NextTagStart
        TagEnd   = $NextTagEnd
        TagLength = $TagLength
        TagRaw = $SingleStringNoGaps.Substring($NextTagStart,$TagLength)
      }
      New-Object -TypeName psobject -Property $Hash
    }
  } until ($NextTagstart -eq -1)
}
