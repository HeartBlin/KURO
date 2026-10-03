{ pkgs, ... }:

pkgs.python3Packages.buildPythonApplication {
  pname = "patch-origin-finality";
  version = "0.14";
  src = ./.;

  propagatedBuildInputs = with pkgs.python3Packages; [
    pycdlib
    pkgs.cpio
  ];

  pyproject = true;
  build-system = [ pkgs.python3Packages.setuptools ];
  doCheck = false;

  meta = with pkgs.lib; {
    description = "A patching utiliy for GLIMs NixOS configuration for my two ISOs";
    license = with licenses; [ mit unlicense ];
    maintainers = [ heartblin ];
    platforms = [ "x86_64-linux" ];
  };
}
