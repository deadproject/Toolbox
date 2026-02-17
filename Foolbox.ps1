<#
- MORE INFO = https://github.com/DeveIopmentSpace/FixOs/tree/dev
- NOTES
    Version: 2.0.7
    Author: Project/Development Space
    Requires: Administrator privileges
#>

param([switch]$Install,[switch]$Silent)

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "=================================================================================" -ForegroundColor Red
    Write-Host "ERROR: This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "=================================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Current user: $env:USERNAME" -ForegroundColor Yellow
    Write-Host "Current token elevation: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    $null = Read-Host
    exit
}

Write-Host "=================================================================================" -ForegroundColor Green
Write-Host "ADMINISTRATOR PRIVILEGES CONFIRMED" -ForegroundColor Green
Write-Host "Running as: $env:USERNAME" -ForegroundColor Green
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor Green
Write-Host "OS: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)" -ForegroundColor Green
Write-Host "=================================================================================" -ForegroundColor Green
Write-Host ""

$fullscreenCode = @'
[DllImport("user32.dll")]
public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
public static extern bool SetForegroundWindow(IntPtr hWnd);
public const byte VK_F11 = 0x7A;
public const uint KEYEVENTF_EXTENDEDKEY = 0x0001;
public const uint KEYEVENTF_KEYUP = 0x0002;
'@

Write-Host "[INIT] Loading keyboard API..." -ForegroundColor Cyan
try { 
    Add-Type -MemberDefinition $fullscreenCode -Name KeyboardAPI -Namespace Win32 -ErrorAction Stop
    Write-Host "[OK] Keyboard API loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to load keyboard API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "[INIT] Attempting to set fullscreen mode..." -ForegroundColor Cyan
try {
    Start-Sleep -Milliseconds 500
    $windowHandle = [Win32.KeyboardAPI]::GetForegroundWindow()
    if ($windowHandle -ne [IntPtr]::Zero) {
        Write-Host "[DEBUG] Window handle obtained: $windowHandle" -ForegroundColor Gray
        [Win32.KeyboardAPI]::SetForegroundWindow($windowHandle)
        Start-Sleep -Milliseconds 100
        [Win32.KeyboardAPI]::keybd_event([Win32.KeyboardAPI]::VK_F11, 0, [Win32.KeyboardAPI]::KEYEVENTF_EXTENDEDKEY, 0)
        Start-Sleep -Milliseconds 50
        [Win32.KeyboardAPI]::keybd_event([Win32.KeyboardAPI]::VK_F11, 0, [Win32.KeyboardAPI]::KEYEVENTF_KEYUP, 0)
        Start-Sleep -Milliseconds 500
        Write-Host "[OK] Fullscreen mode activated" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Could not get foreground window handle" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[ERROR] Failed to set fullscreen: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "[INIT] Resizing console window..." -ForegroundColor Cyan
try {
    $maxWidth = $Host.UI.RawUI.MaxWindowSize.Width
    $maxHeight = $Host.UI.RawUI.MaxWindowSize.Height
    Write-Host "[DEBUG] Max window size: $maxWidth x $maxHeight" -ForegroundColor Gray
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($maxWidth, $maxHeight)
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($maxWidth, 9999)
    Write-Host "[OK] Console resized to maximum" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not set maximum size, using fallback: $($_.Exception.Message)" -ForegroundColor Yellow
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(120, 50)
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(120, 9999)
    Write-Host "[OK] Console resized to 120x50" -ForegroundColor Green
}

function Show-Menu {
    Clear-Host
    $bannerLines = @(
        " ███████╗██╗██╗  ██╗  ██████╗ ███████╗ ",
        " ██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝ ", 
        " █████╗  ██║ ╚███╔╝  ██║   ██║███████╗ ",
        " ██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║ ",
        " ██║     ██║██╔╝ ██╗ ╚██████╔╝███████║ ",
        " ╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝ ",
        "                                       ",
        "                                       ",
        " © 2026 Devspace. All rights reserved. ",
        "                                       "
    )

    function Write-CenteredLine {
        param([string]$Text,[ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor)
        try {
            $width = $Host.UI.RawUI.WindowSize.Width
            if ($width -eq 0) { $width = 80 }
            $padded = $Text.PadLeft(([int](($width + $Text.Length)/2)))
            Write-Host $padded -ForegroundColor $ForegroundColor
        } catch { 
            Write-Host $Text -ForegroundColor $ForegroundColor 
        }
    }

    Write-Host ""
    foreach ($line in $bannerLines) { Write-CenteredLine -Text $line }
    Write-CenteredLine -Text ""
    Write-CenteredLine -Text "[1] Install FixOS    [2] Learn More"
    Write-CenteredLine -Text ""
    Write-CenteredLine -Text "[3] Exit"
    Write-CenteredLine -Text ""

    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { Install-FixOS }
        "2" { 
            Write-Host "[ACTION] Opening GitHub repository..." -ForegroundColor Cyan
            Start-Process "https://github.com/DeveIopmentSpace/FixOs"
            Write-Host "[OK] Browser launched" -ForegroundColor Green
            Start-Sleep -Seconds 2
            Show-Menu 
        }
        "3" { 
            Write-Host "[ACTION] Exiting FixOS installer" -ForegroundColor Cyan
            exit 
        }
        default { 
            Write-Host "[ERROR] Invalid selection: '$choice'" -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-Menu 
        }
    }
}

function Set-BestPerformanceVisuals {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "VISUAL PERFORMANCE OPTIMIZATION" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    $visualReg = @(
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name = "VisualFXSetting"; Value = 2; Description = "Adjust for best performance"}
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "UserPreferencesMask"; Value = ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)); Type = "Binary"; Description = "Visual effects mask"}
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "MenuShowDelay"; Value = "0"; Type = "String"; Description = "Menu show delay"}
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "MinAnimate"; Value = "0"; Type = "String"; Description = "Minimize animation"}
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations"; Value = 0; Description = "Taskbar animations"}
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "AnimateMinMax"; Value = 0; Description = "Window minimize/maximize animations"}
    )
    
    $successCount = 0
    $failCount = 0
    
    foreach ($reg in $visualReg) {
        Write-Host "[CONFIG] $($reg.Description)..." -NoNewline -ForegroundColor Cyan
        try {
            if (-not (Test-Path $reg.Path)) { 
                New-Item -Path $reg.Path -Force -ErrorAction Stop | Out-Null
                Write-Host " [CREATED PATH] " -NoNewline -ForegroundColor Yellow
            }
            $type = if ($reg.ContainsKey("Type")) { $reg.Type } else { "DWord" }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type $type -Force -ErrorAction Stop
            Write-Host " [OK]" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
            $failCount++
        }
    }
    
    Write-Host "[SUMMARY] Visual registry tweaks: $successCount succeeded, $failCount failed" -ForegroundColor Yellow
    
    Write-Host "[CONFIG] Applying system-wide performance settings..." -ForegroundColor Cyan
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class VisualPerf {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, int lpvParam, int fuWinIni);
    public const int SPI_SETANIMATION = 0x0049;
    public const int SPI_SETUIEFFECTS = 0x103F;
    public static void SetBestPerformance() {
        SystemParametersInfo(SPI_SETANIMATION, 0, 0, 0x02);
        SystemParametersInfo(SPI_SETUIEFFECTS, 0, 0, 0x02);
    }
}
"@ -ErrorAction SilentlyContinue
    try { 
        [VisualPerf]::SetBestPerformance()
        Write-Host "[OK] System-wide performance settings applied" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to apply system-wide settings: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "[COMPLETE] Visual performance optimization finished" -ForegroundColor Green
}

