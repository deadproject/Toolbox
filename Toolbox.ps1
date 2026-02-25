# FixOs Toolbox - Modern UI Version
# © 2026 Devspace. All rights reserved

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# Initialize the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox v1.0.0"
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $true
$form.MinimizeBox = $true

# Create main panel
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.Controls.Add($mainPanel)

# Header panel with logo
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Height = 150
$headerPanel.Dock = "Top"
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$mainPanel.Controls.Add($headerPanel)

# Logo label
$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = "FIXOS TOOLBOX"
$logoLabel.Font = New-Object System.Drawing.Font("Consolas", 28, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = [System.Drawing.Color]::White
$logoLabel.AutoSize = $true
$logoLabel.Location = New-Object System.Drawing.Point(50, 40)
$headerPanel.Controls.Add($logoLabel)

# Version label
$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "Version 1.0.0 | © 2026 Devspace"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$versionLabel.ForeColor = [System.Drawing.Color]::Gray
$versionLabel.AutoSize = $true
$versionLabel.Location = New-Object System.Drawing.Point(50, 90)
$headerPanel.Controls.Add($versionLabel)

# Status panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Height = 40
$statusPanel.Dock = "Bottom"
$statusPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$mainPanel.Controls.Add($statusPanel)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "✓ Ready"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$statusLabel.ForeColor = [System.Drawing.Color]::LimeGreen
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(20, 10)
$statusPanel.Controls.Add($statusLabel)

# Admin status
$adminStatus = New-Object System.Windows.Forms.Label
if ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) {
    $adminStatus.Text = "✓ Administrator"
    $adminStatus.ForeColor = [System.Drawing.Color]::LimeGreen
} else {
    $adminStatus.Text = "✗ Administrator Required"
    $adminStatus.ForeColor = [System.Drawing.Color]::Red
}
$adminStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$adminStatus.AutoSize = $true
$adminStatus.Location = New-Object System.Drawing.Point(200, 10)
$statusPanel.Controls.Add($adminStatus)

# Time label
$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Text = "Session started: $(Get-Date -Format 'HH:mm:ss')"
$timeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$timeLabel.ForeColor = [System.Drawing.Color]::Gray
$timeLabel.AutoSize = $true
$timeLabel.Location = New-Object System.Drawing.Point($form.Width - 200, 10)
$statusPanel.Controls.Add($timeLabel)

# Create tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(20, 170)
$tabControl.Size = New-Object System.Drawing.Size(1140, 540)
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$tabControl.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$tabControl.ForeColor = [System.Drawing.Color]::White
$mainPanel.Controls.Add($tabControl)

# Function to create category tab
function Create-CategoryTab($name) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $name
    $tab.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $tab.ForeColor = [System.Drawing.Color]::White
    $tab.UseVisualStyleBackColor = $true
    
    # Create flow layout panel for apps
    $flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowPanel.Location = New-Object System.Drawing.Point(10, 10)
    $flowPanel.Size = New-Object System.Drawing.Size(1100, 450)
    $flowPanel.AutoScroll = $true
    $flowPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $tab.Controls.Add($flowPanel)
    
    return $tab, $flowPanel
}

# Function to create app button
function Create-AppButton($appName, $appId) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $appName
    $button.Size = New-Object System.Drawing.Size(180, 60)
    $button.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $button.Tag = $appId
    $button.Add_MouseEnter({
        $this.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    })
    $button.Add_MouseLeave({
        $this.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    })
    $button.Add_Click({
        Install-App $this.Tag $this.Text
    })
    return $button
}

# Progress form for installation
$progressForm = New-Object System.Windows.Forms.Form
$progressForm.Size = New-Object System.Drawing.Size(400, 200)
$progressForm.StartPosition = "CenterScreen"
$progressForm.Text = "Installing..."
$progressForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$progressForm.ControlBox = $false
$progressForm.FormBorderStyle = "FixedDialog"

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Location = New-Object System.Drawing.Point(20, 30)
$progressLabel.Size = New-Object System.Drawing.Size(360, 30)
$progressLabel.Text = "Installing application..."
$progressLabel.ForeColor = [System.Drawing.Color]::White
$progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$progressLabel.TextAlign = "MiddleCenter"
$progressForm.Controls.Add($progressLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 80)
$progressBar.Size = New-Object System.Drawing.Size(360, 30)
$progressBar.Style = "Marquee"
$progressForm.Controls.Add($progressBar)

