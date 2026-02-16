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
$form.BackColor = "#0a1929"
$form.ForeColor = "#ffffff"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.FormBorderStyle = "None"

$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Height = 40
$titleBar.Dock = "Top"
$titleBar.BackColor = "#0a1929"

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "×"
$closeBtn.Size = New-Object System.Drawing.Size(40, 40)
$closeBtn.Location = New-Object System.Drawing.Point(1150, 0)
$closeBtn.FlatStyle = "Flat"
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.BackColor = "#0a1929"
$closeBtn.ForeColor = "#ffffff"
$closeBtn.Font = New-Object System.Drawing.Font("Segoe UI", 20)
$closeBtn.Cursor = "Hand"
$closeBtn.Add_Click({ $form.Close() })
$titleBar.Controls.Add($closeBtn)

$form.Controls.Add($titleBar)

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Location = New-Object System.Drawing.Point(20, 60)
$mainPanel.Size = New-Object System.Drawing.Size(1160, 720)
$mainPanel.BackColor = "#10243b"
$mainPanel.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $mainPanel.Width, $mainPanel.Height), 20))
$form.Controls.Add($mainPanel)

function Show-FixOsLogo {
    $logoLabel = New-Object System.Windows.Forms.Label
    $logoLabel.Text = @"
███████╗██╗██╗  ██╗  ██████╗ ███████╗
██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
█████╗  ██║ ╚███╔╝  ██║   ██║███████╗
██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
"@
    $logoLabel.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $logoLabel.ForeColor = "#ffffff"
    $logoLabel.Size = New-Object System.Drawing.Size(600, 150)
    $logoLabel.Location = New-Object System.Drawing.Point(280, 40)
    $logoLabel.TextAlign = "MiddleCenter"
    return $logoLabel
}

function Show-ToolboxLogo {
    $toolboxLabel = New-Object System.Windows.Forms.Label
    $toolboxLabel.Text = @"
████████╗ ██████╗  ██████╗ ██╗     ██████╗  ██████╗ ██╗  ██╗
╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔══██╗██╔═══██╗╚██╗██╔╝
   ██║   ██║   ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝ 
   ██║   ██║   ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗ 
   ██║   ╚██████╔╝╚██████╔╝███████╗██████╔╝╚██████╔╝██╔╝ ██╗
   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
"@
    $toolboxLabel.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $toolboxLabel.ForeColor = "#4a9eff"
    $toolboxLabel.Size = New-Object System.Drawing.Size(600, 150)
    $toolboxLabel.Location = New-Object System.Drawing.Point(280, 180)
    $toolboxLabel.TextAlign = "MiddleCenter"
    return $toolboxLabel
}

$logo = Show-FixOsLogo
$toolbox = Show-ToolboxLogo
$mainPanel.Controls.Add($logo)
$mainPanel.Controls.Add($toolbox)

$centerPanel = New-Object System.Windows.Forms.Panel
$centerPanel.Size = New-Object System.Drawing.Size(500, 300)
$centerPanel.Location = New-Object System.Drawing.Point(330, 350)
$centerPanel.BackColor = "#0a1929"
$centerPanel.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $centerPanel.Width, $centerPanel.Height), 15))

$appsBtn = New-Object System.Windows.Forms.Button
$appsBtn.Text = "APPS INSTALLER"
$appsBtn.Size = New-Object System.Drawing.Size(400, 60)
$appsBtn.Location = New-Object System.Drawing.Point(50, 40)
$appsBtn.BackColor = "#4a9eff"
$appsBtn.ForeColor = "#ffffff"
$appsBtn.FlatStyle = "Flat"
$appsBtn.FlatAppearance.BorderSize = 0
$appsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$appsBtn.Cursor = "Hand"
$appsBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $appsBtn.Width, $appsBtn.Height), 10))