function Set-HighPerformancePower {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "POWER PLAN OPTIMIZATION" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    Write-Host "[INFO] Available power schemes:" -ForegroundColor Cyan
    powercfg /list
    
    Write-Host "[CONFIG] Activating High Performance power plan..." -ForegroundColor Cyan
    try {
        $result = powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] High Performance power plan activated" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Could not activate High Performance: $result" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[ERROR] Failed to set power plan: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $timeoutSettings = @(
        @{Setting = "monitor-timeout-ac"; Description = "Monitor timeout (AC)"},
        @{Setting = "monitor-timeout-dc"; Description = "Monitor timeout (DC)"},
        @{Setting = "disk-timeout-ac"; Description = "Disk timeout (AC)"},
        @{Setting = "disk-timeout-dc"; Description = "Disk timeout (DC)"},
        @{Setting = "standby-timeout-ac"; Description = "Standby timeout (AC)"},
        @{Setting = "standby-timeout-dc"; Description = "Standby timeout (DC)"},
        @{Setting = "hibernate-timeout-ac"; Description = "Hibernate timeout (AC)"},
        @{Setting = "hibernate-timeout-dc"; Description = "Hibernate timeout (DC)"}
    )
    
    foreach ($setting in $timeoutSettings) {
        Write-Host "[CONFIG] Setting $($setting.Description) to 0 (never)..." -NoNewline -ForegroundColor Cyan
        try {
            $result = powercfg -change -$($setting.Setting) 0 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host " [OK]" -ForegroundColor Green
            } else {
                Write-Host " [FAILED: $result]" -ForegroundColor Red
            }
        } catch {
            Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
        }
    }
    
    Write-Host "[COMPLETE] Power plan optimization finished" -ForegroundColor Green
}

