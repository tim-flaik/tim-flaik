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


