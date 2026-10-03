{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "gnome-rounded-blur";

  src = sources.gnome-rounded-blur;
  version = builtins.substring 0 8 sources.gnome-rounded-blur.revision;

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
