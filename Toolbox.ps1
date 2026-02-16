$ToolboxConfig = @{
    Version = "2.0.0"
    Author = "FixOs Team"
}

function Show-Logo {
    Clear-Host
    Write-Host @"
    
    ███████╗██╗██╗  ██╗  ██████╗ ███████╗
    ██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
    █████╗  ██║ ╚███╔╝  ██║   ██║███████╗
    ██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
    ██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
    ╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
    
              TOOLBOX v$($ToolboxConfig.Version)
"@ -ForegroundColor Cyan
    Write-Host ""
}

function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Run as Administrator dumbass!" -ForegroundColor Red
        Exit 1
    }
}

function Remove-Bloatware {
    Write-Host "[*] Killing bloatware..." -ForegroundColor Yellow
    
    $bloat = @(
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingFinance"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "Microsoft.WindowsCommunicationsApps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.549981C3F5F10" # Cortana
        "Microsoft.Windows.DevHome"
        "Clipchamp.Clipchamp"
        "SpotifyAB.SpotifyMusic"
        "Disney.37853FC22B2CE"
        "Netflix.Netflix"
        "TikTok.TikTok"
    )
    
    foreach ($app in $bloat) {
        Write-Host "  Removing: $app" -ForegroundColor Gray
        Get-AppxPackage $app | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$app*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    
    Write-Host "[✓] Bloatware removed" -ForegroundColor Green
}

function Disable-Telemetry {
    Write-Host "[*] Killing telemetry..." -ForegroundColor Yellow
    
    $services = @(
        "DiagTrack"                    # Diagnostics Tracking
        "dmwappushservice"             # Device Management WAP Push
        "WMPNetworkSvc"                # Windows Media Player Network Sharing
        "RemoteRegistry"                # Remote Registry
        "RemoteAccess"                  # Routing and Remote Access
        "lfsvc"                        # Geolocation Service
        "MapsBroker"                    # Downloaded Maps Manager
        "PcaSvc"                        # Program Compatibility Assistant
        "WdiServiceHost"                 # Diagnostic Service Host
        "WdiSystemHost"                  # Diagnostic System Host
    )
    
    foreach ($service in $services) {
        Stop-Service $service -Force -ErrorAction SilentlyContinue
        Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  Disabled: $service" -ForegroundColor Gray
    }
    
    # Registry tweaks
    $paths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    )
    
    foreach ($path in $paths) {
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    }
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    
    Write-Host "[✓] Telemetry disabled" -ForegroundColor Green
}

function Optimize-Performance {
    Write-Host "[*] Optimizing performance..." -ForegroundColor Yellow
    
    # Disable animations
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
    
    # Power settings
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 5
    powercfg -change -disk-timeout-ac 0
    powercfg -change -disk-timeout-dc 10
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 15
    powercfg -h off
    
    # Disable indexing on C:
    if (Get-Service -Name "WSearch" -ErrorAction SilentlyContinue) {
        Stop-Service WSearch -Force
        Set-Service WSearch -StartupType Disabled
    }
    
    Write-Host "[✓] Performance optimized" -ForegroundColor Green
}

function Install-Apps {
    Write-Host "[*] Installing essential apps..." -ForegroundColor Yellow
    
    $apps = @(
        @{Name = "Google Chrome"; ID = "Google.Chrome"}
        @{Name = "Mozilla Firefox"; ID = "Mozilla.Firefox"}
        @{Name = "Brave"; ID = "Brave.Brave"}
        @{Name = "7-Zip"; ID = "7zip.7zip"}
        @{Name = "WinRAR"; ID = "RARLab.WinRAR"}
        @{Name = "VLC"; ID = "VideoLAN.VLC"}
        @{Name = "qBittorrent"; ID = "qBittorrent.qBittorrent"}
        @{Name = "Notepad++"; ID = "Notepad++.Notepad++"}
        @{Name = "Git"; ID = "Git.Git"}
        @{Name = "Discord"; ID = "Discord.Discord"}
        @{Name = "Telegram"; ID = "Telegram.TelegramDesktop"}
        @{Name = "Spotify"; ID = "Spotify.Spotify"}
        @{Name = "OBS Studio"; ID = "OBSProject.OBSStudio"}
        @{Name = "Steam"; ID = "Valve.Steam"}
        @{Name = "Epic Games"; ID = "EpicGames.EpicGamesLauncher"}
    )
    
    foreach ($app in $apps) {
        Write-Host "  Installing: $($app.Name)" -ForegroundColor Gray
        winget install --id $app.ID --silent --accept-package-agreements --accept-source-agreements -e > $null 2>&1
    }
    
    Write-Host "[✓] Apps installed" -ForegroundColor Green
}

