@echo off
REM Daily Task Setup Script
REM This script creates a Windows Scheduled Task

echo ========================================
echo Daily Task Setup Tool
echo ========================================
echo.

echo Setting up daily scheduled task...
echo.

REM Delete old task if exists
echo [1/2] Deleting old task (if exists)...
schtasks /delete /tn "DailyClaudeTask" /f 2>nul
echo Old task deleted
echo.

REM Create new task
echo [2/2] Creating new task...
schtasks /create /tn "DailyClaudeTask" /tr "powershell.exe -ExecutionPolicy Bypass -File \"%~dp0daily_log_task.ps1\"" /sc daily /st 05:00 /rl highest /f
echo.

echo schtasks command completed, return code: %errorlevel%
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo [SUCCESS] Task created successfully!
    echo ========================================
    echo.
    echo Task Name: DailyClaudeTask
    echo Schedule: Daily at 13:46 + random delay (0-5 min)
    echo Script: %~dp0daily_log_task.ps1
    echo Log: %~dp0daily_execution_log.txt
    echo.
    echo To view task: schtasks /query /tn "DailyClaudeTask"
    echo To delete task: schtasks /delete /tn "DailyClaudeTask" /f
    echo To test now: schtasks /run /tn "DailyClaudeTask"
    echo.
) else (
    echo ========================================
    echo [ERROR] Task creation failed!
    echo ========================================
    echo.
    echo Possible reasons:
    echo 1. Not running as Administrator
    echo 2. Path contains special characters
    echo 3. System permissions
    echo.
    echo Please right-click and select "Run as Administrator"
    echo.
)

echo.
echo Press any key to exit...
pause >nul
