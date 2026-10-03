{ pkgs, ... }:

pkgs.linux_zen.override {
  extraMakeFlags = [ "LLVM=1" ];
  stdenv = pkgs.overrideCC pkgs.llvmPackages.stdenv (
    pkgs.llvmPackages.stdenv.cc.override {
      bintools = pkgs.llvmPackages.bintools;
    }
  );
}
