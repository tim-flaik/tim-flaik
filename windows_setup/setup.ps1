# setup.ps1 - bootstrap seed for a fresh Windows machine.
#
#   irm https://raw.githubusercontent.com/tim-flaik/tim-flaik/main/windows_setup/setup.ps1 | iex
#
# This is the ONLY part of the provisioning that lives in a public repo, and it
# does as little as possible: install git + gh, authenticate, clone the private
# machine-setup repo, and hand off. Everything substantive lives there.
#
# Why the split: machine-setup is private, so a plain unauthenticated `irm` cannot
# reach it. This seed exists purely to get far enough to authenticate.
#
# NOTE ON PARAMETERS: piping to `iex` means there is no param() block and no
# $PSScriptRoot - a parameter block would silently do nothing. Configure with
# environment variables instead:
#
#   $env:MACHINE_SETUP_ROLE = 'desktop'      # default: laptop
#   $env:MACHINE_SETUP_PATH = 'D:\provision' # default: $HOME\tim-flaik\machine-setup
#   $env:MACHINE_SETUP_NO_BOOTSTRAP = '1'    # clone only, do not run bootstrap.ps1
#   irm https://raw.githubusercontent.com/tim-flaik/tim-flaik/main/windows_setup/setup.ps1 | iex

$ErrorActionPreference = 'Stop'

$Role = if ($env:MACHINE_SETUP_ROLE) { $env:MACHINE_SETUP_ROLE } else { 'laptop' }
if ($Role -notin @('laptop', 'desktop')) {
    Write-Host "MACHINE_SETUP_ROLE must be 'laptop' or 'desktop', got '$Role'" -ForegroundColor Red
    return
}

# $HOME, not a hardcoded username: this file is public and a fresh machine may
# well have a different account name.
$Target = if ($env:MACHINE_SETUP_PATH) {
    $env:MACHINE_SETUP_PATH
} else {
    Join-Path $HOME 'tim-flaik\machine-setup'
}

function Write-Step { param([string] $m) Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok   { param([string] $m) Write-Host "  [ok]   $m" -ForegroundColor Green }
function Write-Skip { param([string] $m) Write-Host "  [skip] $m" -ForegroundColor DarkGray }
function Write-Bad  { param([string] $m) Write-Host "  [fail] $m" -ForegroundColor Red }

# winget writes the persisted PATH, not the PATH of this already-running shell.
# Without this, `gh` is "not found" immediately after being installed.
function Update-SessionPath {
    $env:PATH = @(
        [Environment]::GetEnvironmentVariable('PATH', 'Machine'),
        [Environment]::GetEnvironmentVariable('PATH', 'User')
    ) -join ';'
}

function Test-Exists { param([string] $n) return [bool] (Get-Command $n -ErrorAction SilentlyContinue) }

Write-Host ''
Write-Host 'tim-flaik bootstrap seed' -ForegroundColor White
Write-Host "  role   : $Role"
Write-Host "  target : $Target"
Write-Host ''

# ---------------------------------------------------------------------------
# 1. git + gh
# ---------------------------------------------------------------------------

Write-Step 'git and GitHub CLI'

if (-not (Test-Exists 'winget')) {
    Write-Bad 'winget is not available. Install "App Installer" from the Microsoft Store, then re-run.'
    return
}

foreach ($pkg in @(
    @{ Id = 'Git.Git';    Cmd = 'git' },
    @{ Id = 'GitHub.cli'; Cmd = 'gh'  }
)) {
    if (Test-Exists $pkg.Cmd) {
        Write-Skip "$($pkg.Cmd) already installed"
        continue
    }
    Write-Host "  installing $($pkg.Id)"
    & winget install --id $pkg.Id --exact `
        --accept-package-agreements --accept-source-agreements --disable-interactivity
    Update-SessionPath
    if (Test-Exists $pkg.Cmd) { Write-Ok "$($pkg.Cmd) installed" }
    else { Write-Bad "$($pkg.Cmd) still not on PATH after install - open a new shell and re-run"; return }
}

Update-SessionPath

# ---------------------------------------------------------------------------
# 2. Authenticate
# ---------------------------------------------------------------------------

Write-Step 'GitHub authentication'

& gh auth status *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Ok "already authenticated as $(& gh api user --jq .login 2>$null)"
} else {
    Write-Host '  starting the device-code login - a browser will open'
    & gh auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) {
        Write-Bad 'gh auth login did not complete. machine-setup is private, so the clone below needs it.'
        return
    }
    Write-Ok 'authenticated'
}

# ---------------------------------------------------------------------------
# 3. Clone machine-setup
# ---------------------------------------------------------------------------

Write-Step 'machine-setup'

if (Test-Path -LiteralPath (Join-Path $Target '.git')) {
    Write-Skip "already cloned at $Target - pulling"
    & git -C $Target pull --ff-only
    if ($LASTEXITCODE -ne 0) {
        Write-Bad 'pull failed - resolve by hand, then re-run'
        return
    }
} else {
    if ((Test-Path -LiteralPath $Target) -and
        (@(Get-ChildItem -LiteralPath $Target -Force -ErrorAction SilentlyContinue).Count -gt 0)) {
        Write-Bad "$Target exists, is not a git repo, and is not empty. Refusing to clone over it."
        return
    }
    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    & gh repo clone tim-flaik/machine-setup $Target
    if ($LASTEXITCODE -ne 0) {
        Write-Bad 'clone failed - check that this account can read tim-flaik/machine-setup'
        return
    }
    Write-Ok "cloned to $Target"
}

# ---------------------------------------------------------------------------
# 4. Hand off
# ---------------------------------------------------------------------------

$bootstrap = Join-Path $Target 'bootstrap.ps1'
if (-not (Test-Path -LiteralPath $bootstrap)) {
    Write-Bad "bootstrap.ps1 not found at $bootstrap"
    return
}

if ($env:MACHINE_SETUP_NO_BOOTSTRAP) {
    Write-Step 'handoff'
    Write-Skip "MACHINE_SETUP_NO_BOOTSTRAP is set. Run it yourself:"
    Write-Host "    cd $Target"
    Write-Host "    .\bootstrap.ps1 -Role $Role"
    return
}

Write-Step "handing off to bootstrap.ps1 -Role $Role"
Write-Host '  (bootstrap is idempotent; -WhatIf on it shows what would change)' -ForegroundColor DarkGray
Write-Host ''

& $bootstrap -Role $Role
