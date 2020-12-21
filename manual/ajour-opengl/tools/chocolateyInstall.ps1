$expectedHash = "cd66dde53cb2ce6bea1ea83bed8ab7256674c24863b921f61f797a11b658e78d";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour (OpenGL)' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.6.0/ajour-opengl.exe' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour-opengl.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour (OpenGL).lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour-opengl.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
