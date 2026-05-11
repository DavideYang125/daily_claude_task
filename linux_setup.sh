#!/bin/bash
# ============================================================
# Claude Code Linux 一键安装配置脚本
# 包含：安装 Claude Code、配置智谱 API Key、设置定时任务
# ============================================================

set -e

echo "========================================"
echo " Claude Code Linux 安装配置脚本"
echo "========================================"
echo ""

# ----------------------------------------------------------
# Step 1: Install Node.js (if not installed)
# ----------------------------------------------------------
echo "[1/5] Checking Node.js..."

if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    echo "  Node.js already installed: $NODE_VERSION"
else
    echo "  Node.js not found, installing via nvm..."

    # Install nvm
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install latest LTS Node.js
    nvm install --lts
    echo "  Node.js installed: $(node --version)"
fi

# ----------------------------------------------------------
# Step 2: Install Claude Code
# ----------------------------------------------------------
echo ""
echo "[2/5] Installing Claude Code..."

if command -v claude &>/dev/null; then
    echo "  Claude Code already installed: $(claude --version 2>/dev/null || echo 'unknown version')"
else
    npm install -g @anthropic-ai/claude-code
    echo "  Claude Code installed successfully"
fi

# ----------------------------------------------------------
# Step 3: Configure Zhipu API Key
# ----------------------------------------------------------
echo ""
echo "[3/5] Configuring Zhipu API Key..."

# Zhipu API base URL and key
ZHIPU_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
ZHIPU_API_KEY="${ZHIPU_API_KEY:-}"

if [ -z "$ZHIPU_API_KEY" ]; then
    echo ""
    echo "  Please enter your Zhipu API Key:"
    echo "  (Get it from: https://open.bigmodel.cn/)"
    read -r -p "  API Key: " ZHIPU_API_KEY
fi

if [ -z "$ZHIPU_API_KEY" ]; then
    echo "  [ERROR] API Key cannot be empty!"
    exit 1
fi

# Add to shell profile for persistence
SHELL_RC="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ] && [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

# Remove old entries if they exist, then add new ones
sed -i '/# Zhipu Claude Code config/,+2d' "$SHELL_RC" 2>/dev/null || true

cat >> "$SHELL_RC" << 'ENVEOF'

# Zhipu Claude Code config
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
ENVEOF

# Also write the key (masked approach: use claude's own config)
# We need to set ANTHROPIC_API_KEY for Claude Code to use
sed -i '/export ANTHROPIC_API_KEY=/d' "$SHELL_RC" 2>/dev/null || true
echo "export ANTHROPIC_API_KEY=\"$ZHIPU_API_KEY\"" >> "$SHELL_RC"

# Apply to current session
export ANTHROPIC_BASE_URL="$ZHIPU_BASE_URL"
export ANTHROPIC_API_KEY="$ZHIPU_API_KEY"

echo "  API Key configured in $SHELL_RC"

# ----------------------------------------------------------
# Step 4: Deploy daily task script
# ----------------------------------------------------------
echo ""
echo "[4/5] Deploying daily task script..."

TASK_DIR="$HOME/cc_auto"
mkdir -p "$TASK_DIR"

# Create the daily task script
cat > "$TASK_DIR/daily_task.sh" << 'TASKEOF'
#!/bin/bash
# Daily Claude task - sends message to Claude and logs response

LOG_DIR="$HOME/cc_auto"
LOG_FILE="$LOG_DIR/daily_execution_log.txt"
MESSAGE="What time is it now? Please answer briefly."

# Load environment (needed when running from cron)
export PATH="/usr/local/bin:/usr/bin:$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node/ 2>/dev/null | tail -1)/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Ensure ANTHROPIC vars are loaded
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null

mkdir -p "$LOG_DIR"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Sending to Claude: $MESSAGE" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

RESPONSE=$(claude -p "$MESSAGE" 2>&1)

echo "Claude Response:" >> "$LOG_FILE"
echo "$RESPONSE" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "[$TIMESTAMP] Claude task completed"
TASKEOF

chmod +x "$TASK_DIR/daily_task.sh"
echo "  Task script deployed to: $TASK_DIR/daily_task.sh"

# ----------------------------------------------------------
# Step 5: Setup cron job
# ----------------------------------------------------------
echo ""
echo "[5/5] Setting up cron job (daily at 05:00)..."

# Remove old entry if exists
(crontab -l 2>/dev/null | grep -v "cc_auto/daily_task.sh") | crontab -

# Add new cron entry: run daily at 05:00
(crontab -l 2>/dev/null; echo "0 5 * * * $TASK_DIR/daily_task.sh >> $TASK_DIR/cron.log 2>&1") | crontab -

echo "  Cron job created: runs daily at 05:00"

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
echo ""
echo "========================================"
echo " [SUCCESS] Setup complete!"
echo "========================================"
echo ""
echo "  Task script:  $TASK_DIR/daily_task.sh"
echo "  Log file:     $TASK_DIR/daily_execution_log.txt"
echo "  Cron log:     $TASK_DIR/cron.log"
echo "  Schedule:     Daily at 05:00"
echo ""
echo "  Test now:     $TASK_DIR/daily_task.sh"
echo "  View cron:    crontab -l"
echo "  Remove cron:  crontab -l | grep -v 'daily_task.sh' | crontab -"
echo ""
echo "  NOTE: Run 'source $SHELL_RC' or open a new terminal"
echo "        to apply the API key to your current session."
echo ""
