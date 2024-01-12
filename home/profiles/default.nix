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
    inputs.nix-index-db.hmModules.nix-index
    module_args
    {_module.args = {inherit inputs' self';};}
  ]);

  sharedWorkstationModules = [
    ../programs
    ../wayland
    ../services/eww
    inputs.hyprland.homeManagerModules.default
    inputs.anyrun.homeManagerModules.default
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
    "space@mediaVps" =
      [
        # ./mediaVps
      ]
      ++ sharedModules;
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in {
  imports = [
    {_module.args = {inherit homeImports;};}
  ];

  flake = {
    homeConfigurations = withSystem "x86_64-linux" ({
      pkgs,
      system,
      ...
    }: {
      "space@spacelaptop" = homeManagerConfiguration {
        modules = homeImports."space@spacelaptop" ++ module_args ++ (withSystemInputs system);
        inherit pkgs;
      };
      "space@spacedesktop" = homeManagerConfiguration {
        modules = homeImports."space@spacedesktop" ++ module_args ++ (withSystemInputs system);
        inherit pkgs;
      };
      "space@mediaVps" = homeManagerConfiguration {
        modules = homeImports."space@mediaVps" ++ module_args ++ (withSystemInputs system);
        inherit pkgs;
      };
    });
  };
}
