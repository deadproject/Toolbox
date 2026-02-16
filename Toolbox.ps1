$ToolboxConfig = @{
    Version = "2.0.0"
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
    
    foreach ($line in $logoLines) {
        $coloredLine = ""
        $chars = $line.ToCharArray()
        for ($i = 0; $i -lt $chars.Count; $i++) {
            $colorIndex = $i % $colors.Count
            $coloredLine += "$($chars[$i])"
        }
        Write-Host (Center-Text $coloredLine) -ForegroundColor $colors[$i % $colors.Count]
    }
    
    $versionLine = "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
    Write-Host (Center-Text $versionLine) -ForegroundColor DarkGray
    Write-Host (Center-Text "        T O O L B O X   v$($ToolboxConfig.Version)        ") -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host (Center-Text $versionLine) -ForegroundColor DarkGray
    Write-Host ""
}

function Initialize-Toolbox {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host (Center-Text "╔════════════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "║  X Toolbox requires Administrator privileges ║") -ForegroundColor Red
        Write-Host (Center-Text "║     Please run as Administrator. Exiting...  ║") -ForegroundColor Red
        Write-Host (Center-Text "╚════════════════════════════════════════════╝") -ForegroundColor Red
        Exit 1
    }
    
    Clear-Host
    Show-FixOsLogo
    
    $statusLine = ">> System Check: [████████████████████] 100% - ADMIN ACCESS GRANTED"
    Write-Host (Center-Text $statusLine) -ForegroundColor Green
    Write-Host (Center-Text ">> Initialized at $(Get-Date -Format 'HH:mm:ss')") -ForegroundColor Cyan
    Write-Host ""
    Start-Sleep -Seconds 1.5
}

