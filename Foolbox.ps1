<#
- MORE INFO = https://github.com/DeveIopmentSpace/FixOs/tree/dev
- NOTES
    Version: 2.0.1
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

function Set-PerformanceVisualEffects {
    $visualEffects = @(
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name = "VisualFXSetting"; Value = 2},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "UserPreferencesMask"; Value = ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "MenuShowDelay"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "AutoEndTasks"; Value = "1"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "HungAppTimeout"; Value = "1000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "WaitToKillAppTimeout"; Value = "2000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "LowLevelHooksTimeout"; Value = "1000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "ForegroundLockTimeout"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "ForegroundFlashCount"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "FontSmoothing"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "DragFullWindows"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "SmoothScroll"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop\WindowMetrics"; Name = "MinAnimate"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop\WindowMetrics"; Name = "MaxAnimate"; Value = "0"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "AnimateMinMax"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewAlphaSelect"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewShadow"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCompColor"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowInfoTip"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarGlomLevel"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "DisallowShaking"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "EnableAeroPeek"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "AlwaysHibernateThumbnails"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "EnableWindowColorization"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "ColorizationOpaqueBlend"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "Composition"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ThemeManager"; Name = "ThemeActive"; Value = "0"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "AppsUseLightTheme"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "ColorPrevalence"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "EnableTransparency"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "SystemUsesLightTheme"; Value = 0}
    )
    
    foreach ($effect in $visualEffects) {
        try {
            if (-not (Test-Path $effect.Path)) {
                New-Item -Path $effect.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $effect.Path -Name $effect.Name -Value $effect.Value -Force
        } catch {}
    }
    
    $code = @'
using System;
using System.Runtime.InteropServices;
public class PerformanceSettings {
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    
    private const uint SPI_SETANIMATION = 0x0049;
    private const uint SPI_SETDRAGFULLWINDOWS = 0x0025;
    private const uint SPI_SETCOMBOBOXANIMATION = 0x1004;
    private const uint SPI_SETLISTBOXSMOOTHSCROLLING = 0x1006;
    private const uint SPI_SETGRADIENTCAPTIONS = 0x1008;
    private const uint SPI_SETKEYBOARDCUES = 0x100B;
    private const uint SPI_SETMENUANIMATION = 0x1002;
    private const uint SPI_SETSELECTIONFADE = 0x1014;
    private const uint SPI_SETTOOLTIPANIMATION = 0x1016;
    private const uint SPI_SETTOOLTIPFADE = 0x1018;
    private const uint SPIF_UPDATEINIFILE = 0x01;
    private const uint SPIF_SENDCHANGE = 0x02;
    
    public static void DisableAllAnimations() {
        IntPtr zero = IntPtr.Zero;
        SystemParametersInfo(SPI_SETANIMATION, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETCOMBOBOXANIMATION, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETLISTBOXSMOOTHSCROLLING, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETGRADIENTCAPTIONS, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETKEYBOARDCUES, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETMENUANIMATION, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETSELECTIONFADE, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETTOOLTIPANIMATION, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        SystemParametersInfo(SPI_SETTOOLTIPFADE, 0, zero, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
'@
    Add-Type $code -ErrorAction SilentlyContinue
    [PerformanceSettings]::DisableAllAnimations()
}

function Disable-AllBackgroundApps {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
    }
    
    $apps = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -ErrorAction SilentlyContinue
    foreach ($app in $apps) {
        try {
            Set-ItemProperty -Path $app.PSPath -Name "Disabled" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path $app.PSPath -Name "IsSystemReserved" -Value 0 -Type DWord -Force
        } catch {}
    }
    
    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnceEx",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            try {
                $items = Get-ItemProperty -Path $path
                $properties = $items.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' }
                foreach ($prop in $properties) {
                    Remove-ItemProperty -Path $path -Name $prop.Name -Force -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }
}

function Disable-AllNonCriticalServices {
    $servicesToDisable = @(
        "wuauserv", "UsoSvc", "DoSvc", "WaaSMedicSvc", "TrustedInstaller", "InstallService",
        "WSearch", "wcncsvc", "FrameServer", "StiSvc", "WiaRpc", "icssvc",
        "XboxGipSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxNetApiSvc",
        "XblAuthManager", "XboxGipSvc", "XboxNetApiSvc", "XboxLiveAuthManager", "XboxLiveGameSave",
        "XboxLiveNetworking", "GamingServices", "GamingServicesNet", "bcastdvr", "cbdhsvc",
        "DiagTrack", "dmwappushservice", "WdiServiceHost", "WdiSystemHost", "DiagSvc", 
        "DPS", "WPRdiag", "WpcMonSvc", "wisvc", "RetailDemo", "lfsvc", "MapsBroker",
        "PimIndexMaintenanceSvc", "UnistoreSvc", "UserDataSvc", "WpnService", "WpnUserService",
        "OneSyncSvc", "PcaSvc", "SysMain", "edgeupdate", "edgeupdatem", "MicrosoftEdgeElevationService",
        "BcastDVRUserService", "CaptureService", "cbdhsvc", "ConsentUxUserSvc", "CredentialEnrollmentManagerUserSvc",
        "DeviceAssociationBrokerSvc", "DevicePickerUserSvc", "DevicesFlowUserSvc", "MessagingService",
        "NPSMSvc", "P9RdrService", "PenService", "PrintWorkflowUserSvc", "UdkUserSvc", "WpnUserService",
        "autotimesvc", "tzautoupdate", "shpamsvc", "PhoneSvc", "RemoteRegistry", "RemoteAccess",
        "SessionEnv", "TermService", "UmRdpService", "SharedAccess", "hidserv", "WbioSrvc",
        "icssvc", "WlanSvc", "WwanSvc", "lfsvc", "MapsBroker", "TokenBroker",
        "WMPNetworkSvc", "HomeGroupListener", "HomeGroupProvider", "NetTcpPortSharing",
        "RemoteAccess", "RemoteRegistry", "RetailDemo", "SCardSvr", "ScDeviceEnum",
        "SensorDataService", "SensorsService", "SensorsService", "shpamsvc", "smphost",
        "SNMPTRAP", "spectrum", "Spooler", "SSDPSRV", "SstpSvc", "StorSvc",
        "TabletInputService", "TapiSrv", "TextInputManagementService", "Themes",
        "TieringEngineService", "TimeBrokerSvc", "TrkWks", "UevAgentService",
        "upnphost", "VacSvc", "vmicguestinterface", "vmicheartbeat", "vmickvpexchange",
        "vmicrdcomponents", "vmicshutdown", "vmictimesync", "vmicvmsession", "vmicvss",
        "W32Time", "W3LOGSVC", "WAS", "wcncsvc", "WdiServiceHost", "WdiSystemHost",
        "WebClient", "Wecsvc", "wercplsupport", "WerSvc", "WiaRpc", "WinHttpAutoProxySvc",
        "WinRM", "wisvc", "WlanSvc", "WMPNetworkSvc", "workfolderssvc", "WpcMonSvc",
        "WPDBusEnum", "WpnService", "wscsvc", "WSearch", "WwanSvc", "XblAuthManager",
        "XblGameSave", "XboxGipSvc", "XboxNetApiSvc", "XboxNetApiSvc", "MSDTC",
        "Spooler", "Fax", "fhsvc", "FontCache", "FontCache3.0.0.0", "GameDVR",
        "GraphicsPerfSvc", "hidserv", "HvHost", "IISADMIN", "irmon", "KtmRm",
        "lltdsvc", "LMHosts", "MapsBroker", "MessagingService", "MicrosoftEdgeElevationService",
        "MixedRealityOpenXRSvc", "MozillaMaintenance", "MSiSCSI", "NaturalAuthentication",
        "NcaSvc", "NcbService", "NcdAutoSetup", "Netlogon", "Netman", "NetSetupSvc",
        "NetTcpPortSharing", "NgcCtnrSvc", "NgcSvc", "NlaSvc", "nsi", "p2pimsvc",
        "p2psvc", "PcaSvc", "PeerDistSvc", "PerfHost", "PhoneSvc", "PimIndexMaintenanceSvc",
        "PNRPsvc", "p2psvc", "PNRPAutoReg", "PolicyAgent", "Power", "PrintNotify",
        "QWAVE", "RasAuto", "RasMan", "RemoteAccess", "RemoteRegistry", "RetailDemo",
        "RpcLocator", "SamSs", "SCardSvr", "ScDeviceEnum", "Schedule", "SDRSVC",
        "seclogon", "SENS", "Sense", "SensorDataService", "SensorsService", "SensorsService",
        "SessionEnv", "shpamsvc", "smphost", "SmsRouter", "SNMPTRAP", "spectrum",
        "Spooler", "SSDPSRV", "SstpSvc", "StateRepository", "StiSvc", "StorSvc",
        "SysMain", "SystemEventsBroker", "TabletInputService", "TapiSrv", "TermService",
        "TextInputManagementService", "Themes", "TieringEngineService", "TimeBrokerSvc",
        "TokenBroker", "TrkWks", "TrustedInstaller", "tzautoupdate", "UdkUserSvc",
        "UevAgentService", "UmRdpService", "UnistoreSvc", "upnphost", "UserDataSvc",
        "UserManager", "VacSvc", "VaultSvc", "vds", "vmicguestinterface", "vmicheartbeat",
        "vmickvpexchange", "vmicrdcomponents", "vmicshutdown", "vmictimesync", "vmicvmsession",
        "vmicvss", "W32Time", "W3LOGSVC", "WaaSMedicSvc", "WAS", "wcncsvc", "WdiServiceHost",
        "WdiSystemHost", "WebClient", "Wecsvc", "wercplsupport", "WerSvc", "WiaRpc",
        "WinHttpAutoProxySvc", "WinRM", "wisvc", "WlanSvc", "WMPNetworkSvc", "workfolderssvc",
        "WpcMonSvc", "WPDBusEnum", "WpnService", "wscsvc", "WSearch", "WwanSvc"
    )
    
    foreach ($service in $servicesToDisable) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
                if ($svc.Status -eq 'Running') {
                    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {}
    }
    
    $servicesToKeepManual = @(
        "RpcSs", "DcomLaunch", "RpcEptMapper", "PlugPlay", "ProfSvc", "EventLog", 
        "EventSystem", "gpsvc", "Audiosrv", "AudioEndpointBuilder", "Dhcp", "Dnscache",
        "CryptSvc", "BFE", "MpsSvc", "mpssvc", "KeyIso", "SamSs", "LanmanServer",
        "LanmanWorkstation", "nsi", "Wcmsvc", "iphlpsvc", "NetSetupSvc", "Netman",
        "NlaSvc", "PolicyAgent", "Power", "Schedule", "SENS", "ShellHWDetection",
        "SystemEventsBroker", "TimeBrokerSvc", "UserManager", "VaultSvc", "Winmgmt"
    )
    
    foreach ($service in $servicesToKeepManual) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.StartType -ne 'Manual') {
                Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue
            }
        } catch {}
    }
}

