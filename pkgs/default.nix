# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  hyprswitch = pkgs.callPackage ./hyprswitch { };
  sessionizer = pkgs.callPackage ./sessionizer { };
}
