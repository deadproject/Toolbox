Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="FixOs Toolbox v2.0" 
    Height="800" 
    Width="1200"
    WindowStartupLocation="CenterScreen"
    Background="#1E1E1E"
    FontFamily="Segoe UI"
    BorderThickness="0"
    WindowStyle="None"
    AllowsTransparency="True"
    Opacity="1">
    
    <Window.Resources>
        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="5">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#404040"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#555555"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        
        <Style x:Key="CategoryButton" TargetType="Button" BasedOn="{StaticResource ModernButton}">
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="2"/>
            <Setter Property="Background" Value="#252525"/>
        </Style>
        
        <Style x:Key="InstallButton" TargetType="Button" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Background" Value="#007ACC"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#1E8FE9"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        
        <Style x:Key="CloseButton" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#C42B1C"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        
        <Style x:Key="MinimizeButton" TargetType="Button" BasedOn="{StaticResource CloseButton}">
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#404040"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        
        <Style x:Key="CheckBoxStyle" TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="5,3"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal">
                            <Border Width="18" Height="18" Background="#2D2D2D" CornerRadius="3" BorderBrush="#404040" BorderThickness="1">
                                <TextBlock Text="✓" Foreground="#007ACC" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center">
                                    <TextBlock.Style>
                                        <Style TargetType="TextBlock">
                                            <Setter Property="Visibility" Value="Collapsed"/>
                                            <Style.Triggers>
                                                <DataTrigger Binding="{Binding IsChecked, RelativeSource={RelativeSource AncestorType=CheckBox}}" Value="True">
                                                    <Setter Property="Visibility" Value="Visible"/>
                                                </DataTrigger>
                                            </Style.Triggers>
                                        </Style>
                                    </TextBlock.Style>
                                </TextBlock>
                            </Border>
                            <TextBlock Text="{TemplateBinding Content}" Margin="8,0,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Grid Margin="0">
        <Grid.RowDefinitions>
            <RowDefinition Height="40"/>
            <RowDefinition Height="120"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="60"/>
        </Grid.RowDefinitions>
        
        <Border Grid.Row="0" Background="#0D0D0D" MouseLeftButtonDown="DragWindow">
            <Grid>
                <TextBlock Text="FIXOS TOOLBOX" Foreground="#007ACC" FontSize="16" FontWeight="Bold" VerticalAlignment="Center" Margin="20,0,0,0"/>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0">
                    <Button x:Name="MinimizeBtn" Style="{StaticResource MinimizeButton}" Width="30" Height="30" Content="─" Click="MinimizeWindow"/>
                    <Button x:Name="CloseBtn" Style="{StaticResource CloseButton}" Width="30" Height="30" Content="✕" Margin="5,0,0,0" Click="CloseWindow"/>
                </StackPanel>
            </Grid>
        </Border>
        
        <Border Grid.Row="1" Background="#252525" BorderBrush="#404040" BorderThickness="0,0,0,1">
            <Grid Margin="20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="200"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <Border Grid.Column="0" Background="#1E1E1E" CornerRadius="10" Padding="10">
                    <StackPanel VerticalAlignment="Center">
                        <TextBlock Text="FIXOS" FontSize="28" FontWeight="Bold" Foreground="#007ACC"/>
                        <TextBlock Text="Toolbox v2.0" FontSize="14" Foreground="Gray" Margin="0,5,0,0"/>
                    </StackPanel>
                </Border>
                
                <Grid Grid.Column="1" Margin="20,0,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <TextBlock Grid.Column="0" Text="Windows Application Manager & System Tools" FontSize="18" Foreground="White" VerticalAlignment="Center"/>
                    <Button x:Name="InstallSelectedBtn" Grid.Column="1" Style="{StaticResource InstallButton}" Content="INSTALL SELECTED" Width="150" Height="40" Click="InstallSelected"/>
                </Grid>
            </Grid>
        </Border>
        
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="250"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            
            <Border Grid.Column="0" Background="#1A1A1A" BorderBrush="#404040" BorderThickness="0,0,1,0">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Margin="10">
                        <TextBlock Text="CATEGORIES" Foreground="Gray" FontSize="12" Margin="10,10,0,5"/>
                        
                        <Button x:Name="CatBrowsers" Style="{StaticResource CategoryButton}" Content="BROWSERS" Tag="Browsers" Click="FilterCategory"/>
                        <Button x:Name="CatFileTools" Style="{StaticResource CategoryButton}" Content="FILE TOOLS" Tag="FileTools" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatDevTools" Style="{StaticResource CategoryButton}" Content="DEV TOOLS" Tag="DevTools" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatDotNet" Style="{StaticResource CategoryButton}" Content=".NET TOOLS" Tag="DotNet" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatCommunication" Style="{StaticResource CategoryButton}" Content="COMMUNICATION" Tag="Communication" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatGaming" Style="{StaticResource CategoryButton}" Content="GAMING" Tag="Gaming" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatMicrosoft" Style="{StaticResource CategoryButton}" Content="MICROSOFT" Tag="Microsoft" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatMedia" Style="{StaticResource CategoryButton}" Content="MEDIA" Tag="Media" Margin="0,2" Click="FilterCategory"/>
                        <Button x:Name="CatProductivity" Style="{StaticResource CategoryButton}" Content="PRODUCTIVITY" Tag="Productivity" Margin="0,2" Click="FilterCategory"/>
                        
                        <Border Height="1" Background="#404040" Margin="10,15,10,10"/>
                        
                        <Button x:Name="CatAll" Style="{StaticResource CategoryButton}" Content="ALL APPLICATIONS" Tag="All" Margin="0,2" Background="#2D2D2D" Click="FilterCategory"/>
                        <Button x:Name="RunFixOsBtn" Style="{StaticResource CategoryButton}" Content="RUN FIXOS PRESET" Tag="FixOs" Margin="0,10,0,2" Background="#007ACC" Click="RunFixOsPreset"/>
                    </StackPanel>
                </ScrollViewer>
            </Border>
            
            <Border Grid.Column="1" Background="#1E1E1E">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <Border Grid.Row="0" Background="#252525" BorderBrush="#404040" BorderThickness="0,0,0,1">
                        <Grid Margin="15,0">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="30"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            
                            <CheckBox x:Name="SelectAllCheckbox" Grid.Column="0" Style="{StaticResource CheckBoxStyle}" Content="" VerticalAlignment="Center" Click="ToggleSelectAll"/>
                            <TextBlock Grid.Column="1" Text="Application" Foreground="Gray" FontSize="12" VerticalAlignment="Center"/>
                            <TextBlock Grid.Column="2" Text="Status" Foreground="Gray" FontSize="12" VerticalAlignment="Center" Margin="0,0,20,0"/>
                        </Grid>
                    </Border>
                    
                    <ScrollViewer x:Name="AppsScrollViewer" Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="#1E1E1E">
                        <StackPanel x:Name="AppsContainer" Margin="10"/>
                    </ScrollViewer>
                </Grid>
            </Border>
        </Grid>
        
        <Border Grid.Row="3" Background="#0D0D0D" BorderBrush="#404040" BorderThickness="0,1,0,0">
            <Grid Margin="20,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <TextBlock Grid.Column="0" Text="Ready" Foreground="Gray" VerticalAlignment="Center"/>
                <TextBlock x:Name="StatusText" Grid.Column="1" Text="Select applications to install" Foreground="White" VerticalAlignment="Center" Margin="20,0,0,0"/>
                <TextBlock x:Name="SelectedCountText" Grid.Column="2" Text="0 selected" Foreground="#007ACC" FontWeight="Bold" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.Add_MouseLeftButtonDown({
    $window.DragMove()
})

