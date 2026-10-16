{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "gnome-shell-extension-gradia-capture";
  version = "0-unstable-2026-10-16";
  src = pkgs.fetchFromGitHub {
    owner = "AlexanderVanhee";
    repo = "gradia-capture";
    rev = "0b7e47e1e5c1e68e234e4d2d24b307e1da1d18a9";
    hash = "sha256-ZpJTf6gfepiC0kXUWfjB73iWLRuiQtRBq4kFzk0N6Ss=";
  };

  nativeBuildInputs = [ pkgs.glib ];

  dontConfigure = true;
  dontBuild = true;

  passthru.extensionUuid = "gradia-integration@alexandervanhee.github.io";

  installPhase = ''
    runHook preInstall

    extensionDir="$out/share/gnome-shell/extensions/${passthru.extensionUuid}"

    mkdir -p "$extensionDir"
    cp -r src/. "$extensionDir/"
    cp -r icons "$extensionDir/icons"

    mkdir -p "$extensionDir/schemas"

    cp \
      schemas/org.gnome.shell.extensions.gradia-companion.gschema.xml \
      "$extensionDir/schemas/"

    glib-compile-schemas "$extensionDir/schemas"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Enhances the GNOME screenshot tool with annotation features";
    homepage = "https://github.com/AlexanderVanhee/gradia-capture";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
