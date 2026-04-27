#!/usr/bin/env bash
# setup.sh - Set up project infrastructure
#
# Creates standard project files including README.md, repos.list,
# .devcontainer/ configuration, and optionally a GHA workflow.
#
# Usage: setup.sh [OPTIONS] [DIRECTORY]

set -e

# Resolve SCRIPTS_DIR relative to this script
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
project_type="single"
image_type="bioconductor"
add_gha=false
install_repos=false
no_readme=false
no_repos_list=false
force=false
project_name=""
target_dir=""
prebuild_tag=""

usage() {
  cat <<EOF
Usage: setup.sh [OPTIONS] [DIRECTORY]

Set up project infrastructure in the specified directory (default: current directory).

Options:
  --type TYPE         Project type: single or compendium (default: single)
  --image TYPE        Devcontainer image type: bioconductor, rocker, or python
                      (default: bioconductor)
  --add-gha           Add prebuild-devcontainer GitHub Actions workflow
  --install-repos     Install the MiguelRodo/repos utility
  --no-readme         Skip creating README.md
  --no-repos-list     Skip creating repos.list
  --force             Overwrite existing files
  --name NAME         Project name for README (default: directory basename)
  --prebuild-tag TAG  Pre-built image tag to use (default: fetch latest from GitHub)
  -h, --help          Show this help message

Examples:
  setup.sh                              Set up current directory (BioConductor, single repo)
  setup.sh --type compendium .          Set up current directory as compendium
  setup.sh --image python --add-gha .  Python devcontainer with GHA workflow
  setup.sh --install-repos .            Also install the repos utility
EOF
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      project_type="$2"
      shift 2
      ;;
    --image)
      image_type="$2"
      shift 2
      ;;
    --add-gha)
      add_gha=true
      shift
      ;;
    --install-repos)
      install_repos=true
      shift
      ;;
    --no-readme)
      no_readme=true
      shift
      ;;
    --no-repos-list)
      no_repos_list=true
      shift
      ;;
    --force)
      force=true
      shift
      ;;
    --name)
      project_name="$2"
      shift 2
      ;;
    --prebuild-tag)
      prebuild_tag="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -z "$target_dir" ]; then
        target_dir="$1"
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# Validate options
case "$project_type" in
  single|compendium) ;;
  *)
    echo "Invalid project type: $project_type. Must be single or compendium." >&2
    exit 1
    ;;
esac

case "$image_type" in
  bioconductor|rocker|python) ;;
  *)
    echo "Invalid image type: $image_type. Must be bioconductor, rocker, or python." >&2
    exit 1
    ;;
esac

# Resolve target directory
if [ -z "$target_dir" ]; then
  target_dir="."
fi
mkdir -p "$target_dir"
target_dir="$(cd "$target_dir" && pwd)"

echo "Setting up project infrastructure in: $target_dir"
echo "  Type:  $project_type"
echo "  Image: $image_type"
echo ""

# 1. Install repos utility (optional)
if [ "$install_repos" = true ]; then
  echo "==> Installing repos utility..."
  if [ "$force" = true ]; then
    bash "$SCRIPTS_DIR/install-repos.sh" --force
  else
    bash "$SCRIPTS_DIR/install-repos.sh"
  fi
  echo ""
fi

# 2. Create README.md
if [ "$no_readme" = false ]; then
  echo "==> Creating README.md..."
  readme_args=(--dir "$target_dir")
  [ -n "$project_name" ] && readme_args+=(--name "$project_name")
  [ "$force" = true ] && readme_args+=(--force)
  bash "$SCRIPTS_DIR/helper/create-readme.sh" "${readme_args[@]}"
  echo ""
fi

# 3. Create repos.list
if [ "$no_repos_list" = false ]; then
  echo "==> Creating repos.list..."
  repos_args=(--type "$project_type" --dir "$target_dir")
  [ "$force" = true ] && repos_args+=(--force)
  bash "$SCRIPTS_DIR/helper/create-repos-list.sh" "${repos_args[@]}"
  echo ""
fi

# 4. Create devcontainer files
echo "==> Creating .devcontainer files..."
dc_args=(--image "$image_type" --dir "$target_dir")
[ -n "$prebuild_tag" ] && dc_args+=(--prebuild-tag "$prebuild_tag")
[ "$force" = true ] && dc_args+=(--force)
bash "$SCRIPTS_DIR/helper/create-devcontainer.sh" "${dc_args[@]}"
echo ""

# 5. Add GHA workflow (optional)
if [ "$add_gha" = true ]; then
  echo "==> Adding prebuild-devcontainer GitHub Actions workflow..."
  gha_args=(--dir "$target_dir")
  [ "$force" = true ] && gha_args+=(--force)
  bash "$SCRIPTS_DIR/helper/create-gha.sh" "${gha_args[@]}"
  echo ""
fi

echo "Infrastructure setup complete!"
echo ""
echo "Files created in $target_dir:"
[ "$no_readme" = false ] && echo "  README.md"
[ "$no_repos_list" = false ] && echo "  repos.list"
echo "  .devcontainer/devcontainer.json"
echo "  .devcontainer/Dockerfile"
echo "  .devcontainer/prebuild/devcontainer.json"
[ "$add_gha" = true ] && echo "  .github/workflows/prebuild-devcontainer.yml"
echo ""
echo "Next steps:"
echo "  1. Edit README.md to describe your project"
if [ "$project_type" = "compendium" ]; then
  echo "  2. Add repository URLs to repos.list"
  echo "  3. Run 'repos clone' to clone all repositories"
fi
if [ "$add_gha" = true ]; then
  echo "  - Push a tag (e.g. v1.0.0) to trigger the prebuild workflow"
fi
