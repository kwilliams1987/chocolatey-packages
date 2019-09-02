$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum 'E954C9BA6011CA87485DD2BE6AB4E8B4C4782335176D8A8462718DF9FF41AE6E' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @("GeForceNOW-release.exe", "GeforceNOW\GeforceNow_Installer.exe", "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe", "GeforceNOW\CEF\GeForceNOWStreamer.exe", "NVI2\NVNetworkService.exe")
foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}