{ pkgs, sources, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "gnome-shell-extension-gradia-capture";

  src = sources.gradia-capture;
  version = builtins.substring 0 8 sources.gradia-capture.revision;

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
