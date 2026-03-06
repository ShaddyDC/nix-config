{
  inputs,
  self,
  ...
}: {
  # Custom nixpkgs instance with overlay + unfree + permitted insecure packages.
  # Used by NixOS hosts via `nixpkgs.pkgs = self.legacyPackages.${system}` (modules/nix.nix)
  # and by standalone home-manager configs via mkHome in hosts/default.nix.
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [self.overlays.default];
      config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];
    };
  };
}
