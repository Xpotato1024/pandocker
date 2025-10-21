param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ReportName,

    [Parameter(Position=1)]
    [string[]]$InputFiles,

    [Parameter()]
    [switch]$All,

    [Parameter()]
    [switch]$Log
)

# --- 1. 共通設定とヘルパー関数を読み込む ---
try {
    . (Join-Path $PSScriptRoot "config.ps1")
    . (Join-Path $PSScriptRoot "wsl-helpers.ps1")
} catch {
    Write-Host "エラー: config.ps1 または wsl-helpers.ps1 が見つかりません。" -ForegroundColor Red
    return
}

# --- 2. 前提条件をチェック ---
Test-WslPrerequisites -WslDistro $PandockerConfig.WslDistro
if ($LASTEXITCODE -ne 0) { return }

# --- 3. Windows/WSLパス設定 ---
$WslDistro = $PandockerConfig.WslDistro
$WindowsProjectRoot = (Get-Location).Path
$TexProjectRoot = Join-Path $WindowsProjectRoot "projects"
$WslHome = (wsl.exe -d $WslDistro -e sh -c 'echo $HOME').Trim()
$WslProjectRootUnix = "$WslHome/$($PandockerConfig.WslWorkDirName)"
$WslProjectRootWin = (wsl.exe -d $WslDistro wslpath -w $WslProjectRootUnix).Trim()

# --- 4. ビルド対象ファイルの決定 ---
$SrcDir = Join-Path $TexProjectRoot "$ReportName/src"

if ($All.IsPresent) {
    Write-Host "All オプションが指定されました: src 内のすべての .md ファイルをビルドします。" -ForegroundColor Cyan
    $InputFiles = Get-ChildItem -Path $SrcDir -Filter "*.md" | ForEach-Object { $_.Name }
} elseif (-not $InputFiles) {
    $InputFiles = @("report.md")  # デフォルト
}

# --- 5. WSL同期 ---
Write-Host "[1/3] プロジェクトファイルをWSLに同期中..." -ForegroundColor DarkGray
robocopy $WindowsProjectRoot $WslProjectRootWin /MIR /XF ".git" /XD ".git" "log" /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) {
    Write-Host "エラー: Robocopyでのファイル同期に失敗しました。コード=$LASTEXITCODE" -ForegroundColor Red
    return
}

# --- 6. ログ準備 ---
$Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH-mm-ss")
if ($Log.IsPresent) {
    $LogFileName = "pandoc_${ReportName}_$Timestamp.log"
    Write-Host "ログ出力有効: log/$LogFileName" -ForegroundColor Cyan
} else {
    $LogFileName = $null
}

# --- 7. 各ファイルを順次ビルド ---
foreach ($InputFile in $InputFiles) {
    $InputPath = Join-Path $SrcDir $InputFile
    if (-not (Test-Path $InputPath)) {
    Write-Host "警告: $InputFile が存在しません。スキップします。" -ForegroundColor Yellow
    continue
    }

    $FileBase = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $ContainerWorkDir = "/data/projects/$ReportName/src"
    $Defaults = "../defaults.yml"
    $OutputFile = "../output/${ReportName}_${FileBase}.pdf"
    $PandocArgs = "--defaults '$Defaults' -F pandoc-crossref '$InputFile' -o '$OutputFile' --citeproc -M listings"

    if ($Log.IsPresent) {
        $PandocArgs += " --verbose"
        $BashCommandRaw = "cd '$ContainerWorkDir' && { echo '--- Build started at $Timestamp ($InputFile) ---'; pandoc $PandocArgs; } &>> /data/log/$LogFileName"
    } else {
        $BashCommandRaw = "cd '$ContainerWorkDir' && pandoc $PandocArgs"
    }

    $BashCommandForSh = $BashCommandRaw -replace "'", "'\''"

    # --- 7.1 ログディレクトリ作成 ---
    Write-Host "[準備] WSL内に log ディレクトリを作成中..." -ForegroundColor DarkGray
    & wsl.exe -d $WslDistro -e sh -c "cd '$WslProjectRootUnix' && mkdir -p log"

    # --- 7.2 Dockerビルド実行 ---
    Write-Host "[2/3] WSL内でPandocビルドを実行中 ($InputFile)..." -ForegroundColor Gray
    $WslCommand = "cd '$WslProjectRootUnix' && docker compose run --rm --entrypoint bash pandoc -c '$BashCommandForSh'"

    $StartTime = Get-Date
    try {
        & wsl.exe -d $WslDistro -e sh -c $WslCommand
    } catch {
        Write-Host "エラー: $InputFile のビルド中に失敗しました。" -ForegroundColor Red
        continue
    }
    $ElapsedTime = (New-TimeSpan -Start $StartTime -End (Get-Date)).TotalSeconds

    # --- 7.3 PDFコピー ---
    $PdfFileName = "${ReportName}_${FileBase}.pdf"
    $WslPdfPath = Join-Path $WslProjectRootWin "projects\$ReportName\output\$PdfFileName"
    $WindowsOutputDestDir = Join-Path $TexProjectRoot "$ReportName\output"

    if (-not (Test-Path $WindowsOutputDestDir)) {
        New-Item -ItemType Directory -Force -Path $WindowsOutputDestDir | Out-Null
    }

    try {
        Copy-Item -Path $WslPdfPath -Destination $WindowsOutputDestDir -Force -ErrorAction SilentlyContinue
    } catch {}

    if (Test-Path (Join-Path $WindowsOutputDestDir $PdfFileName)) {
        Write-Host "$InputFile → $PdfFileName 生成完了 (${ElapsedTime}秒)" -ForegroundColor Green
    } else {
        Write-Host "$InputFile のPDF生成に失敗しました。" -ForegroundColor Red
    }
}

# --- 8. ログコピー ---
if ($Log.IsPresent) {
    $WslLogPath = Join-Path $WslProjectRootWin "log"
    $WindowsLogDestDir = Join-Path $WindowsProjectRoot "log"
    if (-not (Test-Path $WindowsLogDestDir)) { New-Item -ItemType Directory -Force -Path $WindowsLogDestDir | Out-Null }

    if (Test-Path (Join-Path $WslLogPath $LogFileName)) {
        robocopy $WslLogPath $WindowsLogDestDir $LogFileName /NFL /NDL /NJH /NJS | Out-Null
        Write-Host "ログをコピーしました: log\$LogFileName" -ForegroundColor DarkGray
    } else {
        Write-Host "ログファイルが見つかりませんでした。" -ForegroundColor Yellow
    }
}
