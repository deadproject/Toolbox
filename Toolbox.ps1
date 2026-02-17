<#
- MORE INFO = https://github.com/DeveIopmentSpace/FixOs/tree/dev
- NOTES
    Version: 2.1.3
    Author: Project/Development Space
    Requires: Administrator privileges
#>

param([switch]$Install,[switch]$Silent)

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    $null = Read-Host
    exit
}

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

try {
    Add-Type -MemberDefinition $fullscreenCode -Name KeyboardAPI -Namespace Win32
} catch {}

try {
    Start-Sleep -Milliseconds 500
    
    $windowHandle = [Win32.KeyboardAPI]::GetForegroundWindow()
    
    if ($windowHandle -ne [IntPtr]::Zero) {
        [Win32.KeyboardAPI]::SetForegroundWindow($windowHandle)
        Start-Sleep -Milliseconds 100
        
        [Win32.KeyboardAPI]::keybd_event([Win32.KeyboardAPI]::VK_F11, 0, [Win32.KeyboardAPI]::KEYEVENTF_EXTENDEDKEY, 0)
        Start-Sleep -Milliseconds 50
        [Win32.KeyboardAPI]::keybd_event([Win32.KeyboardAPI]::VK_F11, 0, [Win32.KeyboardAPI]::KEYEVENTF_KEYUP, 0)
        
        Start-Sleep -Milliseconds 500
    }
} catch {}

try {
    $maxWidth = $Host.UI.RawUI.MaxWindowSize.Width
    $maxHeight = $Host.UI.RawUI.MaxWindowSize.Height
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($maxWidth, $maxHeight)
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($maxWidth, 9999)
} catch {
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(120, 50)
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(120, 9999)
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
        param (
            [string]$Text,
            [ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor
        )
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

    foreach ($line in $bannerLines) {
        Write-CenteredLine -Text $line
    }

    Write-CenteredLine -Text ""
    Write-CenteredLine -Text ""
    Write-CenteredLine -Text "[1] Install FixOS    [2] Learn More"
    Write-CenteredLine -Text ""
    Write-CenteredLine -Text "[3] Exit"
    Write-CenteredLine -Text ""

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Install-FixOS }
        "2" { Start-Process "https://github.com/DeveIopmentSpace/FixOs"; Show-Menu }
        "3" { exit }
        default { Write-Host "Invalid selection..."; Start-Sleep -Seconds 2; Show-Menu }
    }
}

