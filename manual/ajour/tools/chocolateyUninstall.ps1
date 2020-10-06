$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";

Get-Process -Name "ajour" -ErrorAction SilentlyContinue | Stop-Process -Force

Remove-Item -Path "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Ajour.lnk" -Force -Confirm:$false -ErrorAction SilentlyContinue;
Remove-Item -Path "$toolsDir\ajour.exe" -Force -Confirm:$false -ErrorAction SilentlyContinue;