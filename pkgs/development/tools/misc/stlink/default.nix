{ stdenv, fetchFromGitHub, cmake, libusb1, fetchpatch }:

let
  # The Darwin build of stlink explicitly refers to static libusb.
  libusb1' = if stdenv.isDarwin then libusb1.override { withStatic = true; } else libusb1;

# IMPORTANT: You need permissions to access the stlink usb devices.
# Add services.udev.packages = [ pkgs.stlink ] to your configuration.nix

in stdenv.mkDerivation rec {
  pname = "stlink";
  version = "2020-08-09";

  src = fetchFromGitHub {
    owner = "stlink-org";
    repo = "stlink";
    rev = "0a6fe3a8530c950def7b223527574ecf6798d956";
    sha256 = "0sncrqzp97abqgscw69vmjzbbalpisnvcra24rhnsmwdijdmlav3";
  };

  buildInputs = [ libusb1' ];
  nativeBuildInputs = [ cmake ];
  patchPhase = ''
    sed -i 's@/lib/udev/rules.d@$ENV{out}/lib/udev/rules.d@' CMakeLists.txt
    sed -i 's@/etc/modprobe.d@$ENV{out}/etc/modprobe.d@' CMakeLists.txt
  '';
  preInstall = ''
    mkdir -p $out/etc/modprobe.d
  '';

  meta = with stdenv.lib; {
    description = "In-circuit debug and programming for ST-Link devices";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = [ maintainers.bjornfor maintainers.rongcuid ];
  };
}
