$ToolboxConfig = @{
    Version = "1.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
}

. "$PSScriptRoot\Core\Utilities.ps1"

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Toolbox requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit 1
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox v$($ToolboxConfig.Version)"
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0d1117"
$form.ForeColor = "#e6edf3"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

function Center-Text($text) {
    $width = $host.UI.RawUI.WindowSize.Width
    $textLength = $text.Length
    $padding = [math]::Max(0, ($width - $textLength) / 2)
    return (" " * [math]::Floor($padding)) + $text
}

function Show-FixOsLogo {
    $logoLines = @(
        " ███████╗██╗██╗  ██╗  ██████╗ ███████╗ ",
        " ██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝ ",
        " █████╗  ██║ ╚███╔╝  ██║   ██║███████╗ ",
        " ██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║ ",
        " ██║     ██║██╔╝ ██╗ ╚██████╔╝███████║ ",
        " ╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝ "
    )
    
    $logoLabel = New-Object System.Windows.Forms.Label
    $logoLabel.Text = [string]::Join([Environment]::NewLine, $logoLines)
    $logoLabel.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $logoLabel.ForeColor = "#2f81f7"
    $logoLabel.AutoSize = $true
    $logoLabel.Location = New-Object System.Drawing.Point(20, 20)
    return $logoLabel
}

function Install-App($appId, $appName, $outputBox) {
    try {
        $outputBox.Text = "Installing $appName..."
        $outputBox.ForeColor = "#d29922"
        $form.Refresh()
        
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            $outputBox.Text = "✓ $appName installed successfully"
            $outputBox.ForeColor = "#3fb950"
        } else {
            $outputBox.Text = "✗ Failed to install $appName"
            $outputBox.ForeColor = "#f85149"
        }
    } catch {
        $outputBox.Text = "✗ Error installing $appName"
        $outputBox.ForeColor = "#f85149"
    }
    $form.Refresh()
    Start-Sleep -Milliseconds 500
}

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.Padding = New-Object System.Windows.Forms.Padding(20)
$mainPanel.AutoScroll = $true

$logo = Show-FixOsLogo
$logo.Location = New-Object System.Drawing.Point(20, 20)
$mainPanel.Controls.Add($logo)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "TOOLBOX v$($ToolboxConfig.Version)"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$versionLabel.ForeColor = "#e6edf3"
$versionLabel.Size = New-Object System.Drawing.Size(200, 30)
$versionLabel.Location = New-Object System.Drawing.Point(900, 60)
$versionLabel.TextAlign = "MiddleRight"
$mainPanel.Controls.Add($versionLabel)

$menuPanel = New-Object System.Windows.Forms.Panel
$menuPanel.Location = New-Object System.Drawing.Point(20, 180)
$menuPanel.Size = New-Object System.Drawing.Size(1140, 60)

$appsBtn = New-Object System.Windows.Forms.Button
$appsBtn.Text = "APPS INSTALLER"
$appsBtn.Size = New-Object System.Drawing.Size(200, 50)
$appsBtn.Location = New-Object System.Drawing.Point(200, 5)
$appsBtn.BackColor = "#2f81f7"
$appsBtn.ForeColor = "White"
$appsBtn.FlatStyle = "Flat"
$appsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$appsBtn.Cursor = "Hand"

$fixosBtn = New-Object System.Windows.Forms.Button
$fixosBtn.Text = "RUN FIXOS PRESET"
$fixosBtn.Size = New-Object System.Drawing.Size(200, 50)
$fixosBtn.Location = New-Object System.Drawing.Point(450, 5)
$fixosBtn.BackColor = "#d29922"
$fixosBtn.ForeColor = "Black"
$fixosBtn.FlatStyle = "Flat"
$fixosBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fixosBtn.Cursor = "Hand"

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "EXIT"
$exitBtn.Size = New-Object System.Drawing.Size(200, 50)
$exitBtn.Location = New-Object System.Drawing.Point(700, 5)
$exitBtn.BackColor = "#f85149"
$exitBtn.ForeColor = "White"
$exitBtn.FlatStyle = "Flat"
$exitBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$exitBtn.Cursor = "Hand"

