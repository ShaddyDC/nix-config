{
  inputs,
  withSystem,
  self,
  ...
}:
# personal lib
let
  inherit (inputs.nixpkgs) lib;

  default = import ./theme {inherit lib;};
in {
  imports = [
    {
      _module.args = {
        inherit default;

        withSystemInputs = system:
          withSystem system ({
            self',
            inputs',
            ...
          }: [{_module.args = {inherit self' inputs';};}]);
      };
    }
  ];

  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.overlays = [
        self.overlays.default
      ];
    };
  };
}
