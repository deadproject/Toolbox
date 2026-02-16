$ToolboxConfig = @{
    Version = "2.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
}

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Administrator required" -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$darkMode = $true

$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox v$($ToolboxConfig.Version)"
$form.WindowState = "Maximized"
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0d1117"
$form.ForeColor = "#e6edf3"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.BackColor = "#161b22"
$menuStrip.ForeColor = "#e6edf3"

$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = "Exit"
$exitItem.Add_Click({ $form.Close() })

$viewMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$viewMenu.Text = "View"
$themeItem = New-Object System.Windows.Forms.ToolStripMenuItem
$themeItem.Text = "Toggle Dark/Light Mode"
$themeItem.Add_Click({
    if ($darkMode) {
        $darkMode = $false
        $form.BackColor = "#ffffff"
        $menuStrip.BackColor = "#f0f0f0"
        $menuStrip.ForeColor = "#000000"
        $headerPanel.BackColor = "#f8f9fa"
        $logoLabel.ForeColor = "#0066cc"
        $versionLabel.ForeColor = "#666666"
        $bottomPanel.BackColor = "#f8f9fa"
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.GroupBox]) {
                $ctrl.BackColor = "#f8f9fa"
                $ctrl.ForeColor = "#000000"
            }
        }
        $selectAllBtn.BackColor = "#ffaa00"
        $deselectAllBtn.BackColor = "#e0e0e0"
        $deselectAllBtn.ForeColor = "#000000"
        $installBtn.BackColor = "#28a745"
        $fixOsBtn.BackColor = "#0066cc"
        $statusLabel.ForeColor = "#28a745"
    } else {
        $darkMode = $true
        $form.BackColor = "#0d1117"
        $menuStrip.BackColor = "#161b22"
        $menuStrip.ForeColor = "#e6edf3"
        $headerPanel.BackColor = "#161b22"
        $logoLabel.ForeColor = "#2f81f7"
        $versionLabel.ForeColor = "#e6edf3"
        $bottomPanel.BackColor = "#161b22"
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.GroupBox]) {
                $ctrl.BackColor = "#161b22"
                $ctrl.ForeColor = "#e6edf3"
            }
        }
        $selectAllBtn.BackColor = "#d29922"
        $deselectAllBtn.BackColor = "#30363d"
        $deselectAllBtn.ForeColor = "#e6edf3"
        $installBtn.BackColor = "#3fb950"
        $fixOsBtn.BackColor = "#2f81f7"
        $statusLabel.ForeColor = "#3fb950"
    }
})

$fileMenu.DropDownItems.AddRange(@($exitItem))
$viewMenu.DropDownItems.AddRange(@($themeItem))
$menuStrip.Items.AddRange(@($fileMenu, $viewMenu))

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = "Top"
$headerPanel.Height = 100
$headerPanel.BackColor = "#161b22"

$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Location = New-Object System.Drawing.Point(30, 20)
$logoLabel.Size = New-Object System.Drawing.Size(600, 60)
$logoLabel.Text = @"
███████╗██╗██╗  ██╗  ██████╗ ███████╗
██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
█████╗  ██║ ╚███╔╝  ██║   ██║███████╗
██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
"@
$logoLabel.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = "#2f81f7"

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Location = New-Object System.Drawing.Point(1100, 35)
$versionLabel.Size = New-Object System.Drawing.Size(150, 30)
$versionLabel.Text = "v$($ToolboxConfig.Version)"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$versionLabel.ForeColor = "#e6edf3"
$versionLabel.TextAlign = "MiddleRight"

$headerPanel.Controls.AddRange(@($logoLabel, $versionLabel))

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.Padding = New-Object System.Windows.Forms.Padding(20)
$mainPanel.AutoScroll = $true

$categories = @(
    @{Name="BROWSERS"; Apps=@("Google Chrome","Brave","Firefox","Edge","Thorium","LibreWolf")},
    @{Name="DEVELOPMENT"; Apps=@("VS Code","Git","Docker","Python","Node.js","PowerShell 7")},
    @{Name="COMMUNICATION"; Apps=@("Discord","Telegram","WhatsApp","Slack","Zoom","Teams")},
    @{Name="GAMING"; Apps=@("Steam","Epic Games","Ubisoft Connect","EA Desktop","GOG Galaxy","Battle.net")},
    @{Name="MEDIA"; Apps=@("VLC","Spotify","OBS Studio","GIMP","HandBrake","Audacity")},
    @{Name="UTILITIES"; Apps=@("7-Zip","PowerToys","Windows Terminal","Notepad++","WinRAR","CPU-Z")}
)