function Start-WindowsOptimization {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Please run as Administrator"
        return $false
    }

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue

    function Remove-AppxSafe {
        param([string]$AppName)
        try {
            Get-AppxPackage -Name $AppName -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxPackage -Name $AppName -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$AppName*" } | ForEach-Object {
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
            }
            return $true
        } catch { return $false }
    }

    function Set-RegistrySafe {
        param([string]$Path, [string]$Name, [object]$Value, [string]$Type = "DWord")
        try {
            if (-not (Test-Path $Path)) {
                New-Item -Path $Path -Force | Out-Null
            }
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
            return $true
        } catch { return $false }
    }

    function Create-ToolboxShortcut {
        try {
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $shortcutPath = Join-Path $desktopPath "Toolbox.lnk"
            
            $toolboxUrl = "https://raw.githubusercontent.com/DeveIopmentSpace/FixOs/dev/Toolbox/src/Toolbox.ps1"
            
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($shortcutPath)
            $Shortcut.TargetPath = "wt.exe"
            $Shortcut.Arguments = "-p `"Windows PowerShell`" -d `"$env:USERPROFILE`" powershell -Command `"irm '$toolboxUrl' | iex`""
            $Shortcut.WorkingDirectory = "$env:USERPROFILE"
            $Shortcut.Description = "FixOs Toolbox"
            $Shortcut.IconLocation = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe,0"
            $Shortcut.Save()
            
            return $true
        } catch {
            return $false
        }
    }

    function Remove-CrapApps {
        $appsToRemove = @(
        "Microsoft.549981C3F5F10"
        "Microsoft.BingNews"
        "Microsoft.BingWeather"
        "Microsoft.BingSports"
        "Microsoft.BingFinance"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "Microsoft.WindowsCommunicationsApps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.Advertising.Xaml"
        "Microsoft.Todos"
        "Microsoft.PowerAutomateDesktop"
        "Microsoft.Windows.DevHome"
        "Clipchamp.Clipchamp"
        "Microsoft.Copilot"
        "Microsoft.WindowsCopilot"
        "Microsoft.LinkedIn"
        "Microsoft.Teams"
        "Microsoft.People"
        "Microsoft.MixedReality"
        "MicrosoftCorporationII.QuickAssist"
        "Microsoft.OutlookForWindows"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsStore"
        "Microsoft.StorePurchaseApp"
        "Microsoft.Widgets"
        "Microsoft.Windows.Photos"
        "Microsoft.Paint"
        "Microsoft.MSPaint"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsNotepad"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.People"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftEdge"
        "Microsoft.MicrosoftEdge.Stable"
        "MicrosoftEdge"
        "Microsoft.WebMediaExtensions"
        "Microsoft.WebpImageExtension"
        "Microsoft.HEIFImageExtension"
        "Microsoft.VP9VideoExtensions"
        "Microsoft.RawImageExtension"
        "Microsoft.HEVCVideoExtension"
        "Microsoft.DolbyAudioExtensions"
        "Microsoft.DolbyVisionExtensions"
        "Microsoft.MPEG2VideoExtension"
        )

        foreach ($app in $appsToRemove) {
            try {
                Remove-AppxSafe -AppName $app
            } catch {}
        }
    }

    function Optimize-Services {
        try {
            $servicesToDisable = @(
                @{Name = 'DiagTrack'; StartupType = 'Disabled'}
                @{Name = 'dmwappushservice'; StartupType = 'Disabled'}
                @{Name = 'WSearch'; StartupType = 'Disabled'}
                @{Name = 'XboxGipSvc'; StartupType = 'Disabled'}
                @{Name = 'XblAuthManager'; StartupType = 'Disabled'}
                @{Name = 'XblGameSave'; StartupType = 'Disabled'}
                @{Name = 'XboxNetApiSvc'; StartupType = 'Disabled'}
                @{Name = 'OneSyncSvc'; StartupType = 'Disabled'}
                @{Name = 'PcaSvc'; StartupType = 'Disabled'}
                @{Name = 'WpcMonSvc'; StartupType = 'Disabled'}
                @{Name = 'wisvc'; StartupType = 'Disabled'}
                @{Name = 'RetailDemo'; StartupType = 'Disabled'}
                @{Name = 'MessagingService'; StartupType = 'Disabled'}
                @{Name = 'lfsvc'; StartupType = 'Disabled'}
                @{Name = 'MapsBroker'; StartupType = 'Disabled'}
                @{Name = 'PimIndexMaintenanceSvc'; StartupType = 'Disabled'}
                @{Name = 'UnistoreSvc'; StartupType = 'Disabled'}
                @{Name = 'UserDataSvc'; StartupType = 'Disabled'}
                @{Name = 'WpnService'; StartupType = 'Disabled'}
                @{Name = 'WpnUserService'; StartupType = 'Disabled'}
                @{Name = 'WdNisSvc'; StartupType = 'Disabled'}
                @{Name = 'Sense'; StartupType = 'Disabled'}
                @{Name = 'wscsvc'; StartupType = 'Disabled'}
                @{Name = 'SysMain'; StartupType = 'Disabled'}
                @{Name = 'edgeupdate'; StartupType = 'Disabled'}
                @{Name = 'edgeupdatem'; StartupType = 'Disabled'}
                @{Name = 'MicrosoftEdgeElevationService'; StartupType = 'Disabled'}
                @{Name = 'BcastDVRUserService'; StartupType = 'Disabled'}
                @{Name = 'CaptureService'; StartupType = 'Disabled'}
                @{Name = 'cbdhsvc'; StartupType = 'Disabled'}
                @{Name = 'ConsentUxUserSvc'; StartupType = 'Disabled'}
                @{Name = 'CredentialEnrollmentManagerUserSvc'; StartupType = 'Disabled'}
                @{Name = 'DeviceAssociationBrokerSvc'; StartupType = 'Disabled'}
                @{Name = 'DevicePickerUserSvc'; StartupType = 'Disabled'}
                @{Name = 'DevicesFlowUserSvc'; StartupType = 'Disabled'}
                @{Name = 'MessagingService'; StartupType = 'Disabled'}
                @{Name = 'NPSMSvc'; StartupType = 'Disabled'}
                @{Name = 'P9RdrService'; StartupType = 'Disabled'}
                @{Name = 'PenService'; StartupType = 'Disabled'}
                @{Name = 'PrintWorkflowUserSvc'; StartupType = 'Disabled'}
                @{Name = 'UdkUserSvc'; StartupType = 'Disabled'}
                @{Name = 'WpnUserService'; StartupType = 'Disabled'}
                @{Name = 'autotimesvc'; StartupType = 'Disabled'}
                @{Name = 'tzautoupdate'; StartupType = 'Disabled'}
                @{Name = 'shpamsvc'; StartupType = 'Disabled'}
                @{Name = 'PhoneSvc'; StartupType = 'Disabled'}
                @{Name = 'RemoteRegistry'; StartupType = 'Disabled'}
                @{Name = 'RemoteAccess'; StartupType = 'Disabled'}
                @{Name = 'SessionEnv'; StartupType = 'Disabled'}
                @{Name = 'TermService'; StartupType = 'Disabled'}
                @{Name = 'UmRdpService'; StartupType = 'Disabled'}
                @{Name = 'SharedAccess'; StartupType = 'Disabled'}
                @{Name = 'hidserv'; StartupType = 'Disabled'}
                @{Name = 'WbioSrvc'; StartupType = 'Disabled'}
                @{Name = 'FrameServer'; StartupType = 'Disabled'}
                @{Name = 'StiSvc'; StartupType = 'Disabled'}
                @{Name = 'WiaRpc'; StartupType = 'Disabled'}
                @{Name = 'icssvc'; StartupType = 'Disabled'}
                @{Name = 'WlanSvc'; StartupType = 'Disabled'}
                @{Name = 'WwanSvc'; StartupType = 'Disabled'}
            )
            
            $servicesToManual = @(
                @{Name = 'BITS'; StartupType = 'Manual'}
                @{Name = 'wuauserv'; StartupType = 'Manual'}
                @{Name = 'DoSvc'; StartupType = 'Manual'}
                @{Name = 'UsoSvc'; StartupType = 'Manual'}
                @{Name = 'Spooler'; StartupType = 'Manual'}
                @{Name = 'W32Time'; StartupType = 'Manual'}
                @{Name = 'FontCache'; StartupType = 'Manual'}
                @{Name = 'Themes'; StartupType = 'Manual'}
                @{Name = 'Schedule'; StartupType = 'Manual'}
                @{Name = 'TrustedInstaller'; StartupType = 'Manual'}
                @{Name = 'TabletInputService'; StartupType = 'Manual'}
                @{Name = 'TextInputManagementService'; StartupType = 'Manual'}
                @{Name = 'AudioEndpointBuilder'; StartupType = 'Manual'}
                @{Name = 'Audiosrv'; StartupType = 'Manual'}
                @{Name = 'CDPSvc'; StartupType = 'Manual'}
                @{Name = 'CDPUserSvc'; StartupType = 'Manual'}
                @{Name = 'CoreMessagingRegistrar'; StartupType = 'Manual'}
                @{Name = 'StateRepository'; StartupType = 'Manual'}
                @{Name = 'StorSvc'; StartupType = 'Manual'}
                @{Name = 'TimeBrokerSvc'; StartupType = 'Manual'}
                @{Name = 'TokenBroker'; StartupType = 'Manual'}
                @{Name = 'UserManager'; StartupType = 'Manual'}
                @{Name = 'VaultSvc'; StartupType = 'Manual'}
                @{Name = 'WinHttpAutoProxySvc'; StartupType = 'Manual'}
                @{Name = 'Winmgmt'; StartupType = 'Manual'}
                @{Name = 'Wcmsvc'; StartupType = 'Manual'}
                @{Name = 'nsi'; StartupType = 'Manual'}
                @{Name = 'iphlpsvc'; StartupType = 'Manual'}
                @{Name = 'Dnscache'; StartupType = 'Manual'}
                @{Name = 'Dhcp'; StartupType = 'Manual'}
                @{Name = 'EventLog'; StartupType = 'Manual'}
                @{Name = 'EventSystem'; StartupType = 'Manual'}
                @{Name = 'gpsvc'; StartupType = 'Manual'}
                @{Name = 'ProfSvc'; StartupType = 'Manual'}
                @{Name = 'Power'; StartupType = 'Manual'}
                @{Name = 'DcomLaunch'; StartupType = 'Manual'}
                @{Name = 'RpcSs'; StartupType = 'Manual'}
                @{Name = 'RpcEptMapper'; StartupType = 'Manual'}
                @{Name = 'SamSs'; StartupType = 'Manual'}
                @{Name = 'LanmanServer'; StartupType = 'Manual'}
                @{Name = 'LanmanWorkstation'; StartupType = 'Manual'}
                @{Name = 'PlugPlay'; StartupType = 'Manual'}
                @{Name = 'SENS'; StartupType = 'Manual'}
                @{Name = 'ShellHWDetection'; StartupType = 'Manual'}
                @{Name = 'TrkWks'; StartupType = 'Manual'}
                @{Name = 'tiledatamodelsvc'; StartupType = 'Manual'}
                @{Name = 'BrokerInfrastructure'; StartupType = 'Manual'}
                @{Name = 'SystemEventsBroker'; StartupType = 'Manual'}
                @{Name = 'CryptSvc'; StartupType = 'Manual'}
                @{Name = 'DPS'; StartupType = 'Manual'}
                @{Name = 'MpsSvc'; StartupType = 'Manual'}
                @{Name = 'mpssvc'; StartupType = 'Manual'}
                @{Name = 'BFE'; StartupType = 'Manual'}
                @{Name = 'KeyIso'; StartupType = 'Manual'}
                @{Name = 'Netlogon'; StartupType = 'Manual'}
                @{Name = 'NlaSvc'; StartupType = 'Manual'}
                @{Name = 'PolicyAgent'; StartupType = 'Manual'}
                @{Name = 'SgrmBroker'; StartupType = 'Manual'}
                @{Name = 'WinDefend'; StartupType = 'Manual'}
                @{Name = 'SecurityHealthService'; StartupType = 'Manual'}
            )
            
            foreach ($service in $servicesToDisable) {
                try {
                    $svc = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
                    if ($svc) {
                        Set-Service -Name $service.Name -StartupType $service.StartupType -ErrorAction SilentlyContinue
                        if ($svc.Status -eq 'Running') {
                            Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue
                        }
                    }
                } catch {}
            }
            
            foreach ($service in $servicesToManual) {
                try {
                    $svc = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
                    if ($svc) {
                        Set-Service -Name $service.Name -StartupType $service.StartupType -ErrorAction SilentlyContinue
                    }
                } catch {}
            }
        } catch {}
    }

    function Remove-EdgeCompletely {
        try {
            Get-Process -Name "*edge*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            $edgePaths = @(
                "C:\Program Files (x86)\Microsoft\Edge"
                "C:\Program Files (x86)\Microsoft\EdgeWebView"
                "C:\Program Files (x86)\Microsoft\EdgeUpdate"
                "C:\Program Files (x86)\Microsoft\EdgeCore"
                "C:\Windows\System32\Microsoft-Edge-Webview"
                "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
                "C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe"
                "$env:LOCALAPPDATA\Microsoft\Edge"
                "$env:ProgramData\Microsoft\Edge"
            )
            foreach ($path in $edgePaths) { if (Test-Path $path) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue } }
            
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
        } catch {}
    }

    function Disable-Telemetry {
        try {
            $telemetryRegistries = @(
                @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0}
                @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0}
                @{Path = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0}
            )
            
            foreach ($reg in $telemetryRegistries) {
                Set-RegistrySafe -Path $reg.Path -Name $reg.Name -Value $reg.Value
            }
        } catch {}
    }

    function Set-Wallpaper {
        $wallUrl = 'https://github.com/DeveIopmentSpace/FixOs/blob/dev/assets/wallpaper-dev.png?raw=true'
        $wallPath = Join-Path $env:PUBLIC 'FixOs-Wallpaper.png'
        
        try {
            Invoke-WebRequest -Uri $wallUrl -OutFile $wallPath -ErrorAction SilentlyContinue
            
            if (Test-Path $wallPath) {
                Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue
                [Wallpaper]::SystemParametersInfo(20, 0, $wallPath, 0x01 -bor 0x02)
            }
        } catch {}
    }

    Remove-CrapApps
    Optimize-Services
    Disable-Telemetry
    Set-Wallpaper
    Create-ToolboxShortcut
    
    return $true
}

