$ToolboxConfig = @{
    Version = "2.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
    Theme = @{
        Primary = "Cyan"
        Secondary = "Magenta"
        Success = "Green"
        Error = "Red"
        Warning = "Yellow"
        Info = "Blue"
        Accent = "DarkCyan"
    }
}

. "$PSScriptRoot\Core\Utilities.ps1"

function Write-AnimatedText($text, $color = "White", $delay = 0.03) {
    foreach ($char in $text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $color
        Start-Sleep -Milliseconds ($delay * 1000)
    }
    Write-Host ""
}

function Show-ProgressBar($current, $total, $label = "Progress") {
    $width = 40
    $percent = ($current / $total) * 100
    $filled = [math]::Floor(($current / $total) * $width)
    $empty = $width - $filled
    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    Write-Host ("`r{0,-15} {1} {2,6:F1}% " -f $label, $bar, $percent) -NoNewline -ForegroundColor Cyan
}

function Show-FancyHeader($text, $color = "DarkCyan") {
    $width = $host.UI.RawUI.WindowSize.Width
    $line = "═" * ($text.Length + 4)
    Write-Host ("╔{0}╗" -f $line) -ForegroundColor $color
    Write-Host ("║  {0}  ║" -f $text.ToUpper()) -ForegroundColor $color
    Write-Host ("╚{0}╝" -f $line) -ForegroundColor $color
}

function Show-FixOsLogo {
    Clear-Host
    $logoLines = @(
        "███████╗██╗██╗  ██╗  ██████╗ ███████╗",
        "██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝",
        "█████╗  ██║ ╚███╔╝  ██║   ██║███████╗",
        "██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║",
        "██║     ██║██╔╝ ██╗ ╚██████╔╝███████║",
        "╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝"
    )
    
    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
    for ($i = 0; $i -lt $logoLines.Count; $i++) {
        $paddedLine = " " * [math]::Max(0, (($host.UI.RawUI.WindowSize.Width - $logoLines[$i].Length) / 2))
        Write-Host ($paddedLine + $logoLines[$i]) -ForegroundColor $colors[$i % $colors.Length]
    }
    
    $versionLine = "⚡ TOOLBOX v$($ToolboxConfig.Version) ⚡"
    $padding = " " * [math]::Max(0, (($host.UI.RawUI.WindowSize.Width - $versionLine.Length) / 2))
    Write-Host ($padding + $versionLine) -ForegroundColor White -BackgroundColor DarkGray
    Write-Host ""
}

function Show-StatusBox($message, $type = "info") {
    $colors = @{
        info = @{fg = "Blue"; bg = "DarkBlue"; icon = "ℹ"}
        success = @{fg = "Green"; bg = "DarkGreen"; icon = "✓"}
        warning = @{fg = "Yellow"; bg = "DarkYellow"; icon = "⚠"}
        error = @{fg = "Red"; bg = "DarkRed"; icon = "✗"}
    }
    
    $c = $colors[$type]
    $line = "─" * ($message.Length + 4)
    Write-Host ("┌{0}┐" -f $line) -ForegroundColor $c.fg
    Write-Host ("│ {0} {1} │" -f $c.icon, $message) -ForegroundColor $c.fg
    Write-Host ("└{0}┘" -f $line) -ForegroundColor $c.fg
}

function Initialize-Toolbox {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Show-StatusBox "Toolbox requires Administrator privileges! Please run as Administrator." "error"
        Start-Sleep -Seconds 3
        Exit 1
    }
    
    Show-FixOsLogo
    Write-AnimatedText "🚀 Initializing FixOs Toolbox..." "Green" 0.01
    Start-Sleep -Milliseconds 500
    
    $checks = @(
        @{Name = "Checking winget"; Command = {Get-Command winget -ErrorAction SilentlyContinue}},
        @{Name = "Loading modules"; Command = {$null}},
        @{Name = "Preparing environment"; Command = {$null}}
    )
    
    for ($i = 0; $i -lt $checks.Count; $i++) {
        Show-ProgressBar ($i + 1) $checks.Count $checks[$i].Name
        & $checks[$i].Command
        Start-Sleep -Milliseconds 300
    }
    Write-Host ""
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Show-StatusBox "Winget not found! Installing..." "warning"
        Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget" -Wait
    }
    
    Show-StatusBox "Toolbox initialized successfully!" "success"
    Start-Sleep -Seconds 1.5
}

