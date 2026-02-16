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
$form.BackColor = "#0a0f1f"
$form.ForeColor = "#ffffff"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Height = 40
$titleBar.Dock = "Top"
$titleBar.BackColor = "#0a0f1f"

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "×"
$closeBtn.Size = New-Object System.Drawing.Size(40, 40)
$closeBtn.Location = New-Object System.Drawing.Point(1150, 0)
$closeBtn.FlatStyle = "Flat"
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.BackColor = "#0a0f1f"
$closeBtn.ForeColor = "#ffffff"
$closeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 20)
$closeBtn.Cursor = "Hand"
$closeBtn.Add_Click({ $form.Close() })
$titleBar.Controls.Add($closeBtn)

$form.Controls.Add($titleBar)

$mainContainer = New-Object System.Windows.Forms.Panel
$mainContainer.Location = New-Object System.Drawing.Point(40, 60)
$mainContainer.Size = New-Object System.Drawing.Size(1120, 720)
$mainContainer.BackColor = "#1a2332"
$form.Controls.Add($mainContainer)

function Show-Logo {
    $logoBox = New-Object System.Windows.Forms.PictureBox
    $logoBox.Size = New-Object System.Drawing.Size(600, 200)
    $logoBox.Location = New-Object System.Drawing.Point(260, 30)
    
    $logoText = @"
    ███████╗██╗██╗  ██╗  ██████╗ ███████╗
    ██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
    █████╗  ██║ ╚███╔╝  ██║   ██║███████╗
    ██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
    ██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
    ╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
    
                    T O O L B O X   v$($ToolboxConfig.Version)
"@
    
    $logoLabel = New-Object System.Windows.Forms.Label
    $logoLabel.Text = $logoText
    $logoLabel.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
    $logoLabel.ForeColor = "#4a9eff"
    $logoLabel.Size = $logoBox.Size
    $logoLabel.Location = New-Object System.Drawing.Point(0, 0)
    $logoLabel.TextAlign = "MiddleCenter"
    
    $logoBox.Controls.Add($logoLabel)
    return $logoBox
}

$logo = Show-Logo
$mainContainer.Controls.Add($logo)

$menuPanel = New-Object System.Windows.Forms.Panel
$menuPanel.Size = New-Object System.Drawing.Size(400, 300)
$menuPanel.Location = New-Object System.Drawing.Point(360, 250)
$menuPanel.BackColor = "#1f2a3a"

$appsBtn = New-Object System.Windows.Forms.Button
$appsBtn.Text = "APPS INSTALLER"
$appsBtn.Size = New-Object System.Drawing.Size(320, 70)
$appsBtn.Location = New-Object System.Drawing.Point(40, 30)
$appsBtn.BackColor = "#4a9eff"
$appsBtn.ForeColor = "#ffffff"
$appsBtn.FlatStyle = "Flat"
$appsBtn.FlatAppearance.BorderSize = 0
$appsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$appsBtn.Cursor = "Hand"

$fixosBtn = New-Object System.Windows.Forms.Button
$fixosBtn.Text = "RUN FIXOS PRESET"
$fixosBtn.Size = New-Object System.Drawing.Size(320, 70)
$fixosBtn.Location = New-Object System.Drawing.Point(40, 110)
$fixosBtn.BackColor = "#1f2a3a"
$fixosBtn.ForeColor = "#ffffff"
$fixosBtn.FlatStyle = "Flat"
$fixosBtn.FlatAppearance.BorderColor = "#4a9eff"
$fixosBtn.FlatAppearance.BorderSize = 2
$fixosBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$fixosBtn.Cursor = "Hand"

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "EXIT"
$exitBtn.Size = New-Object System.Drawing.Size(320, 70)
$exitBtn.Location = New-Object System.Drawing.Point(40, 190)
$exitBtn.BackColor = "#1f2a3a"
$exitBtn.ForeColor = "#ffffff"
$exitBtn.FlatStyle = "Flat"
$exitBtn.FlatAppearance.BorderColor = "#4a9eff"
$exitBtn.FlatAppearance.BorderSize = 2
$exitBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$exitBtn.Cursor = "Hand"
$exitBtn.Add_Click({ $form.Close() })

$menuPanel.Controls.AddRange(@($appsBtn, $fixosBtn, $exitBtn))
$mainContainer.Controls.Add($menuPanel)

$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Size = New-Object System.Drawing.Size(1120, 40)
$statusBar.Location = New-Object System.Drawing.Point(0, 680)
$statusBar.BackColor = "#0a0f1f"

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.Size = New-Object System.Drawing.Size(300, 30)
$statusLabel.Location = New-Object System.Drawing.Point(20, 5)
$statusLabel.ForeColor = "#4a9eff"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$statusBar.Controls.Add($statusLabel)
$mainContainer.Controls.Add($statusBar)

