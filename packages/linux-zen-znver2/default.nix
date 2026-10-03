{ lib, pkgs, ... }:

let
  targetLlvm = pkgs.llvmPackages_22;
  llvmStdenv = pkgs.overrideCC targetLlvm.stdenv (
    targetLlvm.stdenv.cc.override { bintools = targetLlvm.bintools; }
  );
in
  pkgs.linux_zen.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags =
      (old.extraMakeFlags or [ ])
      ++ [
        "LLVM=1"
        "KCFLAGS=-march=znver2"
      ];

    argsOverride =
      (old.argsOverride or { })
      // {
        structuredExtraConfig =
          (old.structuredExtraConfig or { })
          // (with lib.kernel; {
            LTO_CLANG_THIN = lib.mkForce yes;

            DRM_AMDGPU_CIK = lib.mkForce no;
            DRM_AMDGPU_SI = lib.mkForce no;
            DRM_AMD_DC_SI = lib.mkForce (option no);
            DRM_I915 = lib.mkForce no;
            DRM_I915_GVT = lib.mkForce (option no);
            DRM_I915_GVT_KVMGT = lib.mkForce (option no);
            DRM_NOUVEAU = lib.mkForce no;
            DRM_NOUVEAU_SVM = lib.mkForce (option no);
            DRM_NOVA = lib.mkForce (option no);
            DRM_PANIC_SCREEN_QR_CODE = lib.mkForce (option no);
            DRM_XE = lib.mkForce no;
            NOVA_CORE = lib.mkForce (option no);
            RUST = lib.mkForce (option no); # RIP
          });
      };

    extraMeta =
      (old.extraMeta or { })
      // {
        maxSilent = 24 * 60 * 60;
        timeout = 4 * 60 * 60;
      };
  })
