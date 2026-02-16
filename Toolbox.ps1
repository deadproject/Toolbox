$ToolboxConfig = @{
    Version = "2.0.0"
    Author = "FixOs Development Team - © 2026 Devspace. All rights reserved"
}

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Administrator required" -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# Create temp HTML file
$htmlPath = "$env:TEMP\fixos_toolbox.html"

$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FixOs Toolbox v$($ToolboxConfig.Version)</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', system-ui, sans-serif;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            animation: gradientBG 15s ease infinite;
            background-size: 400% 400%;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .container {
            max-width: 1400px;
            width: 100%;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            overflow: hidden;
            animation: slideUp 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            transform-origin: center;
        }

        @keyframes slideUp {
            0% {
                opacity: 0;
                transform: translateY(100px) scale(0.9);
            }
            100% {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .header {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            padding: 30px;
            color: white;
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .logo {
            font-family: 'Consolas', monospace;
            font-size: 24px;
            font-weight: bold;
            line-height: 1.4;
            position: relative;
            z-index: 1;
            text-shadow: 0 0 20px rgba(102, 126, 234, 0.5);
            animation: glow 2s ease-in-out infinite;
        }

        @keyframes glow {
            0%, 100% { text-shadow: 0 0 20px rgba(102, 126, 234, 0.5); }
            50% { text-shadow: 0 0 40px rgba(102, 126, 234, 0.8); }
        }

        .logo span {
            display: inline-block;
            animation: bounce 2s ease infinite;
            animation-delay: calc(var(--i) * 0.1s);
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .version {
            position: relative;
            z-index: 1;
            font-size: 14px;
            opacity: 0.8;
            margin-top: 10px;
            letter-spacing: 2px;
        }

        .nav {
            display: flex;
            padding: 20px 30px;
            background: white;
            border-bottom: 1px solid #eaeaea;
            gap: 10px;
        }

        .nav-btn {
            padding: 12px 24px;
            border: none;
            background: transparent;
            color: #666;
            font-weight: 600;
            cursor: pointer;
            border-radius: 30px;
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            position: relative;
            overflow: hidden;
        }

        .nav-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(102, 126, 234, 0.2);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .nav-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .nav-btn.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 10px 20px -5px rgba(102, 126, 234, 0.5);
        }

        .nav-btn:hover:not(.active) {
            background: #f0f0f0;
            transform: translateY(-2px);
        }

        .main-content {
            padding: 30px;
            min-height: 500px;
        }

        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateX(20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .category-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .category-card::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }

        .category-card:hover::after {
            left: 100%;
        }

        .category-card:hover {
            transform: translateY(-10px) scale(1.02);
            box-shadow: 0 20px 30px -10px rgba(102, 126, 234, 0.3);
        }

        .category-title {
            font-size: 18px;
            font-weight: bold;
            color: #1a1a2e;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eaeaea;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .category-title .count {
            background: #667eea;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
        }

        .app-list {
            max-height: 300px;
            overflow-y: auto;
            padding-right: 5px;
        }

        .app-list::-webkit-scrollbar {
            width: 6px;
        }

        .app-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        .app-list::-webkit-scrollbar-thumb {
            background: #667eea;
            border-radius: 10px;
        }

        .app-item {
            display: flex;
            align-items: center;
            padding: 8px;
            margin: 5px 0;
            border-radius: 10px;
            transition: all 0.2s;
            animation: slideIn 0.3s ease-out;
            animation-fill-mode: both;
        }

        .app-item:hover {
            background: #f8f9fa;
            transform: translateX(5px);
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .app-item input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-right: 10px;
            cursor: pointer;
            accent-color: #667eea;
            transition: all 0.2s;
        }

        .app-item input[type="checkbox"]:checked {
            transform: scale(1.1);
        }

        .app-item label {
            flex: 1;
            cursor: pointer;
            font-size: 14px;
            color: #4a4a4a;
            transition: color 0.2s;
        }

        .app-item:hover label {
            color: #667eea;
        }

        .bottom-bar {
            background: white;
            padding: 20px 30px;
            border-top: 1px solid #eaeaea;
            display: flex;
            align-items: center;
            gap: 15px;
            position: relative;
        }

        .action-btn {
            padding: 12px 30px;
            border: none;
            border-radius: 30px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            position: relative;
            overflow: hidden;
        }

        .action-btn::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 5px;
            height: 5px;
            background: rgba(255,255,255,0.5);
            opacity: 0;
            border-radius: 100%;
            transform: scale(1, 1) translate(-50%);
            transform-origin: 50% 50%;
        }

        .action-btn:focus:not(:active)::after {
            animation: ripple 1s ease-out;
        }

        @keyframes ripple {
            0% {
                transform: scale(0, 0);
                opacity: 1;
            }
            20% {
                transform: scale(25, 25);
                opacity: 1;
            }
            100% {
                opacity: 0;
                transform: scale(40, 40);
            }
        }

        .install-btn {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            box-shadow: 0 10px 20px -5px rgba(40, 167, 69, 0.4);
        }

        .install-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px -5px rgba(40, 167, 69, 0.6);
        }

        .fixos-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 10px 20px -5px rgba(102, 126, 234, 0.4);
        }

        .fixos-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px -5px rgba(102, 126, 234, 0.6);
        }

        .select-btn {
            background: #f8f9fa;
            color: #666;
            border: 1px solid #eaeaea;
        }

        .select-btn:hover {
            background: #eaeaea;
            transform: translateY(-2px);
        }

        .status {
            flex: 1;
            text-align: right;
            color: #666;
            font-size: 14px;
            padding: 10px 20px;
            background: #f8f9fa;
            border-radius: 30px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.6; }
            100% { opacity: 1; }
        }

        .progress-bar {
            position: absolute;
            bottom: 0;
            left: 0;
            height: 3px;
            background: linear-gradient(90deg, #28a745, #20c997, #667eea, #764ba2);
            background-size: 300% 100%;
            transition: width 0.3s ease;
            animation: gradientMove 3s ease infinite;
        }

        @keyframes gradientMove {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: white;
            border-radius: 30px;
            padding: 15px 25px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            z-index: 1000;
        }

        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }

        .toast.success {
            background: #28a745;
            color: white;
        }

        .toast.error {
            background: #dc3545;
            color: white;
        }

        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                ███████╗██╗██╗  ██╗  ██████╗ ███████╗<br>
                ██╔════╝██║╚██╗██╔╝ ██╔═══██╗██╔════╝<br>
                █████╗  ██║ ╚███╔╝  ██║   ██║███████╗<br>
                ██╔══╝  ██║ ██╔██╗  ██║   ██║╚════██║<br>
                ██║     ██║██╔╝ ██╗ ╚██████╔╝███████║<br>
                ╚═╝     ╚═╝╚═╝  ╚═╝  ╚═════╝ ╚══════╝
            </div>
            <div class="version">TOOLBOX v$($ToolboxConfig.Version)</div>
        </div>

        <div class="nav">
            <button class="nav-btn active" onclick="showCategory('all')">ALL APPS</button>
            <button class="nav-btn" onclick="showCategory('browsers')">BROWSERS</button>
            <button class="nav-btn" onclick="showCategory('dev')">DEV TOOLS</button>
            <button class="nav-btn" onclick="showCategory('communication')">COMMUNICATION</button>
            <button class="nav-btn" onclick="showCategory('gaming')">GAMING</button>
            <button class="nav-btn" onclick="showCategory('media')">MEDIA</button>
            <button class="nav-btn" onclick="showCategory('utilities')">UTILITIES</button>
        </div>

        <div class="main-content" id="mainContent">
            <!-- Dynamic content will be loaded here -->
        </div>

        <div class="bottom-bar">
            <button class="action-btn select-btn" onclick="selectAll()">SELECT ALL</button>
            <button class="action-btn select-btn" onclick="deselectAll()">DESELECT ALL</button>
            <button class="action-btn install-btn" onclick="installSelected()">INSTALL</button>
            <button class="action-btn fixos-btn" onclick="runFixOs()">RUN FIXOS</button>
            <div class="status" id="status">✓ Ready</div>
            <div class="progress-bar" id="progressBar" style="width: 0%;"></div>
        </div>
    </div>

    <div class="toast" id="toast"></div>

    <script>
        const categories = {
            browsers: {
                name: 'Browsers',
                apps: [
                    'Google Chrome', 'Brave', 'Firefox', 'Edge', 'Thorium', 'LibreWolf'
                ]
            },
            dev: {
                name: 'Development Tools',
                apps: [
                    'VS Code', 'Git', 'Docker', 'Python', 'Node.js', 'PowerShell 7', 'Windows Terminal', 'Notepad++'
                ]
            },
            communication: {
                name: 'Communication',
                apps: [
                    'Discord', 'Telegram', 'WhatsApp', 'Slack', 'Zoom', 'Teams'
                ]
            },
            gaming: {
                name: 'Gaming',
                apps: [
                    'Steam', 'Epic Games', 'Ubisoft Connect', 'EA Desktop', 'GOG Galaxy', 'Battle.net'
                ]
            },
            media: {
                name: 'Media',
                apps: [
                    'VLC', 'Spotify', 'OBS Studio', 'GIMP', 'HandBrake', 'Audacity'
                ]
            },
            utilities: {
                name: 'Utilities',
                apps: [
                    '7-Zip', 'PowerToys', 'WinRAR', 'CPU-Z', 'HWMonitor', 'CrystalDiskInfo'
                ]
            }
        };

        const appIds = {
            'Google Chrome': 'Google.Chrome',
            'Brave': 'Brave.Brave',
            'Firefox': 'Mozilla.Firefox',
            'Edge': 'Microsoft.Edge',
            'Thorium': 'Alex313031.Thorium',
            'LibreWolf': 'LibreWolf.LibreWolf',
            'VS Code': 'Microsoft.VisualStudioCode',
            'Git': 'Git.Git',
            'Docker': 'Docker.DockerDesktop',
            'Python': 'Python.Python.3',
            'Node.js': 'OpenJS.NodeJS',
            'PowerShell 7': 'Microsoft.PowerShell',
            'Windows Terminal': 'Microsoft.WindowsTerminal',
            'Notepad++': 'Notepad++.Notepad++',
            'Discord': 'Discord.Discord',
            'Telegram': 'Telegram.TelegramDesktop',
            'WhatsApp': 'WhatsApp.WhatsApp',
            'Slack': 'SlackTechnologies.Slack',
            'Zoom': 'Zoom.Zoom',
            'Teams': 'Microsoft.Teams',
            'Steam': 'Valve.Steam',
            'Epic Games': 'EpicGames.EpicGamesLauncher',
            'Ubisoft Connect': 'Ubisoft.Connect',
            'EA Desktop': 'ElectronicArts.EADesktop',
            'GOG Galaxy': 'GOG.Galaxy',
            'Battle.net': 'Battle.net.Battle.net',
            'VLC': 'VideoLAN.VLC',
            'Spotify': 'Spotify.Spotify',
            'OBS Studio': 'OBSProject.OBSStudio',
            'GIMP': 'GIMP.GIMP',
            'HandBrake': 'Handbrake.Handbrake',
            'Audacity': 'Audacity.Audacity',
            '7-Zip': '7zip.7zip',
            'PowerToys': 'Microsoft.PowerToys',
            'WinRAR': 'RARLab.WinRAR',
            'CPU-Z': 'CPUID.CPU-Z',
            'HWMonitor': 'CPUID.HWMonitor',
            'CrystalDiskInfo': 'CrystalDewWorld.CrystalDiskInfo'
        };

        let currentCategory = 'all';
        let selectedApps = new Set();

        function showToast(message, type = 'success') {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = `toast ${type} show`;
            setTimeout(() => {
                toast.className = 'toast';
            }, 3000);
        }

        function updateStatus(message, type = 'success') {
            const status = document.getElementById('status');
            status.textContent = message;
            status.style.animation = 'none';
            status.offsetHeight;
            status.style.animation = 'pulse 2s infinite';
        }

        function updateProgress(percent) {
            document.getElementById('progressBar').style.width = percent + '%';
        }

        function renderCategory(category) {
            currentCategory = category;
            const content = document.getElementById('mainContent');
            
            if (category === 'all') {
                let html = '<div class="categories-grid">';
                for (let [key, cat] of Object.entries(categories)) {
                    html += `
                        <div class="category-card" onclick="toggleCategory('${key}')">
                            <div class="category-title">
                                ${cat.name}
                                <span class="count">${cat.apps.length}</span>
                            </div>
                            <div class="app-list">
                    `;
                    
                    cat.apps.forEach((app, index) => {
                        const checked = selectedApps.has(app) ? 'checked' : '';
                        html += `
                            <div class="app-item" style="animation-delay: ${index * 0.05}s" onclick="event.stopPropagation()">
                                <input type="checkbox" id="app-${app}" value="${app}" ${checked} onchange="toggleApp('${app}')">
                                <label for="app-${app}">${app}</label>
                            </div>
                        `;
                    });
                    
                    html += `
                            </div>
                        </div>
                    `;
                }
                html += '</div>';
                content.innerHTML = html;
            } else {
                const cat = categories[category];
                let html = '<div class="categories-grid">';
                html += `
                    <div class="category-card" style="grid-column: 1 / -1;">
                        <div class="category-title">
                            ${cat.name}
                            <span class="count">${cat.apps.length}</span>
                        </div>
                        <div class="app-list">
                `;
                
                cat.apps.forEach((app, index) => {
                    const checked = selectedApps.has(app) ? 'checked' : '';
                    html += `
                        <div class="app-item" style="animation-delay: ${index * 0.05}s">
                            <input type="checkbox" id="app-${app}" value="${app}" ${checked} onchange="toggleApp('${app}')">
                            <label for="app-${app}">${app}</label>
                        </div>
                    `;
                });
                
                html += `
                        </div>
                    </div>
                `;
                html += '</div>';
                content.innerHTML = html;
            }

            document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelector(`.nav-btn[onclick*="${category}"]`).classList.add('active');
        }

        function showCategory(category) {
            renderCategory(category);
        }

        function toggleApp(app) {
            const checkbox = document.getElementById(`app-${app}`);
            if (checkbox.checked) {
                selectedApps.add(app);
            } else {
                selectedApps.delete(app);
            }
            updateStatus(`${selectedApps.size} apps selected`);
        }

        function selectAll() {
            if (currentCategory === 'all') {
                for (let cat of Object.values(categories)) {
                    cat.apps.forEach(app => {
                        selectedApps.add(app);
                        const checkbox = document.getElementById(`app-${app}`);
                        if (checkbox) checkbox.checked = true;
                    });
                }
            } else {
                categories[currentCategory].apps.forEach(app => {
                    selectedApps.add(app);
                    const checkbox = document.getElementById(`app-${app}`);
                    if (checkbox) checkbox.checked = true;
                });
            }
            updateStatus(`${selectedApps.size} apps selected`);
        }

        function deselectAll() {
            selectedApps.clear();
            document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
                checkbox.checked = false;
            });
            updateStatus('No apps selected');
        }

        function installSelected() {
            if (selectedApps.size === 0) {
                showToast('No apps selected', 'error');
                return;
            }

            const apps = Array.from(selectedApps);
            showToast(`Installing ${apps.length} apps...`, 'success');
            updateStatus('Installing...', 'warning');
            updateProgress(10);

            let completed = 0;
            apps.forEach((app, index) => {
                const id = appIds[app];
                if (!id) {
                    console.log(`No ID for ${app}`);
                    completed++;
                    updateProgress((completed / apps.length) * 100);
                    return;
                }

                const command = `winget install --id ${id} --exact --silent --accept-package-agreements --accept-source-agreements`;
                
                fetch('http://localhost:3000/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ command: command })
                }).then(response => response.json())
                .then(data => {
                    completed++;
                    updateProgress((completed / apps.length) * 100);
                    
                    if (completed === apps.length) {
                        showToast(`✅ Installed ${apps.length} apps`, 'success');
                        updateStatus('Ready');
                        updateProgress(0);
                    }
                }).catch(err => {
                    console.error(err);
                    completed++;
                    if (completed === apps.length) {
                        showToast(`⚠️ Installation completed with errors`, 'error');
                        updateStatus('Ready');
                        updateProgress(0);
                    }
                });
            });
        }

        function runFixOs() {
            updateStatus('Running FixOs...', 'warning');
            showToast('Running FixOs preset...', 'success');
            updateProgress(50);
            
            fetch('http://localhost:3000/fixos', {
                method: 'POST'
            }).then(() => {
                updateStatus('FixOs completed');
                showToast('✅ FixOs completed', 'success');
                updateProgress(0);
            }).catch(() => {
                updateStatus('FixOs failed');
                showToast('❌ FixOs failed', 'error');
                updateProgress(0);
            });
        }

        function toggleCategory(category) {
            showCategory(category);
        }

        // Initialize
        renderCategory('all');
    </script>
</body>
</html>
"@


$htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8

Write-Host "Starting FixOs Toolbox..." -ForegroundColor Cyan
Write-Host "Opening browser..." -ForegroundColor Yellow

Start-Process $htmlPath
