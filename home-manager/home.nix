# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  me,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "${me.username}";
    homeDirectory = me.homeDirectory;
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    google-chrome
    wofi
    dolphin
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = me.githubUsername;
    userEmail = me.githubEmail;
  };

  programs.kitty.enable = true;
  programs.wofi.enable = true;
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = me.keyboard.layout;
      kb_variant = me.keyboard.variant;
      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
        tap-and-drag = false;
        clickfinger_behavior = true;
      };
      follow_mouse = true;
      mouse_refocus = true;
    };
    "$terminal" = "${pkgs.kitty}/bin/kitty";
    "$filemanager" = "${pkgs.dolphin}/bin/dolphin";
    "$menu" = "${pkgs.wofi}/bin/wofi --show drun";
    "$mod" = "SUPER";
    "$hyper" = "SUPER CTRL ALT SHIFT";
    monitor = [
      ",prefered,auto,1"
    ];
    bind = [
      # General
      "$mod, return, exec, $terminal"
      "$hyper, t, exec, $terminal"
      "$hyper, SPACE, exec, $menu"
      "$hyper, f, exec, $filemanager"
      "$mod SHIFT, e, exit"
      "$mod SHIFT, q, killactive"
      # "$mod SHIFT, l, exec, ${pkgs.hyprlock}/bin/hyprlock"
      # Focus
      "$mod, f, fullscreen"
      # Workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      # Move to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
    ];
  };
  

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
