param($apiKey);

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$source = "https://github.com/WowUp/WowUp/releases/latest";
$template = "https://github.com/WowUp/WowUp/releases/download/v{0}/WowUp-Setup-{0}.exe";
$packageName = "wowup";
$programName = "WowUp";

$cregex = '"([a-fA-F0-9]{64})"';
$versionOffset = 1;

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\..\..\modules\Package-Updater.psm1

if ($null -ne $apiKey -and "" -ne $apiKey) {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -CRegex $cregex -VersionOffset $versionOffset -ApiKey $apiKey
} else {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -CRegex $cregex -VersionOffset $versionOffset
}