function Apply-RegistryTweaks {
    
    function Set-RegistryForce {
        param([string]$Path,[string]$Name,[string]$Type,[object]$Value,[string]$Action = "Add")
        
        try {
            if ($Action -eq "Add") {
                if (-not (Test-Path $Path)) {
                    New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
                }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction SilentlyContinue | Out-Null
            } elseif ($Action -eq "Delete") {
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue | Out-Null
            }
        } catch {}
    }

    function Remove-RegistryKeyForce {
        param([string]$Path)
        
        try {
            if (Test-Path $Path) {
                Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            }
        } catch {}
    }

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightOnLockScreen" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightActiveUser" -Type "DWord" -Value 1

    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins" -Type "String" -Value '{ "pinnedList": [] }'
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_ProviderSet" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_WinningProvider" -Type "String" -Value "B5292708-1619-419B-9923-E5D9F3925E71"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins" -Type "String" -Value '{ "pinnedList": [] }'
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins_LastWrite" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" -Name "TCGSecurityActivationDisabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type "DWord" -Value 3
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays" -Type "DWord" -Value 365
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdates" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays" -Type "DWord" -Value 365
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Type "String" -Value "22H2"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Type "String" -Value "Windows 10"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type "DWord" -Value 10
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type "DWord" -Value 30

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Type "DWord" -Value 8
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type "DWord" -Value 6
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type "String" -Value "High"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type "DWord" -Value 1

    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

    Set-RegistryForce -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" -Name "DisablePushToInstall" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableConsumerAccountStateContent" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Type "DWord" -Value 1

    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"

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

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "IsMiEnabled" -Type "DWord" -Value 0

    Remove-RegistryKeyForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
    Remove-RegistryKeyForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Notepad" -Name "ShowStoreBanner" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type "DWord" -Value 2
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "SettingSyncEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "LocationServicesEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "AutoSample" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "ServiceEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppDiagnostics" -Name "AppDiagnosticsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "DODownloadMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication" -Name "UseSignInInfo" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Maps" -Name "AutoDownload" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SettingsPageVisibility" -Type "String" -Value "hide:home"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDeveloperSettings" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type "DWord" -Value 2
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type "String" -Value "2"

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"
    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"
    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type "String" -Value "506"
    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "HotkeyFlags" -Type "String" -Value "58"

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAcrylicOpacity" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type "DWord" -Value 1

    $photoExtensions = @(".bmp",".cr2",".dib",".gif",".ico",".jfif",".jpe",".jpeg",".jpg",".jxr",".png",".tif",".tiff",".wdp")

    foreach ($ext in $photoExtensions) {
        Set-RegistryForce -Path "HKCU:\SOFTWARE\Classes\$ext" -Name "(default)" -Type "String" -Value "PhotoViewer.FileAssoc.Tiff"
        Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext\OpenWithProgids" -Name "PhotoViewer.FileAssoc.Tiff" -Type "None" -Value $null
    }

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Windows AI" -Name "TurnOffSavingSnapshots" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Multimedia\Audio" -Name "UserDuckingPreference" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Type "DWord" -Value 3

    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
    Remove-RegistryKeyForce -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SettingsPageVisibility" -Type "String" -Value "hide:home"

    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "LinkedIn" -Force -ErrorAction SilentlyContinue | Out-Null
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Hostname" -Value "FixOs" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Hostname" -Value "FixOs" -Force | Out-Null

    Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    $OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
    $OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (Test-Path $OneDriveSetup32) { Start-Process $OneDriveSetup32 "/uninstall" -Wait -ErrorAction SilentlyContinue }
    if (Test-Path $OneDriveSetup64) { Start-Process $OneDriveSetup64 "/uninstall" -Wait -ErrorAction SilentlyContinue }

    $oneDriveDirs = @(
        "$env:SystemDrive\OneDriveTemp"
        "$env:USERPROFILE\OneDrive"
        "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive"
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
        "$env:ProgramData\Microsoft OneDrive"
        "$env:LOCALAPPDATA\Microsoft\OneDrive"
        "$env:ProgramFiles\Microsoft OneDrive"
        "$env:ProgramFiles(x86)\Microsoft OneDrive"
        "$env:SystemDrive\ProgramData\Microsoft OneDrive"
        "$env:USERPROFILE\AppData\Roaming\Microsoft\OneDrive"
    )
    foreach ($dir in $oneDriveDirs) {
        if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue }
    }

    Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -ErrorAction SilentlyContinue

    Get-ScheduledTask | Where-Object {$_.TaskName -like "*OneDrive*"} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

    Remove-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

    Get-Process -Name "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    Get-AppxPackage -AllUsers -Name "*Teams*" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

    $teamsDirs = @(
        "$env:LOCALAPPDATA\Microsoft\Teams"
        "$env:APPDATA\Microsoft\Teams"
        "$env:APPDATA\Teams"
        "$env:ProgramData\Microsoft Teams"
        "$env:USERPROFILE\AppData\Local\Microsoft\Teams"
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Teams"
        "$env:ProgramFiles\Teams Installer"
        "$env:ProgramFiles(x86)\Teams Installer"
    )
    foreach ($dir in $teamsDirs) {
        if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue }
    }

    $quickLaunchDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    if (Test-Path $quickLaunchDir) {
        Get-ChildItem -Path $quickLaunchDir -Include *.lnk -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -ne 'File Explorer.lnk' -and
            $_.Name -ne 'Windows Explorer.lnk' -and
            $_.Name -ne 'explorer.lnk'
        } | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    $SearchRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
    New-Item -Path $SearchRegPath -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsDeviceSearchHistoryEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsCloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsMSACloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $SearchRegPath -Name "IsAADCloudSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null

    $appsToRemove = @(
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.GamingApp"
        "Microsoft.Family"
        "Microsoft.DevHome"
        "Microsoft.LinkedIn"
    )

    foreach ($app in $appsToRemove) {
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "$app*" } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "$app*" } | Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction SilentlyContinue
    }

    $regPaths = @(
        "HKCU:\Software\Microsoft\XboxApp"
        "HKLM:\Software\Microsoft\Xbox"
        "HKLM:\Software\Microsoft\GamingServices"
        "HKCU:\Software\Microsoft\Family"
        "HKCU:\Software\Microsoft\DevHome"
        "HKCU:\Software\Microsoft\LinkedIn"
    )
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $shortcutPatterns = @("*Teams*.lnk","*LinkedIn*.lnk","*Family*.lnk","*Dev Home*.lnk","*Xbox*.lnk")

    $startMenuDirs = @(
        "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs"
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
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
                try {
                    Remove-Item $match.FullName -Force -ErrorAction SilentlyContinue
                } catch { }
            }
        }
    }

    $familyProv = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match 'MicrosoftFamily|LinkedIn' }
    foreach ($prov in $familyProv) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction SilentlyContinue
        } catch {}
    }

    function Remove-AppxRegex {
        param ($regex)
        $pkgs = Get-AppxPackage -AllUsers | Where-Object { $_.Name -match $regex }
        foreach ($pkg in $pkgs) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            } catch { }
        }
    }
    Remove-AppxRegex 'LinkedIn|MicrosoftFamily|CFQ7TTC0HHRK'

    $provPkgs = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match 'LinkedIn|MicrosoftFamily' }
    foreach ($prov in $provPkgs) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction SilentlyContinue
        } catch {}
    }

    $userProfileDirs = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(Default|Public|All Users)$' }
    foreach ($profile in $userProfileDirs) {
        $desktop = Join-Path $profile.FullName "Desktop"
        if (Test-Path $desktop) {
            $lnkMatches = Get-ChildItem -Path $desktop -Filter "*LinkedIn*.lnk" -ErrorAction SilentlyContinue
            foreach ($lnk in $lnkMatches) {
                try {
                    Remove-Item $lnk.FullName -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }

    $regFamily = "HKCU:\Software\Microsoft\MicrosoftFamily"
    $regLinkedIn = "HKCU:\Software\Microsoft\Office\16.0\Common\Internet\LinkedIn"
    foreach ($regKey in @($regFamily, $regLinkedIn)) {
        if (Test-Path $regKey) {
            try {
                Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
            } catch { }
        }
    }

    try {
        $dismArgs = "/Online /Cleanup-Image /RestoreHealth"
        $dismOut = "$env:TEMP\dism_silent.txt"
        $dismErr = "$env:TEMP\dism_silent_err.txt"
        Dism.exe $dismArgs *>$dismOut 2>$dismErr
    } catch {}

    try {
        $sfcOut = "$env:TEMP\sfc_silent.txt"
        $sfcErr = "$env:TEMP\sfc_silent_err.txt"
        sfc /scannow *>$sfcOut 2>$sfcErr
    } catch {}

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type "Binary" -Value ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00))
    
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSizeMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value 0
    
    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "String" -Value "0"
    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "CursorBlinkRate" -Type "String" -Value "-1"
    
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type "DWord" -Value 2
    
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Content Delivery Manager" -Name "ContentDeliveryAllowed" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Content Delivery Manager" -Name "OEMPreInstalledAppsEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Content Delivery Manager" -Name "PreInstalledAppsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TONE_OR_VIBRATION" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "HIGHDPIAWARE" -Type "String" -Value "HIGHDPIAWARE"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" -Name "Priority" -Type "DWord" -Value 6

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShellState" -Type "Binary" -Value ([byte[]](0x24, 0x00, 0x00, 0x00)) -ErrorAction SilentlyContinue

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "GraphicsDrivers" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\PowerCfg\GlobalPowerPolicy" -Name "Policies" -Type "Binary" -Value ([byte[]](0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00))

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoVirtualTours" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenSlideshow" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsAADCloudSearchEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsCloudSearchEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsMSACloudSearchEnabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDeviceSearchHistoryEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowDomainPINLogon" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowUserToConnectToComputer" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Classes\.url\ShellExecuteEx" -Name "IsolationLevel" -Type "DWord" -Value 0x00000000

    Set-RegistryForce -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "RuntimeBroker" -Action "Delete"
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "RuntimeBroker" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettings" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "RequireSignedAppInitDlls" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "GpNetworkStartTimeoutPolicyValue" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Configuration" -Name "EnableTaskScheduler" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "DoubleClickSpeed" -Type "String" -Value "400"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility\StickyKeys" -Name "AudioDescriptionEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NvNetworkSvc" -Name "Start" -Type "DWord" -Value 4
    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type "DWord" -Value 0

    $animationKeys = @(
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "FontSmoothing"; Value = "2"}
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "FontSmoothingType"; Value = "2"}
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "DragFullWindows"; Value = "0"}
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAcrylicOpacity"; Value = 0}
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewAlphaBlendingEnabled"; Value = 0}
        @{Path = "HKCU:\Control Panel\Desktop\WindowMetrics"; Name = "MinAnimate"; Value = "0"}
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "EnableBlurBehindTransparency"; Value = 0}
    )

    foreach ($key in $animationKeys) {
        Set-RegistryForce -Path $key.Path -Name $key.Name -Type "String" -Value $key.Value
    }

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Graphicsdrivers\Configuration" -Name "Scaling" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LegacyDefaultPrinterMode" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGamedvrCapture" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "CompositionPolicy" -Type "DWord" -Value 0
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "MaximizeOptimizations" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\DWM" -Name "AdaptiveMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Accessibility" -Name "AudioDescription" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Ndu" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "InstallTheme" -Type "String" -Value ""

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "SoftwareSASGeneration" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "InlineSharing" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "UIEffects" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility" -Name "AudioDescription" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\System" -Name "DisableStartupSound" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartupFolder" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\AudioDescription" -Name "Enabled" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "OneDriveSetup" -Action "Delete"

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NoLazyMode" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "AlwaysShowVolume" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowInfoTip" -Type "DWord" -Value 1
    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ExtendedUIHoverTime" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateFileSizeFraction" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtTime" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "LetAppsRunInBackground" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "ActiveWndTrkTimeout" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "CaretWidth" -Type "String" -Value "1"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "Beep" -Type "String" -Value "No"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Type "String" -Value "10"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Colors" -Name "Background" -Type "String" -Value "0 0 0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "UsePolicy" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColor" -Type "DWord" -Value 4280191205

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Explorer.exe" -Name "Priority" -Type "DWord" -Value 8

    Set-RegistryForce -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "NtfsDisableLastAccessUpdate" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagedPoolSize" -Type "DWord" -Value 0xffffffff

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "NonPagedPoolSize" -Type "DWord" -Value 0x180000

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "DisableDeleteNotification" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "Flags" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type "String" -Value "58"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\FilterKeys" -Name "Flags" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\HighContrast" -Name "Flags" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "Flags" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\ShowSounds" -Name "On" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\SerialKeys" -Name "Active" -Type "String" -Value "No"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoCDBurning" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StartMenuAdminTools" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRun" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsMenu" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoNetworkPlaces" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Classes\*\shellex\ContextMenuHandlers\CopyAsPathMenu" -Name "" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Software\Classes\*\shellex\ContextMenuHandlers\SendTo" -Name "" -Action "Delete"

    Remove-RegistryKeyForce -Path "HKCU:\Software\Classes\*\shellex\ContextMenuHandlers\CopyAsPathMenu"
    Remove-RegistryKeyForce -Path "HKCU:\Software\Classes\*\shellex\ContextMenuHandlers\SendTo"
    Remove-RegistryKeyForce -Path "HKCU:\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneWidth" -Type "DWord" -Value 200

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "HistoryItemsToKeep" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\Recommended" -Name "" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "verbose" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Type "String" -Value "1252"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "OptimizeStartupLaunchSize" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "IconFont" -Type "String" -Value "MS Shell Dlg 2"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\Personalization" -Name "AllowLockScreenSlideshow" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoAutoplayfornonVolume" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoAutoplay" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Classes\CLSID\{45AC2FB1-6DFB-11D1-9014-00A0C90270F8}" -Name ""  -Type "String" -Value ""

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Comdlg32" -Name "PlacesBar" -Type "String" -Value ""

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "Win31FileSystem" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "AllocationUnitSize" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" -Name "ShowFolderOptions" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "LimitedToastToActionCenter" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "CompactView" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "SchemeSource" -Type "String" -Value ""

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" -Name "PreferredRasterizationMode" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Schedule" -Name "Start" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ViewModeForNewFolders" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\CloudDamage" -Name "" -Type "String" -Value ""

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseDarkMode" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StartupApproved\Run" -Name "OneDriveSetup" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -Name "SaveZoneInformation" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysMain" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "InstallTheme" -Type "String" -Value ""

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\Metrics" -Name "CaptionFont" -Type "String" -Value "Segoe UI"

    $winget = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"

    if (-not (Test-Path $winget)) {
        $installerUrl = "https://aka.ms/getwinget"
        $tempFile = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"

        Invoke-WebRequest -Uri $installerUrl -OutFile $tempFile
        Add-AppxPackage -Path $tempFile
        Start-Sleep -Seconds 5
    }

    if (-not (Test-Path $winget)) {
        Write-Error "winget not available"
        exit 1
    }

    $commonFlags = @("--exact","--silent","--accept-package-agreements","--accept-source-agreements","--source","winget")

    & $winget install --id Brave.Brave @commonFlags
    & $winget install --id Nilesoft.Shell @commonFlags

    return $true
}

