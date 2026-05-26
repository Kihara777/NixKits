{ lib
, stdenv
, fetchFromGitHub
, cmake
, obs-studio
, curl
, qtbase
, pkg-config
}:

let
  pname = "obs-bilibili-stream";
  version = "2.0.12";
in stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Zarosmm";
    repo = "obs-bilibili-stream";
    tag = version;
    hash = "sha256-ilx1u4jN58AUfPh3heEhANxsYJVxoIRfuAOObDY5WoU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    obs-studio
    curl
    qtbase
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DOBS_SOURCE=${obs-studio}"
    "-DENABLE_QT=ON"
  ];

  postInstall = ''
    rm -rf $out/obs-plugins
  '';

  meta = {
    description = "Bilibili 直播插件 for OBS Studio";
    homepage = "https://github.com/Zarosmm/obs-bilibili-stream";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
