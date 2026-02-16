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

$form = New-Object System.Windows.Forms.Form
$form.Text = "FixOs Toolbox"
$form.Size = New-Object System.Drawing.Size(900, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1a1a1a"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$logo = New-Object System.Windows.Forms.Label
$logo.Location = New-Object System.Drawing.Point(20, 20)
$logo.Size = New-Object System.Drawing.Size(400, 100)
$logo.Text = @"
███████╗██╗██╗  ██╗  ██████╗ ███████╗
██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝
█████╗  ██║ ╚███╔╝  ██║   ██║███████╗
██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║
██║     ██║██╔╝ ██╗ ╚██████╔╝███████║
╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝

TOOLBOX v$($ToolboxConfig.Version)
"@
$logo.ForeColor = "#00ff00"
$logo.Font = New-Object System.Drawing.Font("Consolas", 10)

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(20, 130)
$tabControl.Size = New-Object System.Drawing.Size(850, 400)

$tabs = @(
    "Browsers",
    "Dev Tools", 
    "Communication",
    "Gaming",
    "Media",
    "Utilities"
)

$appLists = @{
    "Browsers" = @(
        @{Name="Google Chrome"; Id="Google.Chrome"},
        @{Name="Brave"; Id="Brave.Brave"},
        @{Name="Firefox"; Id="Mozilla.Firefox"},
        @{Name="Edge"; Id="Microsoft.Edge"},
        @{Name="Thorium"; Id="Alex313031.Thorium"},
        @{Name="LibreWolf"; Id="LibreWolf.LibreWolf"}
    )
    "Dev Tools" = @(
        @{Name="VS Code"; Id="Microsoft.VisualStudioCode"},
        @{Name="Git"; Id="Git.Git"},
        @{Name="Docker"; Id="Docker.DockerDesktop"},
        @{Name="Python 3"; Id="Python.Python.3"},
        @{Name="Node.js"; Id="OpenJS.NodeJS"},
        @{Name="PowerShell 7"; Id="Microsoft.PowerShell"}
    )
    "Communication" = @(
        @{Name="Discord"; Id="Discord.Discord"},
        @{Name="Telegram"; Id="Telegram.TelegramDesktop"},
        @{Name="WhatsApp"; Id="WhatsApp.WhatsApp"},
        @{Name="Slack"; Id="SlackTechnologies.Slack"},
        @{Name="Zoom"; Id="Zoom.Zoom"}
    )
    "Gaming" = @(
        @{Name="Steam"; Id="Valve.Steam"},
        @{Name="Epic Games"; Id="EpicGames.EpicGamesLauncher"},
        @{Name="Ubisoft Connect"; Id="Ubisoft.Connect"},
        @{Name="EA Desktop"; Id="ElectronicArts.EADesktop"}
    )
    "Media" = @(
        @{Name="VLC"; Id="VideoLAN.VLC"},
        @{Name="OBS Studio"; Id="OBSProject.OBSStudio"},
        @{Name="Spotify"; Id="Spotify.Spotify"},
        @{Name="GIMP"; Id="GIMP.GIMP"},
        @{Name="HandBrake"; Id="Handbrake.Handbrake"}
    )
    "Utilities" = @(
        @{Name="7-Zip"; Id="7zip.7zip"},
        @{Name="WinRAR"; Id="RARLab.WinRAR"},
        @{Name="PowerToys"; Id="Microsoft.PowerToys"},
        @{Name="Windows Terminal"; Id="Microsoft.WindowsTerminal"},
        @{Name="Notepad++"; Id="Notepad++.Notepad++"}
    )
}

$checkboxes = @{}

foreach ($tabName in $tabs) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $tabName
    $tab.BackColor = "#2d2d2d"
    
    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Location = New-Object System.Drawing.Point(10, 10)
    $panel.Size = New-Object System.Drawing.Size(820, 320)
    $panel.AutoScroll = $true
    $panel.FlowDirection = "TopDown"
    $panel.WrapContents = $false
    
    $checkboxes[$tabName] = @{}
    
    foreach ($app in $appLists[$tabName]) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $app.Name
        $checkbox.Size = New-Object System.Drawing.Size(250, 30)
        $checkbox.ForeColor = "White"
        $checkbox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $checkbox.Tag = $app.Id
        $panel.Controls.Add($checkbox)
        $checkboxes[$tabName][$app.Name] = $checkbox
    }
    
    $tab.Controls.Add($panel)
    $tabControl.Controls.Add($tab)
}

