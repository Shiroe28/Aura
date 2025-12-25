# Update all color references in the codebase
$oldColors = @{
    'AppTheme.midnightBlue' = 'AppTheme.forestGreen'
    'AppTheme.coolBlue' = 'AppTheme.softBlue'
    'AppTheme.almostBlack' = 'AppTheme.stoneGrey'
    'AppTheme.subtleGray' = 'AppTheme.sage'
    'AppTheme.softGray' = 'AppTheme.calmSand'
}

# Get all dart files
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    foreach ($old in $oldColors.Keys) {
        if ($content -match [regex]::Escape($old)) {
            $content = $content -replace [regex]::Escape($old), $oldColors[$old]
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.Name)"
    }
}

Write-Host "Color update complete!"