function Remove-AllBloatwareApps {
    $appsToRemove = @(
        "Microsoft.549981C3F5F10", "Microsoft.BingNews", "Microsoft.BingWeather", "Microsoft.BingSports",
        "Microsoft.BingFinance", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness",
        "Microsoft.BingTravel", "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub", "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal", "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.People",
        "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Wallet", "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera", "Microsoft.WindowsCommunicationsApps", "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp",
        "Microsoft.XboxGameCallableUI", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo",
        "Microsoft.Advertising.Xaml", "Microsoft.Todos", "Microsoft.PowerAutomateDesktop", "Microsoft.Windows.DevHome",
        "Clipchamp.Clipchamp", "Microsoft.Copilot", "Microsoft.WindowsCopilot", "Microsoft.LinkedIn",
        "Microsoft.Teams", "Microsoft.People", "Microsoft.MixedReality", "MicrosoftCorporationII.QuickAssist",
        "Microsoft.OutlookForWindows", "microsoft.windowscommunicationsapps", "Microsoft.WindowsStore",
        "Microsoft.StorePurchaseApp", "Microsoft.Widgets", "Microsoft.Windows.Photos", "Microsoft.Paint",
        "Microsoft.MSPaint", "Microsoft.WindowsCalculator", "Microsoft.WindowsNotepad", "Microsoft.MicrosoftStickyNotes",
        "Microsoft.People", "Microsoft.WindowsFeedbackHub", "Microsoft.Getstarted", "Microsoft.MicrosoftEdge",
        "Microsoft.MicrosoftEdge.Stable", "MicrosoftEdge", "Microsoft.WebMediaExtensions", "Microsoft.WebpImageExtension",
        "Microsoft.HEIFImageExtension", "Microsoft.VP9VideoExtensions", "Microsoft.RawImageExtension",
        "Microsoft.HEVCVideoExtension", "Microsoft.DolbyAudioExtensions", "Microsoft.DolbyVisionExtensions",
        "Microsoft.MPEG2VideoExtension", "Microsoft.AsyncTextService", "Microsoft.BingSearch", "Microsoft.ECApp",
        "Microsoft.Facebook", "Microsoft.FeedbackHub", "Microsoft.GetHelp", "Microsoft.Getstarted",
        "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MixedReality.Portal", "Microsoft.NetworkSpeedTest",
        "Microsoft.News", "Microsoft.Office.OneNote", "Microsoft.Office.Sway", "Microsoft.OneConnect",
        "Microsoft.People", "Microsoft.Print3D", "Microsoft.ScreenSketch", "Microsoft.SkypeApp",
        "Microsoft.StorePurchaseApp", "Microsoft.Todos", "Microsoft.Wallet", "Microsoft.WebMediaExtensions",
        "Microsoft.WebpImageExtension", "Microsoft.Windows.Photos", "Microsoft.WindowsAlarms", "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera", "Microsoft.WindowsCommunicationsApps", "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp",
        "Microsoft.XboxGameCallableUI", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo",
        "Microsoft.Advertising.Xaml", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftPowerBIForWindows",
        "Microsoft.MinecraftEducationEdition", "Microsoft.OneConnect", "Microsoft.PPIProjection",
        "Microsoft.Win32WebViewHost", "Microsoft.Windows.CloudExperienceHost", "Microsoft.Windows.ContentDeliveryManager",
        "Microsoft.Windows.Cortana", "Microsoft.Windows.ParentalControls", "Microsoft.Windows.PeopleExperienceHost",
        "Microsoft.Windows.PinConfirmation", "Microsoft.Windows.PostInstallExperience", "Microsoft.Windows.SecHealthUI",
        "Microsoft.Windows.SecureAssessmentBrowser", "Microsoft.Windows.ShellExperienceHost", "Microsoft.Windows.XGpuEjectDialog",
        "Microsoft.XboxGameCallableUI", "Microsoft.XboxIdentityProvider", "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.MixedReality",
        "Microsoft.WidgetsPlatformRuntime", "Microsoft.Windows.DevHome", "Microsoft.Teams", "Microsoft.Copilot",
        "Microsoft.BingWeather", "Microsoft.BingNews", "Microsoft.BingSports", "Microsoft.BingFinance",
        "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingTravel",
        "Microsoft.Getstarted", "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MixedReality.Portal", "Microsoft.Office.OneNote",
        "Microsoft.OneConnect", "Microsoft.People", "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Wallet",
        "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera", "Microsoft.WindowsCommunicationsApps",
        "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp", "Microsoft.XboxGameCallableUI", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo",
        "Microsoft.Advertising.Xaml", "Microsoft.Todos", "Microsoft.PowerAutomateDesktop", "Microsoft.Windows.DevHome",
        "Clipchamp.Clipchamp", "Microsoft.Copilot", "Microsoft.WindowsCopilot", "Microsoft.LinkedIn", "Microsoft.Teams",
        "MicrosoftCorporationII.QuickAssist", "Microsoft.OutlookForWindows", "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Widgets", "Microsoft.Windows.Photos",
        "Microsoft.Paint", "Microsoft.MSPaint", "Microsoft.WindowsCalculator", "Microsoft.WindowsNotepad",
        "Microsoft.MicrosoftStickyNotes", "Microsoft.WindowsFeedbackHub", "Microsoft.Getstarted", "MicrosoftEdge",
        "Microsoft.MicrosoftEdge", "Microsoft.MicrosoftEdge.Stable"
    )
    
    foreach ($app in $appsToRemove) {
        try {
            Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxPackage -Name $app -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$app*" } | ForEach-Object {
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
            }
        } catch {}
    }
}

