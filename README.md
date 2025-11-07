# Publicly Accessible System Nix Configuration

That's right. We're a PASNC. what are you looking at?

### Setup everything

```bash
$ nix develop
$ just
```

### Usage

To use the nix shell that has everything installed, run `zllg` after the setup
above setup the alias.

### Notes

The bash prompt on the shell that zellij starts is currently broken. I believe the issue is the same one fixed in [NixOS/nix#13916](https://github.com/NixOS/nix/pull/13916). I need to look into this
