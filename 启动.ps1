# 废话人设鉴定所 - 一键启动脚本
# 用法: 双击 启动.bat

$AppDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $AppDir

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "    FeiHua Persona Lab - One-Click Start" -ForegroundColor Cyan
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""

# --- 检测 Python ---
$pythonCmd = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $null = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0) { $pythonCmd = $cmd; break }
    } catch {}
}
$hasPython = $pythonCmd -ne $null

# --- 1. Ollama (port 11434) ---
Write-Host "  [1/3] Ollama..." -NoNewline
$ollamaRunning = $false
try {
    $tags = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 3
    if ($tags.models.name -contains "qwen3.5:4b") {
        Write-Host " OK (model ready)" -ForegroundColor Green
        $ollamaRunning = $true
    } else {
        Write-Host " OK (pulling model...)" -ForegroundColor Yellow
        Start-Process -FilePath "ollama" -ArgumentList "pull","qwen3.5:4b" -WindowStyle Minimized
        $ollamaRunning = $true
    }
} catch {
    Write-Host " Starting..." -ForegroundColor Yellow
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
    Start-Sleep -Seconds 5
    try {
        Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 | Out-Null
        Write-Host "        Ollama started" -ForegroundColor Green
        $ollamaRunning = $true
    } catch {
        Write-Host "        FAILED - run manually: ollama serve" -ForegroundColor Red
    }
}

# --- 2. URL Proxy + HTTP Server (需要 Python) ---
$proxyRunning = $false
$httpRunning = $false

if ($hasPython) {
    # --- 2a. URL Proxy (port 8081) ---
    Write-Host "  [2/3] URL Proxy..." -NoNewline
    try {
        Invoke-RestMethod -Uri "http://localhost:8081/health" -TimeoutSec 3 | Out-Null
        Write-Host " OK" -ForegroundColor Green
        $proxyRunning = $true
    } catch {
        Write-Host " Starting..." -ForegroundColor Yellow
        Start-Process -FilePath $pythonCmd -ArgumentList "$AppDir\proxy.py" -WindowStyle Minimized
        Start-Sleep -Seconds 2
        try {
            Invoke-RestMethod -Uri "http://localhost:8081/health" -TimeoutSec 3 | Out-Null
            Write-Host "        Proxy started" -ForegroundColor Green
            $proxyRunning = $true
        } catch {
            Write-Host "        FAILED - run manually: $pythonCmd proxy.py" -ForegroundColor Red
        }
    }

    # --- 2b. HTTP Server (port 8765) ---
    Write-Host "        HTTP Server..." -NoNewline
    try {
        Invoke-WebRequest -Uri "http://localhost:8765/" -TimeoutSec 2 -UseBasicParsing | Out-Null
        Write-Host " OK" -ForegroundColor Green
        $httpRunning = $true
    } catch {
        Write-Host " Starting..." -ForegroundColor Yellow
        Start-Process -FilePath $pythonCmd -ArgumentList "-m","http.server","8765","--directory",$AppDir -WindowStyle Minimized
        Start-Sleep -Seconds 2
        try {
            Invoke-WebRequest -Uri "http://localhost:8765/" -TimeoutSec 2 -UseBasicParsing | Out-Null
            Write-Host "        HTTP server started" -ForegroundColor Green
            $httpRunning = $true
        } catch {
            Write-Host "        FAILED" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  [2/3] Python not found - skipping URL Proxy" -ForegroundColor Yellow
    Write-Host "        URL scraping will use external proxies (less stable)" -ForegroundColor DarkGray
    Write-Host "        Recommend using text-paste mode instead" -ForegroundColor DarkGray
}

# --- 3. Open Browser ---
Write-Host "  [3/3] Browser..." -NoNewline
Start-Sleep -Seconds 1
if ($httpRunning) {
    Start-Process "http://localhost:8765/index.html"
} else {
    # 无 Python 时直接用文件协议打开
    Start-Process "$AppDir\index.html"
}
Write-Host " Opened" -ForegroundColor Green

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "    Ready!" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
if ($httpRunning) {
    Write-Host "    App:     http://localhost:8765/index.html"
} else {
    Write-Host "    App:     (opened as local file)"
}
Write-Host "    Ollama:  http://localhost:11434"
if ($proxyRunning) {
    Write-Host "    Proxy:   http://localhost:8081"
}
Write-Host ""
if (-not $hasPython) {
    Write-Host "    [!] Python not installed - URL scraping degraded" -ForegroundColor Yellow
    Write-Host "        Recommend: paste text directly instead of URL" -ForegroundColor DarkGray
    Write-Host "        Install Python to enable local proxy: https://python.org" -ForegroundColor DarkGray
    Write-Host ""
}
Write-Host "    Closing this window won't stop services." -ForegroundColor DarkGray
if ($hasPython) {
    Write-Host "    To stop: close the minimized windows." -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
Write-Host "    Made by 乐皮ai  |  v1.6  |  2026.06.26" -ForegroundColor DarkGray
Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
