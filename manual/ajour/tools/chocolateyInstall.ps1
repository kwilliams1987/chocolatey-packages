$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";

Remove-Item -Path "$toolsDir\ajour.exe" -Force -Confirm:$false -ErrorAction SilentlyContinue;

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$toolsDir\ajour.exe" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.3.4/ajour.exe';

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";

$shell = New-Object -ComObject ("WScript.Shell");
$shortCut = $shell.CreateShortcut($shortcutPath);
$shortCut.TargetPath = "$toolsDir\ajour.exe";
$shortCut.Description = "Unified World of Warcraft Add-on Manager";

$shortcut.Save();