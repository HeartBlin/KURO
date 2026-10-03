{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage {
  pname = "alejandra";
  version = "4.0.0-custom";
  src = pkgs.fetchFromGitHub {
    owner = "kamadorueda";
    repo = "alejandra";
    rev = "8c4a4a572bee519b04e9bb9207e7d993f55ecb4f";
    hash = "sha256-pu6dVB6NrIj90rrqCgJ5pPlBzS76pW4WA6rE1rD1Gp8=";
  };

  RUSTFLAGS = "-C target-cpu=x86-64-v3 -C lto=fat";
  patches = [
    ./adblock.patch
    ./attr_set.patch
    ./lambda.patch
    ./list.patch
    ./pattern.patch
  ];

  cargoHash = "sha256-MfDOw3h/aU16CVm1EsLAcFwW2ZOvAnYwg3AGcG4ll3g=";
  doCheck = false;

  meta = with pkgs.lib; {
    description = "The Uncompromising Nix Code Formatter (Patched)";
    homepage = "https://github.com/kamadorueda/alejandra";
    license = licenses.unlicense;
    mainProgram = "alejandra";
  };
}
