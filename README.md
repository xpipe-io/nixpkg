# XPipe nixpkgs

Here you can find nixpkgs for XPipe.

To use the derivation, you need to:
1. Clone this repository
2. Navigate into the directory of the version you want to install, e.g. `cd xpipe/1.7.13`
3. Install the package in the system profile, for that you can add the following to your nixos configuration file:
```
environment.systemPackages = with pkgs; [
   (callPackage <path to cloned repo>/xpipe/<version>/default.nix {})
];
```

Note that you need to allow unfree packages in order for this to work.
