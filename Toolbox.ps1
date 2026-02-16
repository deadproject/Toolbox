$ToolboxConfig = @{
    Version = "1.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
}

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Administrator required" -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$global:theme = "dark"
$darkColors = @{
    bg = "#0d1117"
    surface = "#161b22"
    border = "#30363d"
    text = "#e6edf3"
    accent = "#2f81f7"
    success = "#3fb950"
    warning = "#d29922"
    error = "#f85149"
}

$lightColors = @{
    bg = "#ffffff"
    surface = "#f6f8fa"
    border = "#d0d7de"
    text = "#24292f"
    accent = "#0969da"
    success = "#1a7f37"
    warning = "#9a6700"
    error = "#cf222e"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox"
$form.WindowState = "Maximized"
$form.StartPosition = "CenterScreen"
$form.BackColor = $darkColors.bg
$form.ForeColor = $darkColors.text
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.BackColor = $darkColors.surface
$menuStrip.ForeColor = $darkColors.text

$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = "Exit"
$exitItem.Add_Click({ $form.Close() })

$viewMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$viewMenu.Text = "View"
$themeItem = New-Object System.Windows.Forms.ToolStripMenuItem
$themeItem.Text = "Toggle Theme"
$themeItem.Add_Click({
    if ($global:theme -eq "dark") {
        $global:theme = "light"
        $form.BackColor = $lightColors.bg
        $menuStrip.BackColor = $lightColors.surface
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel] -or $ctrl -is [System.Windows.Forms.GroupBox]) {
                $ctrl.BackColor = $lightColors.surface
                $ctrl.ForeColor = $lightColors.text
            }
        }
    } else {
        $global:theme = "dark"
        $form.BackColor = $darkColors.bg
        $menuStrip.BackColor = $darkColors.surface
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel] -or $ctrl -is [System.Windows.Forms.GroupBox]) {
                $ctrl.BackColor = $darkColors.surface
                $ctrl.ForeColor = $darkColors.text
            }
        }
    }
})

$fileMenu.DropDownItems.AddRange(@($exitItem))
$viewMenu.DropDownItems.AddRange(@($themeItem))
$menuStrip.Items.AddRange(@($fileMenu, $viewMenu))

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = "Top"
$headerPanel.Height = 120
$headerPanel.BackColor = $darkColors.surface

$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Location = New-Object System.Drawing.Point(30, 20)
$logoLabel.Size = New-Object System.Drawing.Size(600, 80)
$logoLabel.Text = @"
███████╗██╗██╗  ██╗  ██████╗ ███████╗
██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
█████╗  ██║ ╚███╔╝  ██║   ██║███████╗
██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
"@
$logoLabel.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = $darkColors.accent

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Location = New-Object System.Drawing.Point(650, 50)
$versionLabel.Size = New-Object System.Drawing.Size(200, 30)
$versionLabel.Text = "v$($ToolboxConfig.Version)"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$versionLabel.ForeColor = $darkColors.text
$versionLabel.TextAlign = "MiddleRight"

$headerPanel.Controls.AddRange(@($logoLabel, $versionLabel))

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.Padding = New-Object System.Windows.Forms.Padding(20)
$mainPanel.AutoScroll = $true

$categoriesGrid = New-Object System.Windows.Forms.TableLayoutPanel
$categoriesGrid.ColumnCount = 3
$categoriesGrid.RowCount = 2
$categoriesGrid.Dock = "Fill"
$categoriesGrid.Padding = New-Object System.Windows.Forms.Padding(10)
$categoriesGrid.BackColor = $darkColors.bg

$categories = @(
    @{Name="🌐 Browsers"; Icon="🦊"; Apps=@("Google Chrome","Brave","Firefox","Edge","Thorium","LibreWolf")},
    @{Name="💻 Development"; Icon="⚙️"; Apps=@("VS Code","Git","Docker","Python","Node.js","PowerShell 7")},
    @{Name="💬 Communication"; Icon="💭"; Apps=@("Discord","Telegram","WhatsApp","Slack","Zoom","Teams")},
    @{Name="🎮 Gaming"; Icon="🎯"; Apps=@("Steam","Epic Games","Ubisoft","EA Desktop","GOG","Battle.net")},
    @{Name="🎵 Media"; Icon="🎬"; Apps=@("VLC","Spotify","OBS Studio","GIMP","HandBrake","Audacity")},
    @{Name="🛠️ Utilities"; Icon="🔧"; Apps=@("7-Zip","PowerToys","Terminal","Notepad++","WinRAR","CPU-Z")}
)

