param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$InstallerManifest = Join-Path $ScriptRoot 'tools\pdx-installer\Cargo.toml'
$SourceManifest = Join-Path $ScriptRoot 'tools\pdx-win\Cargo.toml'
$ProfileFile = Join-Path $env:USERPROFILE 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
$WrapperFile = Join-Path (Split-Path -Parent $ProfileFile) 'Pandocker_profile.ps1'

function Get-FirstExistingPath {
    param([string[]]$Candidates)

    foreach ($Candidate in $Candidates) {
        if ($Candidate -and (Test-Path $Candidate)) {
            return $Candidate
        }
    }

    return $null
}

$Installer = Get-FirstExistingPath @(
    (Join-Path $ScriptRoot 'pdx-bootstrap.exe')
    (Join-Path $ScriptRoot 'tools\pdx-installer\target\release\pdx-bootstrap.exe')
    (Join-Path $ScriptRoot 'tools\pdx-installer\target\debug\pdx-bootstrap.exe')
)

$SourceBinary = Get-FirstExistingPath @(
    (Join-Path $ScriptRoot 'pdx.exe')
    (Join-Path $ScriptRoot 'tools\pdx-win\target\release\pdx.exe')
    (Join-Path $ScriptRoot 'tools\pdx-win\target\debug\pdx.exe')
)

if ($null -eq $SourceBinary) {
    $cargo = Get-Command cargo.exe -ErrorAction SilentlyContinue
    if ($null -eq $cargo) {
        throw 'pdx.exe was not found and cargo.exe is unavailable.'
    }

    & $cargo.Source build --release --manifest-path $SourceManifest
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    $SourceBinary = Get-FirstExistingPath @(
        (Join-Path $ScriptRoot 'tools\pdx-win\target\release\pdx.exe')
        (Join-Path $ScriptRoot 'tools\pdx-win\target\debug\pdx.exe')
    )
    if ($null -eq $SourceBinary) {
        throw 'pdx.exe was not built successfully.'
    }
}

if ($null -eq $Installer) {
    $cargo = Get-Command cargo.exe -ErrorAction SilentlyContinue
    if ($null -eq $cargo) {
        throw 'pdx-bootstrap.exe was not found and cargo.exe is unavailable.'
    }

    $installerArgs = @('run', '--manifest-path', $InstallerManifest, '--')
    if ($Args.Count -eq 0) {
        $installerArgs += 'install'
    } else {
        $installerArgs += $Args
    }

    if ($null -ne $SourceBinary) {
        $installerArgs += @('--source', $SourceBinary)
    }

    $installerArgs += @('--profile-file', $ProfileFile)
    $installerArgs += @('--bundle-root', $ScriptRoot)

    & $cargo.Source @installerArgs
}
else {
    $installerArgs = @()
    if ($Args.Count -eq 0) {
        $installerArgs += 'install'
    } else {
        $installerArgs += $Args
    }

    if ($null -ne $SourceBinary) {
        $installerArgs += @('--source', $SourceBinary)
    }

    $installerArgs += @('--profile-file', $ProfileFile)
    $installerArgs += @('--bundle-root', $ScriptRoot)

    & $Installer @installerArgs
}

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($Args.Count -eq 0 -or $Args[0] -eq 'install') {
    if (Test-Path $WrapperFile) {
        . $WrapperFile
    }
}
