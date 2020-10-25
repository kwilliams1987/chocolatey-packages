$expectedHash = "9cad7594b28437c29ed03afa51c3112fbfeefed9b4cb6b6d966f7357feaa3da2";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'WowUp' -FileFullPath "$fileName" `
    -Url 'https://github.com/jliddev/WowUp/releases/download/v1.19.1/WowUp.zip' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Get-ChocolateyUnzip -FileFullPath $fileName -Destination $toolsDir;
Remove-Item $fileName;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\WowUp.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\WowUp.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
