#!/usr/bin/env bash
# uninstall-local.sh - Remove infra from the user's local directory

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share/infra"

echo "Uninstalling infra..."
echo

if [ -f "$LOCAL_BIN/infra" ]; then
  rm "$LOCAL_BIN/infra"
  echo -e "${GREEN}✓ Removed $LOCAL_BIN/infra${NC}"
else
  echo "infra binary not found at $LOCAL_BIN/infra (already removed?)"
fi

if [ -d "$LOCAL_SHARE" ]; then
  rm -rf "$LOCAL_SHARE"
  echo -e "${GREEN}✓ Removed $LOCAL_SHARE${NC}"
else
  echo "infra data directory not found at $LOCAL_SHARE (already removed?)"
fi

echo
echo -e "${GREEN}Uninstallation complete.${NC}"
