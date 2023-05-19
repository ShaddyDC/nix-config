{ inputs
, withSystem
, sharedModules
, workstationModules
, homeImports
, ...
}: {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({ system, ... }: {
    spacelaptop = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./spacelaptop
          { home-manager.users.space.imports = homeImports."space@spacelaptop"; }
        ]
        ++ sharedModules
        ++ workstationModules;
    };
    spacedesktop = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./spacedesktop
          { home-manager.users.space.imports = homeImports."space@spacedesktop"; }
        ]
        ++ sharedModules
        ++ workstationModules;
    };
    mediavps = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./mediavps
          { home-manager.users.space.imports = homeImports."space@mediavps"; }
        ]
        ++ sharedModules;
    };
  });
}
