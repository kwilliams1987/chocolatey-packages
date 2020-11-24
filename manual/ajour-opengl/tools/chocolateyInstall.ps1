$expectedHash = "8e84024832a0e45c552c2c9361d7287f4a165f78cc77655d3af47cd1e8a0b402";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour (OpenGL)' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.5.3/ajour-opengl.exe' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour-opengl.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour (OpenGL).lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour-opengl.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
