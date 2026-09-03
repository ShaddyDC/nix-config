{pkgs, ...}: {
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

  # Disable the SuperSpeed (USB 3.x) half of the left-side expansion slot that
  # holds the HDMI Expansion Card.
  #
  # Why: that port intermittently wedges and the xHCI driver then retries
  # enumeration forever, once per minute:
  #     usb usb2-port2: Cannot enable. Maybe the USB cable is bad?
  # Once that loop is running, the next s2idle suspend hangs hard -- the journal
  # ends at "PM: suspend entry (s2idle)" and only a power-button hold recovers.
  # It also pins the parent xHCI controller 0000:c1:00.3 at D0 forever
  # (runtime_suspended_time stays 0) while its sibling reaches D3cold.
  #
  # Measured over one 9-day boot (2026-08-15 .. 2026-08-24):
  #     card out: 812 suspends, 812 resumes, 0 hangs,   0 "Cannot enable"
  #     card in :   2 suspends,   1 resume,  1 hang,  106 "Cannot enable"
  #
  # The HDMI card enumerates on the USB 2.0 root hub (usb1-2) and drives video
  # over DisplayPort alt mode, neither of which uses this SuperSpeed port, so
  # disabling it leaves the card fully working. Cost: that one slot is limited
  # to USB 2.0 speeds, which matters only if a storage/USB-A card is put there.
  #
  # Not a udev rule: usb_port devices report SUBSYSTEM=="" and do not reliably
  # generate udev events. Keyed on the PCI address, which is stable, rather than
  # the usbN bus number, which is assigned by controller probe order.
  systemd.services.disable-hdmi-slot-superspeed = {
    description = "Disable wedging SuperSpeed port on the HDMI expansion slot";
    wantedBy = ["multi-user.target"];
    after = ["sysinit.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      shopt -s nullglob
      for hub in /sys/bus/pci/devices/0000:c1:00.3/usb*; do
        [ -e "$hub/speed" ] || continue
        [ "$(cat "$hub/speed")" -ge 5000 ] 2>/dev/null || continue
        name=$(basename "$hub")
        port="$hub/''${name#usb}-0:1.0/$name-port2"
        if [ -w "$port/disable" ]; then
          echo 1 > "$port/disable"
          echo "disabled $port"
          exit 0
        fi
      done
      echo "SuperSpeed port not found under 0000:c1:00.3; nothing disabled" >&2
    '';
    path = [pkgs.coreutils];
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
