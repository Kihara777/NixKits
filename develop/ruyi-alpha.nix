# ruyi-alpha devShell
{ pkgs, ruyi-alpha }:
pkgs.mkShell { name = "ruyi-alpha-dev"; packages = [ ruyi-alpha ]; }