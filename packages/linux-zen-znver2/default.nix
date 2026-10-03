{ pkgs, ... }:

let
  targetLlvm = pkgs.llvmPackages_22;
  llvmStdenv = pkgs.overrideCC targetLlvm.stdenv (
    targetLlvm.stdenv.cc.override { bintools = targetLlvm.bintools; }
  );
in
  pkgs.linux_zen.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags = (old.extraMakeFlags or [ ]) ++ [ "LLVM=1" ];
  })