function Remove-AllEdgeComponents {
    try {
        Get-Process -Name "*edge*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
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
            "C:\Windows\System32\EdgeUpdate",
            "C:\Windows\SysWOW64\EdgeUpdate",
            "C:\Program Files\Microsoft\Edge",
            "C:\Program Files\Microsoft\EdgeCore",
            "C:\Program Files\Microsoft\EdgeUpdate",
            "C:\Program Files\Microsoft\EdgeWebView",
            "$env:LOCALAPPDATA\Microsoft\EdgeUpdate",
            "$env:LOCALAPPDATA\Microsoft\Edge",
            "$env:APPDATA\Microsoft\Edge",
            "$env:ProgramData\Microsoft\Edge",
            "$env:ProgramData\Microsoft\EdgeUpdate",
            "$env:ProgramData\Microsoft\EdgeCore"
        )
        foreach ($path in $edgePaths) { if (Test-Path $path) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue } }
        
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\EdgeNative" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\EdgeNative" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeNative" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {}
}

function Remove-OneDriveCompletely {
    try {
        Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        
        $OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
        $OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
        if (Test-Path $OneDriveSetup32) { Start-Process $OneDriveSetup32 "/uninstall" -Wait -ErrorAction SilentlyContinue }
        if (Test-Path $OneDriveSetup64) { Start-Process $OneDriveSetup64 "/uninstall" -Wait -ErrorAction SilentlyContinue }
        
        Start-Sleep -Seconds 2
        
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
            "$env:USERPROFILE\AppData\Roaming\Microsoft\OneDrive",
            "C:\OneDriveTemp",
            "$env:APPDATA\Microsoft\OneDrive",
            "$env:LOCALAPPDATA\Microsoft\OneDrive",
            "$env:PROGRAMDATA\Microsoft OneDrive",
            "$env:USERPROFILE\OneDrive",
            "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive",
            "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive\Update",
            "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive\Setup",
            "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive\logs",
            "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
            "C:\Users\Default\OneDrive",
            "C:\Users\Default\AppData\Local\Microsoft\OneDrive",
            "C:\Users\Public\OneDrive",
            "C:\Users\Public\AppData\Local\Microsoft\OneDrive"
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
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    } catch {}
}

