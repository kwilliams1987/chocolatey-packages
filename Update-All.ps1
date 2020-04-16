param($apikey);

$updaters = Get-ChildItem *\Update.ps1 -Recurse

foreach ($updater in $updaters) {
    $project = $updater.Directory.Name
    Write-Host "Checking for $project updates..."
    Set-Location $updater.Directory
    .\Update.ps1 -apiKey $apikey
}