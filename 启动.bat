@echo off
chcp 65001 >nul 2>&1
title 废话人设鉴定所 - 一键启动
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0启动.ps1"
pause
