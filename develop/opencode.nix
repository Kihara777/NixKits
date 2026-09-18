# opencode devShell — OpenAI Code CLI + Telegram bot + MCP servers
# Includes: opencode, opencode-telegram, blender-mcp, mcp-searxng, godot-ai
{
  pkgs,
  godot-ai,
  blender-mcp,
  opencode-telegram,
  mcp-searxng,
}:

pkgs.mkShell {
  name = "opencode-dev";
  packages = [
    opencode-telegram
    pkgs.opencode
    pkgs.nodejs
    blender-mcp
    pkgs.blender
    pkgs.python3
    mcp-searxng
    pkgs.searxng
    pkgs.redis
    pkgs.lighttpd
    godot-ai
    pkgs.godot
  ];
  shellHook = ''
    export BLENDER_PATH="${pkgs.blender}/bin/blender"
    export SEARXNG_SETTINGS_DIR="''${XDG_RUNTIME_DIR:-/tmp}/searxng-$$"
    mkdir -p "$SEARXNG_SETTINGS_DIR"
    cat > "$SEARXNG_SETTINGS_DIR/settings.yml" << YML
use_default_settings: true
search:
  formats:
    - html
    - json
server:
  bind_address: "127.0.0.1"
  port: 42701
  secret_key: "opencode-devshell-searxng-key"
YML
    # limiter 配置**必须**放在独立的 limiter.toml —— searxng 只从
    # `<user_cfg_folder>/limiter.toml` 读取（searx/limiter.py 的 get_cfg），
    # settings.yml 里写 limiterSettings 会被**静默忽略**（实测启动即警告
    # "missing config file: .../limiter.toml"）。SEARXNG_SETTINGS_PATH 指向
    # 文件时其所在目录即 user_cfg_folder，故 limiter.toml 与 settings.yml 同目录。
    # trusted_proxies 让 searxng 信任本机 lighttpd 反代传来的 X-Forwarded-For/X-Real-IP。
    cat > "$SEARXNG_SETTINGS_DIR/limiter.toml" << LT
[botdetection]
trusted_proxies = [
  '127.0.0.0/8',
  '::1',
]
LT
    redis-server --port 0 --unixsocket /tmp/searxng-redis-$$.sock --daemonize yes 2>/dev/null
    SEARXNG_SETTINGS_PATH="$SEARXNG_SETTINGS_DIR/settings.yml" \
      searxng-run &
    disown
    sleep 2
    # lighttpd reverse proxy → sets X-Forwarded-For / X-Real-IP headers
    LIGHTTPD_DIR="''${XDG_RUNTIME_DIR:-/tmp}/lighttpd-$$"
    mkdir -p "$LIGHTTPD_DIR"
    cat > "$LIGHTTPD_DIR/lighttpd.conf" << 'LTCONF'
server.document-root = "/dev/null"
server.port = 4270
server.modules = ( "mod_proxy", "mod_setenv" )
proxy.server = ( "" => ( ( "host" => "127.0.0.1", "port" => 42701 ) ) )
setenv.add-request-header = (
  "X-Real-IP"       => "%{remote-addr}e",
  "X-Forwarded-For"  => "%{remote-addr}e",
  "X-Forwarded-Proto" => "http"
)
LTCONF
    lighttpd -f "$LIGHTTPD_DIR/lighttpd.conf" &
    disown
    sleep 1
    export SEARXNG_URL="http://127.0.0.1:4270"
    export GODOT_PATH="${pkgs.godot}/bin/godot"
    # Install NixKits skills if opencode skills dir is empty
    SKILLS_DIR="$HOME/.opencode/skills"
    if [ ! -d "$SKILLS_DIR" ] || [ -z "$(ls -A "$SKILLS_DIR" 2>/dev/null)" ]; then
      mkdir -p "$SKILLS_DIR"
      NIXKITS_SRC="$HOME/NixKits"
      if [ -d "$NIXKITS_SRC/skills" ]; then
        for skill in "$NIXKITS_SRC/skills"/*/; do
          cp -r "$skill" "$SKILLS_DIR/$(basename "$skill")"
        done
        echo "Installed opencode skills from $NIXKITS_SRC"
      else
        TMP=$(mktemp -d)
        git clone --depth 1 https://github.com/Kihara777/NixKits.git "$TMP" 2>/dev/null
        for skill in "$TMP/skills"/*/; do
          cp -r "$skill" "$SKILLS_DIR/$(basename "$skill")"
        done
        rm -rf "$TMP"
        echo "Installed opencode skills (online)"
      fi
    fi
  '' + ''
    OPENCODE_MCP_DIR="$HOME/.config/opencode"
    OPENCODE_MCP_FILE="$OPENCODE_MCP_DIR/mcp.json"
    if [ ! -f "$OPENCODE_MCP_FILE" ]; then
      mkdir -p "$OPENCODE_MCP_DIR"
      cat > "$OPENCODE_MCP_FILE" << MCPJSON
{
  "servers": {
    "SearXNG": {
      "command": "mcp-searxng",
      "env": { "SEARXNG_URL": "http://127.0.0.1:4270" }
    },
    "Blender": {
      "command": "blender-mcp",
      "env": { "BLENDER_PATH": "${pkgs.blender}/bin/blender" }
    },
    "Godot": {
      "command": "godot-ai",
      "env": { "GODOT_PATH": "${pkgs.godot}/bin/godot" }
    }
  }
}
MCPJSON
      echo "opencode mcp.json initialized at $OPENCODE_MCP_FILE"
    fi
    echo "opencode + mcp-searxng + blender-mcp + godot-ai ready"
  '';
}