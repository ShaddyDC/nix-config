{
  inputs,
  withSystem,
  withSystemInputs,
  module_args,
  ...
}: let
  sharedModules = withSystem "x86_64-linux" ({
    inputs',
    self',
    ...
  }: [
    ../.
    ../common.nix
    ../shell
    inputs.nix-index-db.homeModules.nix-index
    module_args
    {_module.args = {inherit inputs' self';};}
  ]);

  sharedWorkstationModules = [
    ../programs
    ../wayland
  ];

  homeImports = {
    "space@worklaptop" =
      [
        ./worklaptop
      ]
      ++ sharedWorkstationModules
      ++ sharedModules;
    "space@spacelaptop" =
      [
        ./spacelaptop
        ../mail
        ../games.nix
        ../programs/rclone.nix
        ../../secrets/accounts.nix
      ]
      ++ sharedWorkstationModules
      ++ sharedModules;
    "space@framework" =
      [
        ./framework
        ../mail
        ../games.nix
        ../programs/rclone.nix
        ../../secrets/accounts.nix
      ]
      ++ sharedWorkstationModules
      ++ sharedModules;
    "space@spacedesktop" =
      [
        ./spacedesktop
        ../mail
        ../games.nix
        ../programs/rclone.nix
        ../../secrets/accounts.nix
      ]
      ++ sharedWorkstationModules
      ++ sharedModules;
    "space@pi" =
      [
        # ./pi
      ]
      ++ sharedModules;
    "space@mediaVps" =
      [
        # ./mediaVps
      ]
      ++ sharedModules;
    # "space@nasps" =
    #   [
    #     # ./nasps
    #   ]
    #   ++ sharedModules;
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in {
  imports = [
    {_module.args = {inherit homeImports;};}
  ];

  flake = {
    homeConfigurations =
      withSystem "aarch64-linux" ({
        legacyPackages,
        system,
        ...
      }: {
        "space@pi" = homeManagerConfiguration {
          modules = homeImports."space@pi" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
      })
      // withSystem "x86_64-linux" ({
        legacyPackages,
        system,
        ...
      }: {
        "space@spacelaptop" = homeManagerConfiguration {
          modules = homeImports."space@spacelaptop" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
        "space@framework" = homeManagerConfiguration {
          modules = homeImports."space@framework" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
        "space@spacedesktop" = homeManagerConfiguration {
          modules = homeImports."space@spacedesktop" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
        "space@worklaptop" = homeManagerConfiguration {
          modules = homeImports."space@worklaptop" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
        "space@mediaVps" = homeManagerConfiguration {
          modules = homeImports."space@mediaVps" ++ module_args ++ (withSystemInputs system);
          pkgs = legacyPackages;
        };
      });
  };
}
