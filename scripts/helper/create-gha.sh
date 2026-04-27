#!/usr/bin/env bash
# create-gha.sh - Add the prebuild-devcontainer GitHub Actions workflow
# Usage: create-gha.sh [--dir DIR] [--force]

set -e

# Resolve TEMPLATES_DIR relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../../templates" && pwd)"

# Default values
target_dir="."
force=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      target_dir="$2"
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    -h|--help)
      echo "Usage: create-gha.sh [--dir DIR] [--force]"
      echo ""
      echo "Options:"
      echo "  --dir DIR   Target directory (default: current)"
      echo "  --force     Overwrite existing workflow file"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Resolve target directory
target_dir="$(cd "$target_dir" && pwd)"

workflows_dir="$target_dir/.github/workflows"
workflow_file="$workflows_dir/prebuild-devcontainer.yml"

# Check if file already exists
if [ -f "$workflow_file" ] && [ "$force" = false ]; then
  echo "$workflow_file already exists (use --force to overwrite)" >&2
  exit 1
fi

mkdir -p "$workflows_dir"
cp "$TEMPLATES_DIR/gha/prebuild-devcontainer.yml" "$workflow_file"
echo "Created $workflow_file"
