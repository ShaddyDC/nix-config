{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ../../nixos/configuration.nix
    # ../../nixos/mail.nix
  ];

  networking.hostName = "spacelaptop";

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

  hardware.bluetooth.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.NetworkManager-wait-online.enable = false;
}
