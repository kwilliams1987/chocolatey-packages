$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum '86c3c96df454285203b3a46dfb70dea8fba6573a0ff12973f5f6d3d0df2b6e2b' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @("GeForceNOW-release.exe", "GeforceNOW\GeforceNow_Installer.exe", "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe", "GeforceNOW\CEF\GeForceNOWStreamer.exe", "NVI2\NVNetworkService.exe")
foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}