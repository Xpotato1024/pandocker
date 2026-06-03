# Create a new report project scaffold.

param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$ReportName,

    [Parameter()]
    [switch]$Paper
)

$ScriptPath = $PSScriptRoot
$PdxRoot = Split-Path $ScriptPath -Parent
$ProjectsBaseDir = Join-Path $PdxRoot "projects"
$TemplatePath = Join-Path $PdxRoot "templates/report.md"
$CslPathFromSrc = "/app/csl/ieee-with-url.csl"

if (-not (Test-Path $ProjectsBaseDir)) {
    New-Item -ItemType Directory -Path $ProjectsBaseDir | Out-Null
}

$TargetReportDir = Join-Path $ProjectsBaseDir $ReportName
if (Test-Path $TargetReportDir) {
    Write-Host "Error: 'projects/$ReportName' already exists." -ForegroundColor Red
    exit 1
}

Write-Host "Creating 'projects/$ReportName'..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $TargetReportDir | Out-Null
foreach ($dir in @("src", "images", "bib", "output")) {
    New-Item -ItemType Directory -Path (Join-Path $TargetReportDir $dir) | Out-Null
}

Set-Content -Path (Join-Path $TargetReportDir "bib/references.bib") -Value "" -Encoding UTF8

$CurrentDate = Get-Date -Format "yyyy-MM-dd"
$ReportMdPath = Join-Path $TargetReportDir "src/report.md"
if (-not (Test-Path $TemplatePath)) {
    Write-Host "Error: template '$TemplatePath' not found." -ForegroundColor Red
    exit 1
}

$Template = Get-Content -Raw -Path $TemplatePath
$Template = $Template.Replace("{{DATE}}", $CurrentDate)
$Template = $Template.Replace("{{CSL_PATH}}", $CslPathFromSrc)
Set-Content -Path $ReportMdPath -Value $Template -Encoding UTF8

$SourceDefaultsPath = if ($Paper.IsPresent) {
    Join-Path $PdxRoot "defaults-paper.yml"
} else {
    Join-Path $PdxRoot "defaults.yml"
}
$TargetDefaultsPath = Join-Path $TargetReportDir "defaults.yml"
if (Test-Path $SourceDefaultsPath) {
    Copy-Item -Path $SourceDefaultsPath -Destination $TargetDefaultsPath -Force
} elseif ($Paper.IsPresent) {
    Write-Host "Error: paper preset '$SourceDefaultsPath' not found." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Project 'projects/$ReportName' is ready." -ForegroundColor Green
Write-Host "Edit projects/$ReportName/src/report.md to start writing."
if ($Paper.IsPresent) {
    Write-Host "Paper preset enabled: defaults.yml was copied from defaults-paper.yml."
}
