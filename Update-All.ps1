$updaters = Get-ChildItem *\Update.ps1 -Recurse

foreach ($updater in $updaters) {
    Set-Location $updater.Directory
    .\Update.ps1
}