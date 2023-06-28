{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-gpu-amd

    ./hardware-configuration.nix
    # ../../nixos/configuration.nix
    # ../../nixos/mail.nix
  ];

  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 4;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    # Setup keyfile
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };
  };

  hardware.opentabletdriver.enable = true;
  virtualisation.libvirtd.enable = true;

  networking.hostName = "spacedesktop";
  # workstation.enable = true;
}
