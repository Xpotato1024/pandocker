param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist'),

    [string]$BinaryDir = (Join-Path $PSScriptRoot '..\tools'),

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath {
    param([string[]]$Candidates)

    foreach ($Candidate in $Candidates) {
        if ($Candidate -and (Test-Path $Candidate)) {
            return (Resolve-Path $Candidate).Path
        }
    }

    return $null
}

function Write-InstallNote {
    param([string]$Path, [string]$VersionText)

    @"
Pandocker-X Windows Release $VersionText

Contents:
- pdx.exe
- pdx-bootstrap.exe
- LICENSE

Install:
1. Extract this zip archive.
2. Run `.\pdx-bootstrap.exe install` from PowerShell, Command Prompt, or Explorer.
3. Restart PowerShell if the pdx wrapper is not available immediately.

If you are using the source tree instead of a release zip, you can still run `install.ps1` from the repository root.
"@ | Set-Content -Path $Path -Encoding UTF8
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$pdxExe = Resolve-ExistingPath @(
    (Join-Path $BinaryDir 'pdx-win\target\release\pdx.exe')
    (Join-Path $BinaryDir 'pdx-win\target\debug\pdx.exe')
)
$bootstrapExe = Resolve-ExistingPath @(
    (Join-Path $BinaryDir 'pdx-installer\target\release\pdx-bootstrap.exe')
    (Join-Path $BinaryDir 'pdx-installer\target\debug\pdx-bootstrap.exe')
)

if (-not $pdxExe) {
    throw 'pdx.exe was not found. Build tools/pdx-win first.'
}

if (-not $bootstrapExe) {
    throw 'pdx-bootstrap.exe was not found. Build tools/pdx-installer first.'
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pandocker-release-$Version-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null

try {
    Copy-Item -LiteralPath $pdxExe -Destination (Join-Path $stagingRoot 'pdx.exe')
    Copy-Item -LiteralPath $bootstrapExe -Destination (Join-Path $stagingRoot 'pdx-bootstrap.exe')
    Copy-Item -LiteralPath (Join-Path $repoRoot 'LICENSE') -Destination (Join-Path $stagingRoot 'LICENSE')

    $installNote = Join-Path $stagingRoot 'INSTALL.txt'
    Write-InstallNote -Path $installNote -VersionText $Version

    $zipName = "pandocker-x-windows-$Version.zip"
    $zipPath = Join-Path $OutputDir $zipName
    if (Test-Path $zipPath) {
        if ($Force) {
            Remove-Item -LiteralPath $zipPath -Force
        } else {
            throw "Archive already exists: $zipPath. Use -Force to overwrite."
        }
    }

    Compress-Archive -Path (Join-Path $stagingRoot '*') -DestinationPath $zipPath -Force
    Write-Host "Created release archive: $zipPath"
}
finally {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force -ErrorAction SilentlyContinue
}
