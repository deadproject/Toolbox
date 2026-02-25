Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox v1.0.0"
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#121212"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.BackColor = "#121212"
$form.Controls.Add($mainPanel)

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Height = 120
$headerPanel.Dock = "Top"
$headerPanel.BackColor = "#1E1E1E"
$mainPanel.Controls.Add($headerPanel)

$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = "FIXOS TOOLBOX"
$logoLabel.Font = New-Object System.Drawing.Font("Consolas", 32, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = "White"
$logoLabel.AutoSize = $true
$logoLabel.Location = New-Object System.Drawing.Point(30, 30)
$headerPanel.Controls.Add($logoLabel)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "Version 1.0.0 | © 2026 Devspace"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$versionLabel.ForeColor = "Gray"
$versionLabel.AutoSize = $true
$versionLabel.Location = New-Object System.Drawing.Point(30, 80)
$headerPanel.Controls.Add($versionLabel)

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.BackColor = "#2D2D2D"
$statusStrip.ForeColor = "White"
$statusStrip.SizingGrip = $false
$mainPanel.Controls.Add($statusStrip)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = "LimeGreen"
$statusStrip.Items.Add($statusLabel)

$adminLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
if ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) {
    $adminLabel.Text = "Administrator"
    $adminLabel.ForeColor = "LimeGreen"
} else {
    $adminLabel.Text = "Administrator Required"
    $adminLabel.ForeColor = "Red"
}
$statusStrip.Items.Add($adminLabel)

$timeLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$timeLabel.Text = "Started: $(Get-Date -Format 'HH:mm:ss')"
$timeLabel.ForeColor = "Gray"
$statusStrip.Items.Add($timeLabel)

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(20, 140)
$tabControl.Size = New-Object System.Drawing.Size(1140, 580)
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$tabControl.BackColor = "#1E1E1E"
$mainPanel.Controls.Add($tabControl)

$installForm = New-Object System.Windows.Forms.Form
$installForm.Size = New-Object System.Drawing.Size(400, 150)
$installForm.StartPosition = "CenterScreen"
$installForm.Text = "Installing"
$installForm.BackColor = "#1E1E1E"
$installForm.ControlBox = $false
$installForm.FormBorderStyle = "FixedDialog"
$installForm.TopMost = $true

$installLabel = New-Object System.Windows.Forms.Label
$installLabel.Location = New-Object System.Drawing.Point(20, 30)
$installLabel.Size = New-Object System.Drawing.Size(360, 30)
$installLabel.Text = "Installing..."
$installLabel.ForeColor = "White"
$installLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$installLabel.TextAlign = "MiddleCenter"
$installForm.Controls.Add($installLabel)

$installProgress = New-Object System.Windows.Forms.ProgressBar
$installProgress.Location = New-Object System.Drawing.Point(20, 70)
$installProgress.Size = New-Object System.Drawing.Size(360, 30)
$installProgress.Style = "Marquee"
$installForm.Controls.Add($installProgress)

function Install-App {
    param($appId, $appName)
    
    $installForm.Show()
    $installLabel.Text = "Installing $appName..."
    $statusLabel.Text = "Installing $appName..."
    $statusLabel.ForeColor = "Yellow"
    
    try {
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $appId --exact --silent --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("$appName installed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            $statusLabel.Text = "$appName installed"
            $statusLabel.ForeColor = "LimeGreen"
        } else {
            throw "Installation failed"
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error installing $appName", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $statusLabel.Text = "Error installing $appName"
        $statusLabel.ForeColor = "Red"
    }
    
    $installForm.Hide()
}

$categories = @{
    "Browsers" = @(
        @("Google Chrome", "Google.Chrome"),
        @("Brave", "Brave.Brave"),
        @("Firefox", "Mozilla.Firefox"),
        @("Edge", "Microsoft.Edge"),
        @("Thorium", "Alex313031.Thorium"),
        @("Waterfox", "Waterfox.Waterfox"),
        @("LibreWolf", "LibreWolf.LibreWolf"),
        @("Floorp", "Floorp.Floorp")
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
    ".NET" = @(
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
        @("EA App", "ElectronicArts.EADesktop")
    )
    "Microsoft" = @(
        @("Windows Terminal", "Microsoft.WindowsTerminal"),
        @("PowerToys", "Microsoft.PowerToys"),
        @("Office", "Microsoft.Office"),
        @("Store", "Microsoft.Store")
    )
    "Media" = @(
        @("VLC", "VideoLAN.VLC"),
        @("OBS", "OBSProject.OBSStudio"),
        @("Handbrake", "Handbrake.Handbrake")
    )
    "Productivity" = @(
        @("Obsidian", "Obsidian.Obsidian"),
        @("Notion", "Notion.Notion"),
        @("AnyDesk", "AnyDeskSoftwareGmbH.AnyDesk"),
        @("TeamViewer", "TeamViewer.TeamViewer")
    )
}

foreach ($cat in $categories.Keys) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $cat
    $tab.BackColor = "#1E1E1E"
    
    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Location = New-Object System.Drawing.Point(10, 10)
    $panel.Size = New-Object System.Drawing.Size(1100, 500)
    $panel.AutoScroll = $true
    $panel.BackColor = "#1E1E1E"
    
    foreach ($app in $categories[$cat]) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $app[0]
        $btn.Size = New-Object System.Drawing.Size(160, 50)
        $btn.BackColor = "#2D2D2D"
        $btn.ForeColor = "White"
        $btn.FlatStyle = "Flat"
        $btn.FlatAppearance.BorderSize = 0
        $btn.Tag = $app[1]
        $btn.Add_MouseEnter({ $this.BackColor = "#3D3D3D" })
        $btn.Add_MouseLeave({ $this.BackColor = "#2D2D2D" })
        $btn.Add_Click({ Install-App $this.Tag $this.Text })
        $panel.Controls.Add($btn)
    }
    
    $installAllPanel = New-Object System.Windows.Forms.Panel
    $installAllPanel.Height = 40
    $installAllPanel.Dock = "Bottom"
    $installAllPanel.BackColor = "#2D2D2D"
    
    $installAllBtn = New-Object System.Windows.Forms.Button
    $installAllBtn.Text = "Install All"
    $installAllBtn.Size = New-Object System.Drawing.Size(120, 30)
    $installAllBtn.Location = New-Object System.Drawing.Point(10, 5)
    $installAllBtn.BackColor = "#0078D4"
    $installAllBtn.ForeColor = "White"
    $installAllBtn.FlatStyle = "Flat"
    $installAllBtn.Add_Click({
        $apps = @()
        foreach ($control in $panel.Controls) {
            if ($control -is [System.Windows.Forms.Button]) {
                $apps += @{Name = $control.Text; Id = $control.Tag}
            }
        }
        $res = [System.Windows.Forms.MessageBox]::Show("Install all apps in $($tab.Text)?", "Confirm", "YesNo", "Question")
        if ($res -eq "Yes") {
            foreach ($app in $apps) {
                Install-App $app.Id $app.Name
            }
        }
    }.GetNewClosure())
    $installAllPanel.Controls.Add($installAllBtn)
    
    $tab.Controls.Add($panel)
    $tab.Controls.Add($installAllPanel)
    $tabControl.TabPages.Add($tab)
}