$checkboxes = @{}

for ($i = 0; $i -lt 6; $i++) {
    $row = [Math]::Floor($i / 3)
    $col = $i % 3
    
    $categoryPanel = New-Object System.Windows.Forms.GroupBox
    $categoryPanel.Text = "$($categories[$i].Icon)  $($categories[$i].Name)"
    $categoryPanel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $categoryPanel.ForeColor = $darkColors.text
    $categoryPanel.BackColor = $darkColors.surface
    $categoryPanel.Size = New-Object System.Drawing.Size(380, 280)
    $categoryPanel.Padding = New-Object System.Windows.Forms.Padding(15)
    $categoryPanel.Dock = "Fill"
    
    $appsPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $appsPanel.Location = New-Object System.Drawing.Point(15, 40)
    $appsPanel.Size = New-Object System.Drawing.Size(350, 220)
    $appsPanel.FlowDirection = "TopDown"
    $appsPanel.WrapContents = $false
    $appsPanel.AutoScroll = $true
    $appsPanel.BackColor = $darkColors.surface
    
    $checkboxes[$categories[$i].Name] = @{}
    
    foreach ($app in $categories[$i].Apps) {
        $check = New-Object System.Windows.Forms.CheckBox
        $check.Text = $app
        $check.Size = New-Object System.Drawing.Size(320, 30)
        $check.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $check.ForeColor = $darkColors.text
        $check.UseVisualStyleBackColor = $false
        $appsPanel.Controls.Add($check)
        $checkboxes[$categories[$i].Name][$app] = $check
    }
    
    $categoryPanel.Controls.Add($appsPanel)
    $categoriesGrid.Controls.Add($categoryPanel, $col, $row)
}

$mainPanel.Controls.Add($categoriesGrid)

$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = "Bottom"
$bottomPanel.Height = 80
$bottomPanel.BackColor = $darkColors.surface
$bottomPanel.Padding = New-Object System.Windows.Forms.Padding(20)

$selectAllBtn = New-Object System.Windows.Forms.Button
$selectAllBtn.Location = New-Object System.Drawing.Point(20, 20)
$selectAllBtn.Size = New-Object System.Drawing.Size(120, 40)
$selectAllBtn.Text = "SELECT ALL"
$selectAllBtn.FlatStyle = "Flat"
$selectAllBtn.FlatAppearance.BorderSize = 0
$selectAllBtn.BackColor = $darkColors.warning
$selectAllBtn.ForeColor = "Black"
$selectAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$selectAllBtn.Cursor = "Hand"

$deselectAllBtn = New-Object System.Windows.Forms.Button
$deselectAllBtn.Location = New-Object System.Drawing.Point(150, 20)
$deselectAllBtn.Size = New-Object System.Drawing.Size(120, 40)
$deselectAllBtn.Text = "DESELECT ALL"
$deselectAllBtn.FlatStyle = "Flat"
$deselectAllBtn.FlatAppearance.BorderSize = 0
$deselectAllBtn.BackColor = $darkColors.border
$deselectAllBtn.ForeColor = $darkColors.text
$deselectAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$deselectAllBtn.Cursor = "Hand"

$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Location = New-Object System.Drawing.Point(550, 20)
$installBtn.Size = New-Object System.Drawing.Size(150, 40)
$installBtn.Text = "INSTALL SELECTED"
$installBtn.FlatStyle = "Flat"
$installBtn.FlatAppearance.BorderSize = 0
$installBtn.BackColor = $darkColors.success
$installBtn.ForeColor = "Black"
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$installBtn.Cursor = "Hand"

