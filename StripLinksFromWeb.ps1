<#
.SYNOPSIS
  This script extract all of the links from a web page
.DESCRIPTION
  This script looks for all of the a hrefs from aweb page and prints them to the screen
.NOTES
  Created by: Brent Denny
  Created on: 30 Aug 2024
.PARAMETER Url
  This defines the URL of the web site to strip the links from
.EXAMPLE
  StripLinksFromWeb
  looks for all of the a hrefs from aweb page and prints them to the screen
#>
[CmdletBinding()]
Param (
  $Url = "https://example.com"
)

# Send a web request to the URL
$Response = Invoke-WebRequest -Uri $Url

# Extract the links from the response
$Links = $Response.Links

# Display the links
foreach ($Link in $Links) {
    Write-Output $Link.href
}
