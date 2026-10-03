{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    sources = import ./npins;
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
      |> builtins.mapAttrs (name: _: pkgs.callPackage "${self}/packages/${name}" { inherit sources; });
  };
}
