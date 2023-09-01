$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum '553ef35b856e65ff9a1c700b983712798375fcc7e168a2d0b358f25426eff2bc' -ChecksumType 'sha256'
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
