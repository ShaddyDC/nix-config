{...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages = {
      berkeley-mono = pkgs.callPackage ./berkeley-mono.nix {};
    };
  };
}
