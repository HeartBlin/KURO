{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

  outputs = inputs: {
    hydraJobs = { inherit (inputs.self) packages; };
    packages."x86_64-linux" = let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in {
      hello = pkgs.callPackage ./packages/hello.nix { };
    };
  };
}