function Remove-TeamsCompletely {
    try {
        Get-Process -Name "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        
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
            "$env:ProgramFiles(x86)\Teams Installer",
            "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin",
            "$env:LOCALAPPDATA\Microsoft\TeamsPresenceAddin",
            "$env:APPDATA\Microsoft\Teams",
            "$env:APPDATA\Microsoft\TeamsMeetingAddin",
            "$env:APPDATA\Microsoft\TeamsPresenceAddin"
        )
        foreach ($dir in $teamsDirs) {
            if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue }
        }
        
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Teams" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Teams" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "Teams" -Force -ErrorAction SilentlyContinue
        
        Remove-Item -Path "HKCU:\Software\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\Software\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {}
}

function Disable-AllScheduledTasks {
    $tasksToDisable = @(
        "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "Microsoft\Windows\Application Experience\StartupAppTask",
        "Microsoft\Windows\Application Experience\PcaPatchDbTask",
        "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
        "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver",
        "Microsoft\Windows\Location\Notifications",
        "Microsoft\Windows\Location\WindowsActionDialog",
        "Microsoft\Windows\Maps\MapsUpdateTask",
        "Microsoft\Windows\Maps\MapsToastTask",
        "Microsoft\Windows\Media Center\ActivateWindowsSearch",
        "Microsoft\Windows\Media Center\ConfigureInternetTimeService",
        "Microsoft\Windows\Media Center\DispatchRecoveryTasks",
        "Microsoft\Windows\Media Center\ehdrqm",
        "Microsoft\Windows\Media Center\InstallPlayReady",
        "Microsoft\Windows\Media Center\mcupdate",
        "Microsoft\Windows\Media Center\MediaCenterRecoveryTask",
        "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask",
        "Microsoft\Windows\Media Center\OCURActivate",
        "Microsoft\Windows\Media Center\OCURDiscovery",
        "Microsoft\Windows\Media Center\PBDADiscovery",
        "Microsoft\Windows\Media Center\PBDADiscoveryW1",
        "Microsoft\Windows\Media Center\PBDADiscoveryW2",
        "Microsoft\Windows\Media Center\PvrRecoveryTask",
        "Microsoft\Windows\Media Center\PvrScheduleTask",
        "Microsoft\Windows\Media Center\RegisterSearch",
        "Microsoft\Windows\Media Center\ReindexSearchRoot",
        "Microsoft\Windows\Media Center\SqlLiteRecoveryTask",
        "Microsoft\Windows\Media Center\UpdateRecordPath",
        "Microsoft\Windows\PI\Sqm-Tasks",
        "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
        "Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "Microsoft\Windows\Windows Update\Automatic App Update",
        "Microsoft\Windows\Windows Update\Scheduled Start",
        "Microsoft\Windows\Windows Update\sih",
        "Microsoft\Windows\Windows Update\sihboot",
        "Microsoft\Windows\WindowsBackup\ConfigNotification",
        "Microsoft\Windows\WindowsBackup\Windows Backup Monitor",
        "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
        "Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
        "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
        "Microsoft\Windows\Windows Defender\Windows Defender Verification",
        "Microsoft\Windows\CloudExperienceHost\CreateObjectTask",
        "Microsoft\Windows\CloudExperienceHost\ShowSession",
        "Microsoft\Windows\DiskFootprint\Diagnostics",
        "Microsoft\Windows\FileHistory\File History",
        "Microsoft\Windows\FileHistory\File History",
        "Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures",
        "Microsoft\Windows\Flighting\OneSettings\RefreshCache",
        "Microsoft\Windows\InstallService\ScanForUpdates",
        "Microsoft\Windows\InstallService\ScanForUpdatesAsUser",
        "Microsoft\Windows\InstallService\SmartRetry",
        "Microsoft\Windows\InstallService\WakeUpAndContinueUpdates",
        "Microsoft\Windows\InstallService\WakeUpAndScanForUpdates",
        "Microsoft\Windows\LanguageComponentsInstaller\Installation",
        "Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources",
        "Microsoft\Windows\LanguageComponentsInstaller\Uninstallation",
        "Microsoft\Windows\License Manager\LicenseManager",
        "Microsoft\Windows\License Manager\LicenseManager",
        "Microsoft\Windows\Location\Notifications",
        "Microsoft\Windows\Location\WindowsActionDialog",
        "Microsoft\Windows\Maintenance\WinSAT",
        "Microsoft\Windows\Maps\MapsUpdateTask",
        "Microsoft\Windows\Maps\MapsToastTask",
        "Microsoft\Windows\Media Center\ActivateWindowsSearch",
        "Microsoft\Windows\Media Center\ConfigureInternetTimeService",
        "Microsoft\Windows\Media Center\DispatchRecoveryTasks",
        "Microsoft\Windows\Media Center\ehdrqm",
        "Microsoft\Windows\Media Center\InstallPlayReady",
        "Microsoft\Windows\Media Center\mcupdate",
        "Microsoft\Windows\Media Center\MediaCenterRecoveryTask",
        "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask",
        "Microsoft\Windows\Media Center\OCURActivate",
        "Microsoft\Windows\Media Center\OCURDiscovery",
        "Microsoft\Windows\Media Center\PBDADiscovery",
        "Microsoft\Windows\Media Center\PBDADiscoveryW1",
        "Microsoft\Windows\Media Center\PBDADiscoveryW2",
        "Microsoft\Windows\Media Center\PvrRecoveryTask",
        "Microsoft\Windows\Media Center\PvrScheduleTask",
        "Microsoft\Windows\Media Center\RegisterSearch",
        "Microsoft\Windows\Media Center\ReindexSearchRoot",
        "Microsoft\Windows\Media Center\SqlLiteRecoveryTask",
        "Microsoft\Windows\Media Center\UpdateRecordPath",
        "Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents",
        "Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic",
        "Microsoft\Windows\NetTrace\GatherNetworkInfo",
        "Microsoft\Windows\OfflineFiles\Background Synchronization",
        "Microsoft\Windows\OfflineFiles\Logon Synchronization",
        "Microsoft\Windows\PI\Sqm-Tasks",
        "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
        "Microsoft\Windows\PushToInstall\LoginCheck",
        "Microsoft\Windows\PushToInstall\Registration",
        "Microsoft\Windows\RecoveryEnvironment\VerifyWinRE",
        "Microsoft\Windows\Registry\RegIdleBackup",
        "Microsoft\Windows\Servicing\StartComponentCleanup",
        "Microsoft\Windows\SharedPC\Account Cleanup",
        "Microsoft\Windows\Shell\FamilySafetyMonitor",
        "Microsoft\Windows\Shell\FamilySafetyRefresh",
        "Microsoft\Windows\Shell\FamilySafetyUpload",
        "Microsoft\Windows\Speech\SpeechModelDownloadTask",
        "Microsoft\Windows\Sysmain\WsSwapAssessmentTask",
        "Microsoft\Windows\SystemRestore\SR",
        "Microsoft\Windows\TPM\Tpm-Maintenance",
        "Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange",
        "Microsoft\Windows\Windows Media Sharing\UpdateLibrary",
        "Microsoft\Windows\Windows Update\Automatic App Update",
        "Microsoft\Windows\Windows Update\Scheduled Start",
        "Microsoft\Windows\Windows Update\sih",
        "Microsoft\Windows\Windows Update\sihboot",
        "Microsoft\Windows\WindowsBackup\ConfigNotification",
        "Microsoft\Windows\WindowsBackup\Windows Backup Monitor",
        "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
        "Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
        "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
        "Microsoft\Windows\Windows Defender\Windows Defender Verification",
        "Microsoft\Windows\WorkFolders\Work Folders Logon Synchronization",
        "Microsoft\Windows\WorkFolders\Work Folders Maintenance Work",
        "Microsoft\Windows\Workplace Join\Automatic-Device-Join",
        "Microsoft\Windows\WwanSvc\NotificationTask",
        "Microsoft\Windows\WwanSvc\OobeDiscovery",
        "Microsoft\Windows\XblGameSave\XblGameSaveTask",
        "Microsoft\Windows\XblGameSave\XblGameSaveTaskLogon",
        "Microsoft\Windows\Xbox\XblDevicePairing",
        "Microsoft\Windows\Xbox\XblGameSaveTask",
        "Microsoft\Windows\Xbox\XblGameSaveTaskLogon",
        "Microsoft\Office\Office Automatic Updates",
        "Microsoft\Office\Office ClickToRun Service Monitor",
        "Microsoft\Office\OfficeTelemetryAgentFallBack",
        "Microsoft\Office\OfficeTelemetryAgentLogOn",
        "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck",
        "Microsoft\Windows\Autochk\Proxy",
        "Microsoft\Windows\CertificateServicesClient\KeyPreProvisioning",
        "Microsoft\Windows\CertificateServicesClient\SystemTask",
        "Microsoft\Windows\CertificateServicesClient\UserTask",
        "Microsoft\Windows\Chkdsk\ProactiveScan",
        "Microsoft\Windows\Clip\LicenseValidation",
        "Microsoft\Windows\CloudRestore\RestoreTask",
        "Microsoft\Windows\CloudRestore\SetupCleanupTask",
        "Microsoft\Windows\DataIntegrityScan\DataIntegrityScan",
        "Microsoft\Windows\Defrag\ScheduledDefrag",
        "Microsoft\Windows\Device Information\Device",
        "Microsoft\Windows\Device Setup\MetadataRefresh",
        "Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner",
        "Microsoft\Windows\Diagnosis\Scheduled",
        "Microsoft\Windows\DirectX\DirectXDatabaseUpdater"
    )
    
    foreach ($taskPath in $tasksToDisable) {
        try {
            $taskName = Split-Path $taskPath -Leaf
            $taskFolder = Split-Path $taskPath -Parent
            
            $task = Get-ScheduledTask -TaskPath "\$taskFolder\" -TaskName $taskName -ErrorAction SilentlyContinue
            if ($task) {
                Disable-ScheduledTask -InputObject $task -ErrorAction SilentlyContinue
                Unregister-ScheduledTask -TaskName $taskName -TaskPath "\$taskFolder\" -Confirm:$false -ErrorAction SilentlyContinue
            }
        } catch {}
    }
}

