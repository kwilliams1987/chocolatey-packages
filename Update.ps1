$source = "https://download.nvidia.com/gfnpc/GeForceNOW-release.exe";
$target = "$env:TEMP\GeForceNOW-release.exe";

$cregex = "-Checksum '([a-fA-F0-9]{64})'";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+\.([0-9]+))</version>";

if (Test-Path $target -PathType Leaf) {
    Write-Host "Removing old file.";
    Remove-Item $target -Force;
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
    $pkgmatch = (Select-String -Path .\geforce-now.nuspec -Pattern $vregex | Select-Object -First 1).Matches.Groups;
    $pkgver = $pkgmatch[1].Value;
    $newver = $pkgver.Replace($pkgmatch[2].Value, (Get-Date -Format "yyyyMMdd"));

    Write-Host "Current package version: $pkgver";
    Write-Host "New package version: $newver";

    ((Get-Content -Path ".\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online) | Set-Content ".\tools\chocolateyInstall.ps1";
    ((Get-Content -Path ".\geforce-now.nuspec" -Raw) -replace $pkgver, $newver) | Set-Content ".\geforce-now.nuspec";

    Write-Host "Repackaging...";
    .\pack.cmd

    $apiKey = Read-Host "Enter a valid Chocolatey API Key to publish:";

    if ($apiKey -ne "") 
    {
        Write-Host "Pushing new version...";
        .\choco push "nvidia-geforce-now.$newver.nupkg" --source=https://chocolatey.org/ --apikey=$apiKey
    }
}