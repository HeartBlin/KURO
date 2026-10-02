{ callPackage, lib, stdenv, fetchurl, testers, versionCheckHook, hello }:

stdenv.mkDerivation (finalAttrs: {
    pname = "hello";
    version = "2.12.3";

    __structuredAttrs = true;
    strictDeps = true;
    enableParallelBuilding = true;

    src = fetchurl {
      url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
      hash = "sha256-DV9gFUOC/uELEUocNOeF2LH0kgc64tOm97FHaHs2aqA=";
    };

    doCheck = true;

    doInstallCheck = true;
    nativeInstallCheckInputs = [
      versionCheckHook
    ];

    postInstallCheck = ''
      stat "''${!outputBin}/bin/${finalAttrs.meta.mainProgram}"
    '';

    passthru.tests = {
      version = testers.testVersion { package = hello; };
    };

    passthru.tests.run = callPackage ./test.nix { hello = finalAttrs.finalPackage; };

    meta = {
      description = "Program that produces a familiar, friendly greeting";
      longDescription = ''
        GNU Hello is a program that prints "Hello, world!" when you run it.
        It is fully customizable.
      '';
      homepage = "https://www.gnu.org/software/hello/manual/";
      changelog = "https://git.savannah.gnu.org/cgit/hello.git/plain/NEWS?h=v${finalAttrs.version}";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ stv0g ];
      mainProgram = "hello";
      platforms = lib.platforms.all;
      identifiers.cpeParts.vendor = "gnu";
    };
  })
