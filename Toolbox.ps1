function Create-ToolboxShortcut {
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "Toolbox.lnk"
        
        Write-Host "Creating shortcut at: $shortcutPath" -ForegroundColor Yellow
        
        $toolboxUrl = "https://raw.githubusercontent.com/DeveIopmentSpace/FixOs/dev/Toolbox/src/Toolbox.ps1"
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -Command `"irm '$toolboxUrl' | iex`""
        $Shortcut.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut.Description = "FixOs Toolbox - Run as Administrator"
        $Shortcut.IconLocation = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe,0"
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