function CloseWindow {
    $window.Close()
}

function MinimizeWindow {
    $window.WindowState = [System.Windows.WindowState]::Minimized
}

$closeBtn = $window.FindName("CloseBtn")
$closeBtn.Add_Click({ CloseWindow })

$minimizeBtn = $window.FindName("MinimizeBtn")
$minimizeBtn.Add_Click({ MinimizeWindow })

$installSelectedBtn = $window.FindName("InstallSelectedBtn")
$selectAllCheckbox = $window.FindName("SelectAllCheckbox")
$appsContainer = $window.FindName("AppsContainer")
$statusText = $window.FindName("StatusText")
$selectedCountText = $window.FindName("SelectedCountText")
$runFixOsBtn = $window.FindName("RunFixOsBtn")

$applications = @(
    @{Name="Google Chrome"; Category="Browsers"; Id="Google.Chrome"; Installed=$false},
    @{Name="Brave Browser"; Category="Browsers"; Id="Brave.Brave"; Installed=$false},
    @{Name="Mozilla Firefox"; Category="Browsers"; Id="Mozilla.Firefox"; Installed=$false},
    @{Name="Microsoft Edge"; Category="Browsers"; Id="Microsoft.Edge"; Installed=$false},
    @{Name="Thorium Browser"; Category="Browsers"; Id="Alex313031.Thorium"; Installed=$false},
    @{Name="Waterfox"; Category="Browsers"; Id="Waterfox.Waterfox"; Installed=$false},
    @{Name="LibreWolf"; Category="Browsers"; Id="LibreWolf.LibreWolf"; Installed=$false},
    @{Name="Floorp Browser"; Category="Browsers"; Id="Floorp.Floorp"; Installed=$false},
    
    @{Name="WinRAR"; Category="FileTools"; Id="RARLab.WinRAR"; Installed=$false},
    @{Name="7-Zip"; Category="FileTools"; Id="7zip.7zip"; Installed=$false},
    
    @{Name="VS Code"; Category="DevTools"; Id="Microsoft.VisualStudioCode"; Installed=$false},
    @{Name="Notepad++"; Category="DevTools"; Id="Notepad++.Notepad++"; Installed=$false},
    @{Name="Sublime Text"; Category="DevTools"; Id="SublimeHQ.SublimeText"; Installed=$false},
    @{Name="Git"; Category="DevTools"; Id="Git.Git"; Installed=$false},
    @{Name="GitHub Desktop"; Category="DevTools"; Id="GitHub.GitHubDesktop"; Installed=$false},
    @{Name="PowerShell 7"; Category="DevTools"; Id="Microsoft.PowerShell"; Installed=$false},
    @{Name="Docker"; Category="DevTools"; Id="Docker.DockerDesktop"; Installed=$false},
    
    @{Name=".NET SDK 8"; Category="DotNet"; Id="Microsoft.DotNet.SDK.8"; Installed=$false},
    @{Name=".NET Runtime 8"; Category="DotNet"; Id="Microsoft.DotNet.Runtime.8"; Installed=$false},
    @{Name=".NET Desktop 8"; Category="DotNet"; Id="Microsoft.DotNet.DesktopRuntime.8"; Installed=$false},
    @{Name=".NET SDK 7"; Category="DotNet"; Id="Microsoft.DotNet.SDK.7"; Installed=$false},
    @{Name=".NET Runtime 7"; Category="DotNet"; Id="Microsoft.DotNet.Runtime.7"; Installed=$false},
    
    @{Name="Telegram"; Category="Communication"; Id="Telegram.TelegramDesktop"; Installed=$false},
    @{Name="Discord"; Category="Communication"; Id="Discord.Discord"; Installed=$false},
    @{Name="WhatsApp"; Category="Communication"; Id="WhatsApp.WhatsApp"; Installed=$false},
    @{Name="Slack"; Category="Communication"; Id="SlackTechnologies.Slack"; Installed=$false},
    @{Name="Zoom"; Category="Communication"; Id="Zoom.Zoom"; Installed=$false},
    
    @{Name="Steam"; Category="Gaming"; Id="Valve.Steam"; Installed=$false},
    @{Name="Epic Games"; Category="Gaming"; Id="EpicGames.EpicGamesLauncher"; Installed=$false},
    @{Name="Ubisoft Connect"; Category="Gaming"; Id="Ubisoft.Connect"; Installed=$false},
    @{Name="EA Desktop"; Category="Gaming"; Id="ElectronicArts.EADesktop"; Installed=$false},
    
    @{Name="Windows Terminal"; Category="Microsoft"; Id="Microsoft.WindowsTerminal"; Installed=$false},
    @{Name="PowerToys"; Category="Microsoft"; Id="Microsoft.PowerToys"; Installed=$false},
    @{Name="Microsoft Office"; Category="Microsoft"; Id="Microsoft.Office"; Installed=$false},
    
    @{Name="VLC Player"; Category="Media"; Id="VideoLAN.VLC"; Installed=$false},
    @{Name="OBS Studio"; Category="Media"; Id="OBSProject.OBSStudio"; Installed=$false},
    @{Name="Handbrake"; Category="Media"; Id="Handbrake.Handbrake"; Installed=$false},
    
    @{Name="Obsidian"; Category="Productivity"; Id="Obsidian.Obsidian"; Installed=$false},
    @{Name="Notion"; Category="Productivity"; Id="Notion.Notion"; Installed=$false},
    @{Name="AnyDesk"; Category="Productivity"; Id="AnyDeskSoftwareGmbH.AnyDesk"; Installed=$false},
    @{Name="TeamViewer"; Category="Productivity"; Id="TeamViewer.TeamViewer"; Installed=$false}
)

