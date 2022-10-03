# setup_checks.ps1

$Desktop = $env:USERPROFILE + "\desktop"
$test_project_name = 'test-python-dev'

Set-Location $Desktop
Write-Host "Set current directory to the Desktop attempting to setup a basic python project."
Write-Host "If this test works out install script has been pretty good."
# add a check if the file exists if not create it - if exists ?? should i stop the checkign script?

if (Test-Path -Path $test_project_name) {
    Write-host "Ahh this file exists - exiting the script now so you can check setup."
    Exit
} else {
    mkdir $test_project_name
}

Set-Location $test_project_name

# would add cookie cutter in here 
New-Item hello.py
Set-Content hello.py "print('hello')"

# initialise a git repository, setup a virtual environemtn 
# activate that enviro and run the file
python -m venv venv
venv\Scripts\activate
git init

# open for viewing pleasure and check git is initialising
code .


123

Write-Host "You should have had a VSCode window open with an initialised git repository $ Hello Workd"
Read-Host -Prompt "Press any key to continue and tear down the test or CTRL+C to quit"

# tear it down again
Set-Location $Desktop
Remove-Item $test_project_name -Recurse -Force
