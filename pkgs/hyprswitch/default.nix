{ lib, buildGoModule }:

buildGoModule rec {
  pname = "hyprswitch";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-NtFLez5uPVy3zSn3IuAvsBPW/wIkZhQMQkacp6/IbUE="; # lib.fakeHash;
  meta = with lib; { description = "open/switch apps in hyprland"; };
}