# Installation function
function Install-App($appId, $appName) {
    $progressForm.Show()
    $progressLabel.Text = "Installing $appName..."
    $statusLabel.Text = "⚙ Installing $appName..."
    $statusLabel.ForeColor = [System.Drawing.Color]::Yellow
    
    try {
        $result = winget install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1
        [System.Windows.Forms.MessageBox]::Show("$appName installed successfully!", "Success", "OK", "Information")
        $statusLabel.Text = "✓ $appName installed"
        $statusLabel.ForeColor = [System.Drawing.Color]::LimeGreen
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error installing $appName", "Error", "OK", "Error")
        $statusLabel.Text = "✗ Error installing $appName"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
    }
    
    $progressForm.Hide()
}

# Create tabs
$tabs = @{
    "Browsers" = @(
        @("Google Chrome", "Google.Chrome"),
        @("Brave Browser", "Brave.Brave"),
        @("Mozilla Firefox", "Mozilla.Firefox"),
        @("Microsoft Edge", "Microsoft.Edge"),
        @("Thorium Browser", "Alex313031.Thorium"),
        @("Waterfox", "Waterfox.Waterfox"),
        @("LibreWolf", "LibreWolf.LibreWolf"),
        @("Floorp Browser", "Floorp.Floorp")
    )
    "File Tools" = @(
        @("WinRAR", "RARLab.WinRAR"),
        @("7-Zip", "7zip.7zip")
    )
    "Development" = @(
        @("VS Code", "Microsoft.VisualStudioCode"),
        @("Notepad++", "Notepad++.Notepad++"),
        @("Sublime Text", "SublimeHQ.SublimeText"),
        @("Git", "Git.Git"),
        @("GitHub Desktop", "GitHub.GitHubDesktop"),
        @("PowerShell 7", "Microsoft.PowerShell"),
        @("Docker", "Docker.DockerDesktop")
    )
    ".NET Tools" = @(
        @(".NET SDK 8", "Microsoft.DotNet.SDK.8"),
        @(".NET Runtime 8", "Microsoft.DotNet.Runtime.8"),
        @(".NET Desktop 8", "Microsoft.DotNet.DesktopRuntime.8"),
        @(".NET SDK 7", "Microsoft.DotNet.SDK.7"),
        @(".NET Runtime 7", "Microsoft.DotNet.Runtime.7")
    )
    "Communication" = @(
        @("Telegram", "Telegram.TelegramDesktop"),
        @("Discord", "Discord.Discord"),
        @("WhatsApp", "WhatsApp.WhatsApp"),
        @("Slack", "SlackTechnologies.Slack"),
        @("Zoom", "Zoom.Zoom")
    )
    "Gaming" = @(
        @("Steam", "Valve.Steam"),
        @("Epic Games", "EpicGames.EpicGamesLauncher"),
        @("Ubisoft Connect", "Ubisoft.Connect"),
        @("EA Desktop", "ElectronicArts.EADesktop")
    )
    "Microsoft" = @(
        @("Windows Terminal", "Microsoft.WindowsTerminal"),
        @("PowerToys", "Microsoft.PowerToys"),
        @("Microsoft Office", "Microsoft.Office"),
        @("Microsoft Store", "Microsoft.Store")
    )
    "Media" = @(
        @("VLC Player", "VideoLAN.VLC"),
        @("OBS Studio", "OBSProject.OBSStudio"),
        @("Handbrake", "Handbrake.Handbrake")
    )
    "Productivity" = @(
        @("Obsidian", "Obsidian.Obsidian"),
        @("Notion", "Notion.Notion"),
        @("AnyDesk", "AnyDeskSoftwareGmbH.AnyDesk"),
        @("TeamViewer", "TeamViewer.TeamViewer")
    )
}

foreach ($category in $tabs.Keys) {
    $tab, $flowPanel = Create-CategoryTab $category
    foreach ($app in $tabs[$category]) {
        $button = Create-AppButton $app[0] $app[1]
        $flowPanel.Controls.Add($button)
    }
    $tabControl.TabPages.Add($tab)
}

# Create FixOs Preset tab
$fixOsTab = New-Object System.Windows.Forms.TabPage
$fixOsTab.Text = "FixOs Preset"
$fixOsTab.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

$fixOsPanel = New-Object System.Windows.Forms.Panel
$fixOsPanel.Location = New-Object System.Drawing.Point(20, 20)
$fixOsPanel.Size = New-Object System.Drawing.Size(1080, 450)
$fixOsPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$fixOsTab.Controls.Add($fixOsPanel)

$fixOsTitle = New-Object System.Windows.Forms.Label
$fixOsTitle.Text = "FixOs System Preset"
$fixOsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$fixOsTitle.ForeColor = [System.Drawing.Color]::White
$fixOsTitle.Location = New-Object System.Drawing.Point(20, 20)
$fixOsTitle.Size = New-Object System.Drawing.Size(400, 50)
$fixOsPanel.Controls.Add($fixOsTitle)

