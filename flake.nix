{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    unstablepkgs.url = "nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/v0.5";

    agenix.url = "github:ryantm/agenix";

    nix-gaming.url = "github:fufexan/nix-gaming";

    hardware.url = "github:nixos/nixos-hardware";

    deploy-rs.url = "github:serokell/deploy-rs";

    fufexan.url = "github:fufexan/dotfiles/2383ae6";
    hyprland.url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, unstablepkgs, home-manager, agenix, deploy-rs, nix-index-database, hyprland, ... }@inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      spacedesktop = unstablepkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/spacedesktop agenix.nixosModules.default hyprland.nixosModules.default ];
      };
      spacelaptop = unstablepkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/spacelaptop agenix.nixosModules.default hyprland.nixosModules.default ];
      };
      mediaVps = unstablepkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/mediaVps agenix.nixosModules.default ];
      };
    };
    deploy.nodes = {
      mediaVps = {
        hostname = "138.201.206.23";
        user = "root";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mediaVps;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;


    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "space@spacedesktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstablepkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix nix-index-database.hmModules.nix-index hyprland.homeManagerModules.default ];
      };
      "space@spacelaptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstablepkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix nix-index-database.hmModules.nix-index hyprland.homeManagerModules.default ];
      };
    };
  };
}
