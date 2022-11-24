# This script id called will install all Powershell modules in the 'powershellSnippets' folder in the repository
# assuming that you are placing files here - and you know what you are doing...

Write-Host    "Installing powershell snippets into local User Repository"
$usr = $env:UserName
$originalLocation = $PSScriptRoot

$scriptRepository = Join-Path $originalLocation -ChildPath 'powershellSnippets'
# $scriptRepository = Join-Path $originalLocation -ChildPath 'powershellSnippets'
$installLocation = "\Users\" + $usr + "\Documents\WindowsPowerShell"
Write-Host "Powershell scripts will be in: " $installLocation

$moduleFolder = Join-Path $installLocation  -ChildPath 'Modules'
Write-Host $moduleFolder

if (Test-Path $moduleFolder) {
    Write-Host "Folder Exists"
    Get-ChildItem -Path $scriptRepository | ForEach-Object {
        # Write-Host "something"
        Copy-Item -Path $_.FullName -Destination $moduleFolder -Force  -Recurse -Verbose -PassThru

    }
}
else {
    #PowerShell Create directory if not exists then copy them in
    New-Item $moduleFolder -ItemType Directory
    Write-Host "Folder Created successfully"
    Copy-Item -Path $_.FullName -Destination $moduleFolder -Force  -Recurse -Verbose -PassThru
}

Write-Host "Great Success Wa Wa Wee Wa."
Write-Host "Going home completed installing powershell modules"