$menuPanel.Controls.AddRange(@($appsBtn, $fixosBtn, $exitBtn))
$mainPanel.Controls.Add($menuPanel)

$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Location = New-Object System.Drawing.Point(20, 260)
$contentPanel.Size = New-Object System.Drawing.Size(1140, 450)
$contentPanel.BackColor = "#161b22"
$contentPanel.AutoScroll = $true
$mainPanel.Controls.Add($contentPanel)

$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Location = New-Object System.Drawing.Point(20, 720)
$statusBox.Size = New-Object System.Drawing.Size(1140, 30)
$statusBox.ReadOnly = $true
$statusBox.BackColor = "#161b22"
$statusBox.ForeColor = "#3fb950"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$statusBox.Text = "Ready"
$mainPanel.Controls.Add($statusBox)

function Show-MainMenuUI {
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "SELECT AN OPTION"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#e6edf3"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(370, 20)
    $contentPanel.Controls.Add($title)
    
    $appsMainBtn = New-Object System.Windows.Forms.Button
    $appsMainBtn.Text = "APPS INSTALLER"
    $appsMainBtn.Size = New-Object System.Drawing.Size(300, 80)
    $appsMainBtn.Location = New-Object System.Drawing.Point(420, 100)
    $appsMainBtn.BackColor = "#2f81f7"
    $appsMainBtn.ForeColor = "White"
    $appsMainBtn.FlatStyle = "Flat"
    $appsMainBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $appsMainBtn.Cursor = "Hand"
    $appsMainBtn.Add_Click({
        Show-CategoriesUI
    })
    
    $fixosMainBtn = New-Object System.Windows.Forms.Button
    $fixosMainBtn.Text = "RUN FIXOS PRESET"
    $fixosMainBtn.Size = New-Object System.Drawing.Size(300, 80)
    $fixosMainBtn.Location = New-Object System.Drawing.Point(420, 200)
    $fixosMainBtn.BackColor = "#d29922"
    $fixosMainBtn.ForeColor = "Black"
    $fixosMainBtn.FlatStyle = "Flat"
    $fixosMainBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $fixosMainBtn.Cursor = "Hand"
    $fixosMainBtn.Add_Click({
        Invoke-FullFixOsPresetUI
    })
    
    $exitMainBtn = New-Object System.Windows.Forms.Button
    $exitMainBtn.Text = "EXIT"
    $exitMainBtn.Size = New-Object System.Drawing.Size(300, 80)
    $exitMainBtn.Location = New-Object System.Drawing.Point(420, 300)
    $exitMainBtn.BackColor = "#f85149"
    $exitMainBtn.ForeColor = "White"
    $exitMainBtn.FlatStyle = "Flat"
    $exitMainBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $exitMainBtn.Cursor = "Hand"
    $exitMainBtn.Add_Click({
        $form.Close()
    })
    
    $contentPanel.Controls.AddRange(@($appsMainBtn, $fixosMainBtn, $exitMainBtn))
}

