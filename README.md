# XPipe nixpkgs

## Flake

```
NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features nix-command --extra-experimental-features flakes profile install --impure github:xpipe-io/nixpkg
```

Here you can find nixpkgs for XPipe.

To use the derivation, you need to:
1. Clone this repository
2. Install the package in the system profile, for that you can add the following to your nixos configuration file:
```
environment.systemPackages = with pkgs; [
   (callPackage <path to cloned repo>/xpipe/<version>/default.nix {})
];
```

Note that you need to allow unfree packages in order for this to work.

## Building

To just build the project without installing it, you need to:
1. Clone this repository
2. Navigate into the directory of the version you want to install, e.g. `cd xpipe/1.7.13`
3. Run `NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'` to build the store
