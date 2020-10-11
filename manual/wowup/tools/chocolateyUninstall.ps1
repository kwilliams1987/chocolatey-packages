$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)";

Remove-Item -Path "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\WowUp.lnk" -Force -Confirm:$false -ErrorAction SilentlyContinue;
Remove-Item -Path "$toolsDir\WowUp.exe" -Force -Confirm:$false -ErrorAction SilentlyContinue;