function Show-MainMenu {
    Clear-Host
    Show-FixOsLogo
    
    $menuOptions = @(
        "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓",
        "┃                 >> CONTROL PANEL <<                 ┃",
        "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫",
        "┃                                                     ┃",
        "┃          ███╗   ███╗ █████╗ ██╗███╗   ██╗          ┃",
        "┃          ████╗ ████║██╔══██╗██║████╗  ██║          ┃",
        "┃          ██╔████╔██║███████║██║██╔██╗ ██║          ┃",
        "┃          ██║╚██╔╝██║██╔══██║██║██║╚██╗██║          ┃",
        "┃          ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║          ┃",
        "┃          ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝          ┃",
        "┃                                                     ┃",
        "┃                 ╔══════════════════╗               ┃",
        "┃                 ║  [1] APP INSTALL ║               ┃",
        "┃                 ║  [2] FIXOS CORE  ║               ┃",
        "┃                 ║  [3] SYSTEM EXIT ║               ┃",
        "┃                 ╚══════════════════╝               ┃",
        "┃                                                     ┃",
        "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    )
    
    foreach ($line in $menuOptions) {
        if ($line -match "CONTROL PANEL") {
            Write-Host (Center-Text $line) -ForegroundColor Yellow
        } elseif ($line -match "╔|╚|╣|╠|┏|┓|┗|┛|━|┃") {
            Write-Host (Center-Text $line) -ForegroundColor DarkCyan
        } elseif ($line -match "█") {
            Write-Host (Center-Text $line) -ForegroundColor Cyan
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
        Write-Host (Center-Text "│      >> DEPLOYING: $($appName.ToUpper())") -ForegroundColor Yellow
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
            $progressBar = "[" + ("▓" * ($i % 10)) + ("░" * (10 - ($i % 10))) + "]"
            Write-Host (Center-Text "  $($frames[$i % 4]) $progressBar Installing... $elapsed s") -ForegroundColor Cyan -NoNewline
            Start-Sleep -Milliseconds 150
            Write-Host "`r" -NoNewline
            $i++
        }
        
        $result = Receive-Job -Job $job
        Remove-Job -Job $job -Force
        
        Write-Host ""
        Write-Host (Center-Text "  ╔══════════════════════════════════════╗") -ForegroundColor Green
        Write-Host (Center-Text "  ║  >> $appName INSTALLED!               ║") -ForegroundColor Green
        Write-Host (Center-Text "  ╚══════════════════════════════════════╝") -ForegroundColor Green
        
    } catch {
        Write-Host ""
        Write-Host (Center-Text "  ╔══════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "  ║  X ERROR: $appName FAILED            ║") -ForegroundColor Red
        Write-Host (Center-Text "  ╚══════════════════════════════════════╝") -ForegroundColor Red
    }
    Write-Host ""
    Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-GridMenu($title, $options, $gridColumns = 3) {
    Clear-Host
    Show-FixOsLogo
    
    $border = "═" * 60
    Write-Host (Center-Text "╔$border╗") -ForegroundColor Magenta
    Write-Host (Center-Text ("║" + " " * 60 + "║")) -ForegroundColor Magenta
    Write-Host (Center-Text ("║" + " " * ((60 - $title.Length) / 2) + $title + " " * ((60 - $title.Length) / 2) + "║")) -ForegroundColor White
    Write-Host (Center-Text ("║" + " " * 60 + "║")) -ForegroundColor Magenta
    Write-Host (Center-Text "╚$border╝") -ForegroundColor Magenta
    Write-Host ""
    
    $maxLength = ($options | Measure-Object -Property Length -Maximum).Maximum + 8
    $colWidth = $maxLength + 6
    
    for ($i = 0; $i -lt $options.Count; $i += $gridColumns) {
        $line = ""
        for ($j = 0; $j -lt $gridColumns; $j++) {
            $index = $i + $j
            if ($index -lt $options.Count) {
                $optionNum = $index + 1
                $optionText = "[$optionNum] $($options[$index])"
                $line += $optionText.PadRight($colWidth)
            }
        }
        Write-Host (Center-Text "  " + $line.Trim()) -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host (Center-Text "════════════════════════════════════════════════════════") -ForegroundColor Gray
    Write-Host (Center-Text ">> [A] INSTALL ALL    |    [0] RETURN TO MAIN <<") -ForegroundColor Yellow
    Write-Host ""
}

function Show-CategoriesMenu {
    Clear-Host
    Show-FixOsLogo
    
    $header = @"
╔══════════════════════════════════════════════════════════╗
║                    ▄▄▄·  ▄▄▄· ▄▄▄  ▄▄▄ .                 ║
║                   ▐█ ▄█ ▐█ ▀█ ▀▄ █·▀▄.▀·                 ║
║                    ██▀· ▄█▀▀█ ▐▀▀▄ ▐▀▀▪▄                 ║
║                   ▐█▪·•▐█ ▪▐▌▐█•█▌▐█▄▄▌                 ║
║                   .▀    ▀  ▀ .▀  ▀ ▀▀▀                  ║
║                  APPLICATION CATEGORIES                  ║
╚══════════════════════════════════════════════════════════╝
"@
    
    $headerLines = $header -split "`n"
    foreach ($line in $headerLines) {
        if ($line -match "▄|▀|·|▪") {
            Write-Host (Center-Text $line) -ForegroundColor DarkCyan
        } else {
            Write-Host (Center-Text $line) -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    
    $categories = @(
        "┌─────────────────────┬─────────────────────┬─────────────────────┐",
        "│  [01] BROWSERS      │  [02] FILE TOOLS    │  [03] DEV TOOLS     │",
        "│  [04] .NET TOOLS    │  [05] COMMUNICATION │  [06] GAMING APPS   │",
        "│  [07] MICROSOFT     │  [08] MEDIA APPS    │  [09] PRODUCTIVITY  │",
        "└─────────────────────┴─────────────────────┴─────────────────────┘"
    )
    
    foreach ($line in $categories) {
        if ($line -match "┌|┐|└|┘|─|┬|┴") {
            Write-Host (Center-Text $line) -ForegroundColor DarkGray
        } else {
            Write-Host (Center-Text $line) -ForegroundColor White
        }
    }
    Write-Host ""
    Write-Host (Center-Text "╔══════════════════════════════════════════════════════╗") -ForegroundColor Gray
    Write-Host (Center-Text "║  SELECT CATEGORY [1-9] OR [0] FOR MAIN MENU        ║") -ForegroundColor Cyan
    Write-Host (Center-Text "╚══════════════════════════════════════════════════════╝") -ForegroundColor Gray
    Write-Host ""
}

function Invoke-BrowsersInstaller {
    $browsers = @(
        "GOOGLE CHROME", "BRAVE", "FIREFOX",
        "EDGE", "THORIUM", "WATERFOX",
        "LIBREWOLF", "FLOORP", "OPERA"
    )
    
    $browserIds = @(
        "Google.Chrome", "Brave.Brave", "Mozilla.Firefox",
        "Microsoft.Edge", "Alex313031.Thorium", "Waterfox.Waterfox",
        "LibreWolf.LibreWolf", "Floorp.Floorp", "Opera.Opera"
    )
    
    while ($true) {
        Show-GridMenu ">> WEB BROWSERS <<" $browsers 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-FileToolsInstaller {
    $tools = @("WINRAR", "7-ZIP", "PEAZIP", "WINSCP", "FILEZILLA")
    $toolIds = @("RARLab.WinRAR", "7zip.7zip", "PeaZip.PeaZip", "WinSCP.WinSCP", "FileZilla.FileZilla")
    
    while ($true) {
        Show-GridMenu ">> FILE MANAGEMENT <<" $tools 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-DevToolsInstaller {
    $tools = @(
        "VS CODE", "NOTEPAD++", "SUBLIME",
        "GIT", "GITHUB DESKTOP", "POWERSHELL 7",
        "DOCKER", "PYTHON", "NODE.JS"
    )
    
    $toolIds = @(
        "Microsoft.VisualStudioCode", "Notepad++.Notepad++", "SublimeHQ.SublimeText",
        "Git.Git", "GitHub.GitHubDesktop", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Python.Python.3.12", "OpenJS.NodeJS"
    )
    
    while ($true) {
        Show-GridMenu ">> DEVELOPMENT TOOLS <<" $tools 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-CommunicationInstaller {
    $apps = @("TELEGRAM", "DISCORD", "WHATSAPP", "SLACK", "ZOOM", "SIGNAL")
    $appIds = @(
        "Telegram.TelegramDesktop", "Discord.Discord", "WhatsApp.WhatsApp",
        "SlackTechnologies.Slack", "Zoom.Zoom", "OpenWhisperSystems.Signal"
    )
    
    while ($true) {
        Show-GridMenu ">> COMMUNICATION <<" $apps 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-GamingInstaller {
    $apps = @("STEAM", "EPIC GAMES", "UBISOFT", "EA APP", "GOG GALAXY", "BATTLENET")
    $appIds = @(
        "Valve.Steam", "EpicGames.EpicGamesLauncher", "Ubisoft.Connect",
        "ElectronicArts.EADesktop", "GOG.Galaxy", "Battle.net"
    )
    
    while ($true) {
        Show-GridMenu ">> GAMING <<" $apps 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-MediaInstaller {
    $apps = @("VLC", "OBS STUDIO", "HANDBRAKE", "SPOTIFY", "AUDACITY", "KODI")
    $appIds = @(
        "VideoLAN.VLC", "OBSProject.OBSStudio", "HandBrake.HandBrake",
        "Spotify.Spotify", "Audacity.Audacity", "XBMCFoundation.Kodi"
    )
    
    while ($true) {
        Show-GridMenu ">> MEDIA <<" $apps 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-ProductivityInstaller {
    $tools = @("OBSIDIAN", "NOTION", "ANYDESK", "TEAMVIEWER", "EVERNOTE", "TRELLO")
    $toolIds = @(
        "Obsidian.Obsidian", "Notion.Notion", "AnyDeskSoftwareGmbH.AnyDesk",
        "TeamViewer.TeamViewer", "Evernote.Evernote", "Trello.Trello"
    )
    
    while ($true) {
        Show-GridMenu ">> PRODUCTIVITY <<" $tools 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-DotNetInstaller {
    $tools = @(".NET SDK 8", ".NET RUNTIME 8", ".NET DESKTOP 8", ".NET SDK 7", ".NET RUNTIME 7", ".NET SDK 6")
    $toolIds = @(
        "Microsoft.DotNet.SDK.8", "Microsoft.DotNet.Runtime.8", "Microsoft.DotNet.DesktopRuntime.8",
        "Microsoft.DotNet.SDK.7", "Microsoft.DotNet.Runtime.7", "Microsoft.DotNet.SDK.6"
    )
    
    while ($true) {
        Show-GridMenu ">> .NET FRAMEWORK <<" $tools 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-MicrosoftInstaller {
    $apps = @("WINDOWS TERMINAL", "POWERTOYS", "OFFICE", "STORE", "WHITEBOARD", "CALCULATOR")
    $appIds = @(
        "Microsoft.WindowsTerminal", "Microsoft.PowerToys", "Microsoft.Office",
        "Microsoft.Store", "Microsoft.Whiteboard", "Microsoft.WindowsCalculator"
    )
    
    while ($true) {
        Show-GridMenu ">> MICROSOFT <<" $apps 3
        
        Write-Host (Center-Text ">> ENTER SELECTION: ") -NoNewline -ForegroundColor Cyan
        $choice = Read-Host
        
        if ($choice -eq "0") { return }
        if ($choice -eq "A" -or $choice -eq "a") {
            Write-Host ""
            Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor Yellow
            Write-Host (Center-Text "│      >> MASS DEPLOYMENT INITIATED           │") -ForegroundColor Yellow
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
            Write-Host (Center-Text "║     X INVALID SELECTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Invoke-AppsInstaller {
    while ($true) {
        Show-CategoriesMenu
        
        Write-Host (Center-Text ">> SELECT CATEGORY: ") -NoNewline -ForegroundColor Cyan
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
                Write-Host (Center-Text "║        X INVALID OPTION              ║") -ForegroundColor Red
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

    Write-Host (Center-Text "┌────────────────────────────────────────────┐") -ForegroundColor White
    Write-Host (Center-Text "│  >> This will run FixOs installer          │") -ForegroundColor White
    Write-Host (Center-Text "└────────────────────────────────────────────┘") -ForegroundColor White
    
    Write-Host (Center-Text "Continue? [Y/N]: ") -NoNewline -ForegroundColor Magenta
    $confirm = Read-Host
    
    if ($confirm -ne "Y" -and $confirm -ne "y") { return }
    
    Write-Host ""
    Write-Host (Center-Text ">> Running FixOs...") -ForegroundColor Yellow
    
    try {
        irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
        Write-Host ""
        Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Green
        Write-Host (Center-Text "║  >> FixOs executed successfully!     ║") -ForegroundColor Green
        Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
        Write-Host (Center-Text "║  X Error running FixOs               ║") -ForegroundColor Red
        Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host (Center-Text ">> FixOs preset completed") -ForegroundColor Green
    Write-Host ""
    Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Initialize-Toolbox

while ($true) {
    Show-MainMenu
    
    Write-Host (Center-Text ">> ENTER CHOICE [1-3]: ") -NoNewline -ForegroundColor Cyan
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Invoke-AppsInstaller }
        "2" { Invoke-FullFixOsPreset }
        "3" { 
            Clear-Host
            Show-FixOsLogo
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Green
            Write-Host (Center-Text "║     >> FIXOS TOOLBOX EXITED <<       ║") -ForegroundColor Green
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Green
            Write-Host ""
            Exit 0
        }
        default {
            Write-Host ""
            Write-Host (Center-Text "╔══════════════════════════════════════╗") -ForegroundColor Red
            Write-Host (Center-Text "║        X INVALID OPTION              ║") -ForegroundColor Red
            Write-Host (Center-Text "╚══════════════════════════════════════╝") -ForegroundColor Red
            Write-Host (Center-Text "Press any key to continue...") -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}
