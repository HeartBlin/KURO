{ pkgs, ... }:

pkgs.ghostty.overrideAttrs (old: {
    zigBuildFlags =
      builtins.filter (flag: flag != "-Dcpu=baseline") old.zigBuildFlags
      ++ [ "-Dcpu=znver2" ];
  })
