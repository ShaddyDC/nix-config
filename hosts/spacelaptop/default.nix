{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration.nix
  ];

  networking.hostName = "spacelaptop";

  hardware.bluetooth.enable = true;
  workstation.enable = true;
}
