$CovertTemplate = @'
{DamName*:Sideling Creek Dam**}
{MaxCapacity:14,192}
{CurrentCapacity:9,344}
{PercentFull:65.8}
{DateMeasured:24/05/2019 02:36AM}
{Comments:}
{DamName*:Somerset Dam}
{MaxCapacity:379,849}
{CurrentCapacity:292,384}
{PercentFull:77.0}
{DateMeasured:24/05/2019 02:19AM}
{Comments:bob}
{DamName*:Wappa Dam}
{MaxCapacity:4,694}
{CurrentCapacity:4,710}
{PercentFull:100.3}
{DateMeasured:24/05/2019 12:53AM}
{Comments:Dam is spilling}
'@

$Tags = Get-TagsInHtml
[xml]$xml = $tags[1].TagRaw
$damdata = $xml.table.tbody.tr.td | Select-Object id,'#text'
$damdata | Select-Object '#text' | ConvertFrom-String -TemplateContent $CovertTemplate