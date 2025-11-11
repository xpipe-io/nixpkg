# XPipe nixpkgs

XPipe is available for Nix on the following platforms:
- x86_64-linux
- aarch64-linux
- x86_64-darwin
- aarch64-darwin

## Official nixpkgs package

There's an official [xpipe nixpkg](https://search.nixos.org/packages?channel=unstable&show=xpipe&from=0&size=50&sort=relevance&type=packages&query=xpipe) available that you can install with `nix-env -iA nixos.xpipe`.

However, this one is usually not up-to-date due to the slow approval of nixpkgs PRs. Furthermore, this package is only available for `x86_64-linux`. There are also no public test build releases published for this package.

If you want to use the latest XPipe version instead of an older one in the official nixpkgs repo, are not on `x86_64-linux`, or want to use early access builds, you can use the flake instead.

## Flake

The flake installs the package using [profiles](https://nix.dev/manual/nix/2.25/package-management/profiles). Since flakes are flexible, you can also run XPipe without installing it on your system. If you want to give it a try first prior to installing it, you can try running this flake:

```
NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features nix-command --extra-experimental-features flakes run --impure "github:xpipe-io/nixpkg?dir=xpipe"
```

To properly install the package on your system using a flake, you can add it to your profile:

```
NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features nix-command --extra-experimental-features flakes profile add --impure "github:xpipe-io/nixpkg?dir=xpipe"
```

It should then show up on your system and in the profile list with `nix --extra-experimental-features nix-command --extra-experimental-features flakes profile list`. You might have to rebuild/refresh your system to make the desktop entry show up as well.

### PTB

The XPipe Public Test Build (PTB) is also available to install from this repository. Simply replace `?dir=xpipe` with `?dir=xpipe-ptb` in all the previous commands to install the PTB instead. You can also install the regular release and PTB at the same time.

### macOS Application

By default, the installed profile package will create a link to the application in `~/.nix-profile/Applications`. Depending on how your system is configured, this path might not be automatically linked to your standard Applications directory, so the app won't show up in Spotlight or others. For more information and possible solutions for your individual setup see https://github.com/NixOS/nix/issues/956

## Development

To just build the project without installing it, you need to:
1. Clone this repository
2. Navigate into the directory of the version you want to install, e.g. `cd xpipe/18.7`
3. Run `NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'` to build the store
