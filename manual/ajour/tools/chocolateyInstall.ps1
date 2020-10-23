$expectedHash = "c0e3559753bda36a7bcd797362aec0e171d106eaf7ded4333059db888faafd3c";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.4.3/ajour.exe' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
