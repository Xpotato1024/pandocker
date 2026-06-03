param (
    [Parameter(Position = 0)]
    [string]$ReportName,

    [Parameter(Position = 1)]
    [string[]]$InputFiles,

    [Parameter()]
    [switch]$All,

    [Parameter()]
    [switch]$Log
)

function Quote-Double {
    param([Parameter(Mandatory = $true)][string]$Value)
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Quote-Single {
    param([Parameter(Mandatory = $true)][string]$Value)
    return "'" + $Value + "'"
}

function Normalize-PosixPath {
    param([Parameter(Mandatory = $true)][string]$Value)
    return $Value -replace '\\', '/'
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )

    $BaseFullPath = (Resolve-Path -LiteralPath $BasePath).Path.TrimEnd('\', '/')
    $TargetFullPath = (Resolve-Path -LiteralPath $TargetPath).Path
    if ($TargetFullPath.Length -lt $BaseFullPath.Length -or -not $TargetFullPath.StartsWith($BaseFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Target path '$TargetPath' is not under '$BasePath'."
    }

    return $TargetFullPath.Substring($BaseFullPath.Length).TrimStart('\', '/')
}

try {
    . (Join-Path $PSScriptRoot "wsl-init.ps1")
} catch {
    Write-Host "Error: failed to load wsl-init.ps1" -ForegroundColor Red
    exit 1
}

$PandocArgsJsonPath = Join-Path $ConfigPath "pandoc-args.json"
if (-not (Test-Path $PandocArgsJsonPath)) {
    Write-Host "Error: pandoc-args.json not found" -ForegroundColor Red
    exit 1
}

try {
    $PandocArgsConfig = Get-Content -Raw -Path $PandocArgsJsonPath | ConvertFrom-Json
} catch {
    Write-Host "Error: failed to parse pandoc-args.json" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ReportName)) {
    Write-Host "Error: report name is required" -ForegroundColor Red
    Write-Host "Usage: pdx build <ProjectName> [options]" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/3] Syncing workspace to WSL..." -ForegroundColor Yellow
Sync-WslWorkspace -SourceRoot $WindowsProjectRoot -DestinationRoot $WslProjectRootWin -SyncMode $PandockerConfig.SyncMode
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: workspace sync failed" -ForegroundColor Red
    exit 1
}

$WslSrcDir = Join-Path $WslProjectRootWin "projects\$ReportName\src"

if ($All.IsPresent) {
    if (Test-Path $WslSrcDir) {
        $InputFiles = Get-ChildItem -Path $WslSrcDir -Recurse -Filter "*.md" -File |
            Sort-Object FullName |
            ForEach-Object { Get-RelativePath -BasePath $WslSrcDir -TargetPath $_.FullName }
    } else {
        Write-Host "Warning: $WslSrcDir not found" -ForegroundColor Yellow
        $InputFiles = @()
    }
} elseif (-not $InputFiles -or $InputFiles.Count -eq 0) {
    $InputFiles = @("report.md")
}

if (-not $InputFiles -or $InputFiles.Count -eq 0) {
    Write-Host "No Markdown files to build." -ForegroundColor Yellow
    exit 0
}

$Timestamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
if ($Log.IsPresent) {
    $LogFileName = "pandoc_${ReportName}_$Timestamp.log"
    Write-Host "Log output enabled: log/$LogFileName" -ForegroundColor Cyan
} else {
    $LogFileName = $null
}

$HostSrcDir = Join-Path $WindowsProjectRoot "projects\$ReportName\src"
$HostLogDir = Join-Path $WindowsProjectRoot "log"
if ($Log.IsPresent) {
    New-Item -ItemType Directory -Force -Path (Join-Path $WslProjectRootWin "log") | Out-Null
}

foreach ($InputFile in $InputFiles) {
    $InputPathOnHost = Join-Path $HostSrcDir $InputFile
    if (-not (Test-Path $InputPathOnHost)) {
        Write-Host "Warning: missing $InputPathOnHost, skipping." -ForegroundColor Yellow
        continue
    }

    $ResolvedInputPathOnHost = (Resolve-Path -LiteralPath $InputPathOnHost).Path
    $RelativePath = Get-RelativePath -BasePath $HostSrcDir -TargetPath $ResolvedInputPathOnHost
    $RelativePathPosix = Normalize-PosixPath $RelativePath
    $RelativeOutputPathPosix = $RelativePathPosix -replace '\.md$', '.pdf'
    $RelativeOutputDir = Split-Path -Parent $RelativePath
    if ([string]::IsNullOrWhiteSpace($RelativeOutputDir) -or $RelativeOutputDir -eq ".") {
        $RelativeOutputDir = ""
    }

    $InputPathOnWsl = Join-Path $WslSrcDir $RelativePath
    if (-not (Test-Path $InputPathOnWsl)) {
        Write-Host "Warning: missing $InputPathOnWsl, skipping." -ForegroundColor Yellow
        continue
    }

    $RelativeOutputDirPosix = if ([string]::IsNullOrWhiteSpace($RelativeOutputDir)) {
        ""
    } else {
        Normalize-PosixPath $RelativeOutputDir
    }
    $ContainerWorkDir = "/data/projects/$ReportName/src"
    $Defaults = "../defaults.yml"
    $OutputFile = "../output/$RelativeOutputPathPosix"
    $OutputDir = if ([string]::IsNullOrWhiteSpace($RelativeOutputDirPosix)) {
        "../output"
    } else {
        "../output/$RelativeOutputDirPosix"
    }

    $WslOutputDir = Join-Path $WslProjectRootWin "projects\$ReportName\output\$RelativeOutputDir"
    New-Item -ItemType Directory -Force -Path $WslOutputDir | Out-Null
    $PandocArgs = @()
    $PandocArgs += @($PandocArgsConfig.pdf_args)
    $PandocArgs += @("--defaults", $Defaults)
    $PandocArgs += $RelativePathPosix
    $PandocArgs += @("-o", $OutputFile)
    if ($Log.IsPresent) {
        $PandocArgs += "--verbose"
    }

    $PandocArgString = ($PandocArgs | ForEach-Object { Quote-Double $_ }) -join " "
    $InnerCommand = "cd $(Quote-Single $ContainerWorkDir) && mkdir -p $(Quote-Single $OutputDir) && pandoc $PandocArgString"

    if ($Log.IsPresent) {
        $WslLogPath = "log/$LogFileName"
        $WslCommand = "cd $(Quote-Single $WslProjectRootUnix) && mkdir -p log && docker compose run --rm --entrypoint bash pandoc -lc $(Quote-Single $InnerCommand) >> $(Quote-Single $WslLogPath) 2>&1"
    } else {
        $WslCommand = "cd $(Quote-Single $WslProjectRootUnix) && docker compose run --rm --entrypoint bash pandoc -lc $(Quote-Single $InnerCommand)"
    }

    $StartTime = Get-Date
    & wsl.exe -d $WslDistro -e sh -lc $WslCommand
    $ExitCode = $LASTEXITCODE
    $ElapsedTime = (New-TimeSpan -Start $StartTime -End (Get-Date)).TotalSeconds

    $PdfFileName = [System.IO.Path]::GetFileName($RelativeOutputPathPosix)
    $WslPdfPath = Join-Path $WslProjectRootWin "projects\$ReportName\output\$RelativeOutputPathPosix"
    $HostOutputDir = Join-Path $WindowsProjectRoot "projects\$ReportName\output\$RelativeOutputDir"
    New-Item -ItemType Directory -Force -Path $HostOutputDir | Out-Null

    if (Test-Path $WslPdfPath) {
        Copy-Item -Path $WslPdfPath -Destination $HostOutputDir -Force
    }

    if ((Test-Path (Join-Path $HostOutputDir $PdfFileName)) -and $ExitCode -eq 0) {
        Write-Host "$RelativePathPosix -> $RelativeOutputPathPosix generated in ${ElapsedTime}s" -ForegroundColor Green
    } else {
        Write-Host "$RelativePathPosix PDF generation failed." -ForegroundColor Red
        if ($Log.IsPresent) {
            Write-Host "See $HostLogDir\$LogFileName for details." -ForegroundColor Yellow
        }
    }
}

if ($Log.IsPresent) {
    New-Item -ItemType Directory -Force -Path $HostLogDir | Out-Null
    $WslLogDir = Join-Path $WslProjectRootWin "log"
    if (Test-Path (Join-Path $WslLogDir $LogFileName)) {
        Copy-Item -Path (Join-Path $WslLogDir $LogFileName) -Destination $HostLogDir -Force
        Write-Host "Log saved to: log\$LogFileName" -ForegroundColor DarkGray
    }
}
