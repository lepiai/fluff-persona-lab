# 废话人设鉴定所 - 一键启动脚本
# 用法: 双击 启动.bat

$AppDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $AppDir

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "    FeiHua Persona Lab - One-Click Start" -ForegroundColor Cyan
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Ollama (port 11434) ---
Write-Host "  [1/4] Ollama..." -NoNewline
$ollamaRunning = $false
try {
    $tags = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 3
    if ($tags.models.name -contains "qwen3.5:2b") {
        Write-Host " OK (model ready)" -ForegroundColor Green
        $ollamaRunning = $true
    } else {
        Write-Host " OK (pulling model...)" -ForegroundColor Yellow
        Start-Process -FilePath "ollama" -ArgumentList "pull","qwen3.5:2b" -WindowStyle Minimized
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

# --- 2. URL Proxy (port 8081) ---
Write-Host "  [2/4] URL Proxy..." -NoNewline
$proxyRunning = $false
try {
    Invoke-RestMethod -Uri "http://localhost:8081/health" -TimeoutSec 3 | Out-Null
    Write-Host " OK" -ForegroundColor Green
    $proxyRunning = $true
} catch {
    Write-Host " Starting..." -ForegroundColor Yellow
    Start-Process -FilePath "python" -ArgumentList "$AppDir\proxy.py" -WindowStyle Minimized
    Start-Sleep -Seconds 2
    try {
        Invoke-RestMethod -Uri "http://localhost:8081/health" -TimeoutSec 3 | Out-Null
        Write-Host "        Proxy started" -ForegroundColor Green
        $proxyRunning = $true
    } catch {
        Write-Host "        FAILED - run manually: python proxy.py" -ForegroundColor Red
    }
}

# --- 3. HTTP Server (port 8765) ---
Write-Host "  [3/4] HTTP Server..." -NoNewline
$httpRunning = $false
try {
    Invoke-WebRequest -Uri "http://localhost:8765/" -TimeoutSec 2 -UseBasicParsing | Out-Null
    Write-Host " OK" -ForegroundColor Green
    $httpRunning = $true
} catch {
    Write-Host " Starting..." -ForegroundColor Yellow
    Start-Process -FilePath "python" -ArgumentList "-m","http.server","8765","--directory",$AppDir -WindowStyle Minimized
    Start-Sleep -Seconds 2
    try {
        Invoke-WebRequest -Uri "http://localhost:8765/" -TimeoutSec 2 -UseBasicParsing | Out-Null
        Write-Host "        HTTP server started" -ForegroundColor Green
        $httpRunning = $true
    } catch {
        Write-Host "        FAILED - run manually: python -m http.server 8765" -ForegroundColor Red
    }
}

# --- 4. Open Browser ---
Write-Host "  [4/4] Browser..." -NoNewline
Start-Sleep -Seconds 1
Start-Process "http://localhost:8765/20260625.html"
Write-Host " Opened" -ForegroundColor Green

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "    Ready!" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "    App:     http://localhost:8765/20260625.html"
Write-Host "    Ollama:  http://localhost:11434"
Write-Host "    Proxy:   http://localhost:8081"
Write-Host ""
Write-Host "    Closing this window won't stop services." -ForegroundColor DarkGray
Write-Host "    To stop: close the 3 minimized windows." -ForegroundColor DarkGray
Write-Host ""
