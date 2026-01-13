Write-Host ">>> Running 1C Assembly Check..." -ForegroundColor Cyan
if (Test-Path "f:\db_1c\test_7_modif") { Remove-Item "f:\db_1c\test_7_modif\*" -Recurse -Force -ErrorAction SilentlyContinue }
else { New-Item -ItemType Directory -Path "f:\db_1c\test_7_modif" -Force | Out-Null }
Start-Process -FilePath "C:\Program Files\1cv8\8.3.25.1374\bin\1cv8.exe" -ArgumentList "CREATEINFOBASE", "File=""f:\db_1c\test_7_modif"";Locale=ru_RU", "/Out", "$env:TEMP\1c_c.log", "/Visible" -Wait
$LoadLog = "$env:TEMP\1c_load.log"
$p = Start-Process -FilePath "C:\Program Files\1cv8\8.3.25.1374\bin\1cv8.exe" -ArgumentList "DESIGNER", "/F", """f:\db_1c\test_7_modif""", "/LoadConfigFromFiles", """F:\VSCodeProjects\1C\test_7_xml""", "/Out", """$LoadLog""", "/Visible" -Wait -PassThru
if ($p.ExitCode -eq 0) { Write-Host "
>>> VICTORY! Assembly Successful. <<<" -ForegroundColor Green }
else { Write-Host "!!! FAILED !!!" -ForegroundColor Red; Get-Content $LoadLog | Select-String "Ошибка", "Error" }
