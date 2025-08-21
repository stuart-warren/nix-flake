{ lib, pkgs, writeShellApplication }:

writeShellApplication {
  name = "sessionizer";
  runtimeInputs = with pkgs; [ fzf fd tmux ];
  text = lib.readFile ./sessionizer.sh;
}
