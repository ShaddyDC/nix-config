{
  self,
  inputs,
  theme,
  ...
}: let
  module_args = {
    _module.args = {
      inherit theme inputs self;
    };
  };
in {
  imports = [
    {
      _module.args = {
        inherit module_args;

        sharedModules = [
          inputs.hm.nixosModules.home-manager
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
          nix-gaming.nixosModules.pipewireLowLatency
          ./workstation.nix
          ./xserver.nix
          ./greetd.nix
        ];
      };
    }
  ];

}
