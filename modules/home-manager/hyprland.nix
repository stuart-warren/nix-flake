{ config, pkgs, me, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      # https://github.com/Alexays/Waybar/blob/master/resources/config.jsonc
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        background = "#00000000";
        opacity = 0.8;
        output = "eDP-1";
        modules-left = [ "sway/workspaces" "sway/mode" "sway/scratchpad" ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "idle_inhibitor"
          "wireplumber"
          "network"
          "backlight"
          "battery"
          "clock"
          "tray"
        ];
      };
    };
    systemd.enable = true;
  };
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
    "$wpctl" = "${pkgs.wireplumber}/bin/wpctl";
    "$brightnessctl" = "${pkgs.brightnessctl}/bin/brightnessctl";
    "$mod" = "SUPER";
    "$hyper" = "SUPER CTRL ALT SHIFT";
    monitor = [ ",prefered,auto,1" ];
    bind = [
      # General
      "$mod, return, exec, $terminal"
      "$hyper, t, exec, hyprswitch kitty"
      "$hyper, SPACE, exec, $menu"
      "$hyper, f, exec, $filemanager"
      "$mod SHIFT, e, exit"
      "$mod SHIFT, q, killactive"
      # "$mod SHIFT, l, exec, ${pkgs.hyprlock}/bin/hyprlock"
      # Focus
      "$mod, f, fullscreen"
      # Windows
      "$mod SHIFT, f, togglefloating"
      "$mod SHIFT, f, centerwindow"
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
      # Audio
      ", XF86AudioRaiseVolume, exec, $wpctl set-volume @DEFAULT_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, $wpctl set-volume @DEFAULT_SINK@ 5%-"
      ", XF86AudioMute, exec, $wpctl set-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioMicMute, exec, $wpctl set-mute @DEFAULT_SOURCE@ toggle"
      # Brightness
      ", XF86MonBrightnessUp, exec, $brightnessctl set 10%+"
      ", XF86MonBrightnessDown, exec, $brightnessctl set 10%-"
    ];
  };

}
