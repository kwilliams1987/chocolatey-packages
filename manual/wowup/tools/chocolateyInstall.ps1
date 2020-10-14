$expectedHash = "158ead0c9c4d72c11a24439b1cec636d47091f16616b2b1d19c955bc027061f3";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'WowUp' -FileFullPath "$fileName" `
    -Url 'https://github.com/jliddev/WowUp/releases/download/v1.18.3/WowUp.zip' `
    -Checksum $expectedHash `
    -ChecksumType 'sha256';

Get-ChocolateyUnzip -FileFullPath $fileName -Destination $toolsDir;
Remove-Item $fileName;

$shortcutPath = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\WowUp.lnk";

Remove-Item -Path $shortcutPath -Force -Confirm:$false -ErrorAction SilentlyContinue;

Write-Host "Creating shortcut";
Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath "$toolsDir\WowUp.exe" `
    -Description "Unified World of Warcraft Add-on Manager";
