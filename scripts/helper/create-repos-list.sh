#!/usr/bin/env bash
# create-repos-list.sh - Generate a repos.list file for a project
# Usage: create-repos-list.sh [--type single|compendium] [--dir DIR] [--force]

set -e

# Default values
project_type="single"
target_dir="."
force=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      project_type="$2"
      shift 2
      ;;
    --dir)
      target_dir="$2"
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    -h|--help)
      echo "Usage: create-repos-list.sh [--type single|compendium] [--dir DIR] [--force]"
      echo ""
      echo "Options:"
      echo "  --type TYPE   Project type: single or compendium (default: single)"
      echo "  --dir DIR     Target directory (default: current)"
      echo "  --force       Overwrite existing repos.list"
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

repos_list_path="$target_dir/repos.list"

# Check if file already exists
if [ -f "$repos_list_path" ] && [ "$force" = false ]; then
  echo "repos.list already exists at $repos_list_path (use --force to overwrite)" >&2
  exit 1
fi

if [ "$project_type" = "compendium" ]; then
  cat > "$repos_list_path" << 'EOF'
# repos.list - Compendium repository list
#
# List the repositories that make up this compendium, one per line.
# Repositories are cloned into the parent directory of the current location.
#
# Format:
#   https://github.com/owner/repo           Clone default branch
#   https://github.com/owner/repo @branch   Clone specific branch as worktree
#   @branch                                 New worktree of the preceding repo
#
# Examples:
#   https://github.com/myorg/analysis
#   https://github.com/myorg/data
#   https://github.com/myorg/reports

EOF
else
  cat > "$repos_list_path" << 'EOF'
# repos.list - Repository list
#
# List additional repositories needed for this project, one per line.
# Repositories are cloned into the parent directory of the current location.
#
# Format:
#   https://github.com/owner/repo           Clone default branch
#   https://github.com/owner/repo @branch   Clone specific branch as worktree
#   @branch                                 New worktree of the preceding repo
#
# Add repository URLs below:

EOF
fi

echo "Created $repos_list_path"
