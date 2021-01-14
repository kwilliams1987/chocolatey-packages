$expectedHash = "28083c2a4d59473be9ab7d258fa8477da30f7b9afc2c31e793bf820bd7d0a43d";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour (OpenGL)' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.6.3/ajour-opengl.exe' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour-opengl.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour (OpenGL).lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour-opengl.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
