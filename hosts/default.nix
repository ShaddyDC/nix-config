{
  inputs,
  withSystem,
  sharedModules,
  workstationModules,
  homeImports,
  ...
}: {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({system, ...}: {
    worklaptop = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./worklaptop
          {home-manager.users.space.imports = homeImports."space@worklaptop";}

          inputs.hardware.nixosModules.common-pc-ssd
          inputs.hardware.nixosModules.common-pc-laptop

          inputs.hardware.nixosModules.common-cpu-intel
        ]
        ++ sharedModules
        ++ workstationModules;
    };
    spacelaptop = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./spacelaptop
          ../modules/mail.nix
          {home-manager.users.space.imports = homeImports."space@spacelaptop";}
        ]
        ++ sharedModules
        ++ workstationModules;
    };
    spacedesktop = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./spacedesktop
          ../modules/mail.nix
          inputs.hardware.nixosModules.common-pc-ssd
          {home-manager.users.space.imports = homeImports."space@spacedesktop";}
        ]
        ++ sharedModules
        ++ workstationModules;
    };
    mediaVps = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./mediaVps
          {home-manager.users.space.imports = homeImports."space@mediaVps";}
        ]
        ++ sharedModules;
    };
  });
}
