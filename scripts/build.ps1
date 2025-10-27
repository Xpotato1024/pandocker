#build.ps1
param (
    [Parameter(Position=0)]
    [string]$ReportName,

    [Parameter(Position=1)]
    [string[]]$InputFiles,

    [Parameter()]
    [switch]$All,

    [Parameter()]
    [switch]$Log
)

# --- 1. 共通のWSL初期化処理を読み込む ---
try {
    . (Join-Path $PSScriptRoot "wsl-init.ps1")
} catch {
    Write-Host "エラー: 共通初期化スクリプト(wsl-init.ps1)の読み込みに失敗しました。" -ForegroundColor Red
    return
}

# --- 2. ビルド対象ファイルの決定 ---
if ([string]::IsNullOrEmpty($ReportName)) {
    Write-Host "エラー: ビルド対象のプロジェクト名が指定されていません。" -ForegroundColor Red
    Write-Host "Usage: pdx build <ProjectName> [options]" -ForegroundColor Yellow
    return
}

$WslSrcDir = Join-Path $WslProjectRootWin "projects\$ReportName\src" # [追加] WSL側のsrcパス

if ($All.IsPresent) {
    Write-Host "All オプションが指定されました: src 内のすべての .md ファイルをビルドします。" -ForegroundColor Cyan
} elseif (-not $InputFiles) {
    $InputFiles = @("report.md")
}

# --- 3. WSL同期 ---
Write-Host "[1/3] プロジェクトファイルをWSLに同期中..." -ForegroundColor DarkGray
robocopy $WindowsProjectRoot $WslProjectRootWin /MIR /XF ".git" /XD ".git" "log" /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) {
    Write-Host "エラー: Robocopyでのファイル同期に失敗しました。コード=$LASTEXITCODE" -ForegroundColor Red
    return
}

# 同期後のWSLパスを基準にファイルリストを作成
if ($All.IsPresent) {
    if (Test-Path $WslSrcDir) {
        $InputFiles = Get-ChildItem -Path $WslSrcDir -Filter "*.md" | ForEach-Object { $_.Name }
    } else {
        Write-Host "警告: WSL側に $WslSrcDir が見つかりません。" -ForegroundColor Yellow
        $InputFiles = @()
    }
}

# --- 4. ログ準備 ---
$Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH-mm-ss")
if ($Log.IsPresent) {
    $LogFileName = "pandoc_${ReportName}_$Timestamp.log"
    Write-Host "ログ出力有効: log/$LogFileName" -ForegroundColor Cyan
} else {
    $LogFileName = $null
}

# --- 5. 各ファイルを順次ビルド ---
foreach ($InputFile in $InputFiles) {
    $InputPathOnWsl = Join-Path $WslSrcDir $InputFile
    if (-not (Test-Path $InputPathOnWsl)) {
    Write-Host "警告: WSL側に $InputFile が存在しません。スキップします。" -ForegroundColor Yellow
    Write-Host "     ( $InputPathOnWsl )"
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

    # --- 6.1 ログディレクトリ作成 ---
    Write-Host "[準備] WSL内に log ディレクトリを作成中..." -ForegroundColor DarkGray
    & wsl.exe -d $WslDistro -e sh -c "cd '$WslProjectRootUnix' && mkdir -p log"

    # --- 6.2 Dockerビルド実行 ---
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

    # --- 6.3 PDFコピー ---
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

# --- 7. ログコピー ---
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
