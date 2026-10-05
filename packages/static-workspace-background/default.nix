{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "gnome-shell-extension-static-workspace-background";
  version = "0-unstable-2026-08-15";
  src = pkgs.fetchFromGitHub {
    owner = "CleoMenezesJr";
    repo = "static-workspace-background";
    rev = "3cfa3fbb2984d36e80f62e3f67d0f4b457843916";
    hash = "sha256-BEz9NF64MvBte12fZk30SGJ2N1JyksRaf2AgUtFOOpk=";
  };

  dontBuild = true;
  dontConfigure = true;

  passthru.extensionUuid = "static-workspace-background@CleoMenezesJr.github.io";

  installPhase = ''
    runHook preInstall

    install -Dm644 extension.js -t $out/share/gnome-shell/extensions/${passthru.extensionUuid}/
    install -Dm644 bounce.js -t $out/share/gnome-shell/extensions/${passthru.extensionUuid}/
    install -Dm644 metadata.json -t $out/share/gnome-shell/extensions/${passthru.extensionUuid}/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Keep a static background while changing workspaces in GNOME";
    homepage = "https://github.com/CleoMenezesJr/static-workspace-background";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