$fixosBtn = New-Object System.Windows.Forms.Button
$fixosBtn.Text = "RUN FIXOS PRESET"
$fixosBtn.Size = New-Object System.Drawing.Size(400, 60)
$fixosBtn.Location = New-Object System.Drawing.Point(50, 120)
$fixosBtn.BackColor = "#1e3a6b"
$fixosBtn.ForeColor = "#ffffff"
$fixosBtn.FlatStyle = "Flat"
$fixosBtn.FlatAppearance.BorderSize = 0
$fixosBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$fixosBtn.Cursor = "Hand"
$fixosBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $fixosBtn.Width, $fixosBtn.Height), 10))

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "EXIT"
$exitBtn.Size = New-Object System.Drawing.Size(400, 60)
$exitBtn.Location = New-Object System.Drawing.Point(50, 200)
$exitBtn.BackColor = "#10243b"
$exitBtn.ForeColor = "#ffffff"
$exitBtn.FlatStyle = "Flat"
$exitBtn.FlatAppearance.BorderSize = 1
$exitBtn.FlatAppearance.BorderColor = "#4a9eff"
$exitBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$exitBtn.Cursor = "Hand"
$exitBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $exitBtn.Width, $exitBtn.Height), 10))
$exitBtn.Add_Click({ $form.Close() })

$centerPanel.Controls.AddRange(@($appsBtn, $fixosBtn, $exitBtn))
$mainPanel.Controls.Add($centerPanel)

$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Size = New-Object System.Drawing.Size(1160, 60)
$statusBar.Location = New-Object System.Drawing.Point(0, 660)
$statusBar.BackColor = "#0a1929"
$statusBar.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $statusBar.Width, $statusBar.Height), 15))

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(800, 20)
$progressBar.Location = New-Object System.Drawing.Point(180, 20)
$progressBar.Style = "Continuous"
$progressBar.ForeColor = "#4a9eff"
$progressBar.BackColor = "#10243b"
$progressBar.Value = 0

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.Size = New-Object System.Drawing.Size(200, 30)
$statusLabel.Location = New-Object System.Drawing.Point(20, 15)
$statusLabel.ForeColor = "#ffffff"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$statusBar.Controls.AddRange(@($progressBar, $statusLabel))
$mainPanel.Controls.Add($statusBar)

$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Size = New-Object System.Drawing.Size(1120, 400)
$contentPanel.Location = New-Object System.Drawing.Point(20, 220)
$contentPanel.BackColor = "#10243b"
$contentPanel.AutoScroll = $true
$contentPanel.Visible = $false
$mainPanel.Controls.Add($contentPanel)

$backBtn = New-Object System.Windows.Forms.Button
$backBtn.Text = "← BACK"
$backBtn.Size = New-Object System.Drawing.Size(100, 35)
$backBtn.Location = New-Object System.Drawing.Point(20, 20)
$backBtn.BackColor = "#1e3a6b"
$backBtn.ForeColor = "#ffffff"
$backBtn.FlatStyle = "Flat"
$backBtn.FlatAppearance.BorderSize = 0
$backBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$backBtn.Cursor = "Hand"
$backBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $backBtn.Width, $backBtn.Height), 8))
$backBtn.Visible = $false
$mainPanel.Controls.Add($backBtn)

function Update-Progress {
    param($Current, $Total, $Message)
    $percent = ($Current / $Total) * 100
    $progressBar.Value = $percent
    $statusLabel.Text = "$Message - $([math]::Round($percent, 0))%"
    $form.Refresh()
}

function Install-App {
    param($appId, $appName, $appList, $currentIndex, $totalApps)
    
    $statusLabel.Text = "Installing $appName..."
    $form.Refresh()
    
    $process = Start-Process -FilePath "winget" -ArgumentList "install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Update-Progress -Current $currentIndex -Total $totalApps -Message "Installed $appName"
    } else {
        $statusLabel.Text = "Failed to install $appName"
        $form.Refresh()
        Start-Sleep -Milliseconds 1000
    }
}

