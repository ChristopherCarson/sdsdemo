[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SourceRepoName = "instantsds",
    [string]$SourceDistSubpath = "dist",
    [string]$DestinationPath = "."
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDist = Join-Path (Join-Path (Split-Path -Parent $scriptRoot) $SourceRepoName) $SourceDistSubpath
$destination = Resolve-Path -LiteralPath (Join-Path $scriptRoot $DestinationPath)

if (-not (Test-Path -LiteralPath $sourceDist -PathType Container)) {
    throw "Source dist folder was not found: $sourceDist"
}

Write-Host "Source:      $sourceDist"
Write-Host "Destination: $($destination.Path)"

$items = Get-ChildItem -LiteralPath $sourceDist -Force
if ($items.Count -eq 0) {
    Write-Host "No files found in source dist folder. Nothing to copy."
    exit 0
}

foreach ($item in $items) {
    $targetPath = Join-Path $destination.Path $item.Name
    if ($PSCmdlet.ShouldProcess($targetPath, "Copy from $($item.FullName)")) {
        Copy-Item -LiteralPath $item.FullName -Destination $targetPath -Recurse -Force
    }
}

Write-Host "Copied $($items.Count) top-level item(s) from dist to repo root."
