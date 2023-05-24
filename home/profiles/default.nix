{
  inputs,
  withSystem,
  module_args,
  ...
}: let
  sharedModules = [
    ../.
    ../common.nix
    ../shell
    inputs.nix-index-db.hmModules.nix-index
    module_args
  ];

  sharedWorkstationModules = [
    ../programs
    ../wayland
    ../games.nix
    ../mail
    ../../secrets/accounts.nix
    inputs.hyprland.homeManagerModules.default
    inputs.fufexan.homeManagerModules.eww-hyprland
  ];

  homeImports = {
    "space@spacelaptop" =
      [
        ./spacelaptop
      ]
      ++ sharedWorkstationModules
      ++ sharedModules;
    "space@spacedesktop" =
      [
        ./spacedesktop
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
    homeConfigurations = withSystem "x86_64-linux" ({pkgs, ...}: {
      "space@spacelaptop" = homeManagerConfiguration {
        modules = homeImports."space@spacelaptop" ++ module_args;
        inherit pkgs;
      };
      "space@spacedesktop" = homeManagerConfiguration {
        modules = homeImports."space@spacedesktop" ++ module_args;
        inherit pkgs;
      };
      "space@mediaVps" = homeManagerConfiguration {
        modules = homeImports."space@mediaVps" ++ module_args;
        inherit pkgs;
      };
    });
  };
}