function Show-Categories {
    $contentPanel.Visible = $true
    $backBtn.Visible = $true
    $centerPanel.Visible = $false
    $logo.Visible = $false
    $toolbox.Visible = $false
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "SELECT CATEGORY"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#ffffff"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(360, 10)
    $contentPanel.Controls.Add($title)
    
    $categories = @(
        @{Name="BROWSERS"; X=100; Y=60},
        @{Name="FILE TOOLS"; X=450; Y=60},
        @{Name="DEV TOOLS"; X=800; Y=60},
        @{Name=".NET TOOLS"; X=100; Y=140},
        @{Name="COMMUNICATION"; X=450; Y=140},
        @{Name="GAMING APPS"; X=800; Y=140},
        @{Name="MICROSOFT APPS"; X=100; Y=220},
        @{Name="MEDIA APPS"; X=450; Y=220},
        @{Name="PRODUCTIVITY"; X=800; Y=220}
    )
    
    foreach ($cat in $categories) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $cat.Name
        $btn.Size = New-Object System.Drawing.Size(300, 60)
        $btn.Location = New-Object System.Drawing.Point($cat.X, $cat.Y)
        $btn.BackColor = "#1e3a6b"
        $btn.ForeColor = "#ffffff"
        $btn.FlatStyle = "Flat"
        $btn.FlatAppearance.BorderSize = 0
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $btn.Cursor = "Hand"
        $btn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $btn.Width, $btn.Height), 10))
        
        switch ($cat.Name) {
            "BROWSERS" { $btn.Add_Click({ Show-AppGrid "BROWSERS" @("Google Chrome","Brave","Firefox","Edge","Thorium","Waterfox","LibreWolf","Floorp") @("Google.Chrome","Brave.Brave","Mozilla.Firefox","Microsoft.Edge","Alex313031.Thorium","Waterfox.Waterfox","LibreWolf.LibreWolf","Floorp.Floorp") }) }
            "FILE TOOLS" { $btn.Add_Click({ Show-AppGrid "FILE TOOLS" @("WinRAR","7-Zip") @("RARLab.WinRAR","7zip.7zip") }) }
            "DEV TOOLS" { $btn.Add_Click({ Show-AppGrid "DEV TOOLS" @("VS Code","Notepad++","Sublime Text","Git","GitHub Desktop","PowerShell 7","Docker") @("Microsoft.VisualStudioCode","Notepad++.Notepad++","SublimeHQ.SublimeText","Git.Git","GitHub.GitHubDesktop","Microsoft.PowerShell","Docker.DockerDesktop") }) }
            ".NET TOOLS" { $btn.Add_Click({ Show-AppGrid ".NET TOOLS" @(".NET SDK 8",".NET Runtime 8",".NET Desktop 8",".NET SDK 7",".NET Runtime 7") @("Microsoft.DotNet.SDK.8","Microsoft.DotNet.Runtime.8","Microsoft.DotNet.DesktopRuntime.8","Microsoft.DotNet.SDK.7","Microsoft.DotNet.Runtime.7") }) }
            "COMMUNICATION" { $btn.Add_Click({ Show-AppGrid "COMMUNICATION" @("Telegram","Discord","WhatsApp","Slack","Zoom") @("Telegram.TelegramDesktop","Discord.Discord","WhatsApp.WhatsApp","SlackTechnologies.Slack","Zoom.Zoom") }) }
            "GAMING APPS" { $btn.Add_Click({ Show-AppGrid "GAMING APPS" @("Steam","Epic Games","Ubisoft","EA Desktop") @("Valve.Steam","EpicGames.EpicGamesLauncher","Ubisoft.Connect","ElectronicArts.EADesktop") }) }
            "MICROSOFT APPS" { $btn.Add_Click({ Show-AppGrid "MICROSOFT APPS" @("Windows Terminal","PowerToys","Microsoft Office","Microsoft Store") @("Microsoft.WindowsTerminal","Microsoft.PowerToys","Microsoft.Office","Microsoft.Store") }) }
            "MEDIA APPS" { $btn.Add_Click({ Show-AppGrid "MEDIA APPS" @("VLC Player","OBS Studio","Handbrake") @("VideoLAN.VLC","OBSProject.OBSStudio","Handbrake.Handbrake") }) }
            "PRODUCTIVITY" { $btn.Add_Click({ Show-AppGrid "PRODUCTIVITY" @("Obsidian","Notion","AnyDesk","TeamViewer") @("Obsidian.Obsidian","Notion.Notion","AnyDeskSoftwareGmbH.AnyDesk","TeamViewer.TeamViewer") }) }
        }
        
        $contentPanel.Controls.Add($btn)
    }
    
    $backBtn.Add_Click({
        $contentPanel.Visible = $false
        $backBtn.Visible = $false
        $centerPanel.Visible = $true
        $logo.Visible = $true
        $toolbox.Visible = $true
        $progressBar.Value = 0
        $statusLabel.Text = "Ready"
    })
}

