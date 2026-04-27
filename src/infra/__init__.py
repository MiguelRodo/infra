"""
infra - Project Infrastructure Setup Utility

A Python wrapper for the infra Bash scripts that set up standard project
infrastructure including devcontainers, README templates, and repository lists.
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Optional, List

__version__ = "1.0.0"

# Version of the infra CLI bundled inside this package.
# Updated automatically by the version-and-release workflow.
_BUNDLED_CLI_VERSION = "1.0.0"


def bundled_cli_version() -> str:
    """
    Return the version of the infra CLI bundled inside this package.

    Returns:
        str: The bundled CLI version (e.g. ``"1.0.0"``).
    """
    return _BUNDLED_CLI_VERSION


def installed_cli_version() -> Optional[str]:
    """
    Return the version of the infra CLI installed on the system PATH, or None.

    Returns:
        str or None: The installed CLI version string, or ``None`` if not found.
    """
    import shutil
    if shutil.which("infra") is None:
        return None
    try:
        result = subprocess.run(
            ["infra", "--version"],
            capture_output=True,
            text=True,
            check=False,
        )
        output = result.stdout.strip() or result.stderr.strip()
        return output.lstrip("v") if output else None
    except Exception:
        return None


def install_cli(run: bool = False) -> None:
    """
    Print OS-appropriate instructions for installing the infra CLI globally.

    Args:
        run (bool): If ``True``, attempt to run the installer automatically
            (Linux and macOS only; ignored on Windows).  Default is ``False``.
    """
    import platform
    import shutil

    system = platform.system()

    if system == "Linux":
        print("To install the infra CLI on Ubuntu/Debian, choose one of:\n")
        print("  # Option 1: APT repository (recommended — keeps infra up to date):")
        print("  curl -fsSL https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/KEY.gpg \\")
        print("     | sudo gpg --dearmor -o /usr/share/keyrings/miguelrodo-infra.gpg")
        print('  echo "deb [signed-by=/usr/share/keyrings/miguelrodo-infra.gpg] '
              'https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/ ./" \\')
        print("     | sudo tee /etc/apt/sources.list.d/miguelrodo-infra.list >/dev/null")
        print("  sudo apt-get update && sudo apt-get install -y infra\n")
        print("  # Option 2: User-level install (no sudo required):")
        print("  git clone https://github.com/MiguelRodo/infra.git /tmp/infra-cli")
        print("  bash /tmp/infra-cli/install-local.sh\n")
        if run:
            print("Running user-level installer...")
            import tempfile
            tmp = os.path.join(tempfile.mkdtemp(), "infra-cli")
            ret = subprocess.run(
                f"git clone https://github.com/MiguelRodo/infra.git {tmp!r}"
                f" && bash {os.path.join(tmp, 'install-local.sh')!r}",
                shell=True,
            ).returncode
            if ret != 0:
                print(
                    f"Warning: installer exited with status {ret}."
                    " Check the output above for details.",
                    file=sys.stderr,
                )
    elif system == "Darwin":
        print("To install the infra CLI on macOS, run:\n")
        print("  brew tap MiguelRodo/infra")
        print("  brew install infra\n")
        if run:
            print("Running Homebrew installer...")
            ret = subprocess.run(
                "brew tap MiguelRodo/infra && brew install infra", shell=True
            ).returncode
            if ret != 0:
                print(
                    f"Warning: installer exited with status {ret}."
                    " Check the output above for details.",
                    file=sys.stderr,
                )
    elif system == "Windows":
        print("To install the infra CLI on Windows, run in PowerShell:\n")
        print("  scoop bucket add infra https://github.com/MiguelRodo/scoop-bucket")
        print("  scoop install infra\n")
        print("Or download and run install.ps1 from the releases page:")
        print("  https://github.com/MiguelRodo/infra/releases\n")
        print("(Automatic installation via run=True is not supported on Windows.)")
    else:
        print("To install the infra CLI, see the installation guide:")
        print("  https://miguelrodo.github.io/infra/install.html\n")

    return None


def get_script_path(script_name: str) -> str:
    """
    Find the path to a bundled infra script.

    Args:
        script_name: Name of the script file (e.g., ``"setup.sh"`` or
            ``"helper/create-devcontainer.sh"``).

    Returns:
        str: Absolute path to the script file.

    Raises:
        FileNotFoundError: If the script cannot be found.
    """
    try:
        if sys.version_info >= (3, 9):
            from importlib.resources import files
            script_path = files('infra').joinpath('scripts', script_name)
            if script_path.is_file():
                return str(script_path)
        else:
            import importlib.resources as pkg_resources
            with pkg_resources.path('infra.scripts', script_name) as p:
                if p.is_file():
                    return str(p)
    except (ImportError, FileNotFoundError, AttributeError):
        pass

    module_dir = Path(__file__).parent
    script_path = module_dir / 'scripts' / script_name

    if script_path.is_file():
        return str(script_path)

    raise FileNotFoundError(
        f"Cannot find {script_name}. Make sure the package is properly installed."
    )


def run_script(script_name: str, args: Optional[List[str]] = None) -> int:
    """
    Run a bundled infra script with the given arguments.

    Args:
        script_name: Name of the script (e.g. ``"setup.sh"``).
        args: List of arguments to pass to the script.

    Returns:
        int: Exit status of the script (0 for success).
    """
    if args is None:
        args = []

    script_path = get_script_path(script_name)

    # Make script executable
    os.chmod(script_path, 0o755)

    result = subprocess.run(["bash", script_path] + args)
    return result.returncode


def setup(
    directory: str = ".",
    project_type: str = "single",
    image: str = "bioconductor",
    add_gha: bool = False,
    install_repos: bool = False,
    no_readme: bool = False,
    no_repos_list: bool = False,
    force: bool = False,
    name: Optional[str] = None,
    prebuild_tag: Optional[str] = None,
) -> int:
    """
    Set up project infrastructure in the specified directory.

    Args:
        directory: Target directory (default: current directory).
        project_type: Project type — ``"single"`` or ``"compendium"``
            (default: ``"single"``).
        image: Devcontainer image type — ``"bioconductor"``, ``"rocker"``,
            or ``"python"`` (default: ``"bioconductor"``).
        add_gha: If ``True``, add a prebuild-devcontainer GitHub Actions workflow.
        install_repos: If ``True``, also install the MiguelRodo/repos utility.
        no_readme: If ``True``, skip creating ``README.md``.
        no_repos_list: If ``True``, skip creating ``repos.list``.
        force: If ``True``, overwrite existing files.
        name: Project name for the README (default: directory basename).
        prebuild_tag: Pre-built image tag to use (default: fetch latest from GitHub).

    Returns:
        int: Exit status (0 for success).

    Examples:
        >>> from infra import setup
        >>> setup()                              # set up current directory
        >>> setup("my-project", image="python", add_gha=True)
    """
    args = ["--type", project_type, "--image", image]

    if add_gha:
        args.append("--add-gha")
    if install_repos:
        args.append("--install-repos")
    if no_readme:
        args.append("--no-readme")
    if no_repos_list:
        args.append("--no-repos-list")
    if force:
        args.append("--force")
    if name:
        args += ["--name", name]
    if prebuild_tag:
        args += ["--prebuild-tag", prebuild_tag]

    args.append(directory)

    return run_script("setup.sh", args)


def install_repos(force: bool = False) -> int:
    """
    Install the MiguelRodo/repos multi-repository management utility.

    Args:
        force: If ``True``, re-install even if already installed.

    Returns:
        int: Exit status (0 for success).
    """
    args = []
    if force:
        args.append("--force")
    return run_script("install-repos.sh", args)


def infra(command: str, *args: str) -> int:
    """
    Dispatch an infra subcommand.

    Args:
        command: One of ``"setup"`` or ``"install-repos"``.
        *args: Additional arguments forwarded to the underlying script.

    Returns:
        int: Exit status (0 for success).

    Examples:
        >>> from infra import infra
        >>> infra("setup", "--image", "python", ".")
        >>> infra("install-repos")
    """
    valid = ("setup", "install-repos")
    if command not in valid:
        print(f"Usage: infra(command, *args)\n\nCommands:")
        for cmd in valid:
            print(f"  {cmd!r}")
        return 1

    if command == "setup":
        return run_script("setup.sh", list(args))
    elif command == "install-repos":
        return run_script("install-repos.sh", list(args))
    return 1