function Show-CategoriesUI {
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "APP CATEGORIES MENU"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#e6edf3"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(370, 10)
    $contentPanel.Controls.Add($title)
    
    $backBtn = New-Object System.Windows.Forms.Button
    $backBtn.Text = "← BACK"
    $backBtn.Size = New-Object System.Drawing.Size(100, 30)
    $backBtn.Location = New-Object System.Drawing.Point(20, 10)
    $backBtn.BackColor = "#30363d"
    $backBtn.ForeColor = "#e6edf3"
    $backBtn.FlatStyle = "Flat"
    $backBtn.Cursor = "Hand"
    $backBtn.Add_Click({ Show-MainMenuUI })
    $contentPanel.Controls.Add($backBtn)
    
    $categories = @(
        @{Name="Browsers"; X=50; Y=70},
        @{Name="File Tools"; X=400; Y=70},
        @{Name="Dev Tools"; X=750; Y=70},
        @{Name=".NET Tools"; X=50; Y=190},
        @{Name="Communication"; X=400; Y=190},
        @{Name="Gaming Apps"; X=750; Y=190},
        @{Name="Microsoft Apps"; X=50; Y=310},
        @{Name="Media Apps"; X=400; Y=310},
        @{Name="Productivity"; X=750; Y=310}
    )
    
    foreach ($cat in $categories) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $cat.Name
        $btn.Size = New-Object System.Drawing.Size(300, 80)
        $btn.Location = New-Object System.Drawing.Point($cat.X, $cat.Y)
        $btn.BackColor = "#2d2d2d"
        $btn.ForeColor = "#e6edf3"
        $btn.FlatStyle = "Flat"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $btn.Cursor = "Hand"
        
        switch ($cat.Name) {
            "Browsers" { $btn.Add_Click({ Show-BrowsersUI }) }
            "File Tools" { $btn.Add_Click({ Show-FileToolsUI }) }
            "Dev Tools" { $btn.Add_Click({ Show-DevToolsUI }) }
            ".NET Tools" { $btn.Add_Click({ Show-DotNetUI }) }
            "Communication" { $btn.Add_Click({ Show-CommunicationUI }) }
            "Gaming Apps" { $btn.Add_Click({ Show-GamingUI }) }
            "Microsoft Apps" { $btn.Add_Click({ Show-MicrosoftUI }) }
            "Media Apps" { $btn.Add_Click({ Show-MediaUI }) }
            "Productivity" { $btn.Add_Click({ Show-ProductivityUI }) }
        }
        
        $contentPanel.Controls.Add($btn)
    }
}

function Show-AppGrid($title, $apps, $appIds) {
    $contentPanel.Controls.Clear()
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $title
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = "#e6edf3"
    $titleLabel.Size = New-Object System.Drawing.Size(500, 40)
    $titleLabel.Location = New-Object System.Drawing.Point(320, 10)
    $contentPanel.Controls.Add($titleLabel)
    
    $backBtn = New-Object System.Windows.Forms.Button
    $backBtn.Text = "← BACK"
    $backBtn.Size = New-Object System.Drawing.Size(100, 30)
    $backBtn.Location = New-Object System.Drawing.Point(20, 10)
    $backBtn.BackColor = "#30363d"
    $backBtn.ForeColor = "#e6edf3"
    $backBtn.FlatStyle = "Flat"
    $backBtn.Cursor = "Hand"
    $backBtn.Add_Click({ Show-CategoriesUI })
    $contentPanel.Controls.Add($backBtn)
    
    $installAllBtn = New-Object System.Windows.Forms.Button
    $installAllBtn.Text = "INSTALL ALL"
    $installAllBtn.Size = New-Object System.Drawing.Size(120, 30)
    $installAllBtn.Location = New-Object System.Drawing.Point(1000, 10)
    $installAllBtn.BackColor = "#d29922"
    $installAllBtn.ForeColor = "Black"
    $installAllBtn.FlatStyle = "Flat"
    $installAllBtn.Cursor = "Hand"
    $installAllBtn.Add_Click({
        for ($i = 0; $i -lt $apps.Count; $i++) {
            Install-App -appId $appIds[$i] -appName $apps[$i] -outputBox $statusBox
        }
    })
    $contentPanel.Controls.Add($installAllBtn)
    
    $x = 50
    $y = 70
    $col = 0
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Size = New-Object System.Drawing.Size(250, 100)
        $panel.Location = New-Object System.Drawing.Point($x, $y)
        $panel.BackColor = "#2d2d2d"
        $panel.BorderStyle = "FixedSingle"
        
        $nameLabel = New-Object System.Windows.Forms.Label
        $nameLabel.Text = $apps[$i]
        $nameLabel.Size = New-Object System.Drawing.Size(230, 30)
        $nameLabel.Location = New-Object System.Drawing.Point(10, 10)
        $nameLabel.ForeColor = "#e6edf3"
        $nameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $panel.Controls.Add($nameLabel)
        
        $installBtn = New-Object System.Windows.Forms.Button
        $installBtn.Text = "INSTALL"
        $installBtn.Size = New-Object System.Drawing.Size(100, 30)
        $installBtn.Location = New-Object System.Drawing.Point(70, 50)
        $installBtn.BackColor = "#2f81f7"
        $installBtn.ForeColor = "White"
        $installBtn.FlatStyle = "Flat"
        $installBtn.Cursor = "Hand"
        $installBtn.Tag = @($appIds[$i], $apps[$i])
        $installBtn.Add_Click({
            $tag = $this.Tag
            Install-App -appId $tag[0] -appName $tag[1] -outputBox $statusBox
        })
        $panel.Controls.Add($installBtn)
        
        $contentPanel.Controls.Add($panel)
        
        $col++
        if ($col -eq 4) {
            $col = 0
            $x = 50
            $y += 120
        } else {
            $x += 270
        }
    }
}

