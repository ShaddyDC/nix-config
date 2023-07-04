{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  environment.systemPackages = with pkgs; [nfs-utils];
  boot.initrd = {
    supportedFilesystems = ["nfs"];
    kernelModules = ["nfs"];
  };

  networking.hostName = "worklaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.enableAllFirmware = true;

  services.hardware.bolt.enable = true;
  services.colord.enable = true;
  services.fprintd.enable = true;

  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  hardware.firmware = with pkgs; [pkgs.sof-firmware];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  # boot.extraModprobeConfig = ''
  #   options snd-intel-dspcfg dsp_driver=1
  # '';

  fileSystems."/mnt/berta/common" = {
    device = "192.168.1.56:/volume1/common";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/berta/dev" = {
    device = "192.168.1.56:/volume1/dev";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  # fileSystems."/mnt/berta/dev-archive" = {
  #   device = "192.168.1.56:/volume1/dev-archive";
  #   fsType = "nfs";
  #   options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  # };

  fileSystems."/mnt/berta/homes" = {
    device = "192.168.1.56:/volume1/homes/@LH-RIIICO.DEV/61/ ";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };
}