$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(650, 540)
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$installButton.Text = "INSTALL"
$installButton.BackColor = "#00ff00"
$installButton.ForeColor = "Black"
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$installAllButton = New-Object System.Windows.Forms.Button
$installAllButton.Location = New-Object System.Drawing.Point(540, 540)
$installAllButton.Size = New-Object System.Drawing.Size(100, 30)
$installAllButton.Text = "SELECT ALL"
$installAllButton.BackColor = "#ffaa00"
$installAllButton.ForeColor = "Black"

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 540)
$outputBox.Size = New-Object System.Drawing.Size(500, 30)
$outputBox.ReadOnly = $true
$outputBox.BackColor = "#333333"
$outputBox.ForeColor = "#00ff00"
$outputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$outputBox.Text = "Ready"

function Update-Output {
    param([string]$Message, [string]$Color = "#00ff00")
    $outputBox.Text = $Message
    $outputBox.ForeColor = $Color
    $outputBox.Refresh()
}

$installButton.Add_Click({
    $installButton.Enabled = $false
    $selected = @()
    foreach ($tabName in $tabs) {
        foreach ($app in $appLists[$tabName]) {
            if ($checkboxes[$tabName][$app.Name].Checked) {
                $selected += @{Name=$app.Name; Id=$app.Id}
            }
        }
    }
    
    if ($selected.Count -eq 0) {
        Update-Output -Message "No applications selected" -Color "Red"
        $installButton.Enabled = $true
        return
    }
    
    Update-Output -Message "Installing $($selected.Count) applications..." -Color "Yellow"
    
    $total = $selected.Count
    $current = 0
    
    foreach ($app in $selected) {
        $current++
        Update-Output -Message "[$current/$total] Installing $($app.Name)..." -Color "#00ff00"
        $form.Refresh()
        
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $($app.Id) --exact --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Update-Output -Message "[$current/$total] ✓ $($app.Name) installed" -Color "#00ff00"
        } else {
            Update-Output -Message "[$current/$total] ✗ $($app.Name) failed" -Color "Red"
        }
        Start-Sleep -Milliseconds 500
    }
    
    Update-Output -Message "✓ Installation complete" -Color "#00ff00"
    $installButton.Enabled = $true
})

$installAllButton.Add_Click({
    $checked = $false
    foreach ($tabName in $tabs) {
        foreach ($app in $appLists[$tabName]) {
            if ($installAllButton.Text -eq "SELECT ALL") {
                $checkboxes[$tabName][$app.Name].Checked = $true
            } else {
                $checkboxes[$tabName][$app.Name].Checked = $false
            }
        }
    }
    
    if ($installAllButton.Text -eq "SELECT ALL") {
        $installAllButton.Text = "DESELECT ALL"
        Update-Output -Message "All applications selected" -Color "#ffaa00"
    } else {
        $installAllButton.Text = "SELECT ALL"
        Update-Output -Message "All applications deselected" -Color "#ffaa00"
    }
})

$fixOsButton = New-Object System.Windows.Forms.Button
$fixOsButton.Location = New-Object System.Drawing.Point(760, 540)
$fixOsButton.Size = New-Object System.Drawing.Size(100, 30)
$fixOsButton.Text = "RUN FIXOS"
$fixOsButton.BackColor = "#0066ff"
$fixOsButton.ForeColor = "White"
$fixOsButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$fixOsButton.Add_Click({
    $fixOsButton.Enabled = $false
    Update-Output -Message "Running FixOs preset..." -Color "Yellow"
    $form.Refresh()
    
    try {
        iex (irm "DevelopmentSpace.pages.dev/FixOs.ps1")
        Update-Output -Message "✓ FixOs completed successfully" -Color "#00ff00"
    } catch {
        Update-Output -Message "✗ FixOs failed: $_" -Color "Red"
    }
    
    $fixOsButton.Enabled = $true
})

$form.Controls.AddRange(@($logo, $tabControl, $installButton, $installAllButton, $outputBox, $fixOsButton))
$form.ShowDialog()
