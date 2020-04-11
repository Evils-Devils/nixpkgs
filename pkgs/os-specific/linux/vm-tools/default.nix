{ lib, stdenv, fetchgit, linux }:

stdenv.mkDerivation {

  pname = "vm-tools";
  version = linux.version;

  src = linux.src;

  makeFlags = [ "sbindir=${placeholder "out"}/bin" ];

  preBuild = "cd tools/vm/";

  meta = with lib; {
    license = linux.meta.license;
    platforms = linux.meta.platforms;
    maintainers = [ maintainers.evils ];
  };
}
