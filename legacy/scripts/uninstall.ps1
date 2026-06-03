# Legacy cleanup script kept for reference.

Write-Host "Pandocker-X cleanup started..." -ForegroundColor Cyan

# 1. Define the profile paths used by install.ps1.
$LocalProfileDir = Join-Path $env:USERPROFILE "Documents\PowerShell"
$PandockerProfile = Join-Path $LocalProfileDir "Pandocker_profile.ps1"
$includeLine = ". `"$PandockerProfile`""
$commentLine = "# Load Pandocker profile"

# 2. Remove the Pandocker import block from the main profile.
if (Test-Path $PROFILE) {
    Write-Host "Cleaning main profile ($PROFILE)..."
    try {
        $contentRaw = Get-Content -Path $PROFILE -Raw
        $loadBlock = "`n$commentLine`n$includeLine`n"

        if ($contentRaw.Contains($loadBlock)) {
            $newContentRaw = $contentRaw.Replace($loadBlock, "")
            Set-Content -Path $PROFILE -Value $newContentRaw
            Write-Host "Removed the Pandocker import block from $PROFILE."
        } else {
            Write-Host "No Pandocker block found in $PROFILE."
        }
    } catch {
        Write-Host "Failed to edit $PROFILE. Please check it manually." -ForegroundColor Red
        Write-Host $_
    }
} else {
    Write-Host "$PROFILE not found."
}

# 3. Remove the dedicated Pandocker profile.
if (Test-Path $PandockerProfile) {
    Write-Host "Removing dedicated profile ($PandockerProfile)..."
    Remove-Item $PandockerProfile -Force -ErrorAction SilentlyContinue
    Write-Host "Removed $PandockerProfile."
} else {
    Write-Host "$PandockerProfile not found."
}

# 4. Remove the current session functions and aliases.
Write-Host "Cleaning the current PowerShell session..."
Remove-Item function:pdx -ErrorAction SilentlyContinue
Remove-Item alias:pdx-new -ErrorAction SilentlyContinue
Remove-Item alias:pdx-setup -ErrorAction SilentlyContinue
Remove-Item alias:pdx-build -ErrorAction SilentlyContinue
Write-Host "Removed pdx from the current session."

Write-Host "`nCleanup complete." -ForegroundColor Green
Write-Host "Run `install.ps1` again to restore the wrapper."
