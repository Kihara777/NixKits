# shell-index —— 构建期生成的「这台机器上有哪些命令」索引。
#
# 谁在用：`packages/dsh-nixos-shell`（`nixos_shell` 工具）。它 127 的时候需要分清
# 四件事，而这四件事的答案必须**跟着 nixpkgs 锁走**，不能靠运行时猜：
#
#   1. 命令打错了吗？          → 索引里没有、nixpkgs 属性表里也没有
#   2. 环境里没有吗？          → 索引里没有、nixpkgs 属性表里有
#   3. 这个包里有这个程序吗？  → 用 `pkg:` 显式指定后仍然找不到
#   4. 拉它要多大？            → 只有真要拉时才量（`nix path-info -S`）
#
# 为什么在**构建期**而不是运行时：
#   - 时延：运行时扫一遍要几百毫秒到几秒，而这里只在 rebuild 时付一次；
#   - 正确性：运行时回答「nixpkgs 里有没有这个包」需要求值，而求值的那份 nixpkgs
#     可能不是这台机器锁上的那份。写进 derivation 就天然跟着锁走。
#
# 为什么**不是完整的 nix-locate 数据库**：
#   那份要扫整个 nixpkgs 的 derivation 集合，代价是每次 rebuild 多几十分钟和
#   数 GB 求值内存。它回答的是「这个命令属于哪个包」——而那一问在 90% 的情况下
#   由「属性名与命令同名」和下面这张表就能答掉。真的答不掉时，工具会要求
#   `pkg:<属性>` 显式指定，而不是猜。
#
# ⚠️ 已知射程（不许当成完整）：
#   - `system` 只覆盖 `config.system.path` 的 `bin/`。**不覆盖** man、libexec、
#     以及只在 `$PATH` 之外的服务二进制。
#   - `package` 字段只在 nixpkgs 的 `meta.mainProgram` 声明过时才有值；否则是 null。
#     这不是缺失，是「这个包没声明主程序」，下游不该拿它当包名用。
#   - `nixpkgsAttributes` 是**顶层属性名**，不是「这个属性里有什么可执行文件」。
#     它只回答「这个名字在 nixpkgs 里存在吗」。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixkits.shellIndex;

  # 求值期就能拿到的「命令名 → 包名」：nixpkgs 的 `meta.mainProgram` 约定。
  # 便宜且准；没有声明的包在构建期那一遍里仍然会出现在 `system` 里，只是 `package` 为 null。
  mainPrograms = lib.listToAttrs (
    lib.concatMap (
      p:
      let
        prog = if lib.isDerivation p then p.meta.mainProgram or null else null;
      in
      lib.optional (prog != null && builtins.isString prog) {
        name = prog;
        value = p.pname or p.name or "unknown";
      }
    ) (lib.filter (p: p != null && lib.isDerivation p) config.environment.systemPackages)
  );

  indexFile = pkgs.runCommand "kitsunome-shell-index.json" {
    nativeBuildInputs = [ pkgs.python3 ];
    # 注意：**不要**把这个环境变量叫 `path`——那会覆盖 shell 的 PATH。
    systemPath = config.system.path;
    # 这两份 JSON 是几十万字节（nixpkgs 顶层属性名有几万个），直接放进环境变量
    # 会撞上 ARG_MAX（2026-11-09 实测：`Argument list too long`）。`passAsFile`
    # 会把它们写进临时文件，环境里只留 `<名字>Path` 指向那个文件。
    passAsFile = [ "mainProgramsJson" "nixpkgsAttrsJson" ];
    mainProgramsJson = builtins.toJSON mainPrograms;
    nixpkgsAttrsJson = builtins.toJSON (
      if cfg.includeNixpkgsAttributes then builtins.attrNames pkgs else [ ]
    );
    nixpkgsRev = config.system.nixos.revision or "unknown";
    nixpkgsLabel = config.system.nixos.label or "";
  } ''
    python3 - > $out <<'PY'
    import json, os

    root = os.environ["systemPath"]
    with open(os.environ["mainProgramsJsonPath"], encoding="utf8") as fh:
        owners = json.load(fh)
    with open(os.environ["nixpkgsAttrsJsonPath"], encoding="utf8") as fh:
        attrs = json.load(fh)

    system = {}
    bin_dir = os.path.join(root, "bin")
    if os.path.isdir(bin_dir):
        for name in sorted(os.listdir(bin_dir)):
            full = os.path.join(bin_dir, name)
            try:
                if not (os.path.isfile(full) or os.path.islink(full)):
                    continue
                if not os.access(full, os.X_OK):
                    continue
            except OSError:
                continue
            system[name] = {
                "package": owners.get(name),
                "path": "/run/current-system/sw/bin/" + name,
            }

    print(json.dumps({
        "nixpkgs": {
            "rev": os.environ.get("nixpkgsRev", "unknown"),
            "label": os.environ.get("nixpkgsLabel", ""),
        },
        "system": system,
        "nixpkgsAttributes": attrs,
    }, ensure_ascii=False, sort_keys=True))
    PY
  '';
in
{
  options.nixkits.shellIndex = {
    enable = lib.mkEnableOption ''
      构建期生成的命令索引（`/etc/kitsunome/shell-index.json`）。
      给 `dsh-nixos-shell` 的 `nixos_shell` 用：它靠这份索引分清
      「命令打错」「环境里没有」「仓库里有但没装」三种情形，
      并在兜底拉临时 nix shell 之前先查它。索引随 nixpkgs 锁重建。
    '';

    includeNixpkgsAttributes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否把 nixpkgs 的顶层属性名一起写进索引。默认开：它让工具能**离线**回答
        「这个名字在仓库里存在吗」，而不必在运行时对 nixpkgs 求值（那份求值
        未必是这台机器锁上的那一份）。关掉会让 `nixos_shell` 在兜底时多一次
        `nix eval`，且那次求值与锁不保证一致。
      '';
    };

    path = lib.mkOption {
      type = lib.types.str;
      default = "/etc/kitsunome/shell-index.json";
      readOnly = true;
      description = "索引在系统里的固定位置。只读——插件按这个路径读。";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."kitsunome/shell-index.json".source = indexFile;

    # 让索引本身可被单独取用（调试与自检用，不进 PATH）。
    system.build.kitsunomeShellIndex = indexFile;
  };
}
