{
  self,
  inputs,
  lib,
  ...
}: {
  systems = ["x86_64-linux"];

  flake.overlays.default = (
    inputs.nixpkgs.lib.composeManyExtensions [
      (
        _inputs: prev: {
        }
      )
    ]
  );

  perSystem = {pkgs, ...}: {
    packages = self.overlays.default inputs pkgs;
  };
}