function Clean-System {
    Write-Host "[*] Cleaning system..." -ForegroundColor Yellow
    
    # Clean temp files
    $tempPaths = @(
        "$env:TEMP\*"
        "$env:WINDIR\Temp\*"
        "$env:WINDIR\Prefetch\*"
        "$env:USERPROFILE\Downloads\*" # Careful with this one
    )
    
    foreach ($path in $tempPaths) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Clean DNS
    ipconfig /flushdns > $null
    
    # Clean SxS
    dism /online /cleanup-image /startcomponentcleanup /quiet > $null 2>&1
    
    Write-Host "[✓] System cleaned" -ForegroundColor Green
}

function Show-Status {
    Clear-Host
    Show-Logo
    
    $os = Get-WmiObject Win32_OperatingSystem
    $cpu = Get-WmiObject Win32_Processor
    $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $free = [math]::Round($disk.FreeSpace / 1GB, 2)
    $total = [math]::Round($disk.Size / 1GB, 2)
    
    Write-Host "SYSTEM INFO" -ForegroundColor Cyan
    Write-Host "-----------"
    Write-Host "OS: $($os.Caption)"
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "RAM: ${ram}GB"
    Write-Host "C: Drive: ${free}GB / ${total}GB free"
    Write-Host ""
    Write-Host "Press any key..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-Menu {
    Clear-Host
    Show-Logo
    
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║           MAIN MENU                ║" -ForegroundColor DarkGray
    Write-Host "╠════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "║                                    ║" -ForegroundColor DarkGray
    Write-Host "║  [1] Remove Bloatware              ║" -ForegroundColor DarkGray
    Write-Host "║  [2] Disable Telemetry             ║" -ForegroundColor DarkGray
    Write-Host "║  [3] Optimize Performance          ║" -ForegroundColor DarkGray
    Write-Host "║  [4] Install Essential Apps        ║" -ForegroundColor DarkGray
    Write-Host "║  [5] Clean System                   ║" -ForegroundColor DarkGray
    Write-Host "║  [6] System Status                  ║" -ForegroundColor DarkGray
    Write-Host "║  [7] RUN ALL (FixOs Preset)         ║" -ForegroundColor DarkGray
    Write-Host "║  [8] Exit                           ║" -ForegroundColor DarkGray
    Write-Host "║                                    ║" -ForegroundColor DarkGray
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
}

function Run-All {
    Write-Host "[!] Running FixOs Preset..." -ForegroundColor Red
    Write-Host "Press Enter to continue or Ctrl+C to cancel"
    Read-Host
    
    Remove-Bloatware
    Disable-Telemetry
    Optimize-Performance
    Clean-System
    Install-Apps
    
    Write-Host ""
    Write-Host "[✓] FixOs Preset Complete!" -ForegroundColor Green
    Write-Host "Press any key..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main
Check-Admin

while ($true) {
    Show-Menu
    Write-Host "Select: " -NoNewline
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Remove-Bloatware }
        "2" { Disable-Telemetry }
        "3" { Optimize-Performance }
        "4" { Install-Apps }
        "5" { Clean-System }
        "6" { Show-Status }
        "7" { Run-All }
        "8" { 
            Write-Host "Peace out!" -ForegroundColor Green
            Exit 
        }
        default { 
            Write-Host "Invalid option!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    if ($choice -ne "6" -and $choice -ne "8") {
        Write-Host ""
        Write-Host "Done. Press any key..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
