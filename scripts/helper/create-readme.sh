#!/usr/bin/env bash
# create-readme.sh - Generate a README.md for a new project
# Usage: create-readme.sh [--name NAME] [--dir DIR] [--force]

set -e

# Default values
project_name=""
target_dir="."
force=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      project_name="$2"
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
      echo "Usage: create-readme.sh [--name NAME] [--dir DIR] [--force]"
      echo ""
      echo "Options:"
      echo "  --name NAME   Project name (default: directory basename)"
      echo "  --dir DIR     Target directory (default: current)"
      echo "  --force       Overwrite existing README.md"
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

# Default project name from directory basename
if [ -z "$project_name" ]; then
  project_name="$(basename "$target_dir")"
fi

readme_path="$target_dir/README.md"

# Check if file already exists
if [ -f "$readme_path" ] && [ "$force" = false ]; then
  echo "README.md already exists at $readme_path (use --force to overwrite)" >&2
  exit 1
fi

cat > "$readme_path" << 'EOF'
# README

This repository provides infrastructure for the project to _[Briefly describe the aims and context of the analysis or research project here.]_

## Contact

For more information, please contact:  
- [Name], [Email Address]  
- [Name], [Email Address]

## Links

- [URLs to data sources (e.g. OneDrive), GitHub repositories, publications, etc.]

## Details

[Methods, timeline, team, data sources, software/tools, etc.]
EOF

echo "Created $readme_path"
