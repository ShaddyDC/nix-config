{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot = {
    # kernelPackages = pkgs.linuxPackages_xanmod_latest;
    supportedFilesystems = ["ntfs"];
  };

  # `hardware.opengl` was renamed to `hardware.graphics`, and `amdvlk` was
  # removed from nixpkgs -- AMD deprecated it in favour of RADV, which mesa
  # enables by default, so dropping it needs no replacement.
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    rocmPackages.rocm-runtime
  ];

  services.xserver.videoDrivers = ["amdgpu"];

  # Software like Blender may support HIP for GPU acceleration. Most software has the HIP libraries hard-coded. You can work around it on NixOS by using
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ef5e13c-1cad-4a07-a213-b6768b458c4d";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-48b947d1-eb21-4333-aaf8-48769b0cf3a4".device = "/dev/disk/by-uuid/48b947d1-eb21-4333-aaf8-48769b0cf3a4";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/75C3-A9A7";
    fsType = "vfat";
  };

  # These three data drives never carried an fsType. That used to be fine
  # because `fileSystems.<name>.fsType` defaulted to "auto"; nixpkgs has since
  # made the option mandatory (type = nonEmptyStr, no default), which is what
  # broke evaluation of this host. "auto" restores exactly the previous
  # behaviour -- mount(8) probes the type via blkid at mount time.
  #
  # The machine has been offline too long to read the real types off the
  # disks, so nothing is guessed here. Worth pinning them to concrete types
  # (the last one looks like NTFS, hence supportedFilesystems above) next time
  # it boots, so fsck ordering and the mount helpers are chosen properly.
  fileSystems."/run/media/space/ext4" = {
    device = "/dev/disk/by-uuid/c21e248c-11b2-47de-946a-892852f3c43b";
    fsType = "auto";
  };
  fileSystems."/run/media/space/New_Volume" = {
    device = "/dev/disk/by-uuid/3b6642d6-da03-4782-bcc1-a934b8294896";
    fsType = "auto";
  };
  fileSystems."/run/media/space/media" = {
    device = "/dev/disk/by-uuid/36B2588FB2585589";
    fsType = "auto";
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
