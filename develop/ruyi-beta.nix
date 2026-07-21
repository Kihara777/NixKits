# ruyi-beta devShell
{ pkgs, ruyi-beta }:
pkgs.mkShell { name = "ruyi-beta-dev"; packages = [ ruyi-beta ]; }