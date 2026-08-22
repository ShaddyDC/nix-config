{...}: {
  imports = [
    ./hardware-configuration.nix
    # ../../nixos/configuration.nix
    # ../../nixos/mail.nix
  ];

  networking.hostName = "framework";

  hardware.opentabletdriver.enable = true;

  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 4;
      efi.canTouchEfiVariables = true;
      # efi.efiSysMountPoint = "/boot/efi";
    };

    # Setup keyfile
    #initrd.secrets = {
    #  "/crypto_keyfile.bin" = null;
    #};

    # AMD s2idle power savings
    kernelParams = [
      # NOTE: do NOT set amd_pmc.enable_stb=1 here. It does not enable "deep
      # s2idle" -- it enables the Smart Trace Buffer, a debug facility. On this
      # board the SMU rejects the STB address command ("SMU cmd failed. err:
      # 0xff"), amd_pmc then ioremap()s physical address 0, warns, and the whole
      # amd_pmc probe fails with -12. Without amd_pmc bound the SoC never
      # reaches real hardware sleep (s0i3), which is what was causing the
      # intermittent unresponsive-on-lid-open hangs.

      # Panel self-refresh (PSR) causes hangs on Framework 13 AMD.
      # https://gitlab.freedesktop.org/drm/amd/-/issues/3647
      "amdgpu.dcdebugmask=0x10"

      "rtc_cmos.use_acpi_alarm=1" # reliable RTC wakeup
    ];
  };

  # suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  hardware.bluetooth.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.NetworkManager-wait-online.enable = false;
}
