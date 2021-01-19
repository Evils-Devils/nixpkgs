{ lib
, stdenv
, fetchFromGitHub

, legacy ? false
, libinput

, pkg-config
, makeWrapper

, openal
, alure
, libXtst
, libX11
}:

with lib;

stdenv.mkDerivation rec {
  pname = "bucklespring";
  version = "2021-01-21";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = pname;
    rev = "d63100c4561dd7c57efe6440c12fa8d9e9604145";
    sha256 = "114dib4npb7r1z2zd1fwsx71xbf9r6psxqd7n7590cwz1w3r51mz";
  };

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [ openal alure ]
    ++ optionals (legacy) [ libXtst libX11 ]
    ++ optionals (!legacy) [ libinput ];

  makeFlags = optionals (!legacy) [ "libinput=1" ];

  installPhase = ''
    mkdir -p $out/share/wav
    cp -r $src/wav $out/share/.
    install -D ./buckle.desktop $out/share/applications/buckle.desktop
    install -D ./buckle $out/bin/buckle
    wrapProgram $out/bin/buckle --add-flags "-p $out/share/wav"
  '';

  meta = {
    description = "Nostalgia bucklespring keyboard sound";
    longDescription = ''
      When built with libinput (wayland or bare console),
      users need to be in the input group to use this:
      <code>users.users.alice.extraGroups = [ "input" ];</code>
    '';
    homepage = "https://github.com/zevv/bucklespring";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.evils ];
  };
}
