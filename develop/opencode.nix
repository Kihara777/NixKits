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
YML
    redis-server --port 0 --unixsocket /tmp/searxng-redis-$$.sock --daemonize yes 2>/dev/null
    SEARXNG_SETTINGS_PATH="$SEARXNG_SETTINGS_DIR/settings.yml" \
      searxng-run &
    disown
    sleep 2
    export SEARXNG_URL="http://127.0.0.1:42999"
  '' + (if (builtins.tryEval pkgs.godot-mcp).success
       then "export GODOT_PATH=\"${pkgs.godot_4}/bin/godot\"\n"
       else "") + ''
    echo "opencode + mcp-searxng + blender-mcp + godot-mcp ready"
  '';
}