$fixOsBtn = New-Object System.Windows.Forms.Button
$fixOsBtn.Location = New-Object System.Drawing.Point(710, 20)
$fixOsBtn.Size = New-Object System.Drawing.Size(150, 40)
$fixOsBtn.Text = "RUN FIXOS"
$fixOsBtn.FlatStyle = "Flat"
$fixOsBtn.FlatAppearance.BorderSize = 0
$fixOsBtn.BackColor = $darkColors.accent
$fixOsBtn.ForeColor = "White"
$fixOsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fixOsBtn.Cursor = "Hand"

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(300, 28)
$statusLabel.Size = New-Object System.Drawing.Size(240, 25)
$statusLabel.Text = "✓ Ready"
$statusLabel.ForeColor = $darkColors.success
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)

$selectAllBtn.Add_Click({
    foreach ($category in $checkboxes.Keys) {
        foreach ($app in $checkboxes[$category].Keys) {
            $checkboxes[$category][$app].Checked = $true
        }
    }
    $statusLabel.Text = "✓ All applications selected"
})

$deselectAllBtn.Add_Click({
    foreach ($category in $checkboxes.Keys) {
        foreach ($app in $checkboxes[$category].Keys) {
            $checkboxes[$category][$app].Checked = $false
        }
    }
    $statusLabel.Text = "✓ All applications deselected"
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
        $statusLabel.Text = "✗ No applications selected"
        $statusLabel.ForeColor = $darkColors.error
        return
    }
    
    $installBtn.Enabled = $false
    $statusLabel.Text = "⚡ Installing $($selected.Count) applications..."
    $statusLabel.ForeColor = $darkColors.warning
    $form.Refresh()
    
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
        "Ubisoft" = "Ubisoft.Connect"
        "EA Desktop" = "ElectronicArts.EADesktop"
        "GOG" = "GOG.Galaxy"
        "Battle.net" = "Battle.net.Battle.net"
        "VLC" = "VideoLAN.VLC"
        "Spotify" = "Spotify.Spotify"
        "OBS Studio" = "OBSProject.OBSStudio"
        "GIMP" = "GIMP.GIMP"
        "HandBrake" = "Handbrake.Handbrake"
        "Audacity" = "Audacity.Audacity"
        "7-Zip" = "7zip.7zip"
        "PowerToys" = "Microsoft.PowerToys"
        "Terminal" = "Microsoft.WindowsTerminal"
        "Notepad++" = "Notepad++.Notepad++"
        "WinRAR" = "RARLab.WinRAR"
        "CPU-Z" = "CPUID.CPU-Z"
    }
    
    $success = 0
    $fail = 0
    
    foreach ($app in $selected) {
        $statusLabel.Text = "⚡ Installing: $app..."
        $form.Refresh()
        
        $result = Start-Process -FilePath "winget" -ArgumentList "install --id $($appIds[$app]) --exact --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        
        if ($result.ExitCode -eq 0) {
            $success++
        } else {
            $fail++
        }
    }
    
    $statusLabel.Text = "✓ Complete - $success installed, $fail failed"
    $statusLabel.ForeColor = if ($fail -eq 0) { $darkColors.success } else { $darkColors.warning }
    $installBtn.Enabled = $true
})

$fixOsBtn.Add_Click({
    $fixOsBtn.Enabled = $false
    $statusLabel.Text = "⚡ Running FixOs preset..."
    $statusLabel.ForeColor = $darkColors.warning
    $form.Refresh()
    
    try {
        iex (irm "DevelopmentSpace.pages.dev/FixOs.ps1")
        $statusLabel.Text = "✓ FixOs completed successfully"
        $statusLabel.ForeColor = $darkColors.success
    } catch {
        $statusLabel.Text = "✗ FixOs failed"
        $statusLabel.ForeColor = $darkColors.error
    }
    
    $fixOsBtn.Enabled = $true
})

$bottomPanel.Controls.AddRange(@($selectAllBtn, $deselectAllBtn, $statusLabel, $installBtn, $fixOsBtn))

$form.Controls.AddRange(@($menuStrip, $headerPanel, $mainPanel, $bottomPanel))
$form.MainMenuStrip = $menuStrip
$form.ShowDialog()
