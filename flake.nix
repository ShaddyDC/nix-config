{
  description = "Shaddy's NixOS and Home-Manager flake";
  # TODO Fix all follows

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    hm = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    fu.url = "github:numtide/flake-utils";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "hm";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fufexan = {
      url = "github:fufexan/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-gaming.follows = "nix-gaming";
      inputs.nix-index-db.follows = "nix-index-db";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.anyrun.follows = "anyrun";
      inputs.agenix.follows = "agenix";
      inputs.eww.follows = "eww";
      inputs.flake-parts.follows = "flake-parts";
      inputs.helix.follows = "helix";
      inputs.hm.follows = "hm";
      inputs.hyprland.follows = "hyprland";
      inputs.hyprland-contrib.follows = "hyprland-contrib";
      inputs.gross.follows = "gross";
      inputs.fu.follows = "fu";
      inputs.hyprpaper.follows = "hyprpaper";
    };
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    gross = {
      url = "github:fufexan/gross";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # https://github.com/elkowar/eww/issues/817
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "fu";
    };

    helix = {
      url = "github:SoraTenshi/helix/new-daily-driver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "fu";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.hyprland-protocols.inputs.nixpkgs.follows = "nixpkgs";
      # inputs.xdph.inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # My tools
    highlight-extract = {
      url = "github:ShaddyDC/highlight-extract";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs @ {
    deploy-rs,
    self,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        ./home/profiles
        ./hosts
        ./lib
        ./modules
        ./pkgs
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        # set flake-wide pkgs to the one exported by ./lib
        imports = [{_module.args.pkgs = config.legacyPackages;}];

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.alejandra
            pkgs.git
          ];
          name = "dots";
        };

        formatter = pkgs.alejandra;
      };
      flake = {
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
        checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
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
}
