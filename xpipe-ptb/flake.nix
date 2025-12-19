{
  description = "xpipe-ptb";

  inputs = {
    nixpkgs.url = "nixpkgs";
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
      packages = forAllSystems ({ system, pkgs, ... }:
          pkgs.callPackage ./20.0-7/default.nix { }
      );

      defaultPackage = forAllSystems ({ system, ... }:
          self.packages.${system}
      );
    };
}
