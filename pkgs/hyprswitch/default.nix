{ lib, buildGoModule }:

buildGoModule rec {
  pname = "hyprswitch";
  version = "0.0.1";

  src = ./.;

  vendorHash =
    "sha256-xbS6H9Yh7RcAyMoxBbuyCqgx6nTTpdbxFpOZ4pCh4lE="; # lib.fakeHash;
  # vendorHash = lib.fakeHash;
  meta = with lib; { description = "open/switch apps in hyprland"; };
}
