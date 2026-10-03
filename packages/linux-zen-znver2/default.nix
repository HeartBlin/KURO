{ lib, pkgs, ... }:

let
  targetLlvm = pkgs.llvmPackages_22;
  llvmStdenv = pkgs.overrideCC targetLlvm.stdenv (
    targetLlvm.stdenv.cc.override { bintools = targetLlvm.bintools; }
  );

  # Alight Rust side t libclang 22 as well, it was using 21
  bindgenWrapper =
    pkgs.runCommand "bindgen-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
        mkdir -p $out/bin
      makeWrapper ${lib.getExe pkgs.rust-bindgen} $out/bin/bindgen \
        --set LIBCLANG_PATH "${targetLlvm.libclang.lib}/lib"
    '';
in
  pkgs.linux_zen.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags =
      (old.extraMakeFlags or [ ])
      ++ [
        "LLVM=1"
        "BINDGEN=${lib.getExe bindgenWrapper}"
      ];

    structuredExtraConfig =
      (old.structuredExtraConfig or { })
      // (with lib.kernel; {
        DRM_I915 = no;
        DRM_XE = no;
        DRM_NOUVEAU = no;
        DRM_AMDGPU_SI = no;
        DRM_AMDGPU_CIK = no;
      });
  })
