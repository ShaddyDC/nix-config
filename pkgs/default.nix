{
  self,
  inputs,
  ...
}: {
  systems = ["x86_64-linux"];

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