function Show-BrowsersUI {
    $browsers = @(
        "Google Chrome", "Brave Browser", "Mozilla Firefox",
        "Microsoft Edge", "Thorium Browser", "Waterfox",
        "LibreWolf", "Floorp Browser"
    )
    
    $browserIds = @(
        "Google.Chrome", "Brave.Brave", "Mozilla.Firefox",
        "Microsoft.Edge", "Alex313031.Thorium", "Waterfox.Waterfox",
        "LibreWolf.LibreWolf", "Floorp.Floorp"
    )
    
    Show-AppGrid "BROWSERS SELECTION" $browsers $browserIds
}

function Show-FileToolsUI {
    $tools = @("WinRAR", "7-Zip")
    $toolIds = @("RARLab.WinRAR", "7zip.7zip")
    Show-AppGrid "FILE TOOLS" $tools $toolIds
}

function Show-DevToolsUI {
    $tools = @(
        "VS Code", "Notepad++", "Sublime Text",
        "Git", "GitHub Desktop", "PowerShell 7", "Docker"
    )
    
    $toolIds = @(
        "Microsoft.VisualStudioCode", "Notepad++.Notepad++", "SublimeHQ.SublimeText",
        "Git.Git", "GitHub.GitHubDesktop", "Microsoft.PowerShell", "Docker.DockerDesktop"
    )
    
    Show-AppGrid "DEV TOOLS" $tools $toolIds
}

function Show-DotNetUI {
    $tools = @(".NET SDK 8", ".NET Runtime 8", ".NET Desktop 8", ".NET SDK 7", ".NET Runtime 7")
    $toolIds = @(
        "Microsoft.DotNet.SDK.8", "Microsoft.DotNet.Runtime.8", "Microsoft.DotNet.DesktopRuntime.8",
        "Microsoft.DotNet.SDK.7", "Microsoft.DotNet.Runtime.7"
    )
    
    Show-AppGrid ".NET TOOLS" $tools $toolIds
}

function Show-CommunicationUI {
    $apps = @("Telegram", "Discord", "WhatsApp", "Slack", "Zoom")
    $appIds = @(
        "Telegram.TelegramDesktop", "Discord.Discord", "WhatsApp.WhatsApp",
        "SlackTechnologies.Slack", "Zoom.Zoom"
    )
    
    Show-AppGrid "COMMUNICATION APPS" $apps $appIds
}

function Show-GamingUI {
    $apps = @("Steam", "Epic Games", "Ubisoft", "EA Desktop")
    $appIds = @(
        "Valve.Steam", "EpicGames.EpicGamesLauncher",
        "Ubisoft.Connect", "ElectronicArts.EADesktop"
    )
    
    Show-AppGrid "GAMING APPS" $apps $appIds
}

function Show-MicrosoftUI {
    $apps = @("Windows Terminal", "PowerToys", "Microsoft Office", "Microsoft Store")
    $appIds = @(
        "Microsoft.WindowsTerminal", "Microsoft.PowerToys",
        "Microsoft.Office", "Microsoft.Store"
    )
    
    Show-AppGrid "MICROSOFT APPS" $apps $appIds
}

