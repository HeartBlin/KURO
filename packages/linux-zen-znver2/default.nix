{ lib, pkgs, ... }:

let
  targetLlvm = pkgs.llvmPackages_22;
  llvmStdenv = pkgs.overrideCC targetLlvm.stdenv (
    targetLlvm.stdenv.cc.override { bintools = targetLlvm.bintools; }
  );
in
  pkgs.linux_zen.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags = (old.extraMakeFlags or [ ]) ++ [ "LLVM=1" ];
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
