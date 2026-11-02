{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Fingerprint for sudo and polkit prompts. Enabling fprintd puts it in front
  # of every PAM service, so take it back out of the login paths: those unlock
  # the GNOME keyring, which needs the actual password. The DMS lock screen
  # derives its password stack from `login` and runs fprintd in a parallel PAM
  # context of its own (`enableFprint` in its settings).
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = false;
    greetd.fprintAuth = false;
  };
  # The lock screen keeps a verify running, so suspend always interrupts one
  # ("Cannot run while suspended"). pam_fprintd's ReleaseDevice then fails
  # ("still busy"), the claim outlives the client, and after resume every Claim
  # fails at once: PAM code 9, DMS gives up after two tries and shows an error.
  # Stopping the daemon drops the claim; DMS's post-resume attempt D-Bus
  # activates a fresh one.
  powerManagement.powerDownCommands = ''
    systemctl stop fprintd.service
  '';
  # Passwordless sudo made any user-level compromise root; ask for a finger
  # (or the password, after Ctrl+C) instead.
  security.sudo.wheelNeedsPassword = true;

  # The laptop joins untrusted networks; only reach its LAN services over
  # Tailscale. The kdeconnect module opens its range with no opt-out, and it is
  # the only contributor to the port-range lists left once steam's is off.
  programs.steam.remotePlay.openFirewall = lib.mkForce false;
  programs.ausweisapp.openFirewall = lib.mkForce false;
  networking.firewall = {
    allowedTCPPortRanges = lib.mkForce [];
    allowedUDPPortRanges = lib.mkForce [];
    interfaces.tailscale0 = {
      # Steam Remote Play (27036 is also its discovery port)
      allowedTCPPorts = [27036 27037];
      allowedUDPPorts = [10400 10401 27036];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
        {
          from = 27031;
          to = 27035;
        } # Steam Remote Play
      ];
    };
  };

  networking.hostName = "framework";

  # Secure Boot key management and `sbctl verify`; see boot.lanzaboote below
  environment.systemPackages = [pkgs.sbctl];

  hardware.opentabletdriver.enable = true;

  boot = {
    # TEMPORARY: nixpkgs now merges a per-module `.ko.cer` for every external
    # module, but framework-laptop-kmod still copies the bare .ko, so the
    # modules tree fails to build ("extra/framework_laptop.ko.cer: No such
    # file"). nixpkgs master already switched it to `modules_install`; mirror
    # that and drop this once it reaches nixos-unstable.
    kernelPackages = pkgs.linuxPackages.extend (_: prev: {
      framework-laptop-kmod = prev.framework-laptop-kmod.overrideAttrs (old: {
        makeFlags =
          old.makeFlags
          ++ [
            "INSTALL_MOD_PATH=${placeholder "out"}"
            "INSTALL_MOD_DIR=extra"
            "DEPMOD=true"
          ];
        installTargets = ["modules_install"];
        installPhase = null;
      });
    });

    # Bootloader. Lanzaboote replaces the systemd-boot module (it still boots
    # through systemd-boot) and signs every UKI it writes with the keys in
    # /var/lib/sbctl, made with `sbctl create-keys` and enrolled with
    # `sbctl enroll-keys --microsoft --firmware-builtin`. The firmware-builtin
    # keys are Framework's, which its firmware updates are signed with.
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader = {
      systemd-boot.enable = false;
      # read by lanzaboote's own configurationLimit
      systemd-boot.configurationLimit = 4;
      efi.canTouchEfiVariables = true;
      # efi.efiSysMountPoint = "/boot/efi";
    };

    # Setup keyfile
    #initrd.secrets = {
    #  "/crypto_keyfile.bin" = null;
    #};

    # NOTE: do NOT add amd_pmc.enable_stb=1 to kernelParams. It does not
    # enable "deep s2idle" -- it enables the Smart Trace Buffer, a debug
    # facility. On this board the SMU rejects the STB address command ("SMU
    # cmd failed. err: 0xff"), amd_pmc then ioremap()s physical address 0,
    # warns, and the whole amd_pmc probe fails with -12. Without amd_pmc bound
    # the SoC never reaches real hardware sleep (s0i3), which is what was
    # causing the intermittent unresponsive-on-lid-open hangs.
    #
    # The PSR workaround (amdgpu.dcdebugmask=0x10) comes from the
    # nixos-hardware module above. rtc_cmos.use_acpi_alarm=1 is no longer
    # set: it only works around a bug fixed in Linux 6.8.
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
