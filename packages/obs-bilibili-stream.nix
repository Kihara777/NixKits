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
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "Zarosmm";
    repo = "obs-bilibili-stream";
    tag = finalAttrs.version;
    hash = "sha256-cFIPbOHhafsH1YLV8wqnRZF+df3K/cEWP6h6KuZsqNc=";
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
    # 上游自己的 appstream 元数据写着 <project_license>GPL-2.0-only</project_license>
    # （com.obsproject.Studio.Plugin.BilibiliStream.metainfo.xml）。
    # LICENSE 是 GPLv2 标准全文，src/plugin-support.{h,c.in} 是**未改动的 OBS 模板**
    # （`Copyright (C) <Year> <Developer>` 与 `Plugin Name` 都没填），
    # 那里面「or any later version」是样板而非作者的授权。
    # 2026-10-10 更正：此前写的 gpl2Plus（= or-later）没有依据。
    license = lib.licenses.gpl2Only;
    mainProgram = "obs-bilibili-stream";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
