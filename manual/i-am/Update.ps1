param([String] $apiKey);

$source = "https://download.voipit.nl/IAM/PC/IAM.msi";
$packageName = "i-am";
$programName = "I AM";
$targetFile = "CM_FP_Communicator.exe";
$cregex = '-Checksum "([a-fA-F0-9]{64})"';
$vregex = "<version>([0-9]+\.[0-9]+\.[0-9]+\.([0-9]+))</version>";

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\..\..\modules\Package-Updater.psm1

if ($null -ne $apiKey -and "" -ne $apiKey) {
    Update-CompressedPackage -Source $source -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -TargetFile $targetFile -CRegex $cregex -VRegex $vregex -ApiKey $apiKey
} else {
    Update-CompressedPackage -Source $source -PackageName $packageName -PackageDirectory $ScriptDir -ProgramName $programName -TargetFile $targetFile -CRegex $cregex -VRegex $vregex
}