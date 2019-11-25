$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum '7e1d5637b629254774a0aaa91eee1e74f138cc171927000db11924fc0a8cbc94' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @("GeForceNOW-release.exe", "GeforceNOW\GeforceNow_Installer.exe", "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe", "GeforceNOW\CEF\GeForceNOWStreamer.exe", "NVI2\NVNetworkService.exe")
foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}
