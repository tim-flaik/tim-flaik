# windows setup instructions

On a fresh install.

``` ps1
Set-ExecutionPolicy RemoteSigned -Force
```

``` ps1
iwr -useb github_raw_link_to_setup.ps1_file | iex
```

Current example

``` ps1
iwr -useb https://raw.githubusercontent.com/tim-flaik/tim-flaik/main/windows_setup/setup.ps1 | iex
```

- Open Github and sign in
- Settings > SSH NEw Key
- Copy clipboard contents to that (may need to accept RSA)
- check install went OK with

```ps1
ssh -T git@github.com
```

This should return a verification that you are connected.  Onto Part 2 we will set up a test python environment and register with github.

## Part 2

run powershell script setup_checks.ps1

``` ps1
.\setup_checks.ps1
```

This creates a basic project, add a virtual environment, initialises a git repository and opens it up in VS Code so you can check that git is working.  If happy close VSCode and continue the script - it will clean itself up.
