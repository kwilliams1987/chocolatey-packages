$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum '98c3eb700d48e9c525a200c617266e6556e99e34cc29624752bd1c6259d11d6e' -ChecksumType 'sha256'
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
