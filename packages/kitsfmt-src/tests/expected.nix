{ pkgs }:
let
  # Test configuration for kitsfmt formatter
  config = {
    a = 1;
    b = 2;
  };
in
{
  demo = "value";
  services = {
    # Test comment preserved by formatter
    database.package = pkgs.postgresql_14;
    nginx.enable = true;
  };
}
