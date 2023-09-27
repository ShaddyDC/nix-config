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
          {home-manager.useGlobalPkgs = true;}
          inputs.hm.nixosModule
          inputs.agenix.nixosModules.default
          ./common.nix
          ./nix.nix
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
