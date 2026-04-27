# infra

A CLI utility for setting up standard project infrastructure, including devcontainers, README templates, and repository lists — for both individual repositories and multi-repo compendia.

VERSION_INFRA=1.0.0

## Features

- **Install [`repos`](https://github.com/MiguelRodo/repos)** — the multi-repository management utility, in an OS-appropriate way
- **Generate `repos.list`** — for single repos or multi-repo compendia
- **Generate `README.md`** — with a structured template (project aim, contact, links, details)
- **Set up `.devcontainer/`** — with build-based and pre-built image configurations for BioConductor, Rocker (verse), or Python
- **Add a GitHub Actions workflow** — to pre-build and publish the devcontainer image

## Installation

### Ubuntu / Debian — APT (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/KEY.gpg \
   | sudo gpg --dearmor -o /usr/share/keyrings/miguelrodo-infra.gpg
echo "deb [signed-by=/usr/share/keyrings/miguelrodo-infra.gpg] https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/ ./" \
   | sudo tee /etc/apt/sources.list.d/miguelrodo-infra.list >/dev/null
sudo apt-get update
sudo apt-get install -y infra
```

### Linux / macOS — Local install (no sudo)

```bash
git clone https://github.com/MiguelRodo/infra.git
cd infra
bash install-local.sh
```

This installs `infra` to `~/.local/bin/infra`. Ensure `~/.local/bin` is on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
# Add the above line to ~/.bashrc or ~/.profile to persist it
```

### macOS — Homebrew

```bash
brew tap MiguelRodo/infra
brew install infra
```

### Windows — Scoop

```powershell
scoop bucket add infra https://github.com/MiguelRodo/scoop-bucket
scoop install infra
```

### Windows — Manual

```powershell
git clone https://github.com/MiguelRodo/infra.git
cd infra
pwsh install.ps1
```

### R package

```r
devtools::install_github("MiguelRodo/infra")
```

### Python package

```bash
pip install git+https://github.com/MiguelRodo/infra.git
```

## Usage

```
infra <command> [options]

Commands:
  setup           Set up project infrastructure
  install-repos   Install the MiguelRodo/repos utility
```

### `infra setup`

```
Usage: infra setup [OPTIONS] [DIRECTORY]

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
```

**Examples:**

```bash
# Set up current directory with defaults (BioConductor devcontainer, single repo)
infra setup .

# Compendium with Python devcontainer and GHA prebuild workflow
infra setup --type compendium --image python --add-gha .

# Rocker verse devcontainer, also install repos utility
infra setup --image rocker --install-repos ~/my-project

# Overwrite existing files
infra setup --force .
```

### Files created by `infra setup`

| File | Description |
|------|-------------|
| `README.md` | Project README with aim, contact, links, details sections |
| `repos.list` | Repository list for use with `repos clone` |
| `.devcontainer/devcontainer.json` | Build-based devcontainer (uses local Dockerfile) |
| `.devcontainer/Dockerfile` | Dockerfile for the chosen image type |
| `.devcontainer/prebuild/devcontainer.json` | Pre-built image devcontainer |
| `.devcontainer/renv/.gitkeep` | renv cache placeholder (R images only) |
| `.github/workflows/prebuild-devcontainer.yml` | GHA workflow (if `--add-gha` specified) |

### Devcontainer image types

| Type | Base image | R support | renv cache |
|------|-----------|-----------|------------|
| `bioconductor` | `bioconductor/bioconductor_docker:RELEASE_3_21-r-4.5.2` | ✓ | ✓ |
| `rocker` | `rocker/verse:latest` | ✓ | ✓ |
| `python` | `python:3.12-slim` | ✗ | ✗ |

## Dependencies

- `bash` ≥ 3.2
- `curl` — for downloading repos and fetching the latest devcontainer image tag
- `jq` — for parsing GitHub API responses

## Documentation

Full documentation: <https://miguelrodo.github.io/infra/>

## License

MIT