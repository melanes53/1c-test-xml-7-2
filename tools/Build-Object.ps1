param($Type, $Name, $DonorName)
. ".\tools\lib\MetadataLib.ps1"
Write-Host ">>> Cloning $Type.$Name from $DonorName..." -ForegroundColor Cyan
$DonorFile = "$($Type)s\$DonorName.xml"
$rawXml = Get-Content $DonorFile -Raw -Encoding UTF8
$rawXml = $rawXml.Replace(".$DonorName", ".$Name").Replace(">$DonorName<", ">$Name<")
[xml]$xml = $rawXml
Write-Host " - Mapping UUIDs..."
$uuidNodes = $xml.SelectNodes("//@uuid | //*[local-name()='TypeId'] | //*[local-name()='ValueId']")
$uuidMap = @{}
foreach ($node in $uuidNodes) {
    $oldGuid = if ($node.LocalName -eq "uuid") { $node.Value } else { $node.InnerText }
    if (-not $uuidMap.ContainsKey($oldGuid)) { $uuidMap[$oldGuid] = [guid]::NewGuid().ToString() }
    if ($node.LocalName -eq "uuid") { $node.Value = $uuidMap[$oldGuid] } else { $node.InnerText = $uuidMap[$oldGuid] }
}
$NewObjUUID = $uuidMap[($xml.SelectSingleNode("//*[local-name()='$Type']")).uuid]
$xml.Save("$($Type)s\$Name.xml")
Remove-1CObjectTraces -Type $Type -Name $Name
[xml]$conf = Get-Content "Configuration.xml" -Encoding UTF8
$pC = Get-1CInsertionPoint -XmlDoc $conf -ContainerXPath "//*[local-name()='ChildObjects']" -TargetType $Type
$newRef = $conf.CreateElement($Type, "http://v8.1c.ru/8.3/MDClasses")
$newRef.InnerText = $Name
if ($pC.After) { $pC.Parent.InsertAfter($newRef, $pC.After) } else { $pC.Parent.AppendChild($newRef) }
$conf.Save("Configuration.xml")
[xml]$cdi = Get-Content "ConfigDumpInfo.xml" -Encoding UTF8
$pD = Get-1CInsertionPoint -XmlDoc $cdi -ContainerXPath "//*[local-name()='ConfigVersions']" -TargetType $Type
$newM = $cdi.CreateElement("Metadata", "http://v8.1c.ru/8.3/xcf/dumpinfo")
$newM.SetAttribute("name", "$Type.$Name")
$newM.SetAttribute("id", $NewObjUUID)
$newM.SetAttribute("configVersion", ([guid]::NewGuid().ToString().Replace("-","")))
if ($pD.After) { $pD.Parent.InsertAfter($newM, $pD.After) } else { $pD.Parent.AppendChild($newM) }
$cdi.Save("ConfigDumpInfo.xml")
Write-Host ">>> Clone Ready." -ForegroundColor Green