$fixOsTab = New-Object System.Windows.Forms.TabPage
$fixOsTab.Text = "FixOs Preset"
$fixOsTab.BackColor = "#1E1E1E"

$fixOsPanel = New-Object System.Windows.Forms.Panel
$fixOsPanel.Location = New-Object System.Drawing.Point(20, 20)
$fixOsPanel.Size = New-Object System.Drawing.Size(1080, 500)
$fixOsPanel.BackColor = "#1E1E1E"

$fixOsTitle = New-Object System.Windows.Forms.Label
$fixOsTitle.Text = "FixOs System Preset"
$fixOsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$fixOsTitle.ForeColor = "White"
$fixOsTitle.Location = New-Object System.Drawing.Point(20, 20)
$fixOsTitle.Size = New-Object System.Drawing.Size(500, 50)
$fixOsPanel.Controls.Add($fixOsTitle)

$fixOsDesc = New-Object System.Windows.Forms.Label
$fixOsDesc.Text = "Run the complete FixOs system optimization preset.`nThis will apply all recommended settings and optimizations.`n`n⚠ Make sure you have a backup before proceeding."
$fixOsDesc.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$fixOsDesc.ForeColor = "LightGray"
$fixOsDesc.Location = New-Object System.Drawing.Point(20, 80)
$fixOsDesc.Size = New-Object System.Drawing.Size(600, 100)
$fixOsPanel.Controls.Add($fixOsDesc)

$runFixOs = New-Object System.Windows.Forms.Button
$runFixOs.Text = "RUN FIXOS PRESET"
$runFixOs.Size = New-Object System.Drawing.Size(250, 60)
$runFixOs.Location = New-Object System.Drawing.Point(20, 200)
$runFixOs.BackColor = "#0078D4"
$runFixOs.ForeColor = "White"
$runFixOs.FlatStyle = "Flat"
$runFixOs.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$runFixOs.Add_MouseEnter({ $this.BackColor = "#106EBE" })
$runFixOs.Add_MouseLeave({ $this.BackColor = "#0078D4" })
$runFixOs.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show("Run FixOs Preset?", "Confirm", "YesNo", "Warning")
    if ($res -eq "Yes") {
        $statusLabel.Text = "Running FixOs..."
        $statusLabel.ForeColor = "Yellow"
        try {
            $scriptBlock = { irm "DevelopmentSpace.pages.dev/FixOs.ps1" | iex }
            Start-Job -ScriptBlock $scriptBlock | Out-Null
            [System.Windows.Forms.MessageBox]::Show("FixOs started in background", "Info", "OK", "Information")
            $statusLabel.Text = "FixOs running"
            $statusLabel.ForeColor = "Yellow"
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error starting FixOs", "Error", "OK", "Error")
            $statusLabel.Text = "Error"
            $statusLabel.ForeColor = "Red"
        }
    }
})
$fixOsPanel.Controls.Add($runFixOs)

$box = New-Object System.Windows.Forms.PictureBox
$box.Location = New-Object System.Drawing.Point(700, 50)
$box.Size = New-Object System.Drawing.Size(300, 300)
$box.BackColor = "#2D2D2D"
$box.BorderStyle = "FixedSingle"
$fixOsPanel.Controls.Add($box)

$boxText = New-Object System.Windows.Forms.Label
$boxText.Text = "FIXOS"
$boxText.Font = New-Object System.Drawing.Font("Consolas", 48, [System.Drawing.FontStyle]::Bold)
$boxText.ForeColor = "White"
$boxText.AutoSize = $true
$boxText.Location = New-Object System.Drawing.Point(770, 150)
$fixOsPanel.Controls.Add($boxText)

$fixOsTab.Controls.Add($fixOsPanel)
$tabControl.TabPages.Add($fixOsTab)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $tabControl.Enabled = $false
    $runFixOs.Enabled = $false
    [System.Windows.Forms.MessageBox]::Show("Run PowerShell as Administrator", "Admin Required", "OK", "Warning")
}

$form.ShowDialog()
