{ inputs
, withSystem
, module_args
, ...
}:
let
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
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in
{
  imports = [
    { _module.args = { inherit homeImports; }; }
  ];

  flake = {
    homeConfigurations = withSystem "x86_64-linux" ({ pkgs, ... }: {
      "space@spacelaptop" = homeManagerConfiguration {
        modules = homeImports."space@spacelaptop" ++ module_args;
        inherit pkgs;
      };
    });
  };
}
