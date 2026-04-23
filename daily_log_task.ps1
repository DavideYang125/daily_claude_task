# Daily Claude task - sends message to Claude and logs response

# Set git-bash path for Claude Code (required when running from Task Scheduler)
$env:CLAUDE_CODE_GIT_BASH_PATH = "D:\software\git\set\Git\bin\bash.exe"

$logPath = "E:\demo\learn\auto_tool\cc_auto\daily_execution_log.txt"

# Get current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Message to send to Claude
$message = "What time is it now? Please answer briefly."

# Write request to log
$logMessage = "[$timestamp] Sending to Claude: $message"
Add-Content -Path $logPath -Value $logMessage
Add-Content -Path $logPath -Value "----------------------------------------"

# Call Claude with -p flag (non-interactive, print response and exit)
$response = claude -p $message 2>&1

# Write Claude's response to log
Add-Content -Path $logPath -Value "Claude Response:"
Add-Content -Path $logPath -Value $response
Add-Content -Path $logPath -Value "========================================"
Add-Content -Path $logPath -Value ""

# Output to console
Write-Host "[$timestamp] Claude task completed"
Write-Host "Response logged to: $logPath"
Write-Host "Closing in 3 seconds..."

# Wait 3 seconds then close
Start-Sleep -Seconds 3
