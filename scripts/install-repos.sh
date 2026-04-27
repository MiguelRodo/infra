#!/usr/bin/env bash
# install-repos.sh - Install the MiguelRodo/repos utility in an OS-specific manner
# Usage: install-repos.sh [--force]

set -e

force=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    -h|--help)
      echo "Usage: install-repos.sh [--force]"
      echo ""
      echo "Installs the MiguelRodo/repos CLI utility."
      echo ""
      echo "Options:"
      echo "  --force   Re-install even if already installed"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Check if already installed
if command -v repos > /dev/null 2>&1 && [ "$force" = false ]; then
  echo "repos is already installed ($(repos --version 2>/dev/null || echo 'version unknown'))"
  echo "Use --force to re-install."
  exit 0
fi

# Detect OS
os="$(uname -s 2>/dev/null || echo 'unknown')"

install_linux_macos() {
  echo "Installing repos via install-local.sh..."

  if ! command -v curl > /dev/null 2>&1; then
    echo "Error: curl is required to download repos." >&2
    exit 1
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  echo "Downloading MiguelRodo/repos..."
  curl -fsSL "https://github.com/MiguelRodo/repos/archive/refs/heads/main.tar.gz" \
    -o "$tmp_dir/repos.tar.gz"

  tar -xzf "$tmp_dir/repos.tar.gz" -C "$tmp_dir"
  repos_dir="$(ls -d "$tmp_dir"/repos-* | head -1)"

  echo "Running install-local.sh..."
  bash "$repos_dir/install-local.sh"
}

install_macos_homebrew() {
  echo "Installing repos via Homebrew..."
  brew tap MiguelRodo/repos 2>/dev/null || true
  brew install repos
}

case "$os" in
  Linux)
    install_linux_macos
    ;;
  Darwin)
    if command -v brew > /dev/null 2>&1; then
      install_macos_homebrew
    else
      install_linux_macos
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Windows detected."
    echo "Please install repos using one of the following methods:"
    echo ""
    echo "  Scoop (recommended):"
    echo "    scoop bucket add MiguelRodo https://github.com/MiguelRodo/repos"
    echo "    scoop install repos"
    echo ""
    echo "  PowerShell (manual):"
    echo "    Download https://github.com/MiguelRodo/repos/archive/refs/heads/main.zip"
    echo "    Extract it and run: pwsh install.ps1"
    exit 0
    ;;
  *)
    echo "Unknown OS: $os. Attempting Linux-style installation..."
    install_linux_macos
    ;;
esac
