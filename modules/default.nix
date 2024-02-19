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
        ];

        workstationModules = with inputs; [
          hyprland.nixosModules.default
          nix-gaming.nixosModules.pipewireLowLatency
          nix-gaming.nixosModules.steamCompat
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
