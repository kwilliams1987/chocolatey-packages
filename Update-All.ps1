param($apikey);

if ($null -ne $apikey -and $null -ne $env:CHOCO_API_KEY) {
    Write-Host "Overriding API Key from CHOCO_API_KEY environment variable with parameter." -ForegroundColor Yellow
}

if ($null -eq $apikey -and $null -ne $env:CHOCO_API_KEY) {
    Write-Host "Using API Key from CHOCO_API_KEY environment variable." -ForegroundColor Yellow
    $apikey = $env:CHOCO_API_KEY
}

if ($null -eq $apikey -and $null -eq $env:CHOCO_API_KEY) {
    Write-Host "No API key available, updated packages will not be published." -ForegroundColor Orange
}

$source = Get-Location
$updaters = Get-ChildItem *\Update.ps1 -Recurse

foreach ($updater in $updaters) {
    $project = $updater.Directory.Name
    Write-Host "Checking for $project updates..."
    Set-Location $updater.Directory
    .\Update.ps1 -apiKey $apikey
}

Set-Location $source