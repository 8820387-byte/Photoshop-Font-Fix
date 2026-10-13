@echo off
setlocal
chcp 65001 >nul
title Photoshop Font Repair
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Repair-PS-Fonts.ps1"
if errorlevel 1 (
  echo.
  echo Repair script exited. Review the messages above.
  pause
)
endlocal
