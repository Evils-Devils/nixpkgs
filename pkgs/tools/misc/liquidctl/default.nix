{ stdenv, fetchFromGitHub
, python3, python3Packages
, libusb
}:

python3Packages.buildPythonPackage rec {

  pname = "liquidctl";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "jonasmalacofilho";
    repo = "liquidctl";
    rev = "v${version}";
    sha256 = "1ndylcygp3p4rblxykavcvmgqgirc47iq1p0ka2gpnfnjqh8pziq";
  };

  propagatedBuildInputs = with python3Packages; [ libusb hidapi pyusb docopt ];

  pipInstallFlags = [ "--no-warn-script-location" ];

  postInstall = ''
    mkdir -p "$out/share/man/man8"
    cp liquidctl.8 "$out/share/man/man8/"
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform tool and drivers for liquid coolers and other devices";
    homepage = "https://github.com/jonasmalacofilho/liquidctl";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = [ maintainers.evils ];
  };
}
