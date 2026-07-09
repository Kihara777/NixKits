{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
  curl,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-bilibili-stream";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Zarosmm";
    repo = "obs-bilibili-stream";
    tag = finalAttrs.version;
    hash = "sha256-1vH/QTJKX5AlWtABsUmT9p7jHriJiCHJZ2SamfmVwbM=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    obs-studio
    curl
    qt6.qtbase
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DOBS_SOURCE=${obs-studio}"
    "-DENABLE_QT=ON"
  ];

  postInstall = ''
    rm -rf "$out/obs-plugins"
  '';

  meta = {
    description = "Bilibili streaming plugin for OBS Studio";
    homepage = "https://github.com/Zarosmm/obs-bilibili-stream";
    changelog = "https://github.com/Zarosmm/obs-bilibili-stream/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    mainProgram = "obs-bilibili-stream";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
