#!/usr/bin/env bash
# install-local.sh - Install infra to the user's local directory without sudo
# This script installs infra to ~/.local/bin and ~/.local/share/infra

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation directories
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share/infra"

# Script directory (where this install script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Installing infra to user's local directory...${NC}"
echo

# Check for required dependencies
echo "Checking dependencies..."
MISSING_DEPS=()
for dep in bash curl jq; do
  if ! command -v "$dep" > /dev/null 2>&1; then
    MISSING_DEPS+=("$dep")
  fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo -e "${RED}Error: Missing required dependencies: ${MISSING_DEPS[*]}${NC}"
  echo "Please install them using:"
  echo "  sudo apt-get install ${MISSING_DEPS[*]}"
  echo "or equivalent for your system."
  exit 1
fi
echo -e "${GREEN}✓ All dependencies are installed${NC}"
echo

# Create installation directories
echo "Creating installation directories..."
mkdir -p "$LOCAL_BIN"
mkdir -p "$LOCAL_SHARE"
echo -e "${GREEN}✓ Created directories${NC}"
echo

# Copy scripts and templates to local share directory
echo "Installing scripts and templates to $LOCAL_SHARE..."
cp -r "$SCRIPT_DIR/scripts" "$LOCAL_SHARE/"
cp -r "$SCRIPT_DIR/templates" "$LOCAL_SHARE/"

# Make all shell scripts executable
find "$LOCAL_SHARE/scripts" -type f -name "*.sh" -exec chmod +x {} \;
echo -e "${GREEN}✓ Scripts and templates installed${NC}"
echo

# Create wrapper script in local bin
echo "Creating infra command in $LOCAL_BIN..."
cat > "$LOCAL_BIN/infra" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# infra - Project infrastructure setup utility (installed wrapper)

set -e

SCRIPTS_DIR="$HOME/.local/share/infra/scripts"

usage() {
  cat <<EOF
Usage: infra <command> [options]

Commands:
  setup           Set up project infrastructure (README, repos.list, devcontainer)
  install-repos   Install the MiguelRodo/repos utility

Run 'infra <command> --help' for more information on a command.

Examples:
  infra setup .
  infra setup --type compendium --image python --add-gha .
  infra install-repos
EOF
}

if [ $# -eq 0 ]; then
  usage >&2
  exit 1
fi

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
  setup)
    shift
    exec bash "$SCRIPTS_DIR/setup.sh" "$@"
    ;;
  install-repos)
    shift
    exec bash "$SCRIPTS_DIR/install-repos.sh" "$@"
    ;;
  *)
    echo "Error: unknown command '$1'" >&2
    echo "" >&2
    usage >&2
    exit 1
    ;;
esac
WRAPPER_EOF

chmod +x "$LOCAL_BIN/infra"
echo -e "${GREEN}✓ infra command installed${NC}"
echo

# Check if ~/.local/bin is in PATH
echo "Checking PATH configuration..."
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
  echo -e "${YELLOW}Warning: $LOCAL_BIN is not in your PATH${NC}"
  echo
  echo "Add the following line to your ~/.bashrc or ~/.profile:"
  echo
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo
  echo "Then reload your shell configuration:"
  echo "  source ~/.bashrc"
  echo
  echo "Or start a new terminal session."
else
  echo -e "${GREEN}✓ $LOCAL_BIN is already in PATH${NC}"
fi
echo

echo -e "${GREEN}Installation complete!${NC}"
echo
echo "You can now use the infra command:"
echo "  infra --help"
echo "  infra setup ."
echo "  infra setup --type compendium --add-gha ."
echo
echo "To uninstall, run:"
echo "  bash $SCRIPT_DIR/uninstall-local.sh"
echo
