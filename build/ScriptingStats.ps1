# Get the module root directory (parent of Build folder)
$ModuleRoot = Split-Path $PSScriptRoot -Parent

# Count all PS1 files in the Public and Private folders
$PublicFiles = Get-ChildItem -Path (Join-Path $ModuleRoot "src\Public") -Filter "*.ps1" -Recurse
$PrivateFiles = Get-ChildItem -Path (Join-Path $ModuleRoot "src\Private") -Filter "*.ps1" -Recurse
$DocFiles = Get-ChildItem -Path (Join-Path $ModuleRoot "docs") -Filter "*.md" -Recurse

# Count Lines of Code in each file
$PublicStats = $PublicFiles | ForEach-Object {
    $Lines = Get-Content -Path $_.FullName
    [PSCustomObject]@{
        Name = $_.Name
        Lines = $Lines.Count
        Words = ($Lines | Measure-Object -Word).Words
    }
}

$PrivateStats = $PrivateFiles | ForEach-Object {
    $Lines = Get-Content -Path $_.FullName
    [PSCustomObject]@{
        Name = $_.Name
        Lines = $Lines.Count
        Words = ($Lines | Measure-Object -Word).Words
    }
}

$DocStats = $DocFiles | ForEach-Object {
    $Lines = Get-Content -Path $_.FullName
    [PSCustomObject]@{
        Name = $_.Name
        Lines = $Lines.Count
        Words = ($Lines | Measure-Object -Word).Words
    }
}

# Calculate the total lines of code
$TotalPublicLines = ($PublicStats | Measure-Object -Property Lines -Sum).Sum
$TotalPrivateLines = ($PrivateStats | Measure-Object -Property Lines -Sum).Sum
$TotalDocLines = ($DocStats | Measure-Object -Property Lines -Sum).Sum

# Calculate the total words
$TotalPublicWords = ($PublicStats | Measure-Object -Property Words -Sum).Sum
$TotalPrivateWords = ($PrivateStats | Measure-Object -Property Words -Sum).Sum
$TotalDocWords = ($DocStats | Measure-Object -Property Words -Sum).Sum

# Calculate totals
$TotalCodeLines = $TotalPublicLines + $TotalPrivateLines
$TotalAllLines = $TotalPublicLines + $TotalPrivateLines + $TotalDocLines
$TotalCodeWords = $TotalPublicWords + $TotalPrivateWords
$TotalAllWords = $TotalPublicWords + $TotalPrivateWords + $TotalDocWords

# Clear the screen for clean output
Clear-Host

# Display header with module information
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                 📊 DOMAIN REMOVAL MODULE STATISTICS" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Display code statistics in organized sections
Write-Host "🔧 CODE STATISTICS" -ForegroundColor Yellow
Write-Host "├─ Public Functions:" -ForegroundColor Gray -NoNewline
Write-Host "    $($PublicFiles.Count) files" -ForegroundColor White -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalPublicLines lines" -ForegroundColor Green -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalPublicWords words" -ForegroundColor Cyan
Write-Host "├─ Private Functions:" -ForegroundColor Gray -NoNewline
Write-Host "   $($PrivateFiles.Count) files" -ForegroundColor White -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalPrivateLines lines" -ForegroundColor Green -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalPrivateWords words" -ForegroundColor Cyan
Write-Host "└─ Total Code:" -ForegroundColor Gray -NoNewline
Write-Host "         $($PublicFiles.Count + $PrivateFiles.Count) files" -ForegroundColor White -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalCodeLines lines" -ForegroundColor Green -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalCodeWords words" -ForegroundColor Cyan
Write-Host ""

Write-Host "📚 DOCUMENTATION STATISTICS" -ForegroundColor Yellow
Write-Host "├─ Documentation Files:" -ForegroundColor Gray -NoNewline
Write-Host " $($DocFiles.Count) files" -ForegroundColor White -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalDocLines lines" -ForegroundColor Green -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalDocWords words" -ForegroundColor Cyan
Write-Host ""

Write-Host "📈 OVERALL TOTALS" -ForegroundColor Yellow
Write-Host "├─ All Files:" -ForegroundColor Gray -NoNewline
Write-Host "         $($PublicFiles.Count + $PrivateFiles.Count + $DocFiles.Count) files" -ForegroundColor White -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalAllLines lines" -ForegroundColor Green -NoNewline
Write-Host " │ " -ForegroundColor Gray -NoNewline
Write-Host "$TotalAllWords words" -ForegroundColor Cyan
Write-Host ""

