# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  hyprswitch = pkgs.callPackage ./hyprswitch { };
  sessionizer = pkgs.callPackage ./sessionizer { };
  my-bambu-studio = pkgs.unstable.bambu-studio.overrideAttrs
    (finalAttrs: previousAttrs: {
      preFixup = previousAttrs.preFixup + ''
        gappsWrapperArgs+=(
          # Otherwise crashes the application for many people (see #293854, #328235)
          --unset __GLX_VENDOR_LIBRARY_NAME
        )
      '';
    });
}
