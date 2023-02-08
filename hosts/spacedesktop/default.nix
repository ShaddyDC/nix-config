{ pkgs, inputs, ... }: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ../../nixos/configuration.nix
    ../../nixos/mail.nix
  ];

  hardware.opentabletdriver.enable = true;
  virtualisation.libvirtd.enable = true;

  networking.hostName = "spacedesktop";
}