function Show-AppGrid {
    param($title, $apps, $appIds)
    
    $contentPanel.Controls.Clear()
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $title
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = "#ffffff"
    $titleLabel.Size = New-Object System.Drawing.Size(400, 40)
    $titleLabel.Location = New-Object System.Drawing.Point(360, 10)
    $contentPanel.Controls.Add($titleLabel)
    
    $installAllBtn = New-Object System.Windows.Forms.Button
    $installAllBtn.Text = "INSTALL ALL"
    $installAllBtn.Size = New-Object System.Drawing.Size(150, 35)
    $installAllBtn.Location = New-Object System.Drawing.Point(900, 10)
    $installAllBtn.BackColor = "#4a9eff"
    $installAllBtn.ForeColor = "#ffffff"
    $installAllBtn.FlatStyle = "Flat"
    $installAllBtn.FlatAppearance.BorderSize = 0
    $installAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $installAllBtn.Cursor = "Hand"
    $installAllBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $installAllBtn.Width, $installAllBtn.Height), 8))
    $installAllBtn.Add_Click({
        $progressBar.Value = 0
        $total = $apps.Count
        for ($i = 0; $i -lt $total; $i++) {
            Install-App -appId $appIds[$i] -appName $apps[$i] -appList $apps -currentIndex ($i + 1) -totalApps $total
        }
        $statusLabel.Text = "All installations completed"
        $progressBar.Value = 100
    })
    $contentPanel.Controls.Add($installAllBtn)
    
    $x = 100
    $y = 60
    $col = 0
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Size = New-Object System.Drawing.Size(300, 100)
        $panel.Location = New-Object System.Drawing.Point($x, $y)
        $panel.BackColor = "#0a1929"
        $panel.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $panel.Width, $panel.Height), 10))
        
        $nameLabel = New-Object System.Windows.Forms.Label
        $nameLabel.Text = $apps[$i]
        $nameLabel.Size = New-Object System.Drawing.Size(280, 30)
        $nameLabel.Location = New-Object System.Drawing.Point(10, 10)
        $nameLabel.ForeColor = "#ffffff"
        $nameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $panel.Controls.Add($nameLabel)
        
        $installBtn = New-Object System.Windows.Forms.Button
        $installBtn.Text = "INSTALL"
        $installBtn.Size = New-Object System.Drawing.Size(120, 35)
        $installBtn.Location = New-Object System.Drawing.Point(90, 50)
        $installBtn.BackColor = "#4a9eff"
        $installBtn.ForeColor = "#ffffff"
        $installBtn.FlatStyle = "Flat"
        $installBtn.FlatAppearance.BorderSize = 0
        $installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $installBtn.Cursor = "Hand"
        $installBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $installBtn.Width, $installBtn.Height), 8))
        $installBtn.Tag = @($appIds[$i], $apps[$i])
        $installBtn.Add_Click({
            $tag = $this.Tag
            $progressBar.Value = 0
            Install-App -appId $tag[0] -appName $tag[1] -appList @($tag[1]) -currentIndex 1 -totalApps 1
            $progressBar.Value = 100
        })
        $panel.Controls.Add($installBtn)
        
        $contentPanel.Controls.Add($panel)
        
        $col++
        if ($col -eq 3) {
            $col = 0
            $x = 100
            $y += 120
        } else {
            $x += 320
        }
    }
}

