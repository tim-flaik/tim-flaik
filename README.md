# tim-flaik

Bootstrap seed for provisioning a fresh Windows machine.

**The real content lives in `tim-flaik/machine-setup` (private).** This repo is
public and exists for one reason: a private repo cannot be reached by an
unauthenticated one-liner, so something has to get far enough to authenticate.

```
 THIS REPO (public)                    machine-setup (private)
 windows_setup/setup.ps1        --->   bootstrap.ps1
   winget install git + gh               winget packages, SSH key
   gh auth login (device code)           WSL2 + Linux toolchain
   gh repo clone machine-setup           dotfiles via chezmoi
   hand off  ------------------->        agentic tooling
                                         desktop host config
                                         validation
```

## Usage

From PowerShell on a fresh machine:

```powershell
irm https://raw.githubusercontent.com/tim-flaik/tim-flaik/main/windows_setup/setup.ps1 | iex
```

That installs `git` and `gh`, runs the device-code login, clones `machine-setup`
to `$HOME\tim-flaik\machine-setup`, and hands off to its `bootstrap.ps1`.

### Options

Piping to `iex` means the script cannot take parameters, so configure it with
environment variables set beforehand:

| Variable | Default | Effect |
|---|---|---|
| `MACHINE_SETUP_ROLE` | `laptop` | `laptop` or `desktop`. `desktop` adds the always-on host config - no sleep, Tailscale, overnight scheduling. |
| `MACHINE_SETUP_PATH` | `$HOME\tim-flaik\machine-setup` | Where to clone. |
| `MACHINE_SETUP_NO_BOOTSTRAP` | unset | Clone only; print the bootstrap command instead of running it. |

```powershell
$env:MACHINE_SETUP_ROLE = 'desktop'
irm https://raw.githubusercontent.com/tim-flaik/tim-flaik/main/windows_setup/setup.ps1 | iex
```

The seed is idempotent: `git`/`gh` already installed are skipped, an existing
authenticated session is reused, and an existing clone is fast-forwarded rather
than re-cloned.

## legacy/

The previous Chocolatey-based setup, kept rather than deleted because nothing else
holds a copy:

| File | What it was |
|---|---|
| `setup-chocolatey.ps1` | the old all-in-one installer (Chocolatey, ~25 GUI apps, pyenv pins 3.10.5/3.9.12, SSH keygen) |
| `setup_checks.ps1` | post-install smoke test that scaffolded a Python project on the Desktop |
| `powershellModuleInstall.ps1` | installed the snippet modules below |
| `powershellSnippets/Get-WhoIs/` | a `Get-WhoIs` PowerShell module |
| `setup-instructions.md` | the original notes |

Nothing here runs any more, and the SSH keygen in `setup-chocolatey.ps1` had a real
bug worth remembering: it regenerated `~/.ssh/id_rsa` on every run, silently
overwriting an existing key. `machine-setup/windows/install-apps.ps1` is the
replacement - it skips when a key exists, backs up rather than destroys under
`-ForceNewSshKey`, and generates ed25519.
