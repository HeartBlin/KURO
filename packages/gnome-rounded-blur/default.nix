{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "gnome-rounded-blur";
  version = "1.0.2-unstable-2026-10-13";
  src = pkgs.fetchFromGitHub {
    owner = "kancko";
    repo = "gnome-rounded-blur";
    rev = "a4db9e5947b1cea0a05c57768356921420f91293";
    hash = "sha256-2zRQnORmVQMuubLOZ+0mHDQhDoc7V/+2JM3gmYPia2s=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = with pkgs;
    [ glib mutter ]
    ++ pkgs.mutter.buildInputs
    ++ pkgs.mutter.propagatedBuildInputs;
}