function Show-FixOsPreset {
    $contentPanel.Visible = $true
    $backBtn.Visible = $true
    $centerPanel.Visible = $false
    $logo.Visible = $false
    $toolbox.Visible = $false
    $contentPanel.Controls.Clear()
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "RUN FIXOS PRESET"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#ffffff"
    $title.Size = New-Object System.Drawing.Size(400, 40)
    $title.Location = New-Object System.Drawing.Point(360, 30)
    $contentPanel.Controls.Add($title)
    
    $message = New-Object System.Windows.Forms.Label
    $message.Text = "This will run the FixOs installer script"
    $message.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $message.ForeColor = "#ffffff"
    $message.Size = New-Object System.Drawing.Size(400, 30)
    $message.Location = New-Object System.Drawing.Point(360, 100)
    $contentPanel.Controls.Add($message)
    
    $confirmLabel = New-Object System.Windows.Forms.Label
    $confirmLabel.Text = "Continue?"
    $confirmLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $confirmLabel.ForeColor = "#ffffff"
    $confirmLabel.Size = New-Object System.Drawing.Size(200, 40)
    $confirmLabel.Location = New-Object System.Drawing.Point(460, 160)
    $contentPanel.Controls.Add($confirmLabel)
    
    $yesBtn = New-Object System.Windows.Forms.Button
    $yesBtn.Text = "YES"
    $yesBtn.Size = New-Object System.Drawing.Size(150, 50)
    $yesBtn.Location = New-Object System.Drawing.Point(360, 220)
    $yesBtn.BackColor = "#4a9eff"
    $yesBtn.ForeColor = "#ffffff"
    $yesBtn.FlatStyle = "Flat"
    $yesBtn.FlatAppearance.BorderSize = 0
    $yesBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $yesBtn.Cursor = "Hand"
    $yesBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $yesBtn.Width, $yesBtn.Height), 10))
    $yesBtn.Add_Click({
        $progressBar.Value = 10
        $statusLabel.Text = "Running FixOs..."
        $form.Refresh()
        
        try {
            $progressBar.Value = 30
            irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
            $progressBar.Value = 100
            $statusLabel.Text = "FixOs completed successfully"
        } catch {
            $progressBar.Value = 0
            $statusLabel.Text = "Error running FixOs"
        }
    })
    
    $noBtn = New-Object System.Windows.Forms.Button
    $noBtn.Text = "NO"
    $noBtn.Size = New-Object System.Drawing.Size(150, 50)
    $noBtn.Location = New-Object System.Drawing.Point(570, 220)
    $noBtn.BackColor = "#1e3a6b"
    $noBtn.ForeColor = "#ffffff"
    $noBtn.FlatStyle = "Flat"
    $noBtn.FlatAppearance.BorderSize = 0
    $noBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $noBtn.Cursor = "Hand"
    $noBtn.Region = [System.Drawing.Region]::FromHrunc((New-Object System.Drawing.Drawing2D.GraphicsPath).GetHrunc(New-Object System.Drawing.Rectangle(0, 0, $noBtn.Width, $noBtn.Height), 10))
    $noBtn.Add_Click({
        $contentPanel.Visible = $false
        $backBtn.Visible = $false
        $centerPanel.Visible = $true
        $logo.Visible = $true
        $toolbox.Visible = $true
        $progressBar.Value = 0
        $statusLabel.Text = "Ready"
    })
    
    $contentPanel.Controls.AddRange(@($yesBtn, $noBtn))
}

$appsBtn.Add_Click({ Show-Categories })
$fixosBtn.Add_Click({ Show-FixOsPreset })

$backBtn.Add_Click({
    $contentPanel.Visible = $false
    $backBtn.Visible = $false
    $centerPanel.Visible = $true
    $logo.Visible = $true
    $toolbox.Visible = $true
    $progressBar.Value = 0
    $statusLabel.Text = "Ready"
})

$form.ShowDialog()
