param ($apikey);

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

$source = "https://download.nvidia.com/gfnpc/GeForceNOW-release.exe";
$target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();
$unzip  = "$env:TEMP\" + [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName());

$cregex = "-Checksum '([a-fA-F0-9]{64})'";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+\.([0-9]+))</version>";

Write-Host "Downloading latest GeForceNOW installer.";
Invoke-WebRequest -Uri $source -OutFile $target;

$local = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$online = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

Write-Host "Local Hash: $local"
Write-Host "Online Hash: $online"

if ($local -eq $online) {
    $host.SetShouldExit(0);
    Write-Host "No update available." -ForegroundColor Green;
    return;
} 

Write-Host "New version available!";

$7zip = Get-Command "7z.exe" -ErrorAction SilentlyContinue;
if ($null -eq $7zip) 
{
    Write-Error "Unable to find 7z.exe in your PATH.";
    $host.SetShouldExit(2);
    return;
}

Write-Host "Expanding self-extracting executable.";

& $7zip.Source e -o"$unzip" "$target" "GeForceNOW.exe" -r  | Out-Null;
$pkgmatch = (Select-String -Path $ScriptDir\nvidia-geforce-now.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
$pkgver = $pkgmatch[1].Value;
$newver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$unzip\GeForceNOW.exe").ProductVersion;

Write-Host "Current package version: $pkgver";
Write-Host "New package version: $newver";

if ($pkgver -eq $newver) {
    Write-Error "Unable to auto-increment, package versions are the same!" -ForegroundColor DarkYellow;
    $host.SetShouldExit(2);
    exit;
}

((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";
((Get-Content -Path "$ScriptDir\nvidia-geforce-now.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\nvidia-geforce-now.nuspec";

Write-Host "Repackaging...";
Remove-Item $ScriptDir\*.nupkg
& choco pack $ScriptDir\nvidia-geforce-now.nuspec

if (Test-Path $target -PathType Leaf) {
    Write-Host "Cleaning up temp files...";
    Remove-Item $target -Force;
}

if (Test-Path $unzip -PathType Container) {
    Write-Host "Cleaning up temp directories...";
    Remove-Item $unzip -Force -Recurse;
}

if ($apiKey -eq "" -or $null -eq $apiKey) {
    $apiKeySecure = Read-Host "Enter a valid Chocolatey API Key to publish" -AsSecureString;
    $apiKeyPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure);
    $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($apiKeyPtr);
}

if ($apiKey -ne "" -and $null -ne $apiKey) 
{
    Write-Host "Pushing new version...";
    & choco push "nvidia-geforce-now.$newver.nupkg" --source=https://chocolatey.org/ --apikey=$apiKey | Out-Null
    Write-Host "Upload Complete" -ForegroundColor Green;
    $host.SetShouldExit(1);
}