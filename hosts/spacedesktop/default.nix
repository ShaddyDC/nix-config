{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration.nix
  ];
  #
  networking.hostName = "spacedesktop";
}