$appIds = @{
    "Google Chrome" = "Google.Chrome"
    "Brave" = "Brave.Brave"
    "Firefox" = "Mozilla.Firefox"
    "Edge" = "Microsoft.Edge"
    "Thorium" = "Alex313031.Thorium"
    "LibreWolf" = "LibreWolf.LibreWolf"
    "VS Code" = "Microsoft.VisualStudioCode"
    "Git" = "Git.Git"
    "Docker" = "Docker.DockerDesktop"
    "Python" = "Python.Python.3"
    "Node.js" = "OpenJS.NodeJS"
    "PowerShell 7" = "Microsoft.PowerShell"
    "Discord" = "Discord.Discord"
    "Telegram" = "Telegram.TelegramDesktop"
    "WhatsApp" = "WhatsApp.WhatsApp"
    "Slack" = "SlackTechnologies.Slack"
    "Zoom" = "Zoom.Zoom"
    "Teams" = "Microsoft.Teams"
    "Steam" = "Valve.Steam"
    "Epic Games" = "EpicGames.EpicGamesLauncher"
    "Ubisoft Connect" = "Ubisoft.Connect"
    "EA Desktop" = "ElectronicArts.EADesktop"
    "GOG Galaxy" = "GOG.Galaxy"
    "Battle.net" = "Battle.net.Battle.net"
    "VLC" = "VideoLAN.VLC"
    "Spotify" = "Spotify.Spotify"
    "OBS Studio" = "OBSProject.OBSStudio"
    "GIMP" = "GIMP.GIMP"
    "HandBrake" = "Handbrake.Handbrake"
    "Audacity" = "Audacity.Audacity"
    "7-Zip" = "7zip.7zip"
    "PowerToys" = "Microsoft.PowerToys"
    "Windows Terminal" = "Microsoft.WindowsTerminal"
    "Notepad++" = "Notepad++.Notepad++"
    "WinRAR" = "RARLab.WinRAR"
    "CPU-Z" = "CPUID.CPU-Z"
}

$checkboxes = @{}

$xPos = 20
$yPos = 20
$colWidth = 380
$rowHeight = 280

for ($i = 0; $i -lt $categories.Count; $i++) {
    $col = $i % 3
    $row = [Math]::Floor($i / 3)
    
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = " $($categories[$i].Name) "
    $groupBox.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $groupBox.ForeColor = "#e6edf3"
    $groupBox.BackColor = "#161b22"
    $groupBox.Location = New-Object System.Drawing.Point(20 + ($col * 400), 20 + ($row * 300))
    $groupBox.Size = New-Object System.Drawing.Size(380, 280)
    
    $appsPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $appsPanel.Location = New-Object System.Drawing.Point(15, 30)
    $appsPanel.Size = New-Object System.Drawing.Size(350, 235)
    $appsPanel.FlowDirection = "TopDown"
    $appsPanel.WrapContents = $false
    $appsPanel.AutoScroll = $true
    $appsPanel.BackColor = "#161b22"
    
    $checkboxes[$categories[$i].Name] = @{}
    
    foreach ($app in $categories[$i].Apps) {
        $check = New-Object System.Windows.Forms.CheckBox
        $check.Text = $app
        $check.Size = New-Object System.Drawing.Size(330, 30)
        $check.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $check.ForeColor = "#e6edf3"
        $check.BackColor = "#161b22"
        $check.FlatStyle = "Standard"
        $check.UseVisualStyleBackColor = $false
        $appsPanel.Controls.Add($check)
        $checkboxes[$categories[$i].Name][$app] = $check
    }
    
    $groupBox.Controls.Add($appsPanel)
    $mainPanel.Controls.Add($groupBox)
}

$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = "Bottom"
$bottomPanel.Height = 80
$bottomPanel.BackColor = "#161b22"
$bottomPanel.Padding = New-Object System.Windows.Forms.Padding(20)

$selectAllBtn = New-Object System.Windows.Forms.Button
$selectAllBtn.Location = New-Object System.Drawing.Point(20, 20)
$selectAllBtn.Size = New-Object System.Drawing.Size(120, 40)
$selectAllBtn.Text = "SELECT ALL"
$selectAllBtn.FlatStyle = "Flat"
$selectAllBtn.FlatAppearance.BorderSize = 0
$selectAllBtn.BackColor = "#d29922"
$selectAllBtn.ForeColor = "#000000"
$selectAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$selectAllBtn.Cursor = "Hand"