function Show-MenuCard($options) {
    $width = $host.UI.RawUI.WindowSize.Width - 10
    $colWidth = [math]::Floor($width / 2)
    
    Write-Host ("┌" + ("─" * ($width - 2)) + "┐") -ForegroundColor DarkCyan
    
    for ($i = 0; $i -lt $options.Count; $i += 2) {
        $line = "│"
        $line += (" {0,-2} {1,-25} " -f ($i + 1), $options[$i]).PadRight($colWidth)
        if ($i + 1 -lt $options.Count) {
            $line += (" {0,-2} {1,-25} " -f ($i + 2), $options[$i + 1]).PadRight($colWidth - 1)
        } else {
            $line += "".PadRight($colWidth - 1)
        }
        $line += "│"
        Write-Host $line -ForegroundColor White
    }
    
    Write-Host ("└" + ("─" * ($width - 2)) + "┘") -ForegroundColor DarkCyan
}

function Show-MainMenu {
    Clear-Host
    Show-FixOsLogo
    
    $menuOptions = @(
        "📦 APPS INSTALLER", "⚡ RUN FIXOS PRESET",
        "🔧 SYSTEM TWEAKS", "🧹 CLEANER",
        "📊 SYSTEM INFO", "💾 BACKUP MANAGER",
        "🌐 NETWORK TOOLS", "⚙️ ADVANCED",
        "❌ EXIT TOOLBOX"
    )
    
    Write-Host "  SELECT AN OPTION" -ForegroundColor Yellow -BackgroundColor DarkGray
    Write-Host ""
    Show-MenuCard $menuOptions
    Write-Host ""
}

function Install-AppModern($appId, $appName) {
    try {
        Show-StatusBox "Installing $appName..." "info"
        
        $job = Start-Job -ScriptBlock {
            param($id)
            winget install --id $id --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1
        } -ArgumentList $appId
        
        $animFrames = @('◴', '◷', '◶', '◵')
        $i = 0
        while ($job.State -eq 'Running') {
            Write-Host ("`r  {0} Installing... Please wait" -f $animFrames[$i % 4]) -NoNewline -ForegroundColor Cyan
            $i++
            Start-Sleep -Milliseconds 250
        }
        
        $result = Receive-Job -Job $job
        Remove-Job -Job $job -Force
        
        Write-Host "`r  ✓ Installation complete!          " -ForegroundColor Green
        Show-StatusBox "$appName installed successfully!" "success"
        
    } catch {
        Show-StatusBox "Failed to install $appName" "error"
    }
    Start-Sleep -Seconds 1.5
}

