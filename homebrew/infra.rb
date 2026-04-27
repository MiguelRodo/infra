class Infra < Formula
  desc "Project infrastructure setup utility"
  homepage "https://github.com/MiguelRodo/infra"
  url "https://github.com/MiguelRodo/infra/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"
  license "MIT"

  depends_on "jq"

  def install
    # Install all scripts and templates to libexec to preserve directory structure
    libexec.install "scripts"
    libexec.install "templates"

    # Create a wrapper script in bin that calls the main dispatcher
    (bin/"infra").write <<~EOS
      #!/bin/bash
      SCRIPTS_DIR="#{libexec}/scripts"
      export SCRIPTS_DIR
      exec bash "#{libexec}/scripts/setup.sh" "$@"
    EOS

    # Create proper dispatcher
    (bin/"infra").write <<~EOS
      #!/usr/bin/env bash
      set -e
      SCRIPTS_DIR="#{libexec}/scripts"

      usage() {
        cat <<EOF
      Usage: infra <command> [options]

      Commands:
        setup           Set up project infrastructure (README, repos.list, devcontainer)
        install-repos   Install the MiguelRodo/repos utility

      Run 'infra <command> --help' for more information on a command.
      EOF
      }

      if [ $# -eq 0 ]; then usage >&2; exit 1; fi

      case "$1" in
        -h|--help) usage; exit 0 ;;
        --version|-V) echo "#{version}"; exit 0 ;;
        setup) shift; exec bash "$SCRIPTS_DIR/setup.sh" "$@" ;;
        install-repos) shift; exec bash "$SCRIPTS_DIR/install-repos.sh" "$@" ;;
        *) echo "Error: unknown command '$1'" >&2; echo "" >&2; usage >&2; exit 1 ;;
      esac
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/infra --help")
  end
end
