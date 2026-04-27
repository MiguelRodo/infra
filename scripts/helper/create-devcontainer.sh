#!/usr/bin/env bash
# create-devcontainer.sh - Generate devcontainer files for a project
#
# Creates:
#   .devcontainer/devcontainer.json      Build-based devcontainer
#   .devcontainer/Dockerfile             Image Dockerfile
#   .devcontainer/prebuild/devcontainer.json  Pre-built image devcontainer
#
# Usage: create-devcontainer.sh [OPTIONS]

set -e

# Resolve TEMPLATES_DIR relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../../templates" && pwd)"

# Default values
image_type="bioconductor"
target_dir="."
force=false
prebuild_tag=""

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --image)
      image_type="$2"
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
    --prebuild-tag)
      prebuild_tag="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: create-devcontainer.sh [--image TYPE] [--dir DIR] [--force] [--prebuild-tag TAG]"
      echo ""
      echo "Options:"
      echo "  --image TYPE       Image type: bioconductor, rocker, or python (default: bioconductor)"
      echo "  --dir DIR          Target directory (default: current)"
      echo "  --force            Overwrite existing files"
      echo "  --prebuild-tag TAG Use this tag for the prebuild image (default: fetch from GitHub)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Validate image type
case "$image_type" in
  bioconductor|rocker|python) ;;
  *)
    echo "Invalid image type: $image_type. Must be bioconductor, rocker, or python." >&2
    exit 1
    ;;
esac

# Resolve target directory
target_dir="$(cd "$target_dir" && pwd)"

devcontainer_dir="$target_dir/.devcontainer"
prebuild_dir="$devcontainer_dir/prebuild"

# Fetch latest tag from MiguelRodo/devcontainers if not provided
if [ -z "$prebuild_tag" ]; then
  echo "Fetching latest devcontainer image tag from MiguelRodo/devcontainers..."
  if command -v curl > /dev/null 2>&1 && command -v jq > /dev/null 2>&1; then
    prebuild_tag=$(curl -sf "https://api.github.com/repos/MiguelRodo/devcontainers/tags" \
      | jq -r '.[0].name // empty' 2>/dev/null) || true
  fi
  if [ -z "$prebuild_tag" ]; then
    # v1.0.0 is the first published release of MiguelRodo/devcontainers
    prebuild_tag="v1.0.0"
    echo "Could not fetch latest tag, falling back to $prebuild_tag"
  else
    echo "Using latest tag: $prebuild_tag"
  fi
fi

# Create directories
mkdir -p "$devcontainer_dir"
mkdir -p "$prebuild_dir"

# --- Build-based devcontainer.json ---
devcontainer_json="$devcontainer_dir/devcontainer.json"
if [ -f "$devcontainer_json" ] && [ "$force" = false ]; then
  echo "$devcontainer_json already exists (use --force to overwrite)" >&2
  exit 1
fi
cp "$TEMPLATES_DIR/devcontainers/${image_type}.json" "$devcontainer_json"
echo "Created $devcontainer_json"

# --- Dockerfile ---
dockerfile="$devcontainer_dir/Dockerfile"
if [ -f "$dockerfile" ] && [ "$force" = false ]; then
  echo "$dockerfile already exists (use --force to overwrite)" >&2
  exit 1
fi
cp "$TEMPLATES_DIR/dockerfiles/Dockerfile.${image_type}" "$dockerfile"
echo "Created $dockerfile"

# For R-based images, create the renv directory placeholder
if [ "$image_type" = "bioconductor" ] || [ "$image_type" = "rocker" ]; then
  renv_dir="$devcontainer_dir/renv"
  mkdir -p "$renv_dir"
  if [ ! -f "$renv_dir/.gitkeep" ]; then
    touch "$renv_dir/.gitkeep"
    echo "Created $renv_dir/.gitkeep"
  fi
fi

# --- Prebuild devcontainer.json ---
prebuild_json="$prebuild_dir/devcontainer.json"
if [ -f "$prebuild_json" ] && [ "$force" = false ]; then
  echo "$prebuild_json already exists (use --force to overwrite)" >&2
  exit 1
fi
sed "s|LATEST_TAG|${prebuild_tag}|g" \
  "$TEMPLATES_DIR/devcontainers/prebuild.json" > "$prebuild_json"
echo "Created $prebuild_json"
