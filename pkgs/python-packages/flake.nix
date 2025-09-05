{
  description = "Local Python packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      packageOverrides = pkgs.callPackage ./default.nix { };
      python = pkgs.python3.override { inherit packageOverrides; };
    in
    {
      packages.x86_64-linux.default = (python.withPackages
        (p: [ p.aws-iot-device-sdk-python-v2 p.aws-crt-python ]));
    };
}