function Disable-AllTelemetry {
    $telemetryRegistries = @(
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "MaxTelemetryAllowed"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "DoNotShowFeedbackNotifications"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowCommercialDataPipeline"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "TailoredExperiencesWithDiagnosticDataEnabled"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "LetAppsAccessTelemetry"; Value = 2},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "LetAppsAccessTelemetry_UserInControlOfTheseApps"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "TailoredExperiencesWithDiagnosticDataEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"; Name = "DiagTrackAuthorization"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"; Name = "DiagTrackAuthorization"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; Name = "AITEnable"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; Name = "DisableUAR"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; Name = "DisableInventory"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; Name = "DisablePcaUI"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; Name = "DisableProgramTelemetry"; Value = 1}
    )
    
    foreach ($reg in $telemetryRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
}

function Disable-AllPrivacySettings {
    $privacyRegistries = @(
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; Name = "Value"; Value = "Deny"},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"; Name = "SensorPermissionState"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"; Name = "Status"; Value = 0},
        @{Path = "HKLM:\SYSTEM\Maps"; Name = "AutoUpdateEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync"; Name = "SyncPolicy"; Value = 5},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync"; Name = "BackupPolicy"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name = "RestrictImplicitTextCollection"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name = "RestrictImplicitInkCollection"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"; Name = "AcceptedPrivacyPolicy"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"; Name = "HasAccepted"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "LocationServicesEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "IsMiEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "SettingSyncEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name = "TailoredExperiencesWithDiagnosticDataEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback"; Name = "AutoSample"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback"; Name = "ServiceEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"; Name = "NumberOfSIUFInPeriod"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"; Name = "HarvestContacts"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_TrackDocs"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_TrackProgs"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name = "DisableTailoredExperiencesWithDiagnosticData"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name = "DisableWindowsConsumerFeatures"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsDeviceSearchHistoryEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsCloudSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsMSACloudSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsAADCloudSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name = "DisableSearchBoxSuggestions"; Value = 1}
    )
    
    foreach ($reg in $privacyRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            if ($reg.Value -eq "Deny") {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type String -Force
            } else {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
            }
        } catch {}
    }
}

