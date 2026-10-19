# obs-bilibili-stream — 本仓**不再自行打包**这个插件。
#
# 2026-10-19 起上游 nixpkgs 已收录（PR #574725），且那份定义就是从这里贡献出去、
# 再经 review 改进过的版本（多了 strictDeps / __structuredAttrs / lib.cmakeBool /
# 英文注释 / 正确的 maintainers）。继续维护本地副本只会与上游漂移。
#
# `packages/obs-bilibili-stream.nix` 已删除；overlay 保留一个同名兼容别名，
# 指向 `pkgs.obs-studio-plugins.obs-bilibili-stream`。本模块保留，因为 enable
# 开关仍是有用的接线。详见 docs/zh/deprecated/obs-bilibili-stream.md。
{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.obs-bilibili-stream;
in
{
  options.nixkits.obs-bilibili-stream = {
    enable = lib.mkEnableOption "Bilibili streaming plugin for OBS Studio";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
  };
}
