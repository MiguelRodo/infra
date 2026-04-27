#!/usr/bin/env bash
# infra - Project infrastructure setup utility wrapper
# Dispatches subcommands to the appropriate script

set -e

SCRIPTS_DIR="/usr/share/infra/scripts"

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
  --version|-V)
    echo "1.0.0"
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
