{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0ef5e13c-1cad-4a07-a213-b6768b458c4d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-48b947d1-eb21-4333-aaf8-48769b0cf3a4".device = "/dev/disk/by-uuid/48b947d1-eb21-4333-aaf8-48769b0cf3a4";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/75C3-A9A7";
      fsType = "vfat";
    };

  fileSystems."/run/media/space/ext4" = {
    device = "/dev/disk/by-uuid/c21e248c-11b2-47de-946a-892852f3c43b";
  };
  fileSystems."/run/media/space/New_Volume" = {
    device = "/dev/disk/by-uuid/8A44D93A44D929A9";
  };
  fileSystems."/run/media/space/media" = {
    device = "/dev/disk/by-uuid/36B2588FB2585589";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
