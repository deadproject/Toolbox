$ToolboxConfig = @{
    Version = "1.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
}

. "$PSScriptRoot\Core\Utilities.ps1"

function Center-Text($text) {
    $width = $host.UI.RawUI.WindowSize.Width
    $textLength = $text.Length
    $padding = [math]::Max(0, ($width - $textLength) / 2)
    return (" " * [math]::Floor($padding)) + $text
}

function Show-FixOsLogo {
    $logoLines = @(
        "███████╗██╗██╗  ██╗  ██████╗ ███████╗     ████████╗ ██████╗  ██████╗ ██╗     ██████╗  ██████╗ ██╗  ██╗",
        "██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝     ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔══██╗██╔═══██╗╚██╗██╔╝",
        "█████╗  ██║ ╚███╔╝  ██║   ██║███████╗        ██║   ██║   ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝ ",
        "██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║        ██║   ██║   ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗ ",
        "██║     ██║██╔╝ ██╗ ╚██████╔╝███████║        ██║   ╚██████╔╝╚██████╔╝███████╗██████╔╝╚██████╔╝██╔╝ ██╗",
        "╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝",
        "",
        "                                            v$($ToolboxConfig.Version)                                            "
    )
    
    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
    
    for ($i = 0; $i -lt $logoLines.Count - 1; $i++) {
        Write-Host (Center-Text $logoLines[$i]) -ForegroundColor $colors[$i % $colors.Count]
    }
    Write-Host (Center-Text $logoLines[-1]) -ForegroundColor White
    Write-Host ""
}

function Initialize-Toolbox {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host (Center-Text "╔════════════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "║     ERROR: Administrator Required!        ║") -ForegroundColor Red
        Write-Host (Center-Text "║  Please run PowerShell as Administrator   ║") -ForegroundColor Red
        Write-Host (Center-Text "╚════════════════════════════════════════════╝") -ForegroundColor Red
        Exit 1
    }
    
    Clear-Host
    Show-FixOsLogo
    Write-Host (Center-Text "► Initialized successfully at $(Get-Date)") -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Milliseconds 500
}

function Show-MainMenu {
    Clear-Host
    Show-FixOsLogo
    
    $menuOptions = @(
        "┌──────────────────────────────────────────────────┐",
        "│                 MAIN MENU                         │",
        "├──────────────────────────────────────────────────┤",
        "│                                                   │",
        "│    ╔══════════════════════════════════════════╗   │",
        "│    ║                                          ║   │",
        "│    ║        [1]  APPS INSTALLER              ║   │",
        "│    ║        [2]  RUN FIXOS PRESET            ║   │",
        "│    ║        [3]  EXIT TOOLBOX                ║   │",
        "│    ║                                          ║   │",
        "│    ╚══════════════════════════════════════════╝   │",
        "│                                                   │",
        "└──────────────────────────────────────────────────┘"
    )
    
    foreach ($line in $menuOptions) {
        if ($line -match "MAIN MENU") {
            Write-Host (Center-Text $line) -ForegroundColor Yellow
        } elseif ($line -match "┌|┐|└|┘|─|├|┤|│") {
            Write-Host (Center-Text $line) -ForegroundColor DarkCyan
        } else {
            Write-Host (Center-Text $line) -ForegroundColor White
        }
    }
    Write-Host ""
}