# Define the stats file path
$StatsFilePath = Join-Path $PSScriptRoot "ScriptingStats.json"

# Check if previous stats file exists
if (Test-Path $StatsFilePath) {
    # Get the previous stats
    $PreviousStats = Get-Content -Path $StatsFilePath | ConvertFrom-Json
    
    # Calculate the difference in lines and words
    $LineDifference = $TotalAllLines - $PreviousStats.TotalLines
    $WordDifference = $TotalAllWords - $PreviousStats.TotalWords
    
    # Check if the previous stats are the same as the current stats
    if ($LineDifference -eq 0 -and $WordDifference -eq 0) {
        Write-Host "✅ CHANGE DETECTION" -ForegroundColor Yellow
        Write-Host "└─ Status:" -ForegroundColor Gray -NoNewline
        Write-Host "            No changes detected" -ForegroundColor Green
        Write-Host ""
        Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    } else {
        Write-Host "🔄 CHANGE DETECTION" -ForegroundColor Yellow
        Write-Host "├─ Status:" -ForegroundColor Gray -NoNewline
        Write-Host "            Changes detected" -ForegroundColor Magenta
        
        # Show positive/negative changes with appropriate colors and symbols
        if ($LineDifference -gt 0) {
            Write-Host "├─ Lines Changed:" -ForegroundColor Gray -NoNewline
            Write-Host "      +" -ForegroundColor Green -NoNewline
            Write-Host "$LineDifference" -ForegroundColor Green -NoNewline
            Write-Host " lines added" -ForegroundColor Green
        } elseif ($LineDifference -lt 0) {
            Write-Host "├─ Lines Changed:" -ForegroundColor Gray -NoNewline
            Write-Host "      " -NoNewline
            Write-Host "$LineDifference" -ForegroundColor Red -NoNewline
            Write-Host " lines removed" -ForegroundColor Red
        }
        
        if ($WordDifference -gt 0) {
            Write-Host "└─ Words Changed:" -ForegroundColor Gray -NoNewline
            Write-Host "      +" -ForegroundColor Green -NoNewline
            Write-Host "$WordDifference" -ForegroundColor Green -NoNewline
            Write-Host " words added" -ForegroundColor Green
        } elseif ($WordDifference -lt 0) {
            Write-Host "└─ Words Changed:" -ForegroundColor Gray -NoNewline
            Write-Host "      " -NoNewline
            Write-Host "$WordDifference" -ForegroundColor Red -NoNewline
            Write-Host " words removed" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    }
} else {
    Write-Host "🆕 INITIAL SCAN" -ForegroundColor Yellow
    Write-Host "└─ Status:" -ForegroundColor Gray -NoNewline
    Write-Host "            First time analysis completed" -ForegroundColor Blue
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    $LineDifference = 0
    $WordDifference = 0
}

# Create contents json file that is stored by date
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Content = @{
    Date = $Date
    PublicStats = $PublicStats
    PrivateStats = $PrivateStats
    DocStats = $DocStats
    TotalPublicLines = $TotalPublicLines
    TotalPrivateLines = $TotalPrivateLines
    TotalLinesofCode = $TotalCodeLines
    TotalDocLines = $TotalDocLines
    TotalPublicWords = $TotalPublicWords
    TotalPrivateWords = $TotalPrivateWords
    TotalDocWords = $TotalDocWords
    TotalLines = $TotalAllLines
    TotalWords = $TotalAllWords
    WordDifference = $WordDifference
    LineDifference = $LineDifference
    PublicFileCount = $PublicFiles.Count
    PrivateFileCount = $PrivateFiles.Count
    DocFileCount = $DocFiles.Count
    TotalFileCount = $PublicFiles.Count + $PrivateFiles.Count + $DocFiles.Count
}

# If previous stats file exists, add to the content
if (Test-Path $StatsFilePath) {
    $Content.PreviousStats = $PreviousStats
}

# Export the content to a json file
$Content | ConvertTo-Json -depth 10 | Out-File $StatsFilePath

# Display completion message
Write-Host ""
Write-Host "💾 Analysis completed and saved to:" -ForegroundColor Green
Write-Host "   $StatsFilePath" -ForegroundColor Gray
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan