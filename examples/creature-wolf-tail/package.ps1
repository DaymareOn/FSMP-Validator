# Builds the installable, versioned zip for the "Wolf Tail - FSMP Creature Example" mod.
#
# The zip root mirrors a Skyrim Data install (SKSE/Plugins/...), so a mod manager can install
# it directly, plus the README at the root. Output goes to dist/ (git-ignored); attach the
# resulting zip to a GitHub Release as the versioned asset, then upload that same file to Nexus.
#
# Usage:  pwsh ./package.ps1 [-Version 0.1.0]
param([string]$Version = "0.1.0")

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $here "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$zip = Join-Path $dist ("FSMP-Wolf-Tail-Creature-Example-{0}.zip" -f $Version)
if (Test-Path $zip) { Remove-Item $zip -Force }

# Contents: the installable data tree + the readme. Nothing else (no art assets).
$items = @(
  (Join-Path $here "SKSE"),
  (Join-Path $here "README.md")
)
Compress-Archive -Path $items -DestinationPath $zip -CompressionLevel Optimal

$size = [math]::Round((Get-Item $zip).Length / 1KB, 1)
Write-Output ("Built {0} ({1} KB)" -f $zip, $size)
Write-Output "Contents:"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::OpenRead($zip).Entries | ForEach-Object { Write-Output ("  " + $_.FullName) }