function Set-PerformanceSystemSettings {
    $systemRegistries = @(
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"; Name = "LongPathsEnabled"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "ClearPageFileAtShutdown"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "LargeSystemCache"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "DisablePagingExecutive"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "NonPagedPoolQuota"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "PagedPoolQuota"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "SecondLevelDataCache"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "SystemPages"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name = "WriteWatch"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"; Name = "Win32PrioritySeparation"; Value = 38},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"; Name = "IRPStackSize"; Value = 30},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"; Name = "Size"; Value = 3},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"; Name = "DisableBandwidthThrottling"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"; Name = "DisableLargeMtu"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "Hostname"; Value = "FixOs"},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "NV Hostname"; Value = "FixOs"},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "DisableTaskOffload"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "EnableICMPRedirect"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "EnablePMTUDiscovery"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "Tcp1323Opts"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpMaxDupAcks"; Value = 2},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpWindowSize"; Value = 65536},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "GlobalMaxTcpWindowSize"; Value = 65536},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpNumConnections"; Value = 16777214},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpTimedWaitDelay"; Value = 30},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpAckFrequency"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpDelAckTicks"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"; Name = "TcpCreateAndConnectTcb"; Value = 3},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "SystemResponsiveness"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "NetworkThrottlingIndex"; Value = 10},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "GPU Priority"; Value = 8},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Priority"; Value = 6},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Scheduling Category"; Value = "High"},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "SFIO Priority"; Value = "High"},
        @{Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_FSEBehavior"; Value = 2},
        @{Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_Enabled"; Value = 0},
        @{Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_DXGIHonorFSEWindowsCompatible"; Value = 1},
        @{Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_HonorUserFSEBehaviorMode"; Value = 1},
        @{Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_EFSEFeatureFlags"; Value = 0},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "AutoEndTasks"; Value = "1"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "HungAppTimeout"; Value = "1000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "WaitToKillAppTimeout"; Value = "2000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "LowLevelHooksTimeout"; Value = "1000"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "MenuShowDelay"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "ForegroundLockTimeout"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "ForegroundFlashCount"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Keyboard"; Name = "KeyboardDelay"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Keyboard"; Name = "KeyboardSpeed"; Value = "31"},
        @{Path = "HKCU:\Control Panel\Keyboard"; Name = "InitialKeyboardIndicators"; Value = "2"},
        @{Path = "HKCU:\Control Panel\Mouse"; Name = "MouseSpeed"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Mouse"; Name = "MouseThreshold1"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Mouse"; Name = "MouseThreshold2"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Mouse"; Name = "SmoothMouseXCurve"; Value = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00))},
        @{Path = "HKCU:\Control Panel\Mouse"; Name = "SmoothMouseYCurve"; Value = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))},
        @{Path = "HKCU:\Control Panel\Accessibility\StickyKeys"; Name = "Flags"; Value = "506"},
        @{Path = "HKCU:\Control Panel\Accessibility\ToggleKeys"; Name = "Flags"; Value = "58"},
        @{Path = "HKCU:\Control Panel\Accessibility\FilterKeys"; Name = "Flags"; Value = "122"},
        @{Path = "HKCU:\Control Panel\Accessibility\MouseKeys"; Name = "Flags"; Value = "0"},
        @{Path = "HKCU:\Control Panel\Accessibility\HighContrast"; Name = "Flags"; Value = "0"}
    )
    
    foreach ($reg in $systemRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            if ($reg.Value -is [string] -and $reg.Value -match "^\d+$") {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type String -Force
            } elseif ($reg.Value -is [string] -and $reg.Value -notmatch "^\d+$") {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type String -Force
            } elseif ($reg.Value -is [int]) {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
            } elseif ($reg.Value -is [byte[]]) {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type Binary -Force
            } else {
                Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Force
            }
        } catch {}
    }
}

function Disable-WindowsFeatures {
    $featuresToDisable = @(
        "MediaPlayback",
        "WindowsMediaPlayer",
        "MediaFeatures",
        "FaxServicesClientPackage",
        "Xps-Foundation-Xps-Viewer",
        "Printing-PrintToPDFServices-Features",
        "Printing-XPSServices-Features",
        "WorkFolders-Client",
        "SmbDirect",
        "SmbHashGeneration",
        "DirectoryServices-ADAM-Client",
        "TFTP",
        "TIFFIFilter",
        "Windows-Defender-ApplicationGuard",
        "Hyper-V",
        "Hyper-V-PowerShell",
        "MicrosoftWindowsPowerShellV2",
        "MicrosoftWindowsPowerShellV2Root",
        "Internet-Explorer-Optional-amd64",
        "Internet-Explorer-Optional-x86",
        "TelnetClient",
        "TelnetServer",
        "TFTP-Client",
        "IIS-WebServerRole",
        "IIS-WebServer",
        "IIS-CommonHttpFeatures",
        "IIS-StaticContent",
        "IIS-DefaultDocument",
        "IIS-DirectoryBrowsing",
        "IIS-HttpErrors",
        "IIS-ApplicationDevelopment",
        "IIS-ASPNET",
        "IIS-ASPNET45",
        "IIS-NetFxExtensibility",
        "IIS-NetFxExtensibility45",
        "IIS-ISAPIExtensions",
        "IIS-ISAPIFilter",
        "IIS-HealthAndDiagnostics",
        "IIS-HttpLogging",
        "IIS-LoggingLibraries",
        "IIS-RequestMonitor",
        "IIS-HttpTracing",
        "IIS-CustomLogging",
        "IIS-ODBCLogging",
        "IIS-Security",
        "IIS-BasicAuthentication",
        "IIS-WindowsAuthentication",
        "IIS-DigestAuthentication",
        "IIS-ClientCertificateMappingAuthentication",
        "IIS-IISCertificateMappingAuthentication",
        "IIS-URLAuthorization",
        "IIS-RequestFiltering",
        "IIS-IPSecurity",
        "IIS-Performance",
        "IIS-HttpCompressionStatic",
        "IIS-HttpCompressionDynamic",
        "IIS-WebServerManagementTools",
        "IIS-ManagementConsole",
        "IIS-ManagementScriptingTools",
        "IIS-ManagementService",
        "IIS-IIS6ManagementCompatibility",
        "IIS-Metabase",
        "IIS-WMICompatibility",
        "IIS-LegacyScripts",
        "IIS-LegacySnapIn",
        "IIS-FTPPublishingService",
        "IIS-FTPServer",
        "IIS-FTPManagement",
        "IIS-HostableWebCore",
        "IIS-CertificateMappingAuthentication",
        "Printing-Foundation-Features",
        "Printing-Foundation-InternetPrinting-Client",
        "Printing-Foundation-LPDPrintService",
        "Printing-Foundation-LPRPortMonitor"
    )
    
    foreach ($feature in $featuresToDisable) {
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
        } catch {}
    }
}

