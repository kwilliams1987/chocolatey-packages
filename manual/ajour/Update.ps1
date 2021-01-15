param($apiKey);

Set-StrictMode -Version Latest

$source = "https://github.com/casperstorm/ajour/releases/latest";
$template = "https://github.com/casperstorm/ajour/releases/download/{0}/ajour.exe";
$packageName = "ajour";
$programName = "Ajour";

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\..\..\modules\Package-Updater.psm1

if ($null -ne $apiKey -and "" -ne $apiKey) {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -ApiKey $apiKey
} else {
    Update-GithubPackage -Source $source -Template $template -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName 
}