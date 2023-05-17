{ inputs
, withSystem
, module_args
, ...
}:
let
  sharedModules = [
    ../.
    # ../shell
    module_args
  ];

  homeImports = {
    "space@spacelaptop" =
      [
        ./spacelaptop
        inputs.nix-index-db.hmModules.nix-index
        inputs.spicetify-nix.homeManagerModule
        inputs.hyprland.homeManagerModules.default
        inputs.fufexan.homeManagerModules.eww-hyprland
      ]
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
