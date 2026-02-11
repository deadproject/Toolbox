function Create-ToolboxShortcut {
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "Toolbox.lnk"
        
        Write-Host "Creating shortcut at: $shortcutPath" -ForegroundColor Yellow
        
        $toolboxUrl = "https://raw.githubusercontent.com/DeveIopmentSpace/FixOs/dev/Toolbox/src/Toolbox.ps1"
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "wt.exe"
        $Shortcut.Arguments = "-p `"Windows PowerShell`" -d `"$env:USERPROFILE`" powershell -Command `"Start-Process wt -ArgumentList '-p `\`"Windows PowerShell`\`" -d `\`"$env:USERPROFILE`\`" powershell -Command `\`"irm '$toolboxUrl' | iex`\`"' -Verb RunAs`""
        $Shortcut.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut.Description = "FixOs Toolbox - Run as Administrator"
        $Shortcut.IconLocation = "$env:SystemRoot\System32\WindowsTerminal.exe,0"
        $Shortcut.Save()
        
        if (Test-Path $shortcutPath) {
            Write-Host "✓ Shortcut created successfully!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Shortcut not found after save!" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
}

Create-ToolboxShortcut
