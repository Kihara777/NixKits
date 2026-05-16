{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, obs-studio
, curl
, qt6
}:

stdenv.mkDerivation rec {
 pname = "obs-bilibili-stream";
 version = "2.0.12";

 src = fetchFromGitHub {
   owner = "Zarosmm";
   repo = "obs-bilibili-stream";
   rev = "${version}";
   sha256 = "ilx1u4jN58AUfPh3heEhANxsYJVxoIRfuAOObDY5WoU=";
 };

 nativeBuildInputs = [
   cmake
   pkg-config
 ];

 buildInputs = [
   obs-studio
   curl
   qt6.qtbase # Qt6::Widgets, Qt6::Network 等
   qt6.qtwebsockets # 直播间消息 Websocket 通信
 ];

 # 启用 GUI 前端接口和 Qt 支持（与 OBS 界面集成）
 cmakeFlags = [
   "-DENABLE_FRONTEND_API=ON"
   "-DENABLE_QT=ON"
 ];

 # 防止 Nix 按独立 Qt 应用去包装（本插件不是独立程序）
 dontWrapQtApps = true;

 meta = with lib; {
   description = "OBS 插件，用于 Bilibili 直播开播、获取推流地址等";
   homepage = "https://github.com/Zarosmm/obs-bilibili-stream";
   license = licenses.gpl2Plus;
   maintainers = [ ]; # 不在官方列表可留空
   platforms = platforms.linux;
 };
}
