# opencode devShell — OpenAI Code CLI + Telegram bot + MCP servers
# Includes: opencode, opencode-telegram, blender-mcp, mcp-searxng, godot-mcp
{
  pkgs,
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
  ] ++ (if (builtins.tryEval pkgs.godot-mcp).success
       then [ pkgs.godot-mcp pkgs.godot_4 ]
       else [ ]);
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
  port: 42999
  secret_key: "opencode-devshell-searxng-key"
  limiterSettings:
    botdetection:
      trusted_proxies:
        - "127.0.0.1/32"
    real_ip:
      x_for: 1
YML
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
server.port = 42899
server.modules = ( "mod_proxy", "mod_setenv" )
proxy.server = ( "" => ( ( "host" => "127.0.0.1", "port" => 42999 ) ) )
setenv.add-request-header = (
  "X-Real-IP"       => "%{remote-addr}e",
  "X-Forwarded-For"  => "%{remote-addr}e",
  "X-Forwarded-Proto" => "http"
)
LTCONF
    lighttpd -f "$LIGHTTPD_DIR/lighttpd.conf" &
    disown
    sleep 1
    export SEARXNG_URL="http://127.0.0.1:42899"
  '' + (if (builtins.tryEval pkgs.godot-mcp).success
       then "export GODOT_PATH=\"${pkgs.godot_4}/bin/godot\"\n"
       else "") + ''
    OPENCODE_MCP_DIR="$HOME/.config/opencode"
    OPENCODE_MCP_FILE="$OPENCODE_MCP_DIR/mcp.json"
    if [ ! -f "$OPENCODE_MCP_FILE" ]; then
      mkdir -p "$OPENCODE_MCP_DIR"
      cat > "$OPENCODE_MCP_FILE" << 'MCPJSON'
{
  "servers": {
    "SearXNG": {
      "command": "mcp-searxng",
      "env": { "SEARXNG_URL": "http://127.0.0.1:42899" }
    },
    "Blender": {
      "command": "blender-mcp",
      "env": { "BLENDER_PATH": "/etc/profiles/per-user/kix/bin/blender" }
    },
    "Godot": {
      "command": "godot-mcp",
      "env": { "GODOT_PATH": "/etc/profiles/per-user/kix/bin/godot" }
    }
  }
}
MCPJSON
      echo "opencode mcp.json initialized at $OPENCODE_MCP_FILE"
    fi
    echo "opencode + mcp-searxng + blender-mcp + godot-mcp ready"
  '';
}