$checkboxes = @{}
$currentFilter = "All"

function Update-SelectedCount {
    $selected = ($checkboxes.Values | Where-Object { $_.IsChecked }).Count
    $selectedCountText.Text = "$selected selected"
    
    $total = $appsContainer.Children.Count
    $checked = ($appsContainer.Children | Where-Object { $_.Tag.IsChecked }).Count
    
    if ($total -gt 0 -and $checked -eq $total) {
        $selectAllCheckbox.IsChecked = $true
    } elseif ($checked -eq 0) {
        $selectAllCheckbox.IsChecked = $false
    } else {
        $selectAllCheckbox.IsChecked = $null
    }
}

function Add-AppToGrid {
    param($app)
    
    $border = New-Object System.Windows.Controls.Border
    $border.Margin = "0,0,0,1"
    $border.Background = "#252525"
    $border.Padding = "10,8"
    
    $grid = New-Object System.Windows.Controls.Grid
    $grid.Margin = "0"
    
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = "30"
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = "*"
    $col3 = New-Object System.Windows.Controls.ColumnDefinition
    $col3.Width = "80"
    
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)
    $grid.ColumnDefinitions.Add($col3)
    
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Style = $window.FindResource("CheckBoxStyle")
    $checkbox.Content = ""
    $checkbox.VerticalAlignment = "Center"
    $checkbox.Tag = $app
    $checkbox.Add_Checked({ Update-SelectedCount })
    $checkbox.Add_Unchecked({ Update-SelectedCount })
    $checkboxes[$app.Name] = $checkbox
    
    $nameText = New-Object System.Windows.Controls.TextBlock
    $nameText.Text = $app.Name
    $nameText.Foreground = "White"
    $nameText.FontSize = 13
    $nameText.VerticalAlignment = "Center"
    $nameText.Margin = "5,0,0,0"
    
    $statusText = New-Object System.Windows.Controls.TextBlock
    $statusText.Text = "Ready"
    $statusText.Foreground = "Gray"
    $statusText.FontSize = 11
    $statusText.VerticalAlignment = "Center"
    $statusText.HorizontalAlignment = "Right"
    $statusText.Margin = "0,0,10,0"
    
    [System.Windows.Controls.Grid]::SetColumn($checkbox, 0)
    [System.Windows.Controls.Grid]::SetColumn($nameText, 1)
    [System.Windows.Controls.Grid]::SetColumn($statusText, 2)
    
    $grid.Children.Add($checkbox)
    $grid.Children.Add($nameText)
    $grid.Children.Add($statusText)
    
    $border.Child = $grid
    $border.Tag = $app.Category
    
    return $border
}

