{ stdenv
, buildPythonPackage
, fetchFromGitHub
, python
, pybind11
}:

buildPythonPackage rec {
  pname = "pytomlpp";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "bobfang1992";
    repo = "pytomlpp";
    rev = version;
    fetchSubmodules = true;
    sha256 = "144kzr6ygdrl6f1k48j3qycsnxm2ndbm8c5s27n7d340q263gbf2";
  };

  buildInputs = [ pybind11 ];

  # TODO "ran 0 tests"?

  meta = with stdenv.lib; {
    description = "A python wrapper for tomlplusplus";
    homepage    = "https://github.com/bobfang1992/pytomlpp";
    license     = licenses.mit;
    maintainers = with maintainers; [ evils ];
  };
}
