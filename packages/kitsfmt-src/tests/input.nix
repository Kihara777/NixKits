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
    nginx.enable = true;
    # Test comment preserved by formatter
    database.package = pkgs.postgresql_14;
  };
}
