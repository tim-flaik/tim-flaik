# windows setup instructions

On a fresh install.

``` ps1
Set-ExecutionPolicy RemoteSigned -Force
```

``` ps1
iwr -useb github_raw_link_to_setup.ps1_file | iex
```

- Open Github and sign in
- Settings > SSH NEw Key
- Copy clipboard contents to that (may need to accept RSA)
- check install went OK with

```ps1
ssh -T git@github.com
```