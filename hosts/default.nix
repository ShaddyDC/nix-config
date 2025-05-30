{
  inputs,
  withSystem,
  withSystemInputs,
  sharedModules,
  workstationModules,
  homeImports,
  ...
}: {
  flake.nixosConfigurations =
    withSystem "aarch64-linux" ({system, ...}: {
      pi = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            ./pi
            {home-manager.users.space.imports = homeImports."space@pi";}
          ]
          ++ sharedModules
          ++ (withSystemInputs system);
      };
    })
    // withSystem "x86_64-linux" ({system, ...}: {
      worklaptop = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            ./worklaptop
            ../modules/power-switcher.nix
            {home-manager.users.space.imports = homeImports."space@worklaptop";}

            inputs.hardware.nixosModules.common-pc-ssd
            inputs.hardware.nixosModules.common-pc-laptop

            inputs.hardware.nixosModules.common-cpu-intel
          ]
          ++ sharedModules
          ++ workstationModules
          ++ (withSystemInputs system);
      };
      framework = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            ./framework
            ../modules/mail.nix
            ../modules/power-switcher.nix
            {home-manager.users.space.imports = homeImports."space@framework";}
          ]
          ++ sharedModules
          ++ workstationModules
          ++ (withSystemInputs system);
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
          ++ workstationModules
          ++ (withSystemInputs system);
      };
      mediaVps = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            ./mediaVps
            {home-manager.users.space.imports = homeImports."space@mediaVps";}
          ]
          ++ sharedModules
          ++ (withSystemInputs system);
      };
      # nasps = inputs.nixpkgs.lib.nixosSystem {
      #   inherit system;

      #   modules =
      #     [
      #       ./mediaVps/nasps.nix
      #       {home-manager.users.space.imports = homeImports."space@nasps";}
      #     ]
      #     ++ sharedModules
      #     ++ (withSystemInputs system);
      # };
    });
}
