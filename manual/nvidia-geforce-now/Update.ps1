param ($apikey);

Set-StrictMode -Version Latest

$source = "https://download.nvidia.com/gfnpc/GeForceNOW-release.exe";
$target = "$env:TEMP\GeForceNOW-release.exe";
$unzip  = "$env:TEMP\geforcenow";

$cregex = "-Checksum '([a-fA-F0-9]{64})'";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+\.([0-9]+))</version>";

if (Test-Path $target -PathType Leaf) {
    Write-Host "Removing old GeForceNOW installer.";
    Remove-Item $target -Force;
}

if (Test-Path $unzip -PathType Container) {
    Write-Host "Removing old unzip directory.";
    Remove-Item $unzip -Force -Recurse;
}

Write-Host "Downloading latest GeForceNOW installer.";
Invoke-WebRequest -Uri $source -OutFile $target;

$local = (Select-String -Path ".\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$online = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

Write-Host "Local Hash: $local"
Write-Host "Online Hash: $online"

if ($local -eq $online) {
    Write-Host "No update available.";
} else {
    Write-Host "New version available!";

    $7zip = Get-Command "7z.exe" -ErrorAction SilentlyContinue;
    if ($null -eq $7zip) 
    { 
        Write-Error "Unable to find 7z.exe in your PATH.";
        exit;
    }

    Write-Host "Expanding self-extracting executable.";
    
    & $7zip.Source e -o"$unzip" "$target" "GeForceNOW.exe" -r  | Out-Null;
    $pkgmatch = (Select-String -Path .\nvidia-geforce-now.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
    $pkgver = $pkgmatch[1].Value;
    $newver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$unzip\GeForceNOW.exe").ProductVersion;

    Write-Host "Current package version: $pkgver";
    Write-Host "New package version: $newver";

    if ($pkgver -eq $newver) {
        Write-Error "Unable to auto-increment, package versions are the same!";
        exit;
    }

    ((Get-Content -Path ".\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content ".\tools\chocolateyInstall.ps1";
    ((Get-Content -Path ".\nvidia-geforce-now.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content ".\nvidia-geforce-now.nuspec";

    Write-Host "Repackaging...";
    .\pack.cmd | Out-Null

    if ($apiKey -eq "" -or $null -eq $apiKey) {
        $apiKeySecure = Read-Host "Enter a valid Chocolatey API Key to publish" -AsSecureString;
        $apiKeyPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure);
        $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($apiKeyPtr);
    }

    if ($apiKey -ne "" -and $null -ne $apiKey) 
    {
        Write-Host "Pushing new version...";
        & choco push "nvidia-geforce-now.$newver.nupkg" --source=https://chocolatey.org/ --apikey=$apiKey | Out-Null
        Write-Host "Upload Complete";
    }
}