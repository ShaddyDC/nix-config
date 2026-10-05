{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      berkeley-mono = pkgs.callPackage ./berkeley-mono.nix {inherit (inputs) secrets;};
      # Built from legacyPackages (config.allowUnfree = true; see lib/default.nix)
      # because claude-desktop is unfree — the default perSystem pkgs would refuse.
      claude-desktop = config.legacyPackages.callPackage ./claude-desktop.nix {passwordStore = "gnome-libsecret";};
    };
  };
}
