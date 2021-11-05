$expectedHash = "400b3475e2cefccad2f7d200b9a02f8134fbd91ae6ff0820207950d05c152054";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/1.3.2/ajour-noselfupdate.exe' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
