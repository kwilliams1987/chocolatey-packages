param($apiKey, $version = $null);

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$source = "https://github.com/WowUp/WowUp/releases/latest";
$template = "https://github.com/WowUp/WowUp/releases/download/v{0}/WowUp-Setup-{0}.exe";
$packageName = "wowup";
$programName = "WowUp";

$cregex = '\$expectedHash = "([a-fA-F0-9]{64})"';
$iregex = "([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)";
$vregex = "<version>$iregex</version>";
$versionOffset = 1;

$target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

$pkgmatch = (Select-String -Path $ScriptDir\$packageName.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
$pkgver = $pkgmatch[1].Value;

if ($null -ne $version) {
    Write-Host "Forcing package version to $version";
    $newver = $version;
} else {    
    Write-Host "Finding latest version on Github.";
    $segments = [System.Net.WebRequest]::Create($source).GetResponse().ResponseUri.Segments;
    $newver = $segments[-1].Substring($versionOffset);
}

Write-Host "Current package version: $pkgver";
Write-Host "Newest package version: $newver";

if ($pkgver -eq $newver -and $null -eq $version) {
    $host.SetShouldExit(0);
    Write-Host "No update available." -ForegroundColor Green;
    return;
}

Write-Host "New version available!";

Write-Host "Downloading latest version of $programName.";
Invoke-WebRequest -Uri $template.Replace("{0}", $newver) -OutFile $target;

$localHash = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$localVer = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $iregex | Select-Object -First 1).Matches.Groups[0].Value;
$onlineHash = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $localHash, $onlineHash).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";
((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $localVer, $newver).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";

((Get-Content -Path "$ScriptDir\$packageName.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\$packageName.nuspec";

Write-Host "Repackaging...";
Remove-Item $ScriptDir\*.nupkg
& choco pack $ScriptDir\$packageName.nuspec --outputdirectory $ScriptDir

if (Test-Path $target -PathType Leaf) {
    Write-Host "Cleaning up temp files...";
    Remove-Item $target -Force;
}

if ($apiKey -eq "" -or $null -eq $apiKey) {
    $apiKeySecure = Read-Host "Enter a valid Chocolatey API Key to publish" -AsSecureString;
    $apiKeyPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure);
    $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($apiKeyPtr);
}

if ($apiKey -ne "" -and $null -ne $apiKey) 
{
    Write-Host "Pushing new version...";
    & choco push "$ScriptDir\$packageName.$newver.nupkg" --source=https://chocolatey.org/ --apiKey=$apiKey | Out-Null
    Write-Host "Upload Complete" -ForegroundColor Green;
    $host.SetShouldExit(1);
}