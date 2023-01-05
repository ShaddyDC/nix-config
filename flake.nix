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

    devenv.url = "github:cachix/devenv/v0.5";

    agenix.url = "github:ryantm/agenix";

    nix-gaming.url = "github:fufexan/nix-gaming";

    hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { unstablepkgs, home-manager, agenix, ... }@inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      spacedesktop = unstablepkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/spacedesktop agenix.nixosModule ];
      };
      spacelaptop = unstablepkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/spacelaptop agenix.nixosModule ];
      };
    };

    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "space@spacedesktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstablepkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
      "space@spacelaptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstablepkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
