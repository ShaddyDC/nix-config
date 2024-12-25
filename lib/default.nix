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
      config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];
    };
  };
}
