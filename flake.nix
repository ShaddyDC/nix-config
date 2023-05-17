{
  description = "Shaddy's NixOS and Home-Manager flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # Home manager
    hm = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/v0.5";

    agenix.url = "github:ryantm/agenix";

    nix-gaming.url = "github:fufexan/nix-gaming";

    hardware.url = "github:nixos/nixos-hardware";

    deploy-rs.url = "github:serokell/deploy-rs";

    fufexan.url = "github:fufexan/dotfiles";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";


    nix-xilinx = {
      url = "gitlab:doronbehar/nix-xilinx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./home/profiles
        ./hosts
        ./modules
        # ./pkgs
        # ./lib
        { config._module.args._inputs = inputs // { inherit (inputs) self; }; }
      ];

      perSystem =
        { config
        , inputs'
        , pkgs
        , system
        , ...
        }: {
          imports = [
            {
              _module.args.pkgs = inputs.self.legacyPackages.${system};
            }
          ];
        };
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://fufexan.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  # outputs = { self, unstablepkgs, home-manager, agenix, deploy-rs, nix-index-database, hyprland, ... }@inputs: {
  #   # NixOS configuration entrypoint
  #   # Available through 'nixos-rebuild --flake .#your-hostname'
  #   nixosConfigurations = {
  #     spacedesktop = unstablepkgs.lib.nixosSystem {
  #       specialArgs = { inherit inputs; };
  #       modules = [ ./hosts/spacedesktop agenix.nixosModules.default hyprland.nixosModules.default ];
  #     };
  #     spacelaptop = unstablepkgs.lib.nixosSystem {
  #       specialArgs = { inherit inputs; };
  #       modules = [ ./hosts/spacelaptop agenix.nixosModules.default hyprland.nixosModules.default ];
  #     };
  #     mediaVps = unstablepkgs.lib.nixosSystem {
  #       system = "x86_64-linux";
  #       specialArgs = { inherit inputs; };
  #       modules = [ ./hosts/mediaVps agenix.nixosModules.default ];
  #     };
  #   };
  #   deploy.nodes = {
  #     mediaVps = {
  #       hostname = "138.201.206.23";
  #       user = "root";
  #       profiles.system = {
  #         user = "root";
  #         sshUser = "root";
  #         path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mediaVps;
  #       };
  #     };
  #   };

  #   checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;


  #   # Available through 'home-manager --flake .#your-username@your-hostname'
  #   homeConfigurations = {
  #     "space@spacedesktop" = home-manager.lib.homeManagerConfiguration {
  #       pkgs = unstablepkgs.legacyPackages.x86_64-linux;
  #       extraSpecialArgs = { inherit inputs; };
  #       modules = [ ./home-manager/home.nix nix-index-database.hmModules.nix-index hyprland.homeManagerModules.default ];
  #     };
  #     "space@spacelaptop" = home-manager.lib.homeManagerConfiguration {
  #       pkgs = unstablepkgs.legacyPackages.x86_64-linux;
  #       extraSpecialArgs = { inherit inputs; };
  #       modules = [ ./home-manager/home.nix nix-index-database.hmModules.nix-index hyprland.homeManagerModules.default ];
  #     };
  #   };
  # };
}

