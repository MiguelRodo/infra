# Version of the infra CLI bundled inside this package.
# Updated automatically by the version-and-release workflow.
.bundled_cli_version <- "1.0.0"

#' Return the version of the infra CLI bundled in this package
#'
#' The R package ships its own copy of the Bash scripts at a specific CLI
#' version.  This function returns that pinned version string.
#'
#' @return A character string with the bundled CLI version (e.g. \code{"1.0.0"}).
#'
#' @examples
#' infra_bundled_cli_version()
#'
#' @export
infra_bundled_cli_version <- function() {
  .bundled_cli_version
}

#' Return the version of the infra CLI installed on the system PATH
#'
#' Runs \code{infra --version} using the system-wide \code{infra} binary.  If
#' no system-wide \code{infra} CLI is found, returns \code{NULL} instead of
#' raising an error.
#'
#' @return A character string with the installed CLI version, or \code{NULL}
#'   if \code{infra} is not found on the system \code{PATH}.
#'
#' @examples
#' \dontrun{
#' ver <- infra_installed_cli_version()
#' if (is.null(ver)) {
#'   message("infra CLI is not installed on this system.")
#' } else {
#'   message("Installed CLI version: ", ver)
#' }
#' }
#'
#' @export
infra_installed_cli_version <- function() {
  found <- nchar(Sys.which("infra")) > 0L
  if (!found) {
    return(NULL)
  }
  out <- tryCatch(
    system2("infra", "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) NULL
  )
  if (is.null(out) || length(out) == 0L) {
    return(NULL)
  }
  sub("^v", "", trimws(out[[1L]]))
}

#' Install the infra CLI
#'
#' Prints OS-appropriate instructions for installing the \code{infra}
#' command-line tool and, when \code{run = TRUE}, attempts to run the
#' installer automatically.
#'
#' @param run Logical (default \code{FALSE}).  If \code{TRUE}, attempt to run
#'   the installer automatically.
#'
#' @return Invisibly returns \code{NULL}.
#'
#' @examples
#' \dontrun{
#' infra_install_cli()
#' infra_install_cli(run = TRUE)
#' }
#'
#' @export
infra_install_cli <- function(run = FALSE) {
  sysname <- Sys.info()[["sysname"]]

  if (sysname == "Linux") {
    message("To install the infra CLI on Ubuntu/Debian, choose one of:\n")
    message("  # Option 1: APT repository (recommended -- keeps infra up to date):")
    message("  curl -fsSL https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/KEY.gpg \\")
    message("     | sudo gpg --dearmor -o /usr/share/keyrings/miguelrodo-infra.gpg")
    message('  echo "deb [signed-by=/usr/share/keyrings/miguelrodo-infra.gpg] https://raw.githubusercontent.com/MiguelRodo/apt-miguelrodo/main/ ./" \\')
    message("     | sudo tee /etc/apt/sources.list.d/miguelrodo-infra.list >/dev/null")
    message("  sudo apt-get update && sudo apt-get install -y infra\n")
    message("  # Option 2: User-level install (no sudo required):")
    message("  git clone https://github.com/MiguelRodo/infra.git /tmp/infra-cli")
    message("  bash /tmp/infra-cli/install-local.sh\n")
    if (isTRUE(run)) {
      message("Running user-level installer...")
      tmp <- file.path(tempdir(), "infra-cli")
      ret <- system(paste0("git clone https://github.com/MiguelRodo/infra.git ", shQuote(tmp),
                           " && bash ", shQuote(file.path(tmp, "install-local.sh"))))
      if (ret != 0L) {
        warning("Installer exited with status ", ret,
                ". Check the output above for details.")
      }
    }
  } else if (sysname == "Darwin") {
    message("To install the infra CLI on macOS, run:\n")
    message("  brew tap MiguelRodo/infra")
    message("  brew install infra\n")
    if (isTRUE(run)) {
      message("Running Homebrew installer...")
      ret <- system("brew tap MiguelRodo/infra && brew install infra")
      if (ret != 0L) {
        warning("Installer exited with status ", ret,
                ". Check the output above for details.")
      }
    }
  } else if (sysname == "Windows") {
    message("To install the infra CLI on Windows, run in PowerShell:\n")
    message("  scoop bucket add infra https://github.com/MiguelRodo/scoop-bucket")
    message("  scoop install infra\n")
    message("Or download and run install.ps1 from the releases page:")
    message("  https://github.com/MiguelRodo/infra/releases\n")
    message("(Automatic installation via run = TRUE is not supported on Windows.)")
  } else {
    message("To install the infra CLI, see the installation guide:")
    message("  https://miguelrodo.github.io/infra/install.html\n")
  }

  invisible(NULL)
}


#' Run a bundled infra script
#'
#' Internal helper that locates a bundled script and executes it via
#' \code{system2()}.
#'
#' @param script_name Name of the script file inside \code{inst/scripts/}.
#' @param args Character vector of arguments to pass to the script.
#' @return Invisibly returns the exit status of the script (0 for success).
#' @keywords internal
run_infra_script <- function(script_name, args = character()) {
  script_path <- system.file(file.path("scripts", script_name), package = "infra")

  if (script_path == "" || !file.exists(script_path)) {
    stop(
      "Cannot find ", script_name,
      " script. Make sure the package is properly installed."
    )
  }

  exit_status <- system2(script_path, args = args)
  invisible(exit_status)
}

#' Project Infrastructure Setup Utility
#'
#' Dispatches to the appropriate infra subcommand.
#'
#' @param command Character string specifying the subcommand to run.
#'   Must be one of \code{"setup"} or \code{"install-repos"}.
#' @param ... Additional arguments passed to the underlying script.
#'
#' @return Invisibly returns the exit status of the script (0 for success).
#'
#' @examples
#' \dontrun{
#' infra("setup")
#' infra("setup", "--image", "python", ".")
#' infra("install-repos")
#' }
#'
#' @export
infra <- function(command, ...) {
  valid <- c("setup", "install-repos")
  if (missing(command) || !(command %in% valid)) {
    message("Usage: infra(command, ...)\n")
    message("Commands:")
    message("  \"setup\"          Set up project infrastructure")
    message("  \"install-repos\"  Install the MiguelRodo/repos utility")
    message("\nSee ?infra_setup and ?infra_install_repos for details.")
    return(invisible(1L))
  }

  switch(command,
    setup           = infra_setup(...),
    "install-repos" = infra_install_repos(...)
  )
}

#' Set Up Project Infrastructure
#'
#' Creates standard project files including \code{README.md}, \code{repos.list},
#' \code{.devcontainer/} configuration, and optionally a GHA workflow.
#'
#' @param directory Target directory (default: \code{"."}).
#' @param type Project type: \code{"single"} or \code{"compendium"}
#'   (default: \code{"single"}).
#' @param image Devcontainer image type: \code{"bioconductor"}, \code{"rocker"},
#'   or \code{"python"} (default: \code{"bioconductor"}).
#' @param add_gha Logical.  If \code{TRUE}, add a prebuild-devcontainer GHA workflow.
#' @param install_repos Logical.  If \code{TRUE}, also install the MiguelRodo/repos utility.
#' @param no_readme Logical.  If \code{TRUE}, skip creating \code{README.md}.
#' @param no_repos_list Logical.  If \code{TRUE}, skip creating \code{repos.list}.
#' @param force Logical.  If \code{TRUE}, overwrite existing files.
#' @param name Project name for the README (default: directory basename).
#' @param prebuild_tag Pre-built image tag (default: fetch latest from GitHub).
#'
#' @return Invisibly returns the exit status of the script (0 for success).
#'
#' @examples
#' \dontrun{
#' infra_setup()
#' infra_setup("my-project", image = "python", add_gha = TRUE)
#' infra_setup(type = "compendium", force = TRUE)
#' }
#'
#' @export
infra_setup <- function(
  directory = ".",
  type = "single",
  image = "bioconductor",
  add_gha = FALSE,
  install_repos = FALSE,
  no_readme = FALSE,
  no_repos_list = FALSE,
  force = FALSE,
  name = NULL,
  prebuild_tag = NULL
) {
  args <- c("--type", type, "--image", image)

  if (isTRUE(add_gha))       args <- c(args, "--add-gha")
  if (isTRUE(install_repos)) args <- c(args, "--install-repos")
  if (isTRUE(no_readme))     args <- c(args, "--no-readme")
  if (isTRUE(no_repos_list)) args <- c(args, "--no-repos-list")
  if (isTRUE(force))         args <- c(args, "--force")
  if (!is.null(name))        args <- c(args, "--name", name)
  if (!is.null(prebuild_tag)) args <- c(args, "--prebuild-tag", prebuild_tag)

  args <- c(args, directory)

  run_infra_script("setup.sh", args)
}

#' Install the MiguelRodo/repos Utility
#'
#' Installs the \href{https://github.com/MiguelRodo/repos}{repos} multi-repository
#' management utility in an OS-appropriate manner.
#'
#' @param force Logical.  If \code{TRUE}, re-install even if already installed.
#'
#' @return Invisibly returns the exit status of the script (0 for success).
#'
#' @examples
#' \dontrun{
#' infra_install_repos()
#' infra_install_repos(force = TRUE)
#' }
#'
#' @export
infra_install_repos <- function(force = FALSE) {
  args <- character()
  if (isTRUE(force)) args <- c(args, "--force")
  run_infra_script("install-repos.sh", args)
}
