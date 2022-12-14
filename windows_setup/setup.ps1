# setup.ps1

## unscrupiously stolen mostly form here https://realpython.com/python-coding-setup-windows/
## use as a baseline setup config file for a windows install

Write-Output "Downloading and installing Chocolatey"
Invoke-WebRequest -useb community.chocolatey.org/install.ps1 | Invoke-Expression



Write-Output "Configuring Chocolatey"
choco feature enable -n allowGlobalConfirmation

Write-Output "Installing Chocolatey Packages"
choco install powershell-core
choco install vscode
choco install git --package-parameters="/NoAutoCrlf /NoShellIntegration"
choco install pyenv-win

# The Google Chrome package often gets out of sync because it updates so
# frequently. Ignoring checksums is a way to force install it.
choco install googlechrome --ignore-checksums
# Google Chrome auto-updates so you can pin it to prevent Chocolatey from
# trying to upgrade it and inadvertently downgrading it.
# You could also add VS Code here if you like.
choco pin add -n googlechrome

## installs
Write-Output "Installing more Chocolatey Packages -- yum yum"
choco install vscode
choco install notepadplusplus
choch install autohotkey
choco install firefox
choco install microsoft-teams
choco install zoom
choco install microsoft-windows-terminal
choco install slack
choco install spotify
# choco install thunderbird ## nah not for me
choco install sql-server-management-studio
choco install sonos-controller
choco install bitwarden
choco install bitwarden-chrome
choco install plexamp
choco install visualstudio2022community
choco install mysql.workbench
choco install insomnia-rest-api-client
choco install sql-server-2019
choco install sqltoolbelt ## test at the moment
choco install toggl
choco install whois
choco install brave # web borwser says it private - I'm skeptical but hey why not another chromium based browser

refreshenv

# The refreshenv command usually doesn't work on first install.
# This is a way to make sure that the Path gets updated for the following
# operations that require Path to be refreshed.
# Source: https://stackoverflow.com/a/22670892/10445017
foreach ($level in "Machine", "User") {
    [Environment]::GetEnvironmentVariables($level).GetEnumerator() |
    ForEach-Object {
        if ($_.Name -match 'Path$') {
            $combined_path = (Get-Content "Env:$($_.Name)") + ";$($_.Value)"
            $_.Value = (
                ($combined_path -split ';' | Select-Object -unique) -join ';'
            )
        }
        $_
    } | Set-Content -Path { "Env:$($_.Name)" }
}

Write-Output "Setting up pyenv and installing Python"
pyenv update
pyenv install --quiet 3.10.5 3.9.12
pyenv global 3.10.5

$gitHub = Read-Host "Enter your email to generate a GitHub Key - else press ENTER?"
if ($gitHub) {
    $email_github = Read-Host -Prompt "Please enter your Github email used for ssh key gen"
    Write-Output "Generating SSH key"
    ssh-keygen -C $email_github -P '""' -f "$HOME/.ssh/id_rsa"
    Get-Content $HOME/.ssh/id_rsa.pub | clip
    Write-Output "Your SSH key has been copied to the clipboard"
    Write-Output "Please open your github settings and copy this new key."  
}
else {
    Write-Warning -Message "No Github key generated."
}




Write-Host    "Installing powershell snippets into local repository"

$ModuleScript = $PSScriptRoot + "\powershellModuleInstall.ps1"
. $ModuleScript

# Cmon you fool - don't run this each itme - you'll get errors
# just of the simple upgrade - in case you forgot
# choco upgrade all