function Show-MediaUI {
    $apps = @("VLC Player", "OBS Studio", "Handbrake")
    $appIds = @("VideoLAN.VLC", "OBSProject.OBSStudio", "Handbrake.Handbrake")
    
    Show-AppGrid "MEDIA APPS" $apps $appIds
}

function Show-ProductivityUI {
    $tools = @("Obsidian", "Notion", "AnyDesk", "TeamViewer")
    $toolIds = @(
        "Obsidian.Obsidian", "Notion.Notion",
        "AnyDeskSoftwareGmbH.AnyDesk", "TeamViewer.TeamViewer"
    )
    
    Show-AppGrid "PRODUCTIVITY TOOLS" $tools $toolIds
}

function Invoke-FullFixOsPresetUI {
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "RUN FIXOS PRESET"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#e6edf3"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(370, 50)
    $contentPanel.Controls.Add($title)
    
    $message = New-Object System.Windows.Forms.Label
    $message.Text = "This will run FixOs installer"
    $message.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $message.ForeColor = "#e6edf3"
    $message.Size = New-Object System.Drawing.Size(300, 30)
    $message.Location = New-Object System.Drawing.Point(420, 120)
    $contentPanel.Controls.Add($message)
    
    $confirmLabel = New-Object System.Windows.Forms.Label
    $confirmLabel.Text = "Continue?"
    $confirmLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $confirmLabel.ForeColor = "#e6edf3"
    $confirmLabel.Size = New-Object System.Drawing.Size(100, 30)
    $confirmLabel.Location = New-Object System.Drawing.Point(420, 170)
    $contentPanel.Controls.Add($confirmLabel)
    
    $yesBtn = New-Object System.Windows.Forms.Button
    $yesBtn.Text = "YES"
    $yesBtn.Size = New-Object System.Drawing.Size(100, 40)
    $yesBtn.Location = New-Object System.Drawing.Point(520, 165)
    $yesBtn.BackColor = "#3fb950"
    $yesBtn.ForeColor = "Black"
    $yesBtn.FlatStyle = "Flat"
    $yesBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $yesBtn.Cursor = "Hand"
    $yesBtn.Add_Click({
        $statusBox.Text = "Running FixOs..."
        $statusBox.ForeColor = "#d29922"
        $form.Refresh()
        
        try {
            irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
            $statusBox.Text = "FixOs executed successfully!"
            $statusBox.ForeColor = "#3fb950"
        } catch {
            $statusBox.Text = "Error running FixOs"
            $statusBox.ForeColor = "#f85149"
        }
        
        $statusBox.Text = "FixOs preset completed"
    })
    
    $noBtn = New-Object System.Windows.Forms.Button
    $noBtn.Text = "NO"
    $noBtn.Size = New-Object System.Drawing.Size(100, 40)
    $noBtn.Location = New-Object System.Drawing.Point(630, 165)
    $noBtn.BackColor = "#f85149"
    $noBtn.ForeColor = "White"
    $noBtn.FlatStyle = "Flat"
    $noBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $noBtn.Cursor = "Hand"
    $noBtn.Add_Click({ Show-MainMenuUI })
    
    $contentPanel.Controls.AddRange(@($yesBtn, $noBtn))
    
    $backBtn = New-Object System.Windows.Forms.Button
    $backBtn.Text = "← BACK"
    $backBtn.Size = New-Object System.Drawing.Size(100, 30)
    $backBtn.Location = New-Object System.Drawing.Point(20, 20)
    $backBtn.BackColor = "#30363d"
    $backBtn.ForeColor = "#e6edf3"
    $backBtn.FlatStyle = "Flat"
    $backBtn.Cursor = "Hand"
    $backBtn.Add_Click({ Show-MainMenuUI })
    $contentPanel.Controls.Add($backBtn)
}

$appsBtn.Add_Click({ Show-CategoriesUI })
$fixosBtn.Add_Click({ Invoke-FullFixOsPresetUI })
$exitBtn.Add_Click({ $form.Close() })

Show-MainMenuUI

$form.Controls.Add($mainPanel)
$form.ShowDialog()
