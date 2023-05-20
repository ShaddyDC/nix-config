{
  _inputs,
  inputs,
  default,
  ...
}: let
  module_args = {
    _module.args = {
      inputs = _inputs;
      inherit default;
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
          nix-gaming.nixosModules.default
          ./mail.nix
          ./workstation.nix
          ./xserver.nix
        ];
      };
    }
  ];

  flake.nixosModules = {
    configuration = import ./configuration.nix;
  };
}
