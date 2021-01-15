Set-StrictMode -Version Latest
function Update-CompressedPackage
{
    param(
        [Parameter(Mandatory=$true)]
        [String] $Source,
        
        [Parameter(Mandatory=$true)]
        [String] $PackageName,

        [Parameter(Mandatory=$true)]
        [String] $PackageDirectory,
        
        [Parameter(Mandatory=$true)]
        [String] $ProgramName,
        
        [Parameter(Mandatory=$true)]
        [String] $TargetFile,
        
        [Parameter(Mandatory=$true)]
        [String] $CRegex,
        
        [Parameter(Mandatory=$true)]
        [String] $VRegex,

        [Parameter(Mandatory=$false)]
        [String] $ApiKey = ""
    )

    $target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();
    $unzip  = "$env:TEMP\" + [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName());

    Write-Host "Downloading latest version of $ProgramName.";
    Invoke-WebRequest -Uri $Source -OutFile $target;

    $local = (Select-String -Path "$PackageDirectory\tools\chocolateyInstall.ps1" -Pattern $CRegex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
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

    & $7zip.Source e -o"$unzip" "$target" "$TargetFile" -r  | Out-Null;
    $pkgmatch = (Select-String -Path "$PackageDirectory\$PackageName.nuspec" -Pattern $VRegex | Select-Object -First 1).Matches.Groups;
    $pkgver = $pkgmatch[1].Value;
    $newver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$unzip\$TargetFile").ProductVersion;

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

    ((Get-Content -Path "$PackageDirectory\tools\chocolateyInstall.ps1" -Raw) -replace $local, $online).Trim() | Set-Content "$PackageDirectory\tools\chocolateyInstall.ps1";
    ((Get-Content -Path "$PackageDirectory\$PackageName.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$PackageDirectory\$PackageName.nuspec";

    Write-Host "Repackaging...";
    Remove-Item $PackageDirectory\*.nupkg
    & choco pack $PackageDirectory\$PackageName.nuspec --outputdirectory $PackageDirectory

    if (Test-Path $target -PathType Leaf) {
        Write-Host "Cleaning up temp files...";
        Remove-Item $target -Force;
    }

    if (Test-Path $unzip -PathType Container) {
        Write-Host "Cleaning up temp directories...";
        Remove-Item $unzip -Force -Recurse;
    }

    if ($ApiKey -ne "" -and $null -ne $ApiKey) 
    {
        Write-Host "Pushing new version...";
        & choco push "$PackageDirectory\$PackageName.$newver.nupkg" --source=https://chocolatey.org/ --apiKey=$ApiKey | Out-Null
        Write-Host "Upload Complete" -ForegroundColor Green;
        $host.SetShouldExit(1);
    }
}

function Update-GithubPackage
{
    param(
        [Parameter(Mandatory=$true)]
        [String] $Source,

        [Parameter(Mandatory=$true)]
        [String] $Template,
        
        [Parameter(Mandatory=$true)]
        [String] $PackageName,

        [Parameter(Mandatory=$true)]
        [String] $PackageDirectory,
        
        [Parameter(Mandatory=$true)]
        [String] $ProgramName,

        [Parameter(Mandatory=$false)]
        [String] $IRegex = '([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)',
        
        [Parameter(Mandatory=$false)]
        [String] $CRegex = '\$expectedHash = "([a-fA-F0-9]{64})"',
        
        [Parameter(Mandatory=$false)]
        [String] $VRegex = "<version>([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)</version>",
        
        [Parameter(Mandatory=$false)]
        [Int32] $VersionOffset = 0,

        [Parameter(Mandatory=$false)]
        [String] $ApiKey = ""
    )


    $target = "$env:TEMP\" + [System.IO.Path]::GetRandomFileName();

    $pkgmatch = (Select-String -Path $ScriptDir\$PackageName.nuspec -Pattern $VRegex | Select-Object -First 1).Matches.Groups;
    $pkgver = $pkgmatch[1].Value;

    if ($null -ne $version) {
        Write-Host "Forcing package version to $version";
        $newver = $version;
    } else {    
        Write-Host "Finding latest version on Github.";
        $segments = [System.Net.WebRequest]::Create($Source).GetResponse().ResponseUri.Segments;
        $newver = $segments[-1].Substring($VersionOffset);
    }

    Write-Host "Current package version: $pkgver";
    Write-Host "Newest package version: $newver";

    if ($pkgver -eq $newver -and $null -eq $version) {
        $host.SetShouldExit(0);
        Write-Host "No update available." -ForegroundColor Green;
        return;
    }

    Write-Host "New version available!";

    Write-Host "Downloading latest version of $ProgramName.";
    Invoke-WebRequest -Uri $Template.Replace("{0}", $newver) -OutFile $target;

    $localHash = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $CRegex | Select-Object -First 1).Matches.Groups[1].Value.ToLower();
    $localVer = (Select-String -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Pattern $IRegex | Select-Object -First 1).Matches.Groups[0].Value;
    $onlineHash = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower();

    ((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $localHash, $onlineHash).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";
    ((Get-Content -Path "$ScriptDir\tools\chocolateyInstall.ps1" -Raw) -replace $localVer, $newver).Trim() | Set-Content "$ScriptDir\tools\chocolateyInstall.ps1";

    ((Get-Content -Path "$ScriptDir\$PackageName.nuspec" -Raw) -replace $pkgver, $newver).Trim() | Set-Content "$ScriptDir\$PackageName.nuspec";

    Write-Host "Repackaging...";
    Remove-Item $ScriptDir\*.nupkg
    & choco pack $ScriptDir\$PackageName.nuspec --outputdirectory $ScriptDir

    if (Test-Path $target -PathType Leaf) {
        Write-Host "Cleaning up temp files...";
        Remove-Item $target -Force;
    }

    if ($ApiKey -ne "" -and $null -ne $ApiKey) 
    {
        Write-Host "Pushing new version...";
        & choco push "$ScriptDir\$PackageName.$newver.nupkg" --source=https://chocolatey.org/ --apiKey=$ApiKey | Out-Null
        Write-Host "Upload Complete" -ForegroundColor Green;
        $host.SetShouldExit(1);
    }
}