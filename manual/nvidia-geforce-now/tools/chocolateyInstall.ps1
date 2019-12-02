$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum '1b91869c2665f64f94e8cbf74de5d0f477ca1d915795d5033ccaba70a3474099' -ChecksumType 'sha256'
Get-ChocolateyUnzip "$toolsDir\GeForceNOW-release.exe" $toolsDir

Install-ChocolateyInstallPackage 'Nvidia GeForce NOW' 'exe' '' "$toolsDir\setup.exe"

$shimIgnores = @("GeForceNOW-release.exe", "GeforceNOW\GeforceNow_Installer.exe", "GeforceNOW\CEF\GeForceNOWReliabilityMonitor.exe", "GeforceNOW\CEF\GeForceNOWStreamer.exe", "NVI2\NVNetworkService.exe")
foreach ($ignore in $shimIgnores) {
    New-Item "$toolsDir\$ignore.ignore" -type file -force | out-null
}

