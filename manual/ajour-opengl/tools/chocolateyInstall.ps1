$expectedHash = "bd92dd37df0f06d30814f0b07c6a6e0e3a1151631b7b374264017b2a5798f604";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.4.0/ajour-opengl.exe';

$hash = (Get-FileHash "$fileName" -Algorithm SHA256).Hash.ToLower();

if ($hash -ne $expectedHash) 
{
    Remove-Item $fileName -Force -Confirm:$false -ErrorAction SilentlyContinue;
    Write-Error "The returned hash $hash does not match the expected one.";
    $host.SetShouldExit(-1);
    return;
}

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour-opengl.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour (OpenGL).lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\ajour-opengl.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
