{
  description = "xpipe";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: genAttrs allSystems (system: f rec {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
      });
    in
    {
      packages = forAllSystems
        ({ system, pkgs, lib, ... }:
          let
            xpipeLib = pkgs.callPackage ./xpipe-ptb/19.0-16/default.nix { };
          in
          {
            xpipe = xpipeLib.buildPackage ({ });
          });

      defaultPackage = forAllSystems ({ system, ... }:
          self.packages.${system}.xpipe
      );
    };
}
