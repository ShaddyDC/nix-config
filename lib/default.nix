{
  inputs,
  ...
}: let
  # Single overlay definition — exported as flake.overlays.default and applied to legacyPackages.
  overlay = final: prev: {
    claude-code = inputs.claude-code.packages.${prev.stdenv.hostPlatform.system}.default;
  };
in {
  flake.overlays.default = overlay;

  # Custom nixpkgs instance used by:
  #   - NixOS hosts via `nixpkgs.pkgs = self.legacyPackages.${system}` (modules/nix.nix)
  #   - Standalone home-manager configs via mkHome in hosts/default.nix
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [overlay];
      config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];
    };
  };
}
