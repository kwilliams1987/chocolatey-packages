$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum 'ccea8142dd26da7dd312aed00b4cb332d2656f1e923c4cbb45713ae1c5fa3b16' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @(
    "GeForceNOW-release.exe",
    "GeforceNOW\GeforceNow_Installer.exe",
    "GeforceNOW\CEF\GeForceNOWContainer.exe",
    "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe",
    "GeforceNOW\CEF\GeForceNOWStreamer.exe",
    "NVI2\NVNetworkService.exe"
)

foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}
