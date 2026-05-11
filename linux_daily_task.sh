#!/bin/bash
# Daily Claude task - sends message to Claude and logs response
# Linux equivalent of daily_log_task.ps1

# === Configuration ===
LOG_DIR="$HOME/cc_auto"
LOG_FILE="$LOG_DIR/daily_execution_log.txt"
MESSAGE="What time is it now? Please answer briefly."

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Write request to log
echo "[$TIMESTAMP] Sending to Claude: $MESSAGE" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# Call Claude with -p flag (non-interactive, print response and exit)
RESPONSE=$(claude -p "$MESSAGE" 2>&1)

# Write Claude's response to log
echo "Claude Response:" >> "$LOG_FILE"
echo "$RESPONSE" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Output to console
echo "[$TIMESTAMP] Claude task completed"
echo "Response logged to: $LOG_FILE"
