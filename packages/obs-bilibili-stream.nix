{ lib, stdenv, cmake, obs-studio, curl, src, qt6 }:

stdenv.mkDerivation {
  pname = "obs-bilibili-stream";
  version = "1.0.0";
  inherit src;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    obs-studio
    curl
    # 仅使用 Qt6
    qt6.qtbase
    qt6.qtbase.dev
    qt6.qtsvg
    qt6.qtsvg.dev
    qt6.qt5compat
  ];

  # 设置 Qt6 环境变量
  QT_DIR = "${qt6.qtbase}";
  QMAKE = "${qt6.qtbase.dev}/bin/qmake6";

  # Qt6 头文件路径
  NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-isystem ${qt6.qtbase.dev}/include"
    "-isystem ${qt6.qtbase.dev}/include/QtCore"
    "-isystem ${qt6.qtbase.dev}/include/QtWidgets"
    "-isystem ${qt6.qtbase.dev}/include/QtGui"
    "-isystem ${qt6.qtsvg.dev}/include/QtSvg"
    "-isystem ${qt6.qt5compat.dev}/include/Qt5Compat"
  ];

  # CMake 配置
  cmakeFlags = [
    "-DCMAKE_VERBOSE_MAKEFILE=ON"
    "-DCMAKE_PREFIX_PATH=${qt6.qtbase.dev}:${qt6.qtsvg.dev}"
    "-DQt6_DIR=${qt6.qtbase.dev}/lib/cmake/Qt6"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # 让 CMake 自动查找 Qt6
  CMAKE_FIND_ROOT_PATH = [ "${qt6.qtbase.dev}" "${qt6.qtsvg.dev}" ];

  meta = with lib; {
    description = "Bilibili 直播插件 for OBS Studio";
    homepage = "https://github.com/Zarosmm/obs-bilibili-stream";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