function Disable-CortanaAndSearch {
    $cortanaRegistries = @(
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortana"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "AllowSearchToUseLocation"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "DisableWebSearch"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchUseWeb"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchPrivacy"; Value = 3},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchSafeSearch"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "AllowIndexingEncryptedStoresOrItems"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana"; Name = "value"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Experience"; Name = "AllowCortana"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"; Name = "DisableVoice"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"; Name = "AcceptedPrivacyPolicy"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name = "RestrictImplicitTextCollection"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name = "RestrictImplicitInkCollection"; Value = 1},
        @{Path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"; Name = "HarvestContacts"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"; Name = "HasAccepted"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name = "CortanaConsent"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name = "SearchboxTaskbarMode"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name = "BingSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Name = "AllowSearchToUseLocation"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsDeviceSearchHistoryEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsCloudSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsMSACloudSearchEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsAADCloudSearchEnabled"; Value = 0}
    )
    
    foreach ($reg in $cortanaRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
    
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    } catch {}
}

function Disable-WidgetsAndNews {
    $widgetsRegistries = @(
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"; Name = "ShellFeedsTaskbarViewMode"; Value = 2},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"; Name = "ShellFeedsEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"; Name = "EnableFeeds"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name = "AllowNewsAndInterests"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarDa"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTaskViewButton"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCortanaButton"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowPeopleBar"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"; Name = "PeopleBand"; Value = 0}
    )
    
    foreach ($reg in $widgetsRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
}

function Disable-Notifications {
    $notificationsRegistries = @(
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"; Name = "ToastEnabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"; Name = "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"; Name = "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"; Name = "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"; Name = "NOC_GLOBAL_SETTING_ALLOW_QUEUE"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.LowDisk"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Printing"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance"; Name = "Enabled"; Value = 0},
        @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SystemEvent"; Name = "Enabled"; Value = 0}
    )
    
    foreach ($reg in $notificationsRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
}

function Optimize-Explorer {
    $explorerRegistries = @(
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "DisallowShaking"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "EnableBalloonTips"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "EnableUIAnimation"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ExtendedUIHoverTime"; Value = 10000},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "FolderContentsInfoTip"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "FullPathAddress"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideDrivesWithNoMedia"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideFileExt"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideMergeConflicts"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "IconsOnly"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewAlphaSelect"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewShadow"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "MapNetDrvBtn"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "NavPaneExpandToCurrentFolder"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "NavPaneShowAllFolders"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ServerAdminUI"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCompColor"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCortanaButton"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowEncryptCompressedColor"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowInfoTip"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowPreviewHandlers"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowStatusBar"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowSyncProviderNotifications"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTaskViewButton"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTypeOverlay"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_PowerButtonAction"; Value = 2},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowCommandPrompt"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowControlPanel"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowDownloads"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowFrequentPrograms"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowHome"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowMyGames"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowNetPlaces"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowRecentPrograms"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowRun"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_ShowUser"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAcrylicOpacity"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAl"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarGlomLevel"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarSmallIcons"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "UseCheckBox"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "UseFormFill"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "WebView"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCortanaButton"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTaskViewButton"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowPeopleBar"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "EnableBalloonTips"; Value = 0},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"; Name = "EnthusiastMode"; Value = 1},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"; Name = "ShowProgress"; Value = 0}
    )
    
    foreach ($reg in $explorerRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
    
    try {
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe" -ErrorAction SilentlyContinue
    } catch {}
}

