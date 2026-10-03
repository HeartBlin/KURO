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
    argsOverride =
      (old.argsOverride or { })
      // {
        structuredExtraConfig =
          (old.structuredExtraConfig or { })
          // (with lib.kernel; {
            DRM_I915 = lib.mkForce no;
            DRM_XE = lib.mkForce no;
            DRM_NOUVEAU = lib.mkForce no;
            DRM_AMDGPU_SI = lib.mkForce no;
            DRM_AMDGPU_CIK = lib.mkForce no;
          });
      };
  })
