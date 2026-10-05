{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "gnome-rounded-blur";
  version = "1.0.1-unstable-2026-08-09";
  src = pkgs.fetchFromGitHub {
    owner = "kancko";
    repo = "gnome-rounded-blur";
    rev = "f3bfcc796e1214c1e1d4287ee35cb132ad8133f0";
    hash = "sha256-MBeb0/Drt0UQ/K8UaW93ae9OaV3L5nhFZB2tPwj47co=";
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

  postPatch = ''
    apiver=$(pkg-config --list-all | grep -o 'libmutter-[0-9]\+' | sort -u | tail -n1 | sed 's/libmutter-//')
    substituteInPlace meson.build \
      --replace-fail "dependency('libmutter-18')" "dependency('libmutter-$apiver')"
  '';
}