function Remove-EdgeCompletely {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "MICROSOFT EDGE REMOVAL" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "[WARNING] This operation removes Microsoft Edge completely from the system" -ForegroundColor Red
    Write-Host "[WARNING] This may affect some Windows features that depend on Edge" -ForegroundColor Red
    
    try {
        Write-Host "[PROCESS] Stopping Edge processes..." -ForegroundColor Cyan
        $edgeProcesses = Get-Process -Name "*edge*" -ErrorAction SilentlyContinue
        if ($edgeProcesses) {
            foreach ($proc in $edgeProcesses) {
                Write-Host "[STOP] $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
            }
            $edgeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Edge processes stopped" -ForegroundColor Green
        } else {
            Write-Host "[INFO] No Edge processes running" -ForegroundColor Gray
        }
    } catch {
        Write-Host "[ERROR] Failed to stop Edge processes: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $edgePaths = @(
        "C:\Program Files (x86)\Microsoft\Edge",
        "C:\Program Files (x86)\Microsoft\EdgeWebView",
        "C:\Program Files (x86)\Microsoft\EdgeUpdate",
        "C:\Program Files (x86)\Microsoft\EdgeCore",
        "C:\Windows\System32\Microsoft-Edge-Webview",
        "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe",
        "C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe",
        "$env:LOCALAPPDATA\Microsoft\Edge",
        "$env:ProgramData\Microsoft\Edge",
        "$env:ProgramFiles\Microsoft\Edge",
        "$env:ProgramFiles(x86)\Microsoft\Edge",
        "$env:LOCALAPPDATA\Microsoft\EdgeUpdate",
        "$env:APPDATA\Microsoft\Edge"
    )
    
    $removedPaths = 0
    $failedPaths = 0
    
    foreach ($path in $edgePaths) {
        Write-Host "[DELETE] $path..." -NoNewline -ForegroundColor Cyan
        if (Test-Path $path) {
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                Write-Host " [REMOVED]" -ForegroundColor Green
                $removedPaths++
            } catch {
                Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                $failedPaths++
            }
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    }
    
    Write-Host "[SUMMARY] Edge files: $removedPaths removed, $failedPaths failed" -ForegroundColor Yellow
    
    $edgeRegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Edge",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge",
        "HKLM:\SOFTWARE\Microsoft\EdgeUpdate",
        "HKCU:\SOFTWARE\Microsoft\Edge",
        "HKLM:\SOFTWARE\Policies\Microsoft\Edge",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE"
    )
    
    $removedReg = 0
    $failedReg = 0
    
    foreach ($regPath in $edgeRegPaths) {
        Write-Host "[REG-DELETE] $regPath..." -NoNewline -ForegroundColor Cyan
        if (Test-Path $regPath) {
            try {
                Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
                Write-Host " [REMOVED]" -ForegroundColor Green
                $removedReg++
            } catch {
                Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                $failedReg++
            }
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    }
    
    Write-Host "[SUMMARY] Edge registry keys: $removedReg removed, $failedReg failed" -ForegroundColor Yellow
    
    $edgeShortcuts = @(
        "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
        "C:\Users\Public\Desktop\Microsoft Edge.lnk",
        "$env:PUBLIC\Desktop\Microsoft Edge.lnk"
    )
    
    $removedShortcuts = 0
    $failedShortcuts = 0
    
    foreach ($shortcut in $edgeShortcuts) {
        Write-Host "[SHORTCUT] $shortcut..." -NoNewline -ForegroundColor Cyan
        if (Test-Path $shortcut) {
            try {
                Remove-Item -Path $shortcut -Force -ErrorAction Stop
                Write-Host " [REMOVED]" -ForegroundColor Green
                $removedShortcuts++
            } catch {
                Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                $failedShortcuts++
            }
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    }
    
    Write-Host "[SUMMARY] Edge shortcuts: $removedShortcuts removed, $failedShortcuts failed" -ForegroundColor Yellow
    
    Write-Host "[SCHEDULED TASKS] Removing Edge tasks..." -ForegroundColor Cyan
    $edgeTasks = Get-ScheduledTask -TaskName "*edge*" -ErrorAction SilentlyContinue
    if ($edgeTasks) {
        foreach ($task in $edgeTasks) {
            Write-Host "[TASK] Unregistering $($task.TaskName)..." -NoNewline -ForegroundColor Cyan
            try {
                Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction Stop
                Write-Host " [REMOVED]" -ForegroundColor Green
            } catch {
                Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "[INFO] No Edge scheduled tasks found" -ForegroundColor Gray
    }
    
    Write-Host "[COMPLETE] Microsoft Edge removal finished" -ForegroundColor Green
}

function Remove-AppxSafe {
    param([string]$AppName)
    
    Write-Host "[APPX] Processing $AppName..." -ForegroundColor Cyan
    
    try {
        $packages = Get-AppxPackage -Name $AppName -AllUsers -ErrorAction SilentlyContinue
        if ($packages) {
            foreach ($pkg in $packages) {
                Write-Host "[APPX] Removing $($pkg.PackageFullName)..." -NoNewline -ForegroundColor Cyan
                try {
                    Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Host " [REMOVED]" -ForegroundColor Green
                } catch {
                    Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "[APPX] No packages found for $AppName" -ForegroundColor Gray
        }
        
        $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$AppName*" }
        if ($provisioned) {
            foreach ($prov in $provisioned) {
                Write-Host "[PROVISIONED] Removing $($prov.DisplayName)..." -NoNewline -ForegroundColor Cyan
                try {
                    Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop
                    Write-Host " [REMOVED]" -ForegroundColor Green
                } catch {
                    Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                }
            }
        }
        return $true
    } catch {
        Write-Host "[ERROR] Failed to process $AppName: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-RegistrySafe {
    param([string]$Path, [string]$Name, [object]$Value, [string]$Type = "DWord")
    
    Write-Host "[REG] $Path\$Name = $Value ($Type)..." -NoNewline -ForegroundColor Cyan
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
            Write-Host " [PATH CREATED]" -NoNewline -ForegroundColor Yellow
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        Write-Host " [OK]" -ForegroundColor Green
        return $true
    } catch {
        Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
        return $false
    }
}

function Create-ToolboxShortcut {
    Write-Host "[SHORTCUT] Creating Toolbox desktop shortcut..." -ForegroundColor Cyan
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "Toolbox.lnk"
        $toolboxUrl = "https://raw.githubusercontent.com/DeveIopmentSpace/FixOs/dev/Toolbox/src/Toolbox.ps1"
        
        Write-Host "[SHORTCUT] Target: wt.exe" -ForegroundColor Gray
        Write-Host "[SHORTCUT] Arguments: -p `"Windows PowerShell`" -d `"$env:USERPROFILE`" powershell -Command `"irm '$toolboxUrl' | iex`"" -ForegroundColor Gray
        Write-Host "[SHORTCUT] Path: $shortcutPath" -ForegroundColor Gray
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "wt.exe"
        $Shortcut.Arguments = "-p `"Windows PowerShell`" -d `"$env:USERPROFILE`" powershell -Command `"irm '$toolboxUrl' | iex`""
        $Shortcut.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut.Description = "FixOs Toolbox"
        $Shortcut.IconLocation = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe,0"
        $Shortcut.Save()
        
        if (Test-Path $shortcutPath) {
            Write-Host "[OK] Toolbox shortcut created successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] Shortcut file not found after creation" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] Failed to create Toolbox shortcut: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Remove-CrapApps {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "BLOATWARE REMOVAL" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    $appsToRemove = @(
        "Microsoft.549981C3F5F10",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.BingSports",
        "Microsoft.BingFinance",
        "Microsoft.BingFoodAndDrink",
        "Microsoft.BingHealthAndFitness",
        "Microsoft.BingTravel",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal",
        "Microsoft.Office.OneNote",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.SkypeApp",
        "Microsoft.Wallet",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameCallableUI",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.Advertising.Xaml",
        "Microsoft.Todos",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.Windows.DevHome",
        "Clipchamp.Clipchamp",
        "Microsoft.Copilot",
        "Microsoft.WindowsCopilot",
        "Microsoft.LinkedIn",
        "Microsoft.Teams",
        "Microsoft.People",
        "Microsoft.MixedReality",
        "MicrosoftCorporationII.QuickAssist",
        "Microsoft.OutlookForWindows",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsStore",
        "Microsoft.StorePurchaseApp",
        "Microsoft.Widgets",
        "Microsoft.Windows.Photos",
        "Microsoft.Paint",
        "Microsoft.MSPaint",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsNotepad",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.Getstarted",
        "Microsoft.WebMediaExtensions",
        "Microsoft.WebpImageExtension",
        "Microsoft.HEIFImageExtension",
        "Microsoft.VP9VideoExtensions",
        "Microsoft.RawImageExtension",
        "Microsoft.HEVCVideoExtension",
        "Microsoft.DolbyAudioExtensions",
        "Microsoft.DolbyVisionExtensions",
        "Microsoft.MPEG2VideoExtension",
        "Microsoft.Win32WebViewHost",
        "Microsoft.DesktopAppInstaller",
        "Microsoft.Windows.Photos",
        "Microsoft.ScreenSketch",
        "Microsoft.Windows.SecHealthUI",
        "Microsoft.Windows.Cortana",
        "Microsoft.Windows.ContentDeliveryManager",
        "Microsoft.Windows.CloudExperienceHost",
        "Microsoft.Windows.DevicesFlow",
        "Microsoft.Windows.NarratorQuickStart",
        "Microsoft.Windows.OOBENetworkCaptivePortal",
        "Microsoft.Windows.OOBENetworkConnectionFlow",
        "Microsoft.Windows.ParentalControls",
        "Microsoft.Windows.PeopleExperienceHost",
        "Microsoft.Windows.PinningConfirmation",
        "Microsoft.Windows.PostOOBE",
        "Microsoft.Windows.RetailDemo",
        "Microsoft.Windows.SecureAssessmentBrowser",
        "Microsoft.Windows.ShellExperienceHost",
        "Microsoft.Windows.XGpuEjectDialog",
        "Microsoft.XboxGameCallableUI",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.Xbox.TCUI",
        "Microsoft.ECApp",
        "Microsoft.MicrosoftEdge",
        "Microsoft.MicrosoftEdge.Stable",
        "MicrosoftEdge",
        "Microsoft.Win32WebViewHost",
        "Microsoft.Windows.Apprep.ChxApp",
        "Microsoft.Windows.AssignedAccessLockApp",
        "Microsoft.Windows.CapturePicker",
        "Microsoft.Windows.CloudExperienceHost",
        "Microsoft.Windows.ContentDeliveryManager",
        "Microsoft.Windows.Cortana",
        "Microsoft.Windows.NarratorQuickStart",
        "Microsoft.Windows.PeopleExperienceHost",
        "Microsoft.Windows.PinningConfirmation",
        "Microsoft.Windows.ShellExperienceHost"
    )
    
    $totalApps = $appsToRemove.Count
    $removedApps = 0
    $failedApps = 0
    
    foreach ($app in $appsToRemove) {
        Write-Progress -Activity "Removing bloatware" -Status "Processing $app" -PercentComplete (($removedApps + $failedApps) / $totalApps * 100)
        $result = Remove-AppxSafe -AppName $app
        if ($result) {
            $removedApps++
        } else {
            $failedApps++
        }
    }
    
    Write-Progress -Activity "Removing bloatware" -Completed
    Write-Host "[SUMMARY] Bloatware removal: $removedApps apps processed, $failedApps had issues" -ForegroundColor Yellow
}

function Optimize-Services {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "SERVICE OPTIMIZATION" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    $servicesToDisable = @(
        @{Name = 'DiagTrack'; StartupType = 'Disabled'; Description = 'Connected User Experiences and Telemetry'},
        @{Name = 'dmwappushservice'; StartupType = 'Disabled'; Description = 'Device Management WAP Push'},
        @{Name = 'WSearch'; StartupType = 'Disabled'; Description = 'Windows Search'},
        @{Name = 'XboxGipSvc'; StartupType = 'Disabled'; Description = 'Xbox Accessory Management'},
        @{Name = 'XblAuthManager'; StartupType = 'Disabled'; Description = 'Xbox Live Auth Manager'},
        @{Name = 'XblGameSave'; StartupType = 'Disabled'; Description = 'Xbox Live Game Save'},
        @{Name = 'XboxNetApiSvc'; StartupType = 'Disabled'; Description = 'Xbox Live Networking'},
        @{Name = 'OneSyncSvc'; StartupType = 'Disabled'; Description = 'Sync Host'},
        @{Name = 'PcaSvc'; StartupType = 'Disabled'; Description = 'Program Compatibility Assistant'},
        @{Name = 'WpcMonSvc'; StartupType = 'Disabled'; Description = 'Parental Controls'},
        @{Name = 'wisvc'; StartupType = 'Disabled'; Description = 'Windows Insider Service'},
        @{Name = 'RetailDemo'; StartupType = 'Disabled'; Description = 'Retail Demo Service'},
        @{Name = 'MessagingService'; StartupType = 'Disabled'; Description = 'Messaging Service'},
        @{Name = 'lfsvc'; StartupType = 'Disabled'; Description = 'Geolocation Service'},
        @{Name = 'MapsBroker'; StartupType = 'Disabled'; Description = 'Downloaded Maps Manager'},
        @{Name = 'PimIndexMaintenanceSvc'; StartupType = 'Disabled'; Description = 'Contact Data'},
        @{Name = 'UnistoreSvc'; StartupType = 'Disabled'; Description = 'User Data Storage'},
        @{Name = 'UserDataSvc'; StartupType = 'Disabled'; Description = 'User Data Access'},
        @{Name = 'WpnService'; StartupType = 'Disabled'; Description = 'Windows Push Notifications'},
        @{Name = 'WpnUserService'; StartupType = 'Disabled'; Description = 'Windows Push Notifications User'},
        @{Name = 'WdNisSvc'; StartupType = 'Disabled'; Description = 'Microsoft Defender Antivirus Network Inspection'},
        @{Name = 'Sense'; StartupType = 'Disabled'; Description = 'Windows Defender Advanced Threat Protection'},
        @{Name = 'wscsvc'; StartupType = 'Disabled'; Description = 'Security Center'},
        @{Name = 'SysMain'; StartupType = 'Disabled'; Description = 'SysMain (Superfetch)'},
        @{Name = 'edgeupdate'; StartupType = 'Disabled'; Description = 'Microsoft Edge Update'},
        @{Name = 'edgeupdatem'; StartupType = 'Disabled'; Description = 'Microsoft Edge Update (edgeupdatem)'},
        @{Name = 'MicrosoftEdgeElevationService'; StartupType = 'Disabled'; Description = 'Microsoft Edge Elevation Service'},
        @{Name = 'BcastDVRUserService'; StartupType = 'Disabled'; Description = 'Broadcast DVR'},
        @{Name = 'CaptureService'; StartupType = 'Disabled'; Description = 'Capture Service'},
        @{Name = 'cbdhsvc'; StartupType = 'Disabled'; Description = 'Clipboard User Service'},
        @{Name = 'ConsentUxUserSvc'; StartupType = 'Disabled'; Description = 'Consent UX'},
        @{Name = 'CredentialEnrollmentManagerUserSvc'; StartupType = 'Disabled'; Description = 'Credential Enrollment Manager'},
        @{Name = 'DeviceAssociationBrokerSvc'; StartupType = 'Disabled'; Description = 'Device Association Broker'},
        @{Name = 'DevicePickerUserSvc'; StartupType = 'Disabled'; Description = 'Device Picker'},
        @{Name = 'DevicesFlowUserSvc'; StartupType = 'Disabled'; Description = 'Devices Flow'},
        @{Name = 'NPSMSvc'; StartupType = 'Disabled'; Description = 'Network Protection Service'},
        @{Name = 'P9RdrService'; StartupType = 'Disabled'; Description = 'Phone Service'},
        @{Name = 'PenService'; StartupType = 'Disabled'; Description = 'Pen Service'},
        @{Name = 'PrintWorkflowUserSvc'; StartupType = 'Disabled'; Description = 'Print Workflow'},
        @{Name = 'UdkUserSvc'; StartupType = 'Disabled'; Description = 'UDK User Service'},
        @{Name = 'autotimesvc'; StartupType = 'Disabled'; Description = 'Auto Time Zone Updater'},
        @{Name = 'tzautoupdate'; StartupType = 'Disabled'; Description = 'Time Zone Auto Update'},
        @{Name = 'shpamsvc'; StartupType = 'Disabled'; Description = 'Shared PC Account Manager'},
        @{Name = 'PhoneSvc'; StartupType = 'Disabled'; Description = 'Phone Service'},
        @{Name = 'RemoteRegistry'; StartupType = 'Disabled'; Description = 'Remote Registry'},
        @{Name = 'RemoteAccess'; StartupType = 'Disabled'; Description = 'Routing and Remote Access'},
        @{Name = 'SessionEnv'; StartupType = 'Disabled'; Description = 'Remote Desktop Configuration'},
        @{Name = 'TermService'; StartupType = 'Disabled'; Description = 'Remote Desktop Services'},
        @{Name = 'UmRdpService'; StartupType = 'Disabled'; Description = 'Remote Desktop Services UserMode'},
        @{Name = 'SharedAccess'; StartupType = 'Disabled'; Description = 'Internet Connection Sharing'},
        @{Name = 'hidserv'; StartupType = 'Disabled'; Description = 'Human Interface Device Service'},
        @{Name = 'WbioSrvc'; StartupType = 'Disabled'; Description = 'Windows Biometric Service'},
        @{Name = 'FrameServer'; StartupType = 'Disabled'; Description = 'Windows Camera Frame Server'},
        @{Name = 'StiSvc'; StartupType = 'Disabled'; Description = 'Windows Image Acquisition'},
        @{Name = 'WiaRpc'; StartupType = 'Disabled'; Description = 'Still Image Acquisition Events'},
        @{Name = 'icssvc'; StartupType = 'Disabled'; Description = 'Windows Mobile Hotspot Service'},
        @{Name = 'WlanSvc'; StartupType = 'Disabled'; Description = 'WLAN AutoConfig'},
        @{Name = 'WwanSvc'; StartupType = 'Disabled'; Description = 'WWAN AutoConfig'},
        @{Name = 'Spooler'; StartupType = 'Disabled'; Description = 'Print Spooler'},
        @{Name = 'Themes'; StartupType = 'Disabled'; Description = 'Themes'},
        @{Name = 'TabletInputService'; StartupType = 'Disabled'; Description = 'Touch Keyboard and Handwriting'},
        @{Name = 'TextInputManagementService'; StartupType = 'Disabled'; Description = 'Text Input Management'},
        @{Name = 'FontCache'; StartupType = 'Disabled'; Description = 'Windows Font Cache'}
    )
    
    $servicesToManual = @(
        @{Name = 'BITS'; StartupType = 'Manual'; Description = 'Background Intelligent Transfer'},
        @{Name = 'wuauserv'; StartupType = 'Manual'; Description = 'Windows Update'},
        @{Name = 'DoSvc'; StartupType = 'Manual'; Description = 'Delivery Optimization'},
        @{Name = 'UsoSvc'; StartupType = 'Manual'; Description = 'Update Orchestrator'},
        @{Name = 'W32Time'; StartupType = 'Manual'; Description = 'Windows Time'},
        @{Name = 'Schedule'; StartupType = 'Manual'; Description = 'Task Scheduler'},
        @{Name = 'TrustedInstaller'; StartupType = 'Manual'; Description = 'Windows Modules Installer'},
        @{Name = 'AudioEndpointBuilder'; StartupType = 'Manual'; Description = 'Audio Endpoint Builder'},
        @{Name = 'Audiosrv'; StartupType = 'Manual'; Description = 'Windows Audio'},
        @{Name = 'CDPSvc'; StartupType = 'Manual'; Description = 'Connected Devices Platform'},
        @{Name = 'CDPUserSvc'; StartupType = 'Manual'; Description = 'Connected Devices Platform User'},
        @{Name = 'CoreMessagingRegistrar'; StartupType = 'Manual'; Description = 'CoreMessaging'},
        @{Name = 'StateRepository'; StartupType = 'Manual'; Description = 'State Repository'},
        @{Name = 'StorSvc'; StartupType = 'Manual'; Description = 'Storage Service'},
        @{Name = 'TimeBrokerSvc'; StartupType = 'Manual'; Description = 'Time Broker'},
        @{Name = 'TokenBroker'; StartupType = 'Manual'; Description = 'Web Account Manager'},
        @{Name = 'UserManager'; StartupType = 'Manual'; Description = 'User Manager'},
        @{Name = 'VaultSvc'; StartupType = 'Manual'; Description = 'Credential Manager'},
        @{Name = 'WinHttpAutoProxySvc'; StartupType = 'Manual'; Description = 'WinHTTP Web Proxy Auto-Discovery'},
        @{Name = 'Wcmsvc'; StartupType = 'Manual'; Description = 'Windows Connection Manager'},
        @{Name = 'nsi'; StartupType = 'Manual'; Description = 'Network Store Interface'},
        @{Name = 'iphlpsvc'; StartupType = 'Manual'; Description = 'IP Helper'},
        @{Name = 'Dnscache'; StartupType = 'Manual'; Description = 'DNS Client'},
        @{Name = 'Dhcp'; StartupType = 'Manual'; Description = 'DHCP Client'},
        @{Name = 'EventLog'; StartupType = 'Manual'; Description = 'Windows Event Log'},
        @{Name = 'EventSystem'; StartupType = 'Manual'; Description = 'COM+ Event System'},
        @{Name = 'gpsvc'; StartupType = 'Manual'; Description = 'Group Policy Client'},
        @{Name = 'ProfSvc'; StartupType = 'Manual'; Description = 'User Profile Service'},
        @{Name = 'Power'; StartupType = 'Manual'; Description = 'Power'},
        @{Name = 'DcomLaunch'; StartupType = 'Manual'; Description = 'DCOM Server Process Launcher'},
        @{Name = 'RpcSs'; StartupType = 'Manual'; Description = 'Remote Procedure Call'},
        @{Name = 'RpcEptMapper'; StartupType = 'Manual'; Description = 'RPC Endpoint Mapper'},
        @{Name = 'SamSs'; StartupType = 'Manual'; Description = 'Security Accounts Manager'},
        @{Name = 'LanmanServer'; StartupType = 'Manual'; Description = 'Server'},
        @{Name = 'LanmanWorkstation'; StartupType = 'Manual'; Description = 'Workstation'},
        @{Name = 'PlugPlay'; StartupType = 'Manual'; Description = 'Plug and Play'},
        @{Name = 'SENS'; StartupType = 'Manual'; Description = 'System Event Notification'},
        @{Name = 'ShellHWDetection'; StartupType = 'Manual'; Description = 'Shell Hardware Detection'},
        @{Name = 'TrkWks'; StartupType = 'Manual'; Description = 'Distributed Link Tracking Client'},
        @{Name = 'tiledatamodelsvc'; StartupType = 'Manual'; Description = 'Tile Data Model'},
        @{Name = 'BrokerInfrastructure'; StartupType = 'Manual'; Description = 'Background Tasks Infrastructure'},
        @{Name = 'SystemEventsBroker'; StartupType = 'Manual'; Description = 'System Events Broker'},
        @{Name = 'CryptSvc'; StartupType = 'Manual'; Description = 'Cryptographic Services'},
        @{Name = 'DPS'; StartupType = 'Manual'; Description = 'Diagnostic Policy Service'},
        @{Name = 'MpsSvc'; StartupType = 'Manual'; Description = 'Windows Firewall'},
        @{Name = 'mpssvc'; StartupType = 'Manual'; Description = 'Windows Firewall'},
        @{Name = 'BFE'; StartupType = 'Manual'; Description = 'Base Filtering Engine'},
        @{Name = 'KeyIso'; StartupType = 'Manual'; Description = 'CNG Key Isolation'},
        @{Name = 'Netlogon'; StartupType = 'Manual'; Description = 'Netlogon'},
        @{Name = 'NlaSvc'; StartupType = 'Manual'; Description = 'Network Location Awareness'},
        @{Name = 'PolicyAgent'; StartupType = 'Manual'; Description = 'IPsec Policy Agent'},
        @{Name = 'SgrmBroker'; StartupType = 'Manual'; Description = 'System Guard Runtime Monitor'},
        @{Name = 'WinDefend'; StartupType = 'Manual'; Description = 'Microsoft Defender Antivirus'},
        @{Name = 'SecurityHealthService'; StartupType = 'Manual'; Description = 'Windows Security Health Service'},
        @{Name = 'wcncsvc'; StartupType = 'Manual'; Description = 'Windows Connect Now'},
        @{Name = 'WdiServiceHost'; StartupType = 'Manual'; Description = 'Diagnostic Service Host'},
        @{Name = 'WdiSystemHost'; StartupType = 'Manual'; Description = 'Diagnostic System Host'},
        @{Name = 'WebClient'; StartupType = 'Manual'; Description = 'WebClient'},
        @{Name = 'WinRM'; StartupType = 'Manual'; Description = 'Windows Remote Management'},
        @{Name = 'wmiApSrv'; StartupType = 'Manual'; Description = 'WMI Performance Adapter'},
        @{Name = 'WMPNetworkSvc'; StartupType = 'Manual'; Description = 'Windows Media Player Network Sharing'},
        @{Name = 'WSService'; StartupType = 'Manual'; Description = 'Windows Store Service'},
        @{Name = 'vacsvc'; StartupType = 'Manual'; Description = 'Volume Activation'},
        @{Name = 'vmicguestinterface'; StartupType = 'Manual'; Description = 'Hyper-V Guest Interface'},
        @{Name = 'vmicheartbeat'; StartupType = 'Manual'; Description = 'Hyper-V Heartbeat'},
        @{Name = 'vmickvpexchange'; StartupType = 'Manual'; Description = 'Hyper-V Data Exchange'},
        @{Name = 'vmicrdv'; StartupType = 'Manual'; Description = 'Hyper-V Remote Desktop Virtualization'},
        @{Name = 'vmicshutdown'; StartupType = 'Manual'; Description = 'Hyper-V Guest Shutdown'},
        @{Name = 'vmictimesync'; StartupType = 'Manual'; Description = 'Hyper-V Time Synchronization'},
        @{Name = 'vmicvmsession'; StartupType = 'Manual'; Description = 'Hyper-V PowerShell Direct'},
        @{Name = 'vmicvss'; StartupType = 'Manual'; Description = 'Hyper-V Volume Shadow Copy'},
        @{Name = 'VSS'; StartupType = 'Manual'; Description = 'Volume Shadow Copy'},
        @{Name = 'W3LOGSVC'; StartupType = 'Manual'; Description = 'W3C Logging Service'},
        @{Name = 'WAS'; StartupType = 'Manual'; Description = 'Windows Process Activation'},
        @{Name = 'WcsPlugInService'; StartupType = 'Manual'; Description = 'Windows Color System'},
        @{Name = 'WdBoot'; StartupType = 'Manual'; Description = 'Microsoft Defender Antivirus Boot Driver'},
        @{Name = 'WdFilter'; StartupType = 'Manual'; Description = 'Microsoft Defender Antivirus Filter'},
        @{Name = 'WdNisDrv'; StartupType = 'Manual'; Description = 'Microsoft Defender Antivirus Network Inspection Driver'},
        @{Name = 'WFDSConMgrSvc'; StartupType = 'Manual'; Description = 'Wi-Fi Direct Services Connection Manager'},
        @{Name = 'Winmgmt'; StartupType = 'Manual'; Description = 'Windows Management Instrumentation'},
        @{Name = 'WManSvc'; StartupType = 'Manual'; Description = 'Windows Management Service'},
        @{Name = 'FontCache3.0.0.0'; StartupType = 'Manual'; Description = 'Windows Font Cache 3.0'},
        @{Name = 'BthAvctpSvc'; StartupType = 'Manual'; Description = 'AVCTP service'},
        @{Name = 'bthserv'; StartupType = 'Manual'; Description = 'Bluetooth Support Service'},
        @{Name = 'BluetoothUserService'; StartupType = 'Manual'; Description = 'Bluetooth User Service'},
        @{Name = 'BthHFSrv'; StartupType = 'Manual'; Description = 'Bluetooth Handsfree Service'},
        @{Name = 'UevAgentService'; StartupType = 'Manual'; Description = 'User Experience Virtualization'}
    )
    
    Write-Host "[SERVICES] Configuring services (this may take a while)..." -ForegroundColor Cyan
    
    $allServices = $servicesToDisable + $servicesToManual
    $totalServices = $allServices.Count
    $processedServices = 0
    
    foreach ($service in $allServices) {
        $processedServices++
        Write-Progress -Activity "Configuring services" -Status "$($service.Description) ($($service.Name))" -PercentComplete (($processedServices) / $totalServices * 100)
        
        Write-Host "[SERVICE] $($service.Name) - $($service.Description) -> $($service.StartupType)..." -NoNewline -ForegroundColor Cyan
        try {
            $svc = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
            if ($svc) {
                $currentStartup = $svc.StartType
                Set-Service -Name $service.Name -StartupType $service.StartupType -ErrorAction Stop
                Write-Host " [OK (was $currentStartup)]" -ForegroundColor Green
                
                if ($svc.Status -eq 'Running' -and $service.StartupType -eq 'Disabled') {
                    Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue
                    Write-Host "         [STOPPED]" -ForegroundColor Yellow
                }
            } else {
                Write-Host " [NOT FOUND]" -ForegroundColor Gray
            }
        } catch {
            Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
        }
    }
    
    Write-Progress -Activity "Configuring services" -Completed
    
    Write-Host "[SCHEDULED TASKS] Disabling unnecessary tasks..." -ForegroundColor Cyan
    
    $tasksToDisable = @(
        "Microsoft\Windows\Application Experience\*",
        "Microsoft\Windows\Customer Experience Improvement Program\*",
        "Microsoft\Windows\DiskDiagnostic\*",
        "Microsoft\Windows\Feedback\*",
        "Microsoft\Windows\Location\*",
        "Microsoft\Windows\Maps\*",
        "Microsoft\Windows\Media Center\*",
        "Microsoft\Windows\PI\*",
        "Microsoft\Windows\Power Efficiency Diagnostics\*",
        "Microsoft\Windows\Windows Error Reporting\*",
        "Microsoft\Windows\WindowsUpdate\*",
        "Microsoft\Office\*",
        "Microsoft\XblGameSave\*",
        "Microsoft\Xbox\*",
        "Microsoft\Windows\CloudExperienceHost\*",
        "Microsoft\Windows\Speech\*",
        "Microsoft\Windows\Work Folders\*",
        "Microsoft\Windows\WDI\*",
        "Microsoft\Windows\USB\*",
        "Microsoft\Windows\TPM\*",
        "Microsoft\Windows\Time Zone\*",
        "Microsoft\Windows\TextServicesFramework\*",
        "Microsoft\Windows\Sysmain\*",
        "Microsoft\Windows\SpacePort\*",
        "Microsoft\Windows\SoftwareProtectionPlatform\*",
        "Microsoft\Windows\SettingSync\*",
        "Microsoft\Windows\SharedPC\*",
        "Microsoft\Windows\Shell\*",
        "Microsoft\Windows\Servicing\*",
        "Microsoft\Windows\SecurityAndMaintenance\*",
        "Microsoft\Windows\SecureBoot\*",
        "Microsoft\Windows\RecoveryEnvironment\*",
        "Microsoft\Windows\PushToInstall\*",
        "Microsoft\Windows\Plug and Play\*",
        "Microsoft\Windows\Pin\*",
        "Microsoft\Windows\PerfTrack\*",
        "Microsoft\Windows\Notification\*",
        "Microsoft\Windows\NetTrace\*",
        "Microsoft\Windows\Network\*",
        "Microsoft\Windows\MUI\*",
        "Microsoft\Windows\MemoryDiagnostic\*",
        "Microsoft\Windows\Media Protection\*",
        "Microsoft\Windows\Management\*",
        "Microsoft\Windows\Maintenance\*",
        "Microsoft\Windows\LanguageComponents\*",
        "Microsoft\Windows\InstallService\*",
        "Microsoft\Windows\Input\*",
        "Microsoft\Windows\Hello\*",
        "Microsoft\Windows\Handwriting\*",
        "Microsoft\Windows\GameDVR\*",
        "Microsoft\Windows\ErrorDetails\*",
        "Microsoft\Windows\EnterpriseMgmt\*",
        "Microsoft\Windows\EDP\*",
        "Microsoft\Windows\DxgKrnl\*",
        "Microsoft\Windows\DUSM\*",
        "Microsoft\Windows\DiskFootprint\*",
        "Microsoft\Windows\Diagnosis\*",
        "Microsoft\Windows\DeviceInformation\*",
        "Microsoft\Windows\Device Setup\*",
        "Microsoft\Windows\Data Integrity Scan\*",
        "Microsoft\Windows\Clip\*",
        "Microsoft\Windows\CloudRestore\*",
        "Microsoft\Windows\Chkdsk\*",
        "Microsoft\Windows\Cellular\*",
        "Microsoft\Windows\BitLocker\*",
        "Microsoft\Windows\Biometrics\*",
        "Microsoft\Windows\Autochk\*",
        "Microsoft\Windows\AppxDeploymentClient\*",
        "Microsoft\Windows\AppID\*",
        "Microsoft\Windows\AppListBackup\*",
        "Microsoft\Windows\AppxDeployment\*",
        "Microsoft\Windows\ApplicationData\*",
        "Microsoft\Windows\AgentActivationRuntime\*",
        "Microsoft\Windows\ActionQueue\*"
    )
    
    $totalTasks = $tasksToDisable.Count
    $taskCounter = 0
    
    foreach ($taskPath in $tasksToDisable) {
        $taskCounter++
        Write-Progress -Activity "Disabling scheduled tasks" -Status "Task path: $taskPath" -PercentComplete (($taskCounter) / $totalTasks * 100)
        
        $tasks = Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue
        if ($tasks) {
            foreach ($task in $tasks) {
                Write-Host "[TASK] Disabling $($task.TaskName)..." -NoNewline -ForegroundColor Cyan
                try {
                    Disable-ScheduledTask -TaskName $task.TaskName -ErrorAction Stop | Out-Null
                    Write-Host " [DISABLED]" -ForegroundColor Green
                } catch {
                    Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Progress -Activity "Disabling scheduled tasks" -Completed
    Write-Host "[COMPLETE] Service optimization finished" -ForegroundColor Green
}

function Disable-Telemetry {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "TELEMETRY DISABLEMENT" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    $telemetryRegistries = @(
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0; Description = "Disable telemetry"}
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0; Description = "Disable telemetry (alt)"}
        @{Path = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0; Description = "Disable telemetry (32-bit)"}
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "DoNotShowFeedbackNotifications"; Value = 1; Description = "Disable feedback notifications"}
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowDeviceNameInTelemetry"; Value = 0; Description = "Disable device name in telemetry"}
    )
    
    foreach ($reg in $telemetryRegistries) {
        Set-RegistrySafe -Path $reg.Path -Name $reg.Name -Value $reg.Value
    }
    
    Write-Host "[COMPLETE] Telemetry disablement finished" -ForegroundColor Green
}

function Set-Wallpaper {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "WALLPAPER SETUP" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    $wallUrl = 'https://github.com/DeveIopmentSpace/FixOs/blob/dev/assets/wallpaper-dev.png?raw=true'
    $wallPath = Join-Path $env:PUBLIC 'FixOs-Wallpaper.png'
    
    Write-Host "[DOWNLOAD] Downloading wallpaper from GitHub..." -ForegroundColor Cyan
    Write-Host "[URL] $wallUrl" -ForegroundColor Gray
    Write-Host "[DEST] $wallPath" -ForegroundColor Gray
    
    try {
        Invoke-WebRequest -Uri $wallUrl -OutFile $wallPath -ErrorAction Stop
        Write-Host "[OK] Wallpaper downloaded successfully" -ForegroundColor Green
        
        if (Test-Path $wallPath) {
            Write-Host "[VERIFY] File size: $((Get-Item $wallPath).Length) bytes" -ForegroundColor Gray
            
            Write-Host "[APPLY] Setting wallpaper..." -ForegroundColor Cyan
            Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue
            
            $result = [Wallpaper]::SystemParametersInfo(20, 0, $wallPath, 0x01 -bor 0x02)
            if ($result -ne 0) {
                Write-Host "[OK] Wallpaper applied successfully" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] SystemParametersInfo returned $result" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[ERROR] Wallpaper file not found after download" -ForegroundColor Red
        }
    } catch {
        Write-Host "[ERROR] Failed to download/set wallpaper: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-WindowsOptimization {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "WINDOWS OPTIMIZATION" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "[ERROR] Not running as Administrator!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "[EXECUTION] Setting execution policy to Bypass..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    
    Remove-CrapApps
    Optimize-Services
    Disable-Telemetry
    Set-Wallpaper
    Create-ToolboxShortcut
    Remove-EdgeCompletely
    
    Write-Host "[COMPLETE] Windows optimization finished" -ForegroundColor Green
    return $true
}

function Set-RegistryForce {
    param([string]$Path,[string]$Name,[string]$Type,[string]$Value,[string]$Action = "Add")
    
    Write-Host "[REG] $Path\$Name" -NoNewline -ForegroundColor Cyan
    
    try {
        if ($Action -eq "Add") {
            if (-not (Test-Path $Path)) {
                New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
                Write-Host " [PATH CREATED]" -NoNewline -ForegroundColor Yellow
            }
            New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction Stop | Out-Null
            Write-Host " [SET: $Value ($Type)]" -ForegroundColor Green
        } elseif ($Action -eq "Delete") {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction Stop | Out-Null
            Write-Host " [DELETED]" -ForegroundColor Green
        }
    } catch {
        Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
    }
}

function Remove-RegistryKeyForce {
    param([string]$Path)
    
    Write-Host "[REG-KEY] $Path..." -NoNewline -ForegroundColor Cyan
    
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop | Out-Null
            Write-Host " [REMOVED]" -ForegroundColor Green
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    } catch {
        Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
    }
}

function Apply-RegistryTweaks {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "REGISTRY TWEAKS" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    
    Write-Host "[EXECUTION] Setting execution policy to Bypass..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "[SECTION] System Policies" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightOnLockScreen" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightActiveUser" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Windows Update Blocker" -ForegroundColor Yellow
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate"
    
    Write-Host "[SECTION] Chat & Communication" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Type "DWord" -Value 3
    
    Write-Host "[SECTION] Start Menu Configuration" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins" -Type "String" -Value '{ "pinnedList": [] }'
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_ProviderSet" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_WinningProvider" -Type "String" -Value "B5292708-1619-419B-9923-E5D9F3925E71"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins" -Type "String" -Value '{ "pinnedList": [] }'
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins_LastWrite" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] File System" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] News & Interests" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Security & Encryption" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" -Name "TCGSecurityActivationDisabled" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Windows Update Control" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type "DWord" -Value 3
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays" -Type "DWord" -Value 365
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdates" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays" -Type "DWord" -Value 365
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Type "String" -Value "22H2"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Type "String" -Value "Windows 10"
    
    Write-Host "[SECTION] Cortana & Search" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Activity Feed" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Location Services" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Windows Ink" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Advertising" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Error Reporting" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Delivery Optimization" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Remote Assistance" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Driver Search" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Performance Tweaks" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type "DWord" -Value 10
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type "DWord" -Value 30
    
    Write-Host "[SECTION] Gaming Priority" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Type "DWord" -Value 8
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type "DWord" -Value 6
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type "String" -Value "High"
    
    Write-Host "[SECTION] Taskbar" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Edge Removal" -ForegroundColor Yellow
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    
    Write-Host "[SECTION] Wi-Fi Sense" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Storage Sense" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Game DVR" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] Automatic Restart" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] OneDrive" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Push To Install" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" -Name "DisablePushToInstall" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Cloud Content" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableConsumerAccountStateContent" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] Edge Uninstall Keys" -ForegroundColor Yellow
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"
    
    Write-Host "[SECTION] HKCU - Content Delivery" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OEMPreInstalledAppsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Privacy" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "IsMiEnabled" -Type "DWord" -Value 0
    
    Remove-RegistryKeyForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
    Remove-RegistryKeyForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"
    
    Write-Host "[SECTION] HKCU - Speech" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Copilot" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Notepad" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Notepad" -Name "ShowStoreBanner" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Startup" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -Action "Delete"
    
    Write-Host "[SECTION] HKCU - Taskbar" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Start Menu" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - People" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Task View" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Feeds" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type "DWord" -Value 2
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Notifications" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Sync" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "SettingSyncEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "LocationServicesEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Personalization" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Feedback" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "AutoSample" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "ServiceEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Tracking" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Background Apps" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - App Diagnostics" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppDiagnostics" -Name "AppDiagnosticsEnabled" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Delivery Optimization" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "DODownloadMode" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Authentication" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication" -Name "UseSignInInfo" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Maps" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Maps" -Name "AutoDownload" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - SIUF" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Explorer" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SettingsPageVisibility" -Type "String" -Value "hide:home"
    
    Write-Host "[SECTION] HKCU - Control Panel" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Meet Now" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Developer Settings" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDeveloperSettings" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Notification Center" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Game DVR" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type "DWord" -Value 2
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Type "DWord" -Value 0
    
    Write-Host "[SECTION] HKCU - Search Suggestions" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Keyboard" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type "String" -Value "2"
    
    Write-Host "[SECTION] HKCU - Mouse" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"
    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"
    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"
    
    Write-Host "[SECTION] HKCU - Sticky Keys" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type "String" -Value "506"
    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "HotkeyFlags" -Type "String" -Value "58"
    
    Write-Host "[SECTION] HKCU - Taskbar Appearance" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAcrylicOpacity" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Windows AI" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Windows AI" -Name "TurnOffSavingSnapshots" -Type "DWord" -Value 1
    
    Write-Host "[SECTION] HKCU - Audio" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Multimedia\Audio" -Name "UserDuckingPreference" -Type "DWord" -Value 3
    
    Write-Host "[SECTION] UAC" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Type "DWord" -Value 3
    
    Write-Host "[SECTION] Desktop Icons" -ForegroundColor Yellow
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
    
    Write-Host "[SECTION] Settings Visibility" -ForegroundColor Yellow
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SettingsPageVisibility" -Type "String" -Value "hide:home"
    
    Write-Host "[SECTION] Teams Removal" -ForegroundColor Yellow
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "LinkedIn" -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "[SECTION] Computer Name" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Hostname" -Value "FixOs" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Hostname" -Value "FixOs" -Force | Out-Null
    
    Write-Host "[SECTION] OneDrive Uninstall" -ForegroundColor Yellow
    Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "[ONEDRIVE] Stopped OneDrive processes" -ForegroundColor Green
    
    $OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
    $OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    
    if (Test-Path $OneDriveSetup32) { 
        Write-Host "[ONEDRIVE] Running uninstaller (32-bit)..." -NoNewline -ForegroundColor Cyan
        Start-Process $OneDriveSetup32 "/uninstall" -Wait -ErrorAction SilentlyContinue
        Write-Host " [OK]" -ForegroundColor Green
    }
    if (Test-Path $OneDriveSetup64) { 
        Write-Host "[ONEDRIVE] Running uninstaller (64-bit)..." -NoNewline -ForegroundColor Cyan
        Start-Process $OneDriveSetup64 "/uninstall" -Wait -ErrorAction SilentlyContinue
        Write-Host " [OK]" -ForegroundColor Green
    }
    
    $oneDriveDirs = @(
        "$env:SystemDrive\OneDriveTemp",
        "$env:USERPROFILE\OneDrive",
        "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive",
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
        "$env:ProgramData\Microsoft OneDrive",
        "$env:LOCALAPPDATA\Microsoft\OneDrive",
        "$env:ProgramFiles\Microsoft OneDrive",
        "$env:ProgramFiles(x86)\Microsoft OneDrive",
        "$env:SystemDrive\ProgramData\Microsoft OneDrive",
        "$env:USERPROFILE\AppData\Roaming\Microsoft\OneDrive"
    )
    
    foreach ($dir in $oneDriveDirs) {
        Write-Host "[ONEDRIVE] Removing $dir..." -NoNewline -ForegroundColor Cyan
        if (Test-Path $dir) { 
            Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [REMOVED]" -ForegroundColor Green
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    }
    
    Write-Host "[ONEDRIVE] Removing registry entries..." -ForegroundColor Cyan
    Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -ErrorAction SilentlyContinue
    
    Write-Host "[ONEDRIVE] Removing scheduled tasks..." -ForegroundColor Cyan
    Get-ScheduledTask | Where-Object {$_.TaskName -like "*OneDrive*"} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
    
    Write-Host "[ONEDRIVE] Removing registry keys..." -ForegroundColor Cyan
    Remove-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "[SECTION] Teams Complete Removal" -ForegroundColor Yellow
    Get-Process -Name "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "[TEAMS] Stopped Teams processes" -ForegroundColor Green
    
    Get-AppxPackage -AllUsers -Name "*Teams*" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    
    $teamsDirs = @(
        "$env:LOCALAPPDATA\Microsoft\Teams",
        "$env:APPDATA\Microsoft\Teams",
        "$env:APPDATA\Teams",
        "$env:ProgramData\Microsoft Teams",
        "$env:USERPROFILE\AppData\Local\Microsoft\Teams",
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Teams",
        "$env:ProgramFiles\Teams Installer",
        "$env:ProgramFiles(x86)\Teams Installer"
    )
    
    foreach ($dir in $teamsDirs) {
        Write-Host "[TEAMS] Removing $dir..." -NoNewline -ForegroundColor Cyan
        if (Test-Path $dir) { 
            Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [REMOVED]" -ForegroundColor Green
        } else {
            Write-Host " [NOT FOUND]" -ForegroundColor Gray
        }
    }
    
    Write-Host "[SECTION] Taskbar Cleanup" -ForegroundColor Yellow
    $quickLaunchDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    if (Test-Path $quickLaunchDir) {
        Get-ChildItem -Path $quickLaunchDir -Include *.lnk -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -ne 'File Explorer.lnk' -and
            $_.Name -ne 'Windows Explorer.lnk' -and
            $_.Name -ne 'explorer.lnk'
        } | ForEach-Object {
            Write-Host "[TASKBAR] Removing $_..." -NoNewline -ForegroundColor Cyan
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            Write-Host " [REMOVED]" -ForegroundColor Green
        }
    }
    
    Write-Host "[SECTION] Search Settings" -ForegroundColor Yellow
    $SearchRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
    New-Item -Path $SearchRegPath -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsDeviceSearchHistoryEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsCloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsMSACloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsAADCloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "[SECTION] Additional App Removal" -ForegroundColor Yellow
    $appsToRemove = @(
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.GamingApp",
        "Microsoft.Family",
        "Microsoft.DevHome",
        "Microsoft.LinkedIn"
    )
    
    foreach ($app in $appsToRemove) {
        Write-Host "[APPX] Removing $app..." -NoNewline -ForegroundColor Cyan
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "$app*" } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "$app*" } | Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction SilentlyContinue
        Write-Host " [PROCESSED]" -ForegroundColor Green
    }
    
    $regPaths = @(
        "HKCU:\Software\Microsoft\XboxApp",
        "HKLM:\Software\Microsoft\Xbox",
        "HKLM:\Software\Microsoft\GamingServices",
        "HKCU:\Software\Microsoft\Family",
        "HKCU:\Software\Microsoft\DevHome",
        "HKCU:\Software\Microsoft\LinkedIn"
    )
    
    foreach ($regPath in $regPaths) {
        Remove-RegistryKeyForce -Path $regPath
    }
    
    Write-Host "[SECTION] Shortcut Cleanup" -ForegroundColor Yellow
    $shortcutPatterns = @("*Teams*.lnk","*LinkedIn*.lnk","*Family*.lnk","*Dev Home*.lnk","*Xbox*.lnk")
    
    $startMenuDirs = @(
        "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
        "C:\Users\Public\Desktop"
    )
    
    $profiles = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(Default|Public|All Users)$' }
    foreach ($profile in $profiles) {
        $userStartMenu = Join-Path $profile.FullName "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        if (Test-Path $userStartMenu) {
            $startMenuDirs += $userStartMenu
        }
        $userDesktop = Join-Path $profile.FullName "Desktop"
        if (Test-Path $userDesktop) {
            $startMenuDirs += $userDesktop
        }
    }
    
    $startMenuDirs = $startMenuDirs | Select-Object -Unique
    
    foreach ($dir in $startMenuDirs) {
        foreach ($pattern in $shortcutPatterns) {
            $matches = Get-ChildItem -Path (Join-Path $dir $pattern) -ErrorAction SilentlyContinue
            foreach ($match in $matches) {
                Write-Host "[SHORTCUT] Removing $($match.FullName)..." -NoNewline -ForegroundColor Cyan
                try {
                    Remove-Item $match.FullName -Force -ErrorAction SilentlyContinue
                    Write-Host " [REMOVED]" -ForegroundColor Green
                } catch {
                    Write-Host " [FAILED]" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host "[SECTION] System File Check" -ForegroundColor Yellow
    Write-Host "[DISM] Running DISM RestoreHealth..." -ForegroundColor Cyan
    try {
        $dismOut = "$env:TEMP\dism_silent.txt"
        $dismErr = "$env:TEMP\dism_silent_err.txt"
        Dism.exe /Online /Cleanup-Image /RestoreHealth *>$dismOut 2>$dismErr
        Write-Host "[DISM] Completed (check $dismOut for details)" -ForegroundColor Green
    } catch {
        Write-Host "[DISM] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "[SFC] Running System File Checker..." -ForegroundColor Cyan
    try {
        $sfcOut = "$env:TEMP\sfc_silent.txt"
        $sfcErr = "$env:TEMP\sfc_silent_err.txt"
        sfc /scannow *>$sfcOut 2>$sfcErr
        Write-Host "[SFC] Completed (check $sfcOut for details)" -ForegroundColor Green
    } catch {
        Write-Host "[SFC] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "[SECTION] Winget Installation" -ForegroundColor Yellow
    $winget = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    
    if (-not (Test-Path $winget)) {
        Write-Host "[WINGET] Not found, installing..." -ForegroundColor Cyan
        $installerUrl = "https://aka.ms/getwinget"
        $tempFile = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        
        try {
            Write-Host "[WINGET] Downloading from $installerUrl..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $installerUrl -OutFile $tempFile
            Write-Host "[WINGET] Downloaded to $tempFile" -ForegroundColor Green
            
            Write-Host "[WINGET] Installing..." -ForegroundColor Cyan
            Add-AppxPackage -Path $tempFile
            Start-Sleep -Seconds 5
            Write-Host "[WINGET] Installation complete" -ForegroundColor Green
        } catch {
            Write-Host "[WINGET] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "[WINGET] Already installed at $winget" -ForegroundColor Green
    }
    
    if (Test-Path $winget) {
        Write-Host "[WINGET] Installing Nilesoft Shell..." -ForegroundColor Cyan
        $commonFlags = @("--exact","--silent","--accept-package-agreements","--accept-source-agreements","--source","winget")
        
        try {
            & $winget install --id Nilesoft.Shell @commonFlags
            Write-Host "[WINGET] Nilesoft Shell installation attempted" -ForegroundColor Green
        } catch {
            Write-Host "[WINGET] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "[COMPLETE] Registry tweaks finished" -ForegroundColor Green
    return $true
}

function Install-FixOS {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host "FIXOS INSTALLATION" -ForegroundColor Magenta
    Write-Host "=================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "[                    ] 0%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    Set-BestPerformanceVisuals
    Write-Host "`r[####                ] 20%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    Set-HighPerformancePower
    Write-Host "`r[########            ] 40%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    $optimizationResult = Start-WindowsOptimization
    Write-Host "`r[############        ] 60%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    $registryResult = Apply-RegistryTweaks
    Write-Host "`r[################    ] 80%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    
    Write-Host "[FINAL] Cleaning up remaining registry keys..." -ForegroundColor Cyan
    $finalRegKeys = @(
        "HKCU:\Software\Microsoft\OneDrive",
        "HKCU:\Software\Microsoft\Teams",
        "HKCU:\Software\Microsoft\XboxApp",
        "HKLM:\Software\Microsoft\Xbox",
        "HKLM:\Software\Microsoft\GamingServices",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost",
        "HKCU:\Software\Microsoft\LinkedIn",
        "HKCU:\Software\Microsoft\Family",
        "HKLM:\SOFTWARE\Microsoft\Edge",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge"
    )
    
    foreach ($regKey in $finalRegKeys) {
        Remove-RegistryKeyForce -Path $regKey
    }
    
    Write-Host "`r[####################] 100%"
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Green
    Write-Host "FIXOS INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "=================================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "A Toolbox shortcut has been created on your desktop" -ForegroundColor Yellow
    Write-Host "Your computer name has been set to: FixOs" -ForegroundColor Yellow
    Write-Host "Microsoft Edge has been removed (some features may be affected)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to return to the Menu" -ForegroundColor Gray
    
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

try {
    Write-Host "[STARTUP] Setting execution policy..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    
    if ($Install) {
        Write-Host "[MODE] Direct installation mode (-Install switch detected)" -ForegroundColor Green
        Install-FixOS
    } else {
        Write-Host "[MODE] Interactive menu mode" -ForegroundColor Green
        Show-Menu
    }
} catch {
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Red
    Write-Host "FATAL ERROR" -ForegroundColor Red
    Write-Host "=================================================================================" -ForegroundColor Red
    Write-Host "Error Type: $($_.Exception.GetType().Name)" -ForegroundColor Red
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
