{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    hydraJobs = { inherit (self) packages; };
    packages.${system} =
      ./packages
      |> builtins.readDir
      |> nixpkgs.lib.filterAttrs (_: type: type == "directory")
      |> builtins.mapAttrs (name: _: pkgs.callPackage "${self}/packages/${name}" { });

    checks.${system}.default = let
      yamllintConfig = builtins.toFile "yamllint.yaml" (builtins.toJSON {
        extends = "default";
        rules = {
          brackets = {
            min-spaces-inside = 0;
            max-spaces-inside = 1;
          };
          document-start = "disable";
          line-length.max = 120;
          truthy.allowed-values = [ "true" "false" "on" ];
        };
      });
    in
      pkgs.runCommand "check-overall" { } ''
        cd ${self}
        ${lib.getExe self.packages.${system}.alejandra-custom} --check .
        ${lib.getExe pkgs.deadnix} --fail .
        ${lib.getExe pkgs.statix} check .
        ${lib.getExe pkgs.yamllint} -c ${yamllintConfig} .
        touch $out
      '';
  };
}
