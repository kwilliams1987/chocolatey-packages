$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum 'a17407940a05bde2b8367ced532e7318acbaf0c670af75c998dc26d5f897cabf' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @("GeForceNOW-release.exe", "GeforceNOW\GeforceNow_Installer.exe", "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe", "GeforceNOW\CEF\GeForceNOWStreamer.exe", "NVI2\NVNetworkService.exe")
foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}