$deselectAllBtn = New-Object System.Windows.Forms.Button
$deselectAllBtn.Location = New-Object System.Drawing.Point(150, 20)
$deselectAllBtn.Size = New-Object System.Drawing.Size(120, 40)
$deselectAllBtn.Text = "DESELECT ALL"
$deselectAllBtn.FlatStyle = "Flat"
$deselectAllBtn.FlatAppearance.BorderSize = 0
$deselectAllBtn.BackColor = "#30363d"
$deselectAllBtn.ForeColor = "#e6edf3"
$deselectAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$deselectAllBtn.Cursor = "Hand"

$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Location = New-Object System.Drawing.Point(800, 20)
$installBtn.Size = New-Object System.Drawing.Size(150, 40)
$installBtn.Text = "INSTALL"
$installBtn.FlatStyle = "Flat"
$installBtn.FlatAppearance.BorderSize = 0
$installBtn.BackColor = "#3fb950"
$installBtn.ForeColor = "#000000"
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$installBtn.Cursor = "Hand"

$fixOsBtn = New-Object System.Windows.Forms.Button
$fixOsBtn.Location = New-Object System.Drawing.Point(960, 20)
$fixOsBtn.Size = New-Object System.Drawing.Size(150, 40)
$fixOsBtn.Text = "RUN FIXOS"
$fixOsBtn.FlatStyle = "Flat"
$fixOsBtn.FlatAppearance.BorderSize = 0
$fixOsBtn.BackColor = "#2f81f7"
$fixOsBtn.ForeColor = "#ffffff"
$fixOsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fixOsBtn.Cursor = "Hand"

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(300, 28)
$statusLabel.Size = New-Object System.Drawing.Size(400, 25)
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = "#3fb950"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)

$selectAllBtn.Add_Click({
    foreach ($category in $checkboxes.Keys) {
        foreach ($app in $checkboxes[$category].Keys) {
            $checkboxes[$category][$app].Checked = $true
        }
    }
    $statusLabel.Text = "All applications selected"
    $statusLabel.ForeColor = "#d29922"
})

$deselectAllBtn.Add_Click({
    foreach ($category in $checkboxes.Keys) {
        foreach ($app in $checkboxes[$category].Keys) {
            $checkboxes[$category][$app].Checked = $false
        }
    }
    $statusLabel.Text = "All applications deselected"
    $statusLabel.ForeColor = "#e6edf3"
})

$installBtn.Add_Click({
    $selected = @()
    foreach ($category in $checkboxes.Keys) {
        foreach ($app in $checkboxes[$category].Keys) {
            if ($checkboxes[$category][$app].Checked) {
                $selected += $app
            }
        }
    }
    
    if ($selected.Count -eq 0) {
        $statusLabel.Text = "No applications selected"
        $statusLabel.ForeColor = "#f85149"
        return
    }
    
    $installBtn.Enabled = $false
    $statusLabel.Text = "Installing $($selected.Count) applications..."
    $statusLabel.ForeColor = "#d29922"
    $form.Refresh()
    
    $success = 0
    $fail = 0
    
    foreach ($app in $selected) {
        $statusLabel.Text = "Installing: $app..."
        $form.Refresh()
        
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $($appIds[$app]) --exact --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            $success++
        } else {
            $fail++
        }
    }
    
    $statusLabel.Text = "Complete - $success installed, $fail failed"
    if ($fail -eq 0) {
        $statusLabel.ForeColor = "#3fb950"
    } else {
        $statusLabel.ForeColor = "#d29922"
    }
    $installBtn.Enabled = $true
})

$fixOsBtn.Add_Click({
    $fixOsBtn.Enabled = $false
    $statusLabel.Text = "Running FixOs preset..."
    $statusLabel.ForeColor = "#d29922"
    $form.Refresh()
    
    try {
        iex (irm "DevelopmentSpace.pages.dev/FixOs.ps1")
        $statusLabel.Text = "FixOs completed successfully"
        $statusLabel.ForeColor = "#3fb950"
    } catch {
        $statusLabel.Text = "FixOs failed"
        $statusLabel.ForeColor = "#f85149"
    }
    
    $fixOsBtn.Enabled = $true
})

$bottomPanel.Controls.AddRange(@($selectAllBtn, $deselectAllBtn, $statusLabel, $installBtn, $fixOsBtn))
$form.Controls.AddRange(@($menuStrip, $headerPanel, $mainPanel, $bottomPanel))
$form.MainMenuStrip = $menuStrip
$form.ShowDialog()
