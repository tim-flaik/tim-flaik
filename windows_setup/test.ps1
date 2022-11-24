$gitHub = Read-Host "Do you need to generate a GitHub Key?"
if ($gitHub) {
    $email_github = Read-Host -Prompt "Please enter your Github email used for ssh key gen"
    Write-Output "Generating SSH key"
    ssh-keygen -C $email_github -P '""' -f "$HOME/.ssh/id_rsa"
    Get-Content $HOME/.ssh/id_rsa.pub | clip
} else {
    Write-Warning -Message "No Github key generated."
}
