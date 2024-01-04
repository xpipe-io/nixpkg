# XPipe nixpkgs

Here you can find nixpkgs for XPipe.

To use the derivation to build the package, you need to:
1. Clone this repository
2. Navigate into the directory of the version you want to install, e.g. `cd xpipe/1.7.13`
3. Run `NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'` to build the store