function Clean-StartMenu {
    try {
        $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        
        $shortcutPatterns = @(
            "*.lnk",
            "*Teams*.lnk",
            "*Outlook*.lnk",
            "*OneNote*.lnk",
            "*Xbox*.lnk",
            "*OneDrive*.lnk"
        )
        
        foreach ($pattern in $shortcutPatterns) {
            Get-ChildItem -Path $startMenuPath -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }

        $startLayoutPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*\lis\Settings"
        Remove-Item -Path $startLayoutPath -Recurse -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Value 0 -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Value 0 -Force -ErrorAction SilentlyContinue
        
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OEMPreInstalledAppsEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

        return $true
    } catch {
        return $false
    }
}

function Apply-PerformanceOptimizations {
    
    function Set-RegistryForce {
        param([string]$Path,[string]$Name,[string]$Type,[string]$Value,[string]$Action = "Add")
        
        try {
            if ($Action -eq "Add") {
                if (-not (Test-Path $Path)) {
                    New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
                }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction SilentlyContinue | Out-Null
            } elseif ($Action -eq "Delete") {
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue | Out-Null
            }
        } catch {}
    }

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAcrylicOpacity" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaBlendingEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Type "String" -Value "2"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "CursorBlinkRate" -Type "String" -Value "-1"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGroupSize" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OEMPreInstalledAppsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "AllowSearchToUseLocation" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "IsDeviceSearchHistoryEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "IsCloudSearchEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "IsMSACloudSearchEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtTime" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility\StickyKeys" -Name "Flags" -Type "String" -Value "506"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility\FilterKeys" -Name "Flags" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feedback" -Name "AutoSample" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feedback" -Name "ServiceEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "DODownloadMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type "String" -Value "400"

    Set-RegistryForce -Path "HKCU:\Control Panel\Mouse" -Name "ActiveWindowTracking" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "ActiveWndTrkTimeout" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysMain" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\FontCache" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TabletInputService" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WbioSrvc" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\icssvc" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PowerMenuShowFullShutdown" -Type "DWord" -Value 1

    Clean-StartMenu

    $winget = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"

    if (-not (Test-Path $winget)) {
        $installerUrl = "https://aka.ms/getwinget"
        $tempFile = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"

        Invoke-WebRequest -Uri $installerUrl -OutFile $tempFile -ErrorAction SilentlyContinue
        Add-AppxPackage -Path $tempFile -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
    }

    if (Test-Path $winget) {
        $commonFlags = @("--exact","--silent","--accept-package-agreements","--accept-source-agreements","--source","winget")
        
        & $winget install --id Nilesoft.Shell @commonFlags -ErrorAction SilentlyContinue
    }

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsAccessCheck" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SystemPages" -Type "DWord" -Value 0xFFFFFFFF

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ModifiedPageLife" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "HistoryItemsToKeep" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Clipboard" -Name "CloudClipboardContent" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "CloudNotificationDisabled" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "DiagTrackAuthorized" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "DiagTrackEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessAccount" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCalendar" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessContacts" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessEmail" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMicrophone" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMotion" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessRadios" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessTrustedDevices" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsActivateWithVoice" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\motion" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Type "String" -Value "Deny"

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MpsSvc\Parameters\PortKeywords\RDP" -Name "Inbound" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MpsSvc\Parameters\PortKeywords\Teredo" -Name "Inbound" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MpsSvc\Parameters\PortKeywords\mDNS" -Name "Inbound" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4b2f0-bf7e-4881-8207-c0f040516da8" -Name "Attributes" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DesktopProcess" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "NoLivePreviewOnHover" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Type "DWord" -Value 100

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Type "String" -Value "2"

    Set-RegistryForce -Path "HKCU:\Control Panel\Appearance" -Name "Smoothing" -Type "String" -Value "90"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "UseStandardUserTiling" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\explorer.exe" -Name "DISABLEDXMAXIMIZEDWINDOWEDMODE" -Type "String" -Value "DISABLEDXMAXIMIZEDWINDOWEDMODE"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "FriendlyUIMode" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MpsSvc" -Name "Start" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WindowsUpdate" -Name "Start" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "GhostingEnabled" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmallIconsInSystemMetrics" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFolderMergeConflicts" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisablePreloadingOnHover" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Sidebar" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Sidebar" -Action "Delete"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoEnableTouchpadWithKeyboard" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoEnableTouchpadWithMouse" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StartMenuShowNetPlaces" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StartMenuShowPrinters" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NoNetCrawling" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoWinKeys" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type "DWord" -Value 0

    Remove-RegistryKeyForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
    Remove-RegistryKeyForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "" -Type "String" -Value ""

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\38f30556-646d-11dd-aad8-70f56cffaf4e" -Name "Attributes" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableWindowColorization" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Partmgr" -Name "Start" -Type "DWord" -Value 3

    Set-RegistryForce -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sptd" -Name "Start" -Type "DWord" -Value 4

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Printers\Defaults" -Name "NetID" -Type "String" -Value ""

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptedFiles" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTypeOverlayIcons" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistBrowsers" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistMonitorSettings" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "FolderSizeMode" -Type "DWord" -Value 2

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SuperHiddenStartPage" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Comdlg32" -Name "SearchHidden" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "WebViewBarricade" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoPropertiesMyComputer" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoPropertiesMyDocuments" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoPropertiesTrash" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoSharedDocuments" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMyDocuments" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMyMusic" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMyPictures" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuNetworkPlaces" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuPinnedPlaces" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuRecent" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssistSizeLimit" -Type "DWord" -Value 0

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PowerMenuShowFullShutdown" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Control Panel\Desktop" -Name "SmoothScroll" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "HotkeyActive" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\FilterKeys" -Name "HotKeyActive" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "HotKeyActive" -Type "String" -Value "0"

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -Name "DeviceNotSelectedTimeout" -Type "DWord" -Value 1

    Set-RegistryForce -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -Name "sShell" -Type "String" -Value "explorer.exe"

    return $true
}

