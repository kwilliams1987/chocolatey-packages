$expectedHash = "0000000000000000000000000000000000000000000000000000000000000000";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'WowUp' -FileFullPath "$fileName" `
    -Url 'https://github.com/jliddev/WowUp/releases/download/v0.0.0/WowUp.zip';

$hash = (Get-FileHash "$fileName" -Algorithm SHA256).Hash.ToLower();

if ($hash -ne $expectedHash) 
{
    Remove-Item $fileName -Force -Confirm:$false -ErrorAction SilentlyContinue;
    Write-Error "The returned hash $hash does not match the expected one.";
    $host.SetShouldExit(-1);
    return;
}

Get-ChocolateyUnzip -FileFullPath $fileName -Destination $toolsDir;
Remove-Item $fileName;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\WowUp.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";

$shell = New-Object -ComObject ("WScript.Shell");
$shortCut = $shell.CreateShortcut($shortcutPath);
$shortCut.TargetPath = "$toolsDir\WowUp.exe";
$shortCut.Description = "Unified World of Warcraft Add-on Manager";

$shortcut.Save();
