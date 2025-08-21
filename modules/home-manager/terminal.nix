{ pkgs, config, me, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      startup_session = builtins.toString (pkgs.writeTextFile {
        name = "kitty-startup-session";
        text = ''
          launch sh -c "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux new"
        '';
      });
    };
  };
}