function Optimize-PowerSettings {
    $powerRegistries = @(
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"; Name = "HibernateEnabled"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"; Name = "SleepReliabilityDetailedDiagnostics"; Value = 0},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"; Name = "PowerThrottlingOff"; Value = 1},
        @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"; Name = "HiberbootEnabled"; Value = 0},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "AlwaysOn"; Value = 1},
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "NoLazyMode"; Value = 1}
    )
    
    foreach ($reg in $powerRegistries) {
        try {
            if (-not (Test-Path $reg.Path)) {
                New-Item -Path $reg.Path -Force | Out-Null
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
        } catch {}
    }
    
    try {
        powercfg -h off
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    } catch {}
}

function Remove-AllShortcuts {
    $shortcutPatterns = @(
        "*Teams*.lnk", "*LinkedIn*.lnk", "*Family*.lnk", "*Dev Home*.lnk", 
        "*Xbox*.lnk", "*Skype*.lnk", "*Cortana*.lnk", "*OneDrive*.lnk",
        "*Microsoft Edge*.lnk", "*Edge*.lnk", "*News*.lnk", "*Weather*.lnk",
        "*Sports*.lnk", "*Finance*.lnk", "*Office*.lnk", "*To Do*.lnk",
        "*People*.lnk", "*Mail*.lnk", "*Calendar*.lnk", "*Camera*.lnk",
        "*Photos*.lnk", "*Maps*.lnk", "*Alarms*.lnk", "*Clock*.lnk",
        "*Calculator*.lnk", "*Paint*.lnk", "*Notepad*.lnk", "*Sticky Notes*.lnk",
        "*Feedback*.lnk", "*Get Started*.lnk", "*Tips*.lnk", "*Mixed Reality*.lnk",
        "*Print 3D*.lnk", "*3D Viewer*.lnk", "*Solitaire*.lnk", "*Spotify*.lnk",
        "*Disney*.lnk", "*Netflix*.lnk", "*Hulu*.lnk", "*Facebook*.lnk",
        "*Instagram*.lnk", "*Twitter*.lnk", "*TikTok*.lnk", "*Snapchat*.lnk",
        "*Pinterest*.lnk", "*Reddit*.lnk", "*WhatsApp*.lnk", "*Messenger*.lnk",
        "*Zoom*.lnk", "*Discord*.lnk", "*Slack*.lnk", "*Telegram*.lnk",
        "*Signal*.lnk", "*Viber*.lnk", "*Line*.lnk", "*WeChat*.lnk",
        "*QQ*.lnk", "*Skype*.lnk", "*TeamViewer*.lnk", "*AnyDesk*.lnk",
        "*Chrome*.lnk", "*Firefox*.lnk", "*Opera*.lnk", "*Brave*.lnk",
        "*Vivaldi*.lnk", "*Torch*.lnk", "*Maxthon*.lnk", "*Slimjet*.lnk",
        "*Iron*.lnk", "*Pale Moon*.lnk", "*Waterfox*.lnk", "*SeaMonkey*.lnk"
    )
    
    $desktopPaths = @(
        "$env:PUBLIC\Desktop",
        "$env:USERPROFILE\Desktop"
    )
    
    $profiles = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(Default|Public|All Users|defaultuser0)$' }
    foreach ($profile in $profiles) {
        $userDesktop = Join-Path $profile.FullName "Desktop"
        if (Test-Path $userDesktop -and $userDesktop -notin $desktopPaths) {
            $desktopPaths += $userDesktop
        }
    }
    
    $startMenuPaths = @(
        "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    )
    
    foreach ($profile in $profiles) {
        $userStartMenu = Join-Path $profile.FullName "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        if (Test-Path $userStartMenu -and $userStartMenu -notin $startMenuPaths) {
            $startMenuPaths += $userStartMenu
        }
    }
    
    $allPaths = $desktopPaths + $startMenuPaths
    
    foreach ($path in $allPaths) {
        if (Test-Path $path) {
            foreach ($pattern in $shortcutPatterns) {
                try {
                    Get-ChildItem -Path $path -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }
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

function Start-WindowsOptimization {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Please run as Administrator"
        return $false
    }

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue

    Remove-AllBloatwareApps
    Remove-AllEdgeComponents
    Remove-OneDriveCompletely
    Remove-TeamsCompletely
    Disable-AllScheduledTasks
    Disable-AllTelemetry
    Disable-AllPrivacySettings
    Disable-AllBackgroundApps
    Disable-AllNonCriticalServices
    Set-PerformanceVisualEffects
    Set-PerformanceSystemSettings
    Disable-WindowsFeatures
    Disable-CortanaAndSearch
    Disable-WidgetsAndNews
    Disable-Notifications
    Optimize-Explorer
    Optimize-PowerSettings
    Remove-AllShortcuts
    Set-Wallpaper
    Create-ToolboxShortcut
    
    return $true
}

function Apply-RegistryTweaks {
    
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

    $photoExtensions = @(".bpm", ".cr2", ".dib", ".gif", ".ico", ".jfif", ".jpe", ".jpeg", ".jpg", ".jxr", ".png", ".tif", ".tiff", ".wdp")

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

    $commonFlags = @("--exact", "--silent", "--accept-package-agreements", "--accept-source-agreements", "--source", "winget")

    & $winget install --id Brave.Brave @commonFlags
    & $winget install --id Nilesoft.Shell @commonFlags

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
    
    $finalRegKeys = @(
        "HKCU:\Software\Microsoft\OneDrive",
        "HKCU:\Software\Microsoft\Teams",
        "HKCU:\Software\Microsoft\XboxApp",
        "HKLM:\Software\Microsoft\Xbox",
        "HKLM:\Software\Microsoft\GamingServices",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost",
        "HKCU:\Software\Microsoft\LinkedIn",
        "HKCU:\Software\Microsoft\Family"
    )
    
    foreach ($regKey in $finalRegKeys) {
        if (Test-Path $regKey) {
            Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "`r[###############     ] 75%" -NoNewline
    Start-Sleep -Milliseconds 100
    
    Write-Host "`r[####################] 100%"
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
