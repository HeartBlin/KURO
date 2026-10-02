{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    sources = import ./npins;
  in {
    hydraJobs = { inherit (self) packages; };
    packages.${system} =
      ./packages
      |> builtins.readDir
      |> nixpkgs.lib.filterAttrs (_: type: type == "directory")
      |> builtins.mapAttrs (name: _: pkgs.callPackage "${self}/packages/${name}" { inherit sources; });
  };
}
