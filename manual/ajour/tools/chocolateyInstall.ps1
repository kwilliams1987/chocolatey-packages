$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

Get-ChocolateyWebFile -PackageName 'Ajour' -FileFullPath "$toolsDir\ajour.exe" `
    -Url 'https://github.com/casperstorm/ajour/releases/download/0.3.4/ajour.exe'