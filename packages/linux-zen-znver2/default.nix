{ pkgs, ... }:

let
  inherit (pkgs) lib;

  cc = llvmStdenv.cc;
  llvmStdenv = pkgs.overrideCC pkgs.llvmPackages.stdenv (
    pkgs.llvmPackages.stdenv.cc.override { bintools = pkgs.llvmPackages.bintools; }
  );

  hostFlags = [
    "HOSTCC=${lib.getExe' cc "cc"}"
    "HOSTCXX=${lib.getExe' cc "c++"}"
    "HOSTAR=${lib.getExe' cc.bintools "ar"}"
    "HOSTLD=${lib.getExe' cc.bintools "ld"}"
  ];
in
  pkgs.linux_zen.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags = (old.extraMakeFlags or [ ]) ++ [ "LLVM=1" ] ++ hostFlags;
  })
