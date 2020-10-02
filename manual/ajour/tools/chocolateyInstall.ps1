$expectedHash = "cdb002c5cad1159ef2027e9f59f5e8f516849816d4aed14dd02a5e4539a5e769";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.3.5/ajour.exe';

$hash = (Get-FileHash "$fileName" -Algorithm SHA256).Hash.ToLower();

if ($hash -ne $expectedHash) 
{
    Remove-Item $fileName -Force -Confirm:$false -ErrorAction SilentlyContinue;
    Write-Error "The returned hash $hash does not match the expected one.";
    $host.SetShouldExit(-1);
    return;
}

Move-Item -Path "$fileName" -Destination "$toolsDir\ajour.exe" -Force;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";

$shell = New-Object -ComObject ("WScript.Shell");
$shortCut = $shell.CreateShortcut($shortcutPath);
$shortCut.TargetPath = "$toolsDir\ajour.exe";
$shortCut.Description = "Unified World of Warcraft Add-on Manager";

$shortcut.Save();
