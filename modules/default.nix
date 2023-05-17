{ _inputs
, inputs
, default
, ...
}:
let
  module_args = {
    _module.args = {
      inputs = _inputs;
      inherit default;
    };
  };
in
{
  imports = [
    {
      _module.args = {
        inherit module_args;

        sharedModules = [
          { home-manager.useGlobalPkgs = true; }
          inputs.hm.nixosModule
          inputs.agenix.nixosModules.default
          ./configuration.nix
          module_args
        ];

        workstationModules = with inputs; [
          hyprland.nixosModules.default
          nix-gaming.nixosModules.default
          ./workstation.nix
          ./mail.nix
        ];
      };
    }
  ];

  flake.nixosModules = {
    configuration = import ./configuration.nix;
  };
}
