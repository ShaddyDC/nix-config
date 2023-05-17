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
  });
}
