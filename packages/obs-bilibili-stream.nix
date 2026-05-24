{ lib
, stdenv
, fetchFromGitHub
, cmake
, obs-studio
, curl
, qtbase
, pkg-config
}:

stdenv.mkDerivation finalAttrs@{
  pname = "obs-bilibili-stream";
  version = "2.0.12";

  src = fetchFromGitHub {
    owner = "Zarosmm";
    repo = "obs-bilibili-stream";
    tag = finalAttrs.version;
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

  # OBS 插件 bootstrap 系统通过 OBS_SOURCE 定位 obs-studio 的 cmake 模块
  cmakeFlags = [
    "-DOBS_SOURCE=${obs-studio}"
    "-DENABLE_QT=ON"
  ];

 # CMake 已正确安装到 $out/lib/obs-plugins/ 和 $out/share/obs/obs-plugins/
  # 清理冗余的 64bit 目录
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
