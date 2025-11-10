{
  description = "xpipe";

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
      system = "x86_64-linux";

      pkgs = import nixpkgs { };
      xpipe = pkgs.callPackage ./xpipe-ptb/19.0-16/default.nix { inherit system; };

      forAllSystems = f: genAttrs allSystems (system: f rec {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
      });
    in
    {
      defaultPackage = forAllSystems ({ system, ... }:
          xpipe
      );
    };
}
