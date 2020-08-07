param($choco);

if ($null -ne $choco -and $null -ne $env:CHOCO_API_KEY) {
    Write-Host "Overriding API Key from CHOCO_API_KEY environment variable with parameter." -ForegroundColor Yellow
}

if ($null -eq $choco -and $null -ne $env:CHOCO_API_KEY) {
    Write-Host "Using API Key from CHOCO_API_KEY environment variable." -ForegroundColor Yellow
    $choco = $env:CHOCO_API_KEY
}

if ($null -eq $choco -and $null -eq $env:CHOCO_API_KEY) {
    Write-Host "No Chocolatey API key available, updated packages will not be published." -ForegroundColor DarkYellow
}

$updaters = Get-ChildItem *\Update.ps1 -Recurse
$updates = @();
$updateParams = "-apiKey", $choco;

foreach ($updater in $updaters) {
    $project = $updater.Directory.Name
    Write-Host "Checking for $project updates..."

    $update =  & $updater $updateParams;
    if($update -eq 1) {
        Write-Host "The updater reported an update for $project." -ForegroundColor Green
        $updates += $project;
    }

    if ($update -gt 1) {
        Write-Host "The updater reported error code $update." -ForegroundColor DarkYellow
    }
}