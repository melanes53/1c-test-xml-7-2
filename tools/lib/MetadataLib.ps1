function Backup-File { param($Path) if (Test-Path $Path) { Copy-Item $Path -Destination "$Path.bak" -Force } }
function Remove-1CObjectTraces {
    param($Type, $Name)
    Write-Host " - Cleaning traces of $Type.$Name..." -ForegroundColor Gray
    foreach ($file in @("Configuration.xml", "ConfigDumpInfo.xml")) {
        if (Test-Path $file) {
            Backup-File $file
            [xml]$xml = Get-Content $file -Encoding UTF8
            $xpath = if ($file -eq "Configuration.xml") { "//*[local-name()='ChildObjects']/*[local-name()='$Type' and text()='$Name']" } 
                     else { "//*[local-name()='ConfigVersions']/*[local-name()='Metadata' and (@name='$Type.$Name' or contains(@name, '.$Name'))]" }
            $nodes = $xml.SelectNodes($xpath)
            foreach($n in $nodes) { $n.ParentNode.RemoveChild($n) | Out-Null }
            $xml.Save($file)
        }
    }
}
function Get-1CInsertionPoint {
    param($XmlDoc, $ContainerXPath, $TargetType)
    $container = $XmlDoc.SelectSingleNode($ContainerXPath)
    $typeOrder = @("Language", "CommonModule", "CommonForm", "Catalog", "Document", "Report", "InformationRegister", "AccumulationRegister")
    $targetIdx = $typeOrder.IndexOf($TargetType)
    for ($i = $targetIdx; $i -ge 0; $i--) {
        $checkType = $typeOrder[$i]
        $lastNode = $container.SelectNodes("./*[local-name()='$checkType'] | ./*[local-name()='Metadata' and starts-with(@name, '$checkType.')]") | Select-Object -Last 1
        if ($null -ne $lastNode) { return @{ Parent=$container; After=$lastNode } }
    }
    return @{ Parent=$container; After=$null }
}
