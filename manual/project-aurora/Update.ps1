param($apiKey);

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$source = "https://github.com/antonpup/Aurora/releases/latest";
$template = "https://github.com/antonpup/Aurora/releases/download/v{0}/Aurora-setup-v{0}.exe";
$packageName = "project-aurora";
$programName = "Project Aurora";
$cregex = "-checksum ""([a-fA-F0-9]{64})""";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)</version>";
$versionOffset = 1;

$target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

Write-Host "Finding latest version on Github.";
$segments = [System.Net.WebRequest]::Create($source).GetResponse().ResponseUri.Segments;

$pkgmatch = (Select-String -Path $ScriptDir\$packageName.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
$pkgver = $pkgmatch[1].Value;
$newver = $segments[-1].Substring($versionOffset);

Write-Host "Current package version: $pkgver";
Write-Host "Newest package version: $newver";

if ($pkgver -eq $newver) {
    $host.SetShouldExit(0);
    Write-Host "No update available." -ForegroundColor Green;
    return;
}

Write-Host "New version available!";

Write-Host "Downloading latest version of $programName.";
Invoke-WebRequest -Uri $template.Replace("{0}", $newver) -OutFile $target;

$local = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$online = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";
((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";

((Get-Content -Path "$ScriptDir\$packageName.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\$packageName.nuspec";

Write-Host "Repackaging...";
Remove-Item $ScriptDir\*.nupkg
& choco pack $ScriptDir\$packageName.nuspec

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
    & choco push "$packageName.$newver.nupkg" --source=https://chocolatey.org/ --apiKey=$apiKey | Out-Null
    Write-Host "Upload Complete" -ForegroundColor Green;
    $host.SetShouldExit(1);
}