function Install-App($appId, $appName) {
    try {
        Write-Host ""
        Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
        Write-Host (Center-Text "│         INSTALLING: $($appName)") -ForegroundColor Yellow
        Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
        Write-Host ""
        
        $job = Start-Job -ScriptBlock {
            param($appId)
            winget install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1
        } -ArgumentList $appId
        
        $frames = @('◴', '◷', '◶', '◵')
        $i = 0
        $startTime = Get-Date
        
        while ($job.State -eq 'Running') {
            $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
            $progressBar = "[" + ("█" * ($i % 10)) + ("░" * (10 - ($i % 10))) + "]"
            Write-Host (Center-Text "  $($frames[$i % 4]) $progressBar Installing... $elapsed seconds") -ForegroundColor Cyan -NoNewline
            Start-Sleep -Milliseconds 150
            Write-Host "`r" -NoNewline
            $i++
        }
        
        $result = Receive-Job -Job $job
        Remove-Job -Job $job -Force
        
        Write-Host ""
        Write-Host (Center-Text "  ╔══════════════════════════════════════╗") -ForegroundColor Green
        Write-Host (Center-Text "  ║     ✓ $appName installed!            ║") -ForegroundColor Green
        Write-Host (Center-Text "  ╚══════════════════════════════════════╝") -ForegroundColor Green
        
    } catch {
        Write-Host ""
        Write-Host (Center-Text "  ╔══════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "  ║     ✗ Error installing $appName      ║") -ForegroundColor Red
        Write-Host (Center-Text "  ╚══════════════════════════════════════╝") -ForegroundColor Red
    }
    Write-Host ""
    Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-GridMenu($title, $options, $gridColumns = 3) {
    Clear-Host
    Show-FixOsLogo
    
    Write-Host (Center-Text "┌──────────────────────────────────────────────────┐") -ForegroundColor Magenta
    Write-Host (Center-Text "│  $title") -ForegroundColor White
    Write-Host (Center-Text "├──────────────────────────────────────────────────┤") -ForegroundColor Magenta
    Write-Host ""
    
    $maxLength = ($options | Measure-Object -Property Length -Maximum).Maximum + 8
    $colWidth = $maxLength + 6
    
    for ($i = 0; $i -lt $options.Count; $i += $gridColumns) {
        $line = "  "
        for ($j = 0; $j -lt $gridColumns; $j++) {
            $index = $i + $j
            if ($index -lt $options.Count) {
                $optionNum = $index + 1
                $optionText = "[$optionNum] $($options[$index])"
                $line += $optionText.PadRight($colWidth)
            }
        }
        Write-Host (Center-Text $line) -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host (Center-Text "├──────────────────────────────────────────────────┤") -ForegroundColor Magenta
    Write-Host (Center-Text "  [A] Install All                    [0] Back to Menu") -ForegroundColor Cyan
    Write-Host (Center-Text "└──────────────────────────────────────────────────┘") -ForegroundColor Magenta
    Write-Host ""
}

function Show-CategoriesMenu {
    Clear-Host
    Show-FixOsLogo
    
    Write-Host (Center-Text "┌──────────────────────────────────────────────────┐") -ForegroundColor Blue
    Write-Host (Center-Text "│              APPLICATION CATEGORIES              │") -ForegroundColor Yellow
    Write-Host (Center-Text "├──────────────────────────────────────────────────┤") -ForegroundColor Blue
    
    $categories = @(
        "    [01] BROWSERS          [02] FILE TOOLS       [03] DEV TOOLS    ",
        "    [04] .NET TOOLS        [05] COMMUNICATION    [06] GAMING APPS  ",
        "    [07] MICROSOFT APPS    [08] MEDIA APPS       [09] PRODUCTIVITY "
    )
    
    Write-Host ""
    foreach ($line in $categories) {
        Write-Host (Center-Text $line) -ForegroundColor White
    }
    Write-Host ""
    Write-Host (Center-Text "├──────────────────────────────────────────────────┤") -ForegroundColor Blue
    Write-Host (Center-Text "     Enter [1-9] or [0] to return to Main Menu      ") -ForegroundColor Gray
    Write-Host (Center-Text "└──────────────────────────────────────────────────┘") -ForegroundColor Blue
    Write-Host ""
}

function Invoke-BrowsersInstaller {
    $browsers = @(
        "Google Chrome", "Brave Browser", "Mozilla Firefox",
        "Microsoft Edge", "Thorium", "Waterfox",
        "LibreWolf", "Floorp", "Opera"
    )
    
    $browserIds = @(
        "Google.Chrome", "Brave.Brave", "Mozilla.Firefox",
        "Microsoft.Edge", "Alex313031.Thorium", "Waterfox.Waterfox",
        "LibreWolf.LibreWolf", "Floorp.Floorp", "Opera.Opera"
    )
    
    while ($true) {
        Show-GridMenu "BROWSERS" $browsers 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $browsers.Count; $i++) {
                Install-App $browserIds[$i] $browsers[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $browsers.Count) {
            Install-App $browserIds[$index] $browsers[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-FileToolsInstaller {
    $tools = @("WinRAR", "7-Zip", "PeaZip", "WinSCP", "FileZilla")
    $toolIds = @("RARLab.WinRAR", "7zip.7zip", "PeaZip.PeaZip", "WinSCP.WinSCP", "FileZilla.FileZilla")
    
    while ($true) {
        Show-GridMenu "FILE TOOLS" $tools 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Install-App $toolIds[$i] $tools[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Install-App $toolIds[$index] $tools[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-DevToolsInstaller {
    $tools = @(
        "VS Code", "Notepad++", "Sublime",
        "Git", "GitHub Desktop", "PowerShell 7",
        "Docker", "Python", "Node.js"
    )
    
    $toolIds = @(
        "Microsoft.VisualStudioCode", "Notepad++.Notepad++", "SublimeHQ.SublimeText",
        "Git.Git", "GitHub.GitHubDesktop", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Python.Python.3.12", "OpenJS.NodeJS"
    )
    
    while ($true) {
        Show-GridMenu "DEV TOOLS" $tools 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Install-App $toolIds[$i] $tools[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Install-App $toolIds[$index] $tools[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-DotNetInstaller {
    $tools = @(".NET SDK 8", ".NET Runtime 8", ".NET Desktop 8", ".NET SDK 7", ".NET Runtime 7", ".NET SDK 6")
    $toolIds = @(
        "Microsoft.DotNet.SDK.8", "Microsoft.DotNet.Runtime.8", "Microsoft.DotNet.DesktopRuntime.8",
        "Microsoft.DotNet.SDK.7", "Microsoft.DotNet.Runtime.7", "Microsoft.DotNet.SDK.6"
    )
    
    while ($true) {
        Show-GridMenu ".NET TOOLS" $tools 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Install-App $toolIds[$i] $tools[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Install-App $toolIds[$index] $tools[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-CommunicationInstaller {
    $apps = @("Telegram", "Discord", "WhatsApp", "Slack", "Zoom", "Signal")
    $appIds = @(
        "Telegram.TelegramDesktop", "Discord.Discord", "WhatsApp.WhatsApp",
        "SlackTechnologies.Slack", "Zoom.Zoom", "OpenWhisperSystems.Signal"
    )
    
    while ($true) {
        Show-GridMenu "COMMUNICATION" $apps 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $apps.Count; $i++) {
                Install-App $appIds[$i] $apps[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            Install-App $appIds[$index] $apps[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-GamingInstaller {
    $apps = @("Steam", "Epic Games", "Ubisoft", "EA App", "GOG Galaxy", "Battle.net")
    $appIds = @(
        "Valve.Steam", "EpicGames.EpicGamesLauncher", "Ubisoft.Connect",
        "ElectronicArts.EADesktop", "GOG.Galaxy", "Battle.net"
    )
    
    while ($true) {
        Show-GridMenu "GAMING" $apps 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $apps.Count; $i++) {
                Install-App $appIds[$i] $apps[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            Install-App $appIds[$index] $apps[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-MicrosoftInstaller {
    $apps = @("Windows Terminal", "PowerToys", "Office", "Store", "Whiteboard", "Calculator")
    $appIds = @(
        "Microsoft.WindowsTerminal", "Microsoft.PowerToys", "Microsoft.Office",
        "Microsoft.Store", "Microsoft.Whiteboard", "Microsoft.WindowsCalculator"
    )
    
    while ($true) {
        Show-GridMenu "MICROSOFT" $apps 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $apps.Count; $i++) {
                Install-App $appIds[$i] $apps[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            Install-App $appIds[$index] $apps[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-MediaInstaller {
    $apps = @("VLC", "OBS Studio", "Handbrake", "Spotify", "Audacity", "Kodi")
    $appIds = @(
        "VideoLAN.VLC", "OBSProject.OBSStudio", "HandBrake.HandBrake",
        "Spotify.Spotify", "Audacity.Audacity", "XBMCFoundation.Kodi"
    )
    
    while ($true) {
        Show-GridMenu "MEDIA" $apps 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $apps.Count; $i++) {
                Install-App $appIds[$i] $apps[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            Install-App $appIds[$index] $apps[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-ProductivityInstaller {
    $tools = @("Obsidian", "Notion", "AnyDesk", "TeamViewer", "Evernote", "Trello")
    $toolIds = @(
        "Obsidian.Obsidian", "Notion.Notion", "AnyDeskSoftwareGmbH.AnyDesk",
        "TeamViewer.TeamViewer", "Evernote.Evernote", "Trello.Trello"
    )
    
    while ($true) {
        Show-GridMenu "PRODUCTIVITY" $tools 3
        
        Write-Host (Center-Text "Enter selection: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│         MASS INSTALLATION STARTED          │") -ForegroundColor Yellow
            Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor Yellow
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Install-App $toolIds[$i] $tools[$i]
            }
            continue
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Install-App $toolIds[$index] $tools[$index]
        } else {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid selection!          ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-AppsInstaller {
    while ($true) {
        Show-CategoriesMenu
        
        Write-Host (Center-Text "Select category: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        switch ($choice) {
            "1" { Invoke-BrowsersInstaller }
            "2" { Invoke-FileToolsInstaller }
            "3" { Invoke-DevToolsInstaller }
            "4" { Invoke-DotNetInstaller }
            "5" { Invoke-CommunicationInstaller }
            "6" { Invoke-GamingInstaller }
            "7" { Invoke-MicrosoftInstaller }
            "8" { Invoke-MediaInstaller }
            "9" { Invoke-ProductivityInstaller }
            "0" { return }
            default {
                Write-Host ""
                Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
                Write-Host (Center-Text "║        ✗ Invalid category!           ║") -ForegroundColor Red
                Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
                Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
    }
}

function Invoke-FullFixOsPreset {
    Clear-Host
    Show-FixOsLogo

    Write-Host (Center-Text "┌──────────────────────────────────────────────────┐") -ForegroundColor Magenta
    Write-Host (Center-Text "│              FIXOS PRESET                        │") -ForegroundColor Yellow
    Write-Host (Center-Text "├──────────────────────────────────────────────────┤") -ForegroundColor Magenta
    Write-Host (Center-Text "│  This will run the complete FixOs installer      │") -ForegroundColor White
    Write-Host (Center-Text "│  - System optimization                           │") -ForegroundColor White
    Write-Host (Center-Text "│  - Bloatware removal                             │") -ForegroundColor White
    Write-Host (Center-Text "│  - Performance tweaks                            │") -ForegroundColor White
    Write-Host (Center-Text "└──────────────────────────────────────────────────┘") -ForegroundColor Magenta
    
    Write-Host ""
    Write-Host (Center-Text "Continue? [Y/N]: ") -NoNewline -ForegroundColor Magenta
    $confirm = Read-Host
    
    if ($confirm -ne "Y" -and $confirm -ne "y") { return }
    
    Write-Host ""
    Write-Host (Center-Text "► Running FixOs...") -ForegroundColor Yellow
    
    try {
        irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
        Write-Host ""
        Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Green
        Write-Host (Center-Text "║     ✓ FixOs executed successfully!   ║") -ForegroundColor Green
        Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "║     ✗ Error running FixOs            ║") -ForegroundColor Red
        Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host (Center-Text "► FixOs preset completed") -ForegroundColor Green
    Write-Host ""
    Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Initialize-Toolbox

while ($true) {
    Show-MainMenu
    
    Write-Host (Center-Text "Enter choice [1-3]: ") -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Invoke-AppsInstaller }
        "2" { Invoke-FullFixOsPreset }
        "3" { 
            Clear-Host
            Show-FixOsLogo
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Green
            Write-Host (Center-Text "║     Thank you for using FixOs!       ║") -ForegroundColor Green
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Green
            Write-Host ""
            Exit 0
        }
        default {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        ✗ Invalid option!             ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}
