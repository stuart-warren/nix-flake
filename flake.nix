{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    # NixOS Hardware
    hardware.url = "github:NixOS/nixos-hardware/master";
    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    kmonad.url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
    kmonad.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-25.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # User configuration
      me = rec {
        username = "stuartwarren";
        githubUsername = "stuart-warren";
        githubEmail = "stuart.warren@gmail.com";
        homeDirectory = /home/${username};
        timeZone = "Europe/London";
        keyboard = {
          layout = "us";
          variant = "dvorak";
        };
      };
    in {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # FIXME replace with your hostname
        P72 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit me inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            inputs.kmonad.nixosModules.default
            ./nixos/p72/configuration.nix
            outputs.nixosModules.programs
          ];
        };
        nix5540 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit me inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            inputs.kmonad.nixosModules.default
            ./nixos/5540/configuration.nix
            outputs.nixosModules.programs
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # FIXME replace with your username@hostname
        "${me.username}" = home-manager.lib.homeManagerConfiguration {
          pkgs =
            nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit me inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            inputs.nixvim.homeManagerModules.nixvim
            ./home-manager/home.nix
            outputs.homeManagerModules.neovim
            outputs.homeManagerModules.shell
            outputs.homeManagerModules.terminal
            outputs.homeManagerModules.hyprland
          ];
        };
      };
    };
}
