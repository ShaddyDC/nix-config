{
  inputs,
  withSystem,
  self,
  ...
}: let
  theme = import ../lib/theme {inherit (inputs.nixpkgs) lib;};

  # Injected into both NixOS and HM module systems
  moduleArgs = {_module.args = {inherit theme inputs self;};};

  # Shared NixOS modules that every host gets
  nixosBase = [
    inputs.hm.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.stylix.nixosModules.stylix
    ../modules/common.nix
    ../modules/nix.nix
    ../modules/stylix.nix
    moduleArgs
    {home-manager.backupFileExtension = "backup";}
  ];

  # Additional NixOS modules for workstation hosts
  nixosWorkstation = with inputs; [
    nix-gaming.nixosModules.pipewireLowLatency
    ../modules/workstation.nix
    ../modules/xserver.nix
    ../modules/greetd.nix
    ../modules/app-netns.nix
  ];

  # Shared HM modules that every user gets
  hmBase = [
    ../home
    ../home/common.nix
    ../home/shell
    inputs.nix-index-db.homeModules.nix-index
  ];

  # Additional HM modules for workstation users
  hmWorkstation = [
    ../home/programs
    ../home/wayland
  ];

  # Additional HM modules for personal workstation users (not work machines)
  hmPersonal = [
    ../home/mail
    ../home/games.nix
    ../home/programs/rclone.nix
    "${inputs.secrets}/accounts.nix"
  ];

  # Build a NixOS system, injecting system-specific self'/inputs' into both
  # the NixOS and embedded HM module systems.
  mkSystem = system: extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        extraModules
        ++ nixosBase
        ++ withSystem system ({
          self',
          inputs',
          ...
        }: [
          {_module.args = {inherit self' inputs';};}
          # Propagate system-specific args into the embedded HM module system
          {home-manager.sharedModules = [moduleArgs {_module.args = {inherit self' inputs';};}];}
        ]);
    };
in {
  flake.nixosConfigurations = {
    framework = mkSystem "x86_64-linux" (
      [
        ./framework
        ../modules/mail.nix
        ../modules/power-switcher.nix
        {
          home-manager.users.space.imports =
            hmBase
            ++ [../home/profiles/framework]
            ++ hmWorkstation
            ++ hmPersonal;
        }
      ]
      ++ nixosWorkstation
    );

    spacedesktop = mkSystem "x86_64-linux" (
      [
        ./spacedesktop
        ../modules/mail.nix
        {
          home-manager.users.space.imports =
            hmBase
            ++ [../home/profiles/spacedesktop]
            ++ hmWorkstation
            ++ hmPersonal;
        }
        inputs.hardware.nixosModules.common-pc-ssd
      ]
      ++ nixosWorkstation
    );
  };
}