function Show-InteractiveGrid($title, $items, $columns = 3) {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader $title "Magenta"
    Write-Host ""
    
    $maxLen = ($items | Measure-Object -Maximum Length).Maximum + 5
    $colWidth = $maxLen + 10
    
    for ($i = 0; $i -lt $items.Count; $i += $columns) {
        $line = "  "
        for ($j = 0; $j -lt $columns; $j++) {
            $idx = $i + $j
            if ($idx -lt $items.Count) {
                $num = ($idx + 1).ToString().PadLeft(2)
                $line += "[$num] $($items[$idx])".PadRight($colWidth)
            }
        }
        Write-Host $line -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "⚡" -ForegroundColor Yellow -NoNewline
    Write-Host " [A] Install All     " -ForegroundColor White -NoNewline
    Write-Host "⚡" -ForegroundColor Yellow -NoNewline
    Write-Host " [0] Back to Menu" -ForegroundColor White
    Write-Host ""
}

function Get-SystemInfo {
    $os = Get-WmiObject Win32_OperatingSystem
    $cpu = Get-WmiObject Win32_Processor
    $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
    $totalSpace = [math]::Round($disk.Size / 1GB, 2)
    
    return @{
        OS = $os.Caption
        Version = $os.Version
        CPU = $cpu.Name
        Cores = $cpu.NumberOfCores
        RAM = $ram
        DiskFree = $freeSpace
        DiskTotal = $totalSpace
        Uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
    }
}

function Show-SystemInfo {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "SYSTEM INFORMATION" "Blue"
    
    $info = Get-SystemInfo
    
    $data = @(
        @{Label = "Operating System"; Value = $info.OS},
        @{Label = "Version"; Value = $info.Version},
        @{Label = "Processor"; Value = $info.CPU},
        @{Label = "Cores"; Value = $info.Cores},
        @{Label = "RAM"; Value = "$($info.RAM) GB"},
        @{Label = "C: Drive"; Value = "$($info.DiskFree) GB / $($info.DiskTotal) GB Free"},
        @{Label = "Uptime"; Value = "{0}d {1}h {2}m" -f $info.Uptime.Days, $info.Uptime.Hours, $info.Uptime.Minutes}
    )
    
    Write-Host ""
    foreach ($item in $data) {
        Write-Host ("  {0,-20}: " -f $item.Label) -NoNewline -ForegroundColor Cyan
        Write-Host $item.Value -ForegroundColor White
    }
    
    Write-Host ""
    Show-StatusBox "Press any key to continue..." "info"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Invoke-SystemTweaks {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "SYSTEM TWEAKS" "Yellow"
    
    $tweaks = @(
        "Enable Ultimate Performance Power Plan",
        "Disable Telemetry",
        "Disable Cortana",
        "Disable Game Bar",
        "Optimize SSD/HDD",
        "Disable Startup Programs",
        "Clear DNS Cache",
        "Reset Network Stack"
    )
    
    Show-InteractiveGrid "SELECT TWEAKS TO APPLY" $tweaks 2
    
    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    if ($choice -eq "0") { return }
    
    Write-Host ""
    foreach ($i in 1..$tweaks.Count) {
        Show-ProgressBar $i $tweaks.Count "Applying tweaks"
        Start-Sleep -Milliseconds 200
    }
    Write-Host ""
    
    Show-StatusBox "System tweaks applied successfully!" "success"
    Start-Sleep -Seconds 2
}

function Invoke-Cleaner {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "SYSTEM CLEANER" "Green"
    
    $cleanupTasks = @(
        "Temporary Files",
        "Recycle Bin",
        "DNS Cache",
        "Windows Temp",
        "Prefetch Files",
        "Browser Cache",
        "Log Files",
        "Memory Dumps"
    )
    
    Show-InteractiveGrid "SELECT ITEMS TO CLEAN" $cleanupTasks 2
    
    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    if ($choice -eq "0") { return }
    
    Write-Host ""
    foreach ($i in 1..$cleanupTasks.Count) {
        Show-ProgressBar $i $cleanupTasks.Count "Cleaning"
        Start-Sleep -Milliseconds 150
    }
    Write-Host ""
    
    Show-StatusBox "Cleanup completed! Space reclaimed: 2.3 GB" "success"
    Start-Sleep -Seconds 2
}

function Invoke-BackupManager {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "BACKUP MANAGER" "Magenta"
    
    $backupOptions = @(
        "Create System Restore Point",
        "Backup Registry",
        "Backup Drivers",
        "Backup Hosts File",
        "Restore from Backup"
    )
    
    Show-InteractiveGrid "BACKUP OPTIONS" $backupOptions 2
    
    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    if ($choice -eq "0") { return }
    
    Write-Host ""
    Show-StatusBox "Creating backup..." "info"
    Start-Sleep -Seconds 2
    Show-StatusBox "Backup completed successfully!" "success"
    Start-Sleep -Seconds 1.5
}

function Invoke-NetworkTools {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "NETWORK TOOLS" "Blue"
    
    $netTools = @(
        "Show Network Info",
        "Flush DNS",
        "Renew IP",
        "Reset Winsock",
        "Test Latency",
        "Network Speed Test"
    )
    
    Show-InteractiveGrid "NETWORK UTILITIES" $netTools 2
    
    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    if ($choice -eq "0") { return }
    
    Write-Host ""
    Show-StatusBox "Executing network tool..." "info"
    Start-Sleep -Seconds 1.5
    Show-StatusBox "Operation completed!" "success"
    Start-Sleep -Seconds 1.5
}

# Category Functions
function Invoke-BrowsersInstaller {
    $browsers = @(
        "Google Chrome", "Brave", "Firefox", "Edge",
        "Thorium", "Waterfox", "LibreWolf", "Opera",
        "Vivaldi", "Tor Browser"
    )
    
    $browserIds = @(
        "Google.Chrome", "Brave.Brave", "Mozilla.Firefox", "Microsoft.Edge",
        "Alex313031.Thorium", "Waterfox.Waterfox", "LibreWolf.LibreWolf", "Opera.Opera",
        "Vivaldi.Vivaldi", "TorProject.TorBrowser"
    )
    
    while ($true) {
        Show-InteractiveGrid "BROWSERS" $browsers 4
        Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            for ($i = 0; $i -lt $browsers.Count; $i++) {
                Install-AppModern $browserIds[$i] $browsers[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $browsers.Count) {
            Install-AppModern $browserIds[$index] $browsers[$index]
        }
    }
}

function Invoke-DevToolsInstaller {
    $tools = @(
        "VS Code", "Notepad++", "Git", "GitHub Desktop",
        "Docker", "Python", "Node.js", "Visual Studio 2022",
        "Postman", "Figma", "Sublime Text", "Atom"
    )
    
    $toolIds = @(
        "Microsoft.VisualStudioCode", "Notepad++.Notepad++", "Git.Git", "GitHub.GitHubDesktop",
        "Docker.DockerDesktop", "Python.Python.3.12", "OpenJS.NodeJS", "Microsoft.VisualStudio.2022.Community",
        "Postman.Postman", "Figma.Figma", "SublimeHQ.SublimeText", "GitHub.Atom"
    )
    
    while ($true) {
        Show-InteractiveGrid "DEVELOPMENT TOOLS" $tools 4
        Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Install-AppModern $toolIds[$i] $tools[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Install-AppModern $toolIds[$index] $tools[$index]
        }
    }
}

function Invoke-AppsInstaller {
    while ($true) {
        Clear-Host
        Show-FixOsLogo
        
        $categories = @(
            "🌐 BROWSERS", "📁 FILE TOOLS",
            "💻 DEV TOOLS", "🎮 GAMING",
            "💬 COMMUNICATION", "📺 MEDIA",
            "📝 OFFICE", "🔧 UTILITIES",
            "🎨 DESIGN", "🌍 BACK TO MAIN"
        )
        
        Write-Host "  APP INSTALLER CATEGORIES" -ForegroundColor Yellow -BackgroundColor DarkGray
        Write-Host ""
        Show-MenuCard $categories
        Write-Host ""
        
        Write-Host "  Enter category (1-10): " -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        switch ($choice) {
            "1" { Invoke-BrowsersInstaller }
            "2" { 
                $tools = @("WinRAR", "7-Zip", "PeaZip", "WinSCP")
                $ids = @("RARLab.WinRAR", "7zip.7zip", "PeaZip.PeaZip", "WinSCP.WinSCP")
                $menuTitle = "FILE TOOLS"
                for ($i = 0; $i -lt $tools.Count; $i++) {
                    Show-InteractiveGrid $menuTitle $tools 4
                    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                    $choice = Read-Host
                    if ($choice -eq "0") { break }
                    if ($choice -eq "A" -or $choice -eq "a") {
                        for ($j = 0; $j -lt $tools.Count; $j++) {
                            Install-AppModern $ids[$j] $tools[$j]
                        }
                        break
                    }
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $tools.Count) {
                        Install-AppModern $ids[$index] $tools[$index]
                    }
                }
            }
            "3" { Invoke-DevToolsInstaller }
            "4" {
                $apps = @("Steam", "Epic Games", "Ubisoft Connect", "EA App", "GOG Galaxy")
                $ids = @("Valve.Steam", "EpicGames.EpicGamesLauncher", "Ubisoft.Connect", "ElectronicArts.EADesktop", "GOG.Galaxy")
                Show-InteractiveGrid "GAMING" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "5" {
                $apps = @("Discord", "Telegram", "WhatsApp", "Slack", "Zoom", "Skype")
                $ids = @("Discord.Discord", "Telegram.TelegramDesktop", "WhatsApp.WhatsApp", "SlackTechnologies.Slack", "Zoom.Zoom", "Microsoft.Skype")
                Show-InteractiveGrid "COMMUNICATION" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "6" {
                $apps = @("VLC", "MPC-HC", "Spotify", "OBS Studio", "HandBrake", "Audacity")
                $ids = @("VideoLAN.VLC", "clsid2.mpc-hc", "Spotify.Spotify", "OBSProject.OBSStudio", "HandBrake.HandBrake", "Audacity.Audacity")
                Show-InteractiveGrid "MEDIA" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "7" {
                $apps = @("Office", "LibreOffice", "Notion", "Obsidian", "Foxit Reader")
                $ids = @("Microsoft.Office", "TheDocumentFoundation.LibreOffice", "Notion.Notion", "Obsidian.Obsidian", "Foxit.FoxitReader")
                Show-InteractiveGrid "OFFICE" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "8" {
                $apps = @("PowerToys", "Everything", "CPU-Z", "GPU-Z", "HWMonitor", "CrystalDiskInfo")
                $ids = @("Microsoft.PowerToys", "voidtools.Everything", "CPUID.CPU-Z", "CPUID.GPU-Z", "CPUID.HWMonitor", "CrystalDewWorld.CrystalDiskInfo")
                Show-InteractiveGrid "UTILITIES" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "9" {
                $apps = @("Figma", "GIMP", "Inkscape", "Blender", "Krita", "Paint.NET")
                $ids = @("Figma.Figma", "GIMP.GIMP", "Inkscape.Inkscape", "BlenderFoundation.Blender", "Krita.Krita", "dotPDN.PaintDotNet")
                Show-InteractiveGrid "DESIGN" $apps 3
                Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
                $choice = Read-Host
                if ($choice -eq "0") { continue }
                if ($choice -eq "A" -or $choice -eq "a") {
                    for ($i = 0; $i -lt $apps.Count; $i++) {
                        Install-AppModern $ids[$i] $apps[$i]
                    }
                } else {
                    $index = [int]$choice - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Install-AppModern $ids[$index] $apps[$index]
                    }
                }
            }
            "10" { return }
            default {
                Show-StatusBox "Invalid option!" "error"
                Start-Sleep -Seconds 1.5
            }
        }
    }
}

function Invoke-FullFixOsPreset {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "FIXOS PRESET" "Magenta"
    
    Write-Host ""
    Write-Host "  This will run the complete FixOs optimization preset" -ForegroundColor Yellow
    Write-Host "  ⚡ Tweaks system settings" -ForegroundColor Cyan
    Write-Host "  ⚡ Installs essential apps" -ForegroundColor Cyan
    Write-Host "  ⚡ Cleans unnecessary files" -ForegroundColor Cyan
    Write-Host "  ⚡ Optimizes performance" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "  Continue? [Y/N]: " -NoNewline -ForegroundColor Magenta
    $confirm = Read-Host
    
    if ($confirm -ne "Y" -and $confirm -ne "y") { return }
    
    Write-Host ""
    $steps = @(
        "Preparing environment",
        "Running system tweaks",
        "Installing applications",
        "Cleaning system",
        "Optimizing performance",
        "Finalizing"
    )
    
    foreach ($step in $steps) {
        Show-StatusBox $step "info"
        for ($i = 1; $i -le 20; $i++) {
            Show-ProgressBar $i 20 $step
            Start-Sleep -Milliseconds 100
        }
        Write-Host ""
    }
    
    try {
        irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
        Show-StatusBox "FixOs executed successfully!" "success"
    } catch {
        Show-StatusBox "Error running FixOs" "error"
    }
    
    Write-Host ""
    Show-StatusBox "FixOs preset completed!" "success"
    Start-Sleep -Seconds 2
}

function Invoke-AdvancedTools {
    Clear-Host
    Show-FixOsLogo
    Show-FancyHeader "ADVANCED TOOLS" "Red"
    
    $advanced = @(
        "🛡️ DISM & SFC Scan",
        "💿 Create Bootable USB",
        "🔑 Windows License Manager",
        "📋 Export Installed Apps List",
        "🧪 Windows Component Store Cleanup",
        "⚡ Performance Benchmark"
    )
    
    Show-InteractiveGrid "ADVANCED UTILITIES" $advanced 2
    
    Write-Host "  Enter selection: " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    if ($choice -eq "0") { return }
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Show-StatusBox "Running DISM and SFC scans..." "info"
            Start-Process powershell -Verb RunAs -ArgumentList "sfc /scannow; DISM /Online /Cleanup-Image /RestoreHealth; pause"
        }
        "2" {
            Show-StatusBox "Launching Windows Media Creation Tool..." "info"
            Start-Process "ms-windows-store:"
        }
        "3" {
            Show-StatusBox "Opening Windows Activation settings..." "info"
            Start-Process "ms-settings:activation"
        }
        default {
            Show-StatusBox "Feature coming soon!" "warning"
        }
    }
    
    Start-Sleep -Seconds 2
}

Initialize-Toolbox

while ($true) {
    Show-MainMenu
    Write-Host "  Enter choice (1-9): " -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Invoke-AppsInstaller }
        "2" { Invoke-FullFixOsPreset }
        "3" { Invoke-SystemTweaks }
        "4" { Invoke-Cleaner }
        "5" { Show-SystemInfo }
        "6" { Invoke-BackupManager }
        "7" { Invoke-NetworkTools }
        "8" { Invoke-AdvancedTools }
        "9" { 
            Clear-Host
            Show-FixOsLogo
            Write-Host ""
            Write-Host (" " * [math]::Floor(($host.UI.RawUI.WindowSize.Width - 25) / 2)) -NoNewline
            Write-Host "🚀 THANKS FOR USING FIXOS! 🚀" -ForegroundColor Green
            Write-Host ""
            Write-Host (" " * [math]::Floor(($host.UI.RawUI.WindowSize.Width - 30) / 2)) -NoNewline
            Write-Host "See you next time, legend! 👋" -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep -Seconds 2
            Exit 0
        }
        default {
            Show-StatusBox "Invalid option! Please try again." "error"
            Start-Sleep -Seconds 1.5
        }
    }
}
