{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "gnome-shell-extension-gradia-capture";
  version = "0-unstable-2026-08-22";
  src = pkgs.fetchFromGitHub {
    owner = "AlexanderVanhee";
    repo = "gradia-capture";
    rev = "f70a2127d0a9acc3c9d4d8198361fc9f4e14818f";
    hash = "sha256-XruZoUTbDT/qOPmFj5/CyvQfhH6Tg0IqJ4JPVMiu5zQ=";
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