function Refresh-AppList {
    $appsContainer.Children.Clear()
    $checkboxes.Clear()
    
    $filteredApps = if ($currentFilter -eq "All") {
        $applications
    } else {
        $applications | Where-Object { $_.Category -eq $currentFilter }
    }
    
    foreach ($app in $filteredApps) {
        $border = Add-AppToGrid $app
        $appsContainer.Children.Add($border)
    }
    
    $selectAllCheckbox.IsChecked = $false
    Update-SelectedCount
}

function FilterCategory {
    $button = $args[0]
    $currentFilter = $button.Tag
    Refresh-AppList
    $statusText.Text = "Showing: $currentFilter applications"
}

function ToggleSelectAll {
    $isChecked = $selectAllCheckbox.IsChecked
    
    foreach ($child in $appsContainer.Children) {
        $grid = $child.Child
        if ($grid -and $grid.Children[0] -is [System.Windows.Controls.CheckBox]) {
            $grid.Children[0].IsChecked = $isChecked
        }
    }
}

function InstallSelected {
    $selected = $checkboxes.Values | Where-Object { $_.IsChecked }
    
    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show("No applications selected!", "FixOs Toolbox", "OK", "Warning")
        return
    }
    
    $result = [System.Windows.MessageBox]::Show("Install $($selected.Count) selected application(s)?", "Confirm Installation", "YesNo", "Question")
    
    if ($result -eq "Yes") {
        $statusText.Text = "Installing applications..."
        
        foreach ($checkbox in $selected) {
            $app = $checkbox.Tag
            $statusText.Text = "Installing: $($app.Name)..."
            
            try {
                $process = Start-Process -FilePath "winget" -ArgumentList "install --id $($app.Id) --exact --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
                $app.Installed = $true
            } catch {
                [System.Windows.MessageBox]::Show("Failed to install $($app.Name)", "Error", "OK", "Error")
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        $statusText.Text = "Installation complete!"
        [System.Windows.MessageBox]::Show("Selected applications have been installed!", "Success", "OK", "Asterisk")
        $statusText.Text = "Ready"
    }
}

function RunFixOsPreset {
    $result = [System.Windows.MessageBox]::Show("Run FixOs preset? This will execute the FixOs installer.", "Confirm", "YesNo", "Question")
    
    if ($result -eq "Yes") {
        $statusText.Text = "Running FixOs preset..."
        
        try {
            $powershell = Start-Process -FilePath "powershell" -ArgumentList "-Command irm 'DevelopmentSpace.pages.dev/FixOs.ps1' | iex" -Wait -PassThru -NoNewWindow
            $statusText.Text = "FixOs preset completed!"
            [System.Windows.MessageBox]::Show("FixOs preset executed successfully!", "Success", "OK", "Asterisk")
        } catch {
            $statusText.Text = "Error running FixOs"
            [System.Windows.MessageBox]::Show("Error running FixOs preset", "Error", "OK", "Error")
        }
        
        $statusText.Text = "Ready"
    }
}

$catBrowsers = $window.FindName("CatBrowsers")
$catFileTools = $window.FindName("CatFileTools")
$catDevTools = $window.FindName("CatDevTools")
$catDotNet = $window.FindName("CatDotNet")
$catCommunication = $window.FindName("CatCommunication")
$catGaming = $window.FindName("CatGaming")
$catMicrosoft = $window.FindName("CatMicrosoft")
$catMedia = $window.FindName("CatMedia")
$catProductivity = $window.FindName("CatProductivity")
$catAll = $window.FindName("CatAll")

$catBrowsers.Add_Click({ FilterCategory @($_, "Browsers") })
$catFileTools.Add_Click({ FilterCategory @($_, "FileTools") })
$catDevTools.Add_Click({ FilterCategory @($_, "DevTools") })
$catDotNet.Add_Click({ FilterCategory @($_, "DotNet") })
$catCommunication.Add_Click({ FilterCategory @($_, "Communication") })
$catGaming.Add_Click({ FilterCategory @($_, "Gaming") })
$catMicrosoft.Add_Click({ FilterCategory @($_, "Microsoft") })
$catMedia.Add_Click({ FilterCategory @($_, "Media") })
$catProductivity.Add_Click({ FilterCategory @($_, "Productivity") })
$catAll.Add_Click({ FilterCategory @($_, "All") })

$selectAllCheckbox.Add_Click({ ToggleSelectAll })
$installSelectedBtn.Add_Click({ InstallSelected })
$runFixOsBtn.Add_Click({ RunFixOsPreset })

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.MessageBox]::Show("Please run PowerShell as Administrator!", "FixOs Toolbox", "OK", "Warning")
    exit
}

Refresh-AppList
$window.ShowDialog() | Out-Null
