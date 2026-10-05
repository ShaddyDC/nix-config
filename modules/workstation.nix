{
  pkgs,
  lib,
  self',
  ...
}: {
  # use Wayland where possible (electron)
  environment.variables.NIXOS_OZONE_WL = "1";

  services.resolved.settings.Resolve.FallbackDNS = ["1.1.1.1"];

  security.pam.services = {
    gdm.enableKwallet = true;
    kdm.enableKwallet = true;
    lightdm.enableKwallet = true;
    sddm.enableKwallet = true;
    slim.enableKwallet = true;

    # allow wayland lockers to unlock the screen
    gtklock.text = "auth include login";
    swaylock.text = "auth include login";
    hyprlock.text = "auth include login";
  };

  services.kanidm = {
    # Only the client is enabled here; keep it on the same version as the
    # server at idm.shaddy.dev, which reports 1.11.1 via x-kanidm-version.
    # nixpkgs removed the unversioned `kanidm` alias, so this has to be pinned.
    package = pkgs.kanidm_1_11;
    client = {
      enable = true;
      settings = {
        uri = "https://idm.shaddy.dev";
        verify_ca = true;
        verify_hostnames = true;
      };
    };
  };

  # enable location service
  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  hardware.brillo.enable = true;

  # hardware.keyboard.qmk.enable = true;

  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];

  nix = {
    settings = {
      substituters = [
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
  };

  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # Both the niri and plasma6 modules set defaultSession with mkDefault, which
  # collides. Pick explicitly; regreet still remembers the last session used.
  services.displayManager.defaultSession = "hyprland";

  # Claude Desktop self-downloads a generic-linux Claude Code binary under
  # ~/.config/Claude/claude-code/ and execs it by absolute path. The FHS wrap in
  # pkgs/claude-desktop.nix already provides a glibc loader for it, but nix-ld
  # keeps such generic dynamically-linked ELFs runnable outside the FHS sandbox
  # too (belt-and-suspenders).
  programs.nix-ld.enable = true;

  # Cowork runs its agent in a local QEMU VM; the sandbox needs vsock.
  boot.kernelModules = ["vhost_vsock"];

  # The enable* toggles were dropped upstream: monitoring, VPN and clipboard
  # paste are built in now, matugen and cava ship in the default environment,
  # and calendar events just need a backend on PATH (home-manager's
  # programs.khal provides it).
  programs.dms-shell.enable = true;

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
      niri.default = lib.mkForce ["gtk"];

      # The frontend only loads .portal backends from the user profile
      # (gnome + hyprland), so `gtk` never resolves for the Settings interface
      # and no Settings portal is exposed — apps in "system" theme mode then
      # can't see the (dark) color-scheme. Route Settings to the gnome backend,
      # which is loaded (via gnome-control-center) and reports color-scheme
      # correctly. See reference_settings_portal_broken memory.
      common."org.freedesktop.impl.portal.Settings" = ["gnome"];
      hyprland."org.freedesktop.impl.portal.Settings" = ["gnome"];
      niri."org.freedesktop.impl.portal.Settings" = ["gnome"];
    };

    extraPortals = [
      # pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      # Provides the Settings impl used above; also registers its D-Bus service.
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;

  qt = {
    enable = true;
  };

  services.clight = {
    enable = true;
    settings = {
      verbose = true;
      # dpms.timeouts = [900 300];
      dpms.disabled = true;
      dimmer.timeouts = [870 270];
      screen.disabled = true;
      backlight.no_smooth_transition = true;
      backlight.no_ddcutil = true; # Disable DDC/CI - causes errors probing non-existent monitors
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # make HM-managed GTK stuff work
  programs.dconf.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    lowLatency = {
      enable = true;
      quantum = 256;
      rate = 48000;
    };
    # DeepFilterNet denoising, replacing the old rnnoise filter-chain that
    # used to live in home/programs/rnnoise.nix. Keeping it system-side means
    # it no longer depends on home-manager activation ordering, and the
    # module wires LADSPA_PATH up for us.
    extraLadspaPackages = [pkgs.deepfilternet];
    extraConfig.pipewire."99-input-denoising"."context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "DeepFilter Noise Canceling source";
          "media.name" = "DeepFilter Noise Canceling source";

          "filter.graph".nodes = [
            {
              type = "ladspa";
              name = "DeepFilter Mono";
              plugin = "libdeep_filter_ladspa";
              label = "deep_filter_mono";
              control."Attenuation Limit (dB)" = 100;
            }
          ];

          "audio.rate" = 48000;
          "audio.position" = "[MONO]";

          # Explicit node names: without them pipewire autogenerates
          # `filter-chain-<pid>-<n>`, which changes on every restart, so
          # anything that pins this source by name loses it on reboot.
          "capture.props" = {
            "node.name" = "effect_input.deepfilter";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.deepfilter";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };

  hardware.graphics.enable = true;

  # battery info & stuff
  services.upower.enable = true;

  # needed for GNOME services outside of GNOME Desktop
  services.dbus.packages = [pkgs.gcr_3];
  services.udev.packages = with pkgs; [gnome-settings-daemon];

  programs.gamescope = {
    enable = true;
    # Vulkan WSI layer, needed for HDR/tearing control and gamescope's own
    # present path to work properly inside the nested compositor
    enableWsi = true;
    capSysNice = true;
    args = [
      "--rt"
      "--expose-wayland"
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  environment.systemPackages = with pkgs; [
    xwayland
    gpu-screen-recorder-gtk
  ];

  # Shadowplay-style recording with a replay buffer; the setuid helper the
  # module installs is what lets it capture without a portal prompt.
  programs.gpu-screen-recorder.enable = true;

  programs.localsend = {
    enable = true;
    openFirewall = false;
  };

  # age.secrets.vdirsyncer-config = {
  #   file = ../secrets/vdirsyncer.config.age;
  #   owner = config.users.users.space.name;
  # };

  services.flatpak.enable = true;
  programs.kdeconnect.enable = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-symbols

      # normal fonts
      jost
      lexend
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto
      self'.packages.berkeley-mono

      # nerdfonts
      nerd-fonts.jetbrains-mono
      nerd-fonts._3270
      nerd-fonts.fira-code
    ];

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = let
      addAll = builtins.mapAttrs (k: v: ["Symbols Nerd Font"] ++ v);
    in
      addAll {
        serif = ["Noto Serif"];
        sansSerif = ["Inter"];
        monospace = ["Berkeley Mono"];
        emoji = ["Noto Color Emoji"];
      };
  };
  # `$HOME` becomes pam_env's per-user @{HOME}. Hardcoding /home/space here
  # leaked into root's environment through sudo, so root's nix wrote its
  # cache into ~/.local/cache/nix.
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.local/cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
}
