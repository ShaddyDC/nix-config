{
  self,
  inputs,
  default,
  ...
}: let
  module_args = {
    _module.args = {
      inherit default inputs self;
    };
  };
in {
  imports = [
    {
      _module.args = {
        inherit module_args;

        sharedModules = [
          inputs.hm.nixosModule
          inputs.agenix.nixosModules.default
          inputs.stylix.nixosModules.stylix
          ./common.nix
          ./nix.nix
          ./vpn.nix
          ./stylix.nix
          module_args
          {home-manager.backupFileExtension = "backup";}
        ];

        workstationModules = with inputs; [
          hyprland.nixosModules.default
          nix-gaming.nixosModules.pipewireLowLatency
          ./workstation.nix
          ./xserver.nix
          ./greetd.nix
        ];
      };
    }
  ];

  flake.nixosModules = {
    configuration = import ./configuration.nix;
  };
}
