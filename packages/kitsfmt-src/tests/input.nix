{ pkgs }:

let
  name = "test";
  version = 1;
  # 这是一个测试注释
  config = {
    a = 1;
    b = 2;
  };
in
{
  hello = "world";
  foo = "bar";
  services = {
    nginx.enable = true;
    # 另一个注释
    postgresql.package = pkgs.postgresql_14;
  };
}