$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Size = New-Object System.Drawing.Size(1080, 400)
$contentPanel.Location = New-Object System.Drawing.Point(20, 220)
$contentPanel.BackColor = "#1f2a3a"
$contentPanel.AutoScroll = $true
$contentPanel.Visible = $false
$mainContainer.Controls.Add($contentPanel)

$backBtn = New-Object System.Windows.Forms.Button
$backBtn.Text = "← BACK"
$backBtn.Size = New-Object System.Drawing.Size(80, 30)
$backBtn.Location = New-Object System.Drawing.Point(20, 180)
$backBtn.BackColor = "#1f2a3a"
$backBtn.ForeColor = "#ffffff"
$backBtn.FlatStyle = "Flat"
$backBtn.FlatAppearance.BorderColor = "#4a9eff"
$backBtn.FlatAppearance.BorderSize = 1
$backBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$backBtn.Cursor = "Hand"
$backBtn.Visible = $false
$mainContainer.Controls.Add($backBtn)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(400, 20)
$progressBar.Location = New-Object System.Drawing.Point(360, 650)
$progressBar.Style = "Continuous"
$progressBar.ForeColor = "#4a9eff"
$progressBar.BackColor = "#1f2a3a"
$progressBar.Value = 0
$progressBar.Visible = $false
$mainContainer.Controls.Add($progressBar)

function Install-App {
    param($appId, $appName, $total, $current)
    
    $statusLabel.Text = "Installing $appName... ($current/$total)"
    $form.Refresh()
    
    $process = Start-Process -FilePath "winget" -ArgumentList "install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        $statusLabel.Text = "✓ $appName installed successfully"
        $statusLabel.ForeColor = "#4a9eff"
    } else {
        $statusLabel.Text = "✗ Failed to install $appName"
        $statusLabel.ForeColor = "#ff4a4a"
    }
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    $statusLabel.ForeColor = "#4a9eff"
}

function Show-Categories {
    $contentPanel.Visible = $true
    $backBtn.Visible = $true
    $menuPanel.Visible = $false
    $logo.Visible = $false
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "SELECT CATEGORY"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#ffffff"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(340, 10)
    $contentPanel.Controls.Add($title)
    
    $categories = @(
        @{Name="BROWSERS"; X=80; Y=60; Apps=@("Google Chrome","Brave","Firefox","Edge","Thorium","Waterfox","LibreWolf","Floorp"); Ids=@("Google.Chrome","Brave.Brave","Mozilla.Firefox","Microsoft.Edge","Alex313031.Thorium","Waterfox.Waterfox","LibreWolf.LibreWolf","Floorp.Floorp")}
        @{Name="FILE TOOLS"; X=440; Y=60; Apps=@("WinRAR","7-Zip"); Ids=@("RARLab.WinRAR","7zip.7zip")}
        @{Name="DEV TOOLS"; X=800; Y=60; Apps=@("VS Code","Notepad++","Sublime Text","Git","GitHub Desktop","PowerShell 7","Docker"); Ids=@("Microsoft.VisualStudioCode","Notepad++.Notepad++","SublimeHQ.SublimeText","Git.Git","GitHub.GitHubDesktop","Microsoft.PowerShell","Docker.DockerDesktop")}
        @{Name=".NET TOOLS"; X=80; Y=140; Apps=@(".NET SDK 8",".NET Runtime 8",".NET Desktop 8",".NET SDK 7",".NET Runtime 7"); Ids=@("Microsoft.DotNet.SDK.8","Microsoft.DotNet.Runtime.8","Microsoft.DotNet.DesktopRuntime.8","Microsoft.DotNet.SDK.7","Microsoft.DotNet.Runtime.7")}
        @{Name="COMMUNICATION"; X=440; Y=140; Apps=@("Telegram","Discord","WhatsApp","Slack","Zoom"); Ids=@("Telegram.TelegramDesktop","Discord.Discord","WhatsApp.WhatsApp","SlackTechnologies.Slack","Zoom.Zoom")}
        @{Name="GAMING"; X=800; Y=140; Apps=@("Steam","Epic Games","Ubisoft","EA Desktop"); Ids=@("Valve.Steam","EpicGames.EpicGamesLauncher","Ubisoft.Connect","ElectronicArts.EADesktop")}
        @{Name="MICROSOFT"; X=80; Y=220; Apps=@("Windows Terminal","PowerToys","Microsoft Office","Microsoft Store"); Ids=@("Microsoft.WindowsTerminal","Microsoft.PowerToys","Microsoft.Office","Microsoft.Store")}
        @{Name="MEDIA"; X=440; Y=220; Apps=@("VLC","OBS Studio","Handbrake"); Ids=@("VideoLAN.VLC","OBSProject.OBSStudio","Handbrake.Handbrake")}
        @{Name="PRODUCTIVITY"; X=800; Y=220; Apps=@("Obsidian","Notion","AnyDesk","TeamViewer"); Ids=@("Obsidian.Obsidian","Notion.Notion","AnyDeskSoftwareGmbH.AnyDesk","TeamViewer.TeamViewer")}
    )
    
    foreach ($cat in $categories) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $cat.Name
        $btn.Size = New-Object System.Drawing.Size(280, 50)
        $btn.Location = New-Object System.Drawing.Point($cat.X, $cat.Y)
        $btn.BackColor = "#1f2a3a"
        $btn.ForeColor = "#ffffff"
        $btn.FlatStyle = "Flat"
        $btn.FlatAppearance.BorderColor = "#4a9eff"
        $btn.FlatAppearance.BorderSize = 1
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $btn.Cursor = "Hand"
        $btn.Tag = $cat
        $btn.Add_Click({
            $c = $this.Tag
            Show-AppGrid -title $c.Name -apps $c.Apps -ids $c.Ids
        })
        $contentPanel.Controls.Add($btn)
    }
    
    $backBtn.Add_Click({
        $contentPanel.Visible = $false
        $backBtn.Visible = $false
        $menuPanel.Visible = $true
        $logo.Visible = $true
        $statusLabel.Text = "Ready"
    })
}

