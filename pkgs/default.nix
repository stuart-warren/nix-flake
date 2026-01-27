# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  hyprswitch = pkgs.callPackage ./hyprswitch { };
  sessionizer = pkgs.callPackage ./sessionizer { };
  mynrfutil = pkgs.nrfutil.withExtensions [
    "nrfutil-device"
    "nrfutil-trace"
    "nrfutil-ble-sniffer"
    "nrfutil-completion"
    "nrfutil-mcu-manager"
    "nrfutil-npm"
    "nrfutil-nrf5sdk-tools"
    "nrfutil-sdk-manager"
    "nrfutil-suit"
    "nrfutil-toolchain-manager"
  ];

}
