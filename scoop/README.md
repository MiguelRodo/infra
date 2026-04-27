# Scoop Manifest for infra

This directory contains the Scoop manifest for installing `infra` on Windows.

## Installation

```powershell
scoop bucket add infra https://github.com/MiguelRodo/scoop-bucket
scoop install infra
```

## Development

The manifest is maintained in `scoop/infra.json`.  When a new release is tagged,
the GitHub Actions release workflow automatically updates the `hash` checksum
and `version`/`url` fields.

## Manual bucket setup

If you maintain a Scoop bucket (`MiguelRodo/scoop-bucket`), copy `infra.json`
into the bucket repository root and push.  Scoop will pick it up automatically.

## Dependencies

The manifest declares dependencies on `git` and `jq`, which Scoop installs
automatically. You also need
[Git for Windows](https://git-scm.com/download/win) for Bash support.