function Show-AppGrid {
    param($title, $apps, $ids)
    
    $contentPanel.Controls.Clear()
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "$title APPLICATIONS"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = "#ffffff"
    $titleLabel.Size = New-Object System.Drawing.Size(400, 40)
    $titleLabel.Location = New-Object System.Drawing.Point(340, 10)
    $contentPanel.Controls.Add($titleLabel)
    
    $installAllBtn = New-Object System.Windows.Forms.Button
    $installAllBtn.Text = "INSTALL ALL"
    $installAllBtn.Size = New-Object System.Drawing.Size(120, 30)
    $installAllBtn.Location = New-Object System.Drawing.Point(900, 15)
    $installAllBtn.BackColor = "#4a9eff"
    $installAllBtn.ForeColor = "#ffffff"
    $installAllBtn.FlatStyle = "Flat"
    $installAllBtn.FlatAppearance.BorderSize = 0
    $installAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $installAllBtn.Cursor = "Hand"
    $installAllBtn.Add_Click({
        $progressBar.Visible = $true
        $total = $apps.Count
        for ($i = 0; $i -lt $total; $i++) {
            $percent = (($i + 1) / $total) * 100
            $progressBar.Value = $percent
            Install-App -appId $ids[$i] -appName $apps[$i] -total $total -current ($i + 1)
        }
        $progressBar.Visible = $false
        $statusLabel.Text = "All installations completed"
    })
    $contentPanel.Controls.Add($installAllBtn)
    
    $backToCategories = New-Object System.Windows.Forms.Button
    $backToCategories.Text = "← BACK"
    $backToCategories.Size = New-Object System.Drawing.Size(80, 30)
    $backToCategories.Location = New-Object System.Drawing.Point(20, 15)
    $backToCategories.BackColor = "#1f2a3a"
    $backToCategories.ForeColor = "#ffffff"
    $backToCategories.FlatStyle = "Flat"
    $backToCategories.FlatAppearance.BorderColor = "#4a9eff"
    $backToCategories.FlatAppearance.BorderSize = 1
    $backToCategories.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $backToCategories.Cursor = "Hand"
    $backToCategories.Add_Click({ Show-Categories })
    $contentPanel.Controls.Add($backToCategories)
    
    $x = 80
    $y = 70
    $col = 0
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $appPanel = New-Object System.Windows.Forms.Panel
        $appPanel.Size = New-Object System.Drawing.Size(280, 90)
        $appPanel.Location = New-Object System.Drawing.Point($x, $y)
        $appPanel.BackColor = "#0a0f1f"
        
        $appName = New-Object System.Windows.Forms.Label
        $appName.Text = $apps[$i]
        $appName.Size = New-Object System.Drawing.Size(260, 25)
        $appName.Location = New-Object System.Drawing.Point(10, 10)
        $appName.ForeColor = "#ffffff"
        $appName.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $appPanel.Controls.Add($appName)
        
        $installBtn = New-Object System.Windows.Forms.Button
        $installBtn.Text = "INSTALL"
        $installBtn.Size = New-Object System.Drawing.Size(100, 30)
        $installBtn.Location = New-Object System.Drawing.Point(90, 45)
        $installBtn.BackColor = "#4a9eff"
        $installBtn.ForeColor = "#ffffff"
        $installBtn.FlatStyle = "Flat"
        $installBtn.FlatAppearance.BorderSize = 0
        $installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $installBtn.Cursor = "Hand"
        $installBtn.Tag = @($ids[$i], $apps[$i])
        $installBtn.Add_Click({
            $tag = $this.Tag
            $progressBar.Visible = $true
            $progressBar.Value = 50
            Install-App -appId $tag[0] -appName $tag[1] -total 1 -current 1
            $progressBar.Value = 100
            Start-Sleep -Milliseconds 500
            $progressBar.Visible = $false
        })
        $appPanel.Controls.Add($installBtn)
        
        $contentPanel.Controls.Add($appPanel)
        
        $col++
        if ($col -eq 3) {
            $col = 0
            $x = 80
            $y += 110
        } else {
            $x += 300
        }
    }
}

