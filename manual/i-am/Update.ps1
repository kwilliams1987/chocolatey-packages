param($apiKey);

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$source = "https://download.voipit.nl/IAM/PC/IAM.msi";
$packageName = "i-am";
$programName = "I AM";
$cregex = '-Checksum "([a-fA-F0-9]{64})"';
$targetFile = "CM_FP_Communicator.exe";
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+\.([0-9]+))</version>";

$target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();
$unzip  = "$env:TEMP\" + [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName());

Write-Host "Downloading latest version of $programName.";
Invoke-WebRequest -Uri $source -OutFile $target;

$local = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $cregex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
$online = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

Write-Host "Local Hash: $local"
Write-Host "Online Hash: $online"

if ($local -eq $online) {
    $host.SetShouldExit(0);
    Write-Host "No update available." -ForegroundColor Green;
    
    if (Test-Path $target -PathType Leaf) {
        Write-Host "Cleaning up temp files...";
        Remove-Item $target -Force;
    }

    if (Test-Path $unzip -PathType Container) {
        Write-Host "Cleaning up temp directories...";
        Remove-Item $unzip -Force -Recurse;
    }
    
    return;
} 

Write-Host "New version available!";

$7zip = Get-Command "7z.exe" -ErrorAction SilentlyContinue;
if ($null -eq $7zip) 
{
    Write-Error "Unable to find 7z.exe in your PATH.";
    $host.SetShouldExit(2);
    
    if (Test-Path $target -PathType Leaf) {
        Write-Host "Cleaning up temp files...";
        Remove-Item $target -Force;
    }

    if (Test-Path $unzip -PathType Container) {
        Write-Host "Cleaning up temp directories...";
        Remove-Item $unzip -Force -Recurse;
    }
    
    return;
}

Write-Host "Extracting target file.";

& $7zip.Source e -o"$unzip" "$target" "$targetFile" -r  | Out-Null;
$pkgmatch = (Select-String -Path "$ScriptDir\$packageName.nuspec" -Pattern $vregex | Select-Object -First 1).Matches.Groups;
$pkgver = $pkgmatch[1].Value;
$newver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$unzip\$targetFile").ProductVersion;

Write-Host "Current package version: $pkgver";
Write-Host "New package version: $newver";

if ($pkgver -eq $newver) {
    Write-Error "Unable to auto-increment, package versions are the same!" -ForegroundColor DarkYellow;
    $host.SetShouldExit(2);
    
    if (Test-Path $target -PathType Leaf) {
        Write-Host "Cleaning up temp files...";
        Remove-Item $target -Force;
    }

    if (Test-Path $unzip -PathType Container) {
        Write-Host "Cleaning up temp directories...";
        Remove-Item $unzip -Force -Recurse;
    }
    
    exit;
}

((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";
((Get-Content -Path "$ScriptDir\$packageName.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\$packageName.nuspec";

Write-Host "Repackaging...";
Remove-Item $ScriptDir\*.nupkg
& choco pack $ScriptDir\$packageName.nuspec --outputdirectory $ScriptDir

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
    & choco push "$ScriptDir\$packageName.$newver.nupkg" --source=https://chocolatey.org/ --apiKey=$apiKey | Out-Null
    Write-Host "Upload Complete" -ForegroundColor Green;
    $host.SetShouldExit(1);
}