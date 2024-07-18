$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile 'Nvidia GeForce NOW' "$toolsDir\GeForceNOW-release.exe" -Url 'https://download.nvidia.com/gfnpc/GeForceNOW-release.exe' -Checksum 'c5494af0fd650391ebf70bdf0c8087b8a8692e4f171cdadb4ddc592087333303' -ChecksumType 'sha256'
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