function Show-FixOsPreset {
    $contentPanel.Visible = $true
    $backBtn.Visible = $true
    $menuPanel.Visible = $false
    $logo.Visible = $false
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "RUN FIXOS PRESET"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#ffffff"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(340, 50)
    $contentPanel.Controls.Add($title)
    
    $message = New-Object System.Windows.Forms.Label
    $message.Text = "This will execute the FixOs system optimization preset"
    $message.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $message.ForeColor = "#ffffff"
    $message.Size = New-Object System.Drawing.Size(400, 30)
    $message.Location = New-Object System.Drawing.Point(340, 120)
    $contentPanel.Controls.Add($message)
    
    $confirmPanel = New-Object System.Windows.Forms.Panel
    $confirmPanel.Size = New-Object System.Drawing.Size(400, 100)
    $confirmPanel.Location = New-Object System.Drawing.Point(340, 180)
    $confirmPanel.BackColor = "#0a0f1f"
    
    $question = New-Object System.Windows.Forms.Label
    $question.Text = "Continue with execution?"
    $question.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $question.ForeColor = "#ffffff"
    $question.Size = New-Object System.Drawing.Size(200, 30)
    $question.Location = New-Object System.Drawing.Point(100, 20)
    $confirmPanel.Controls.Add($question)
    
    $yesBtn = New-Object System.Windows.Forms.Button
    $yesBtn.Text = "YES"
    $yesBtn.Size = New-Object System.Drawing.Size(120, 35)
    $yesBtn.Location = New-Object System.Drawing.Point(70, 55)
    $yesBtn.BackColor = "#4a9eff"
    $yesBtn.ForeColor = "#ffffff"
    $yesBtn.FlatStyle = "Flat"
    $yesBtn.FlatAppearance.BorderSize = 0
    $yesBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $yesBtn.Cursor = "Hand"
    $yesBtn.Add_Click({
        $progressBar.Visible = $true
        $statusLabel.Text = "Running FixOs preset..."
        $form.Refresh()
        
        try {
            $progressBar.Value = 30
            irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
            $progressBar.Value = 100
            $statusLabel.Text = "FixOs executed successfully"
        } catch {
            $progressBar.Value = 0
            $statusLabel.Text = "Error running FixOs"
        }
        
        Start-Sleep -Milliseconds 1000
        $progressBar.Visible = $false
    })
    
    $noBtn = New-Object System.Windows.Forms.Button
    $noBtn.Text = "NO"
    $noBtn.Size = New-Object System.Drawing.Size(120, 35)
    $noBtn.Location = New-Object System.Drawing.Point(210, 55)
    $noBtn.BackColor = "#1f2a3a"
    $noBtn.ForeColor = "#ffffff"
    $noBtn.FlatStyle = "Flat"
    $noBtn.FlatAppearance.BorderColor = "#4a9eff"
    $noBtn.FlatAppearance.BorderSize = 1
    $noBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $noBtn.Cursor = "Hand"
    $noBtn.Add_Click({
        $contentPanel.Visible = $false
        $backBtn.Visible = $false
        $menuPanel.Visible = $true
        $logo.Visible = $true
        $statusLabel.Text = "Ready"
    })
    
    $confirmPanel.Controls.AddRange(@($yesBtn, $noBtn))
    $contentPanel.Controls.Add($confirmPanel)
    
    $backBtn.Add_Click({
        $contentPanel.Visible = $false
        $backBtn.Visible = $false
        $menuPanel.Visible = $true
        $logo.Visible = $true
        $statusLabel.Text = "Ready"
    })
}

$appsBtn.Add_Click({ Show-Categories })
$fixosBtn.Add_Click({ Show-FixOsPreset })

$form.ShowDialog()