$fixOsDescription = New-Object System.Windows.Forms.Label
$fixOsDescription.Text = "Run the complete FixOs system optimization preset.`nThis will apply all recommended settings and optimizations.`n`n⚠ Make sure you have a backup before proceeding."
$fixOsDescription.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$fixOsDescription.ForeColor = [System.Drawing.Color]::LightGray
$fixOsDescription.Location = New-Object System.Drawing.Point(20, 80)
$fixOsDescription.Size = New-Object System.Drawing.Size(600, 100)
$fixOsPanel.Controls.Add($fixOsDescription)

$runFixOsButton = New-Object System.Windows.Forms.Button
$runFixOsButton.Text = "▶ RUN FIXOS PRESET"
$runFixOsButton.Size = New-Object System.Drawing.Size(300, 80)
$runFixOsButton.Location = New-Object System.Drawing.Point(20, 200)
$runFixOsButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$runFixOsButton.ForeColor = [System.Drawing.Color]::White
$runFixOsButton.FlatStyle = "Flat"
$runFixOsButton.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$runFixOsButton.Add_MouseEnter({
    $this.BackColor = [System.Drawing.Color]::FromArgb(0, 100, 200)
})
$runFixOsButton.Add_MouseLeave({
    $this.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
})
$runFixOsButton.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to run FixOs Preset?", "Confirm", "YesNo", "Warning")
    if ($result -eq "Yes") {
        $statusLabel.Text = "⚙ Running FixOs Preset..."
        $statusLabel.ForeColor = [System.Drawing.Color]::Yellow
        
        try {
            irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex
            [System.Windows.Forms.MessageBox]::Show("FixOs Preset completed successfully!", "Success", "OK", "Information")
            $statusLabel.Text = "✓ FixOs Preset completed"
            $statusLabel.ForeColor = [System.Drawing.Color]::LimeGreen
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error running FixOs Preset", "Error", "OK", "Error")
            $statusLabel.Text = "✗ Error running FixOs Preset"
            $statusLabel.ForeColor = [System.Drawing.Color]::Red
        }
    }
})
$fixOsPanel.Controls.Add($runFixOsButton)

$fixOsImage = New-Object System.Windows.Forms.PictureBox
$fixOsImage.Location = New-Object System.Drawing.Point(700, 50)
$fixOsImage.Size = New-Object System.Drawing.Size(300, 300)
$fixOsImage.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$fixOsImage.BorderStyle = "FixedSingle"
$fixOsImage.Text = "FixOs"
$fixOsImage.Font = New-Object System.Drawing.Font("Segoe UI", 40, [System.Drawing.FontStyle]::Bold)
$fixOsImage.ForeColor = [System.Drawing.Color]::White
$fixOsImage.TextAlign = "MiddleCenter"
$fixOsPanel.Controls.Add($fixOsImage)

$tabControl.TabPages.Add($fixOsTab)

# Install all button for each tab
foreach ($tab in $tabControl.TabPages) {
    if ($tab.Text -ne "FixOs Preset") {
        $installAllPanel = New-Object System.Windows.Forms.Panel
        $installAllPanel.Height = 40
        $installAllPanel.Dock = "Bottom"
        $installAllPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
        
        $installAllButton = New-Object System.Windows.Forms.Button
        $installAllButton.Text = "⚡ Install All in this Category"
        $installAllButton.Size = New-Object System.Drawing.Size(250, 30)
        $installAllButton.Location = New-Object System.Drawing.Point(10, 5)
        $installAllButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
        $installAllButton.ForeColor = [System.Drawing.Color]::White
        $installAllButton.FlatStyle = "Flat"
        $installAllButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $installAllButton.Add_Click({
            $apps = @()
            foreach ($control in $tab.Controls[0].Controls) {
                if ($control -is [System.Windows.Forms.Button]) {
                    $apps += @{"Name" = $control.Text; "Id" = $control.Tag}
                }
            }
            $result = [System.Windows.Forms.MessageBox]::Show("Install all apps in $($tab.Text)?", "Confirm", "YesNo", "Question")
            if ($result -eq "Yes") {
                foreach ($app in $apps) {
                    Install-App $app.Id $app.Name
                }
            }
        }.GetNewClosure())
        $installAllPanel.Controls.Add($installAllButton)
        
        $tab.Controls.Add($installAllPanel)
    }
}

# Handle non-admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    foreach ($tab in $tabControl.TabPages) {
        $tab.Enabled = $false
    }
    $runFixOsButton.Enabled = $false
    [System.Windows.Forms.MessageBox]::Show("Please run PowerShell as Administrator!", "Admin Required", "OK", "Warning")
}

# Show the form
$form.ShowDialog()
