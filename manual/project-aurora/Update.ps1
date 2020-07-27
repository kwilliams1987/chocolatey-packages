param($apikey);

Set-StrictMode -Version Latest

$source = "https://github.com/antonpup/Aurora/releases/latest";
$template = "https://github.com/antonpup/Aurora/releases/download/v{0}/Aurora-setup-v{0}.exe";
$target = "$env:TEMP\Aurora-setup.exe";

$cregex = "-checksum ""([a-fA-F0-9]{64})""";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)</version>";

Write-Host "Finding latest version on Github.";
$segments = [System.Net.WebRequest]::Create($source).GetResponse().ResponseUri.Segments;

$pkgmatch = (Select-String -Path .\project-aurora.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
$pkgver = $pkgmatch[1].Value;
# Substring(1) to remove "v".
$newver = $segments[-1].Substring(1);

Write-Host "Current package version: $pkgver";
Write-Host "Newest package version: $newver";

if ($pkgver -eq $newver) {
    $host.SetShouldExit(0);
    Write-Host "No update available.";
    return;
}

Write-Host "New version available!";

if (Test-Path $target -PathType Leaf) {
    Write-Host "Removing old Aurora installer.";
    Remove-Item $target -Force;
}

Write-Host "Downloading latest Aurora installer.";
Invoke-WebRequest -Uri $template.Replace("{0}", $newver) -OutFile $target;

$local = (Select-String -Path ".\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$online = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

((Get-Content -Path ".\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content ".\tools\chocolateyInstall.ps1";
((Get-Content -Path ".\tools\chocolateyInstall.ps1" -Raw) -replace $pkgver, $newver).Trim() | Set-Content ".\tools\chocolateyInstall.ps1";

((Get-Content -Path ".\project-aurora.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content ".\project-aurora.nuspec";

Write-Host "Repackaging...";
.\pack.cmd | Out-Null

if ($apikey -eq "" -or $null -eq $apikey) {
    $apiKeySecure = Read-Host "Enter a valid Chocolatey API Key to publish" -AsSecureString;
    $apiKeyPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure);
    $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($apiKeyPtr);
}

if ($apiKey -ne "" -and $null -ne $apiKey) 
{
    Write-Host "Pushing new version...";
    & choco push "project-aurora.$newver.nupkg" --source=https://chocolatey.org/ --apikey=$apiKey | Out-Null
    Write-Host "Upload Complete";
    $host.SetShouldExit(1);
}