$expectedHash = "f2386f07ee5f90fe30279a4c996cd48490222cd9b8dc79260c92fa177371718a";
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";
$fileName = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$fileName" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.3.4/ajour.exe';

$hash = (Get-FileHash "$fileName" -Algorithm SHA256).Hash.ToLower();

if ($hash -ne $expectedHash) {
    Remove-Item $fileName -Force -Confirm:$false -ErrorAction SilentlyContinue;
    throw "The returned hash $hash does not match the expected one.";
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