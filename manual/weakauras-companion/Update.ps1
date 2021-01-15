param($apiKey);

Set-StrictMode -Version Latest

$source = "https://github.com/WeakAuras/WeakAuras-Companion/releases/latest";
$template = "https://github.com/WeakAuras/WeakAuras-Companion/releases/download/v{0}/WeakAuras-Companion-Setup-{0}.exe";
$packageName = "weakauras-companion";
$programName = "WeakAuras Companion";

$cregex = '-checksum "([a-fA-F0-9]{64})"';
$versionOffset = 1;

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\..\..\modules\Package-Updater.psm1

if ($null -ne $apiKey -and "" -ne $apiKey) {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -CRegex $cregex -VersionOffset $versionOffset -ApiKey $apiKey
} else {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -CRegex $cregex -VersionOffset $versionOffset
}