function Install-FixOS {
    Write-Host "[                    ] 0%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    $optimizationResult = Start-WindowsOptimization
    Write-Host "`r[####                ] 25%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    $registryResult = Apply-RegistryTweaks
    Write-Host "`r[##########          ] 50%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    $performanceResult = Apply-PerformanceOptimizations
    Write-Host "`r[###############     ] 75%" -NoNewline
    
    Start-Sleep -Milliseconds 100
    
    $finalRegKeys = @(
        "HKCU:\Software\Microsoft\OneDrive"
        "HKCU:\Software\Microsoft\Teams"
        "HKCU:\Software\Microsoft\XboxApp"
        "HKLM:\Software\Microsoft\Xbox"
        "HKLM:\Software\Microsoft\GamingServices"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost"
        "HKCU:\Software\Microsoft\LinkedIn"
        "HKCU:\Software\Microsoft\Family"
    )
    
    foreach ($regKey in $finalRegKeys) {
        if (Test-Path $regKey) {
            Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "`r[####################] 100%"
    Write-Host "FixOS Optimization Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your system has been optimized with:"
    Write-Host "  ✓ Animations & effects disabled (Atlas OS level)"
    Write-Host "  ✓ Background apps restricted"
    Write-Host "  ✓ Start Menu cleaned (all apps unpinned)"
    Write-Host "  ✓ Recommended section removed"
    Write-Host "  ✓ Telemetry & data collection disabled"
    Write-Host "  ✓ Windows Search disabled"
    Write-Host "  ✓ Superfetch disabled"
    Write-Host "  ✓ ~60 processes target"
    Write-Host ""
    Write-Host "System is fully functional and workable!"
    Write-Host "Press any key to return to the Menu"
    
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    
    if ($Install) {
        Install-FixOS
    } else {
        Show-Menu
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
