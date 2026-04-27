# Homebrew Formula for infra

This directory contains the Homebrew formula for installing `infra` on macOS
(and Linux with Homebrew).

## Installation

```bash
brew tap MiguelRodo/infra
brew install infra
```

## Development

The formula is maintained in `homebrew/infra.rb`.  When a new release is tagged,
the GitHub Actions release workflow automatically updates the `sha256` checksum
and `url` version.

## Manual tap installation

If you maintain a Homebrew tap (`MiguelRodo/homebrew-infra`), copy `infra.rb`
into the tap repository's `Formula/` directory and push.  Homebrew will pick it
up automatically.

## Dependencies

The formula declares a dependency on `jq`. `bash`, `git`, and `curl` are
assumed to be available on the system (macOS provides them by default; Linux
Homebrew users should have them installed already).
