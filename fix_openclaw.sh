#!/bin/bash
# Fix OpenClaw permissions
echo "Fixing permissions for ~/.openclaw..."
sudo chown -R $(whoami) ~/.openclaw
chmod -R u+rw ~/.openclaw

# Update Qwen Base URL
echo "Updating Qwen Base URL..."
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
  # Use sed to replace the incorrect domain
  sed -i '' 's/dashscope.aliyun.com/dashscope.aliyuncs.com/g' "$CONFIG_FILE"
  echo "Updated Base URL in $CONFIG_FILE"
else
  echo "Config file not found at $CONFIG_FILE"
fi

echo "Done. Please restart the gateway with: openclaw gateway restart"
