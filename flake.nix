{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    alejandra = inputs.self.kuro.packages.${system}.alejandra-custom;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    inherit (inputs.hjem // inputs.lanzaboote) nixosModules;
    hydraJobs = { inherit (inputs.self) packages; };
    packages.${system} =
      (
        ./packages
        |> builtins.readDir
        |> inputs.nixpkgs.lib.filterAttrs (_: type: type == "directory")
        |> builtins.mapAttrs (name: _: pkgs.callPackage "${inputs.self}/packages/${name}" { })
      )
      // (inputs.hjem.packages."x86_64-linux" or { })
      // (inputs.lanzaboote.packages."x86_64-linux" or { });

    checks.${system}.overall = pkgs.writeShellApplication {
      name = "check";
      text = ''deadnix --fail . && statix check . && alejandra --check .'';
      runtimeInputs = [
        alejandra
        pkgs.deadnix
        pkgs.statix
      ];
    };
  };
}
