{
  inputs',
  pkgs,
  self',
  ...
}: {
  # use Wayland where possible (electron)
  environment.variables.NIXOS_OZONE_WL = "1";

  services.resolved.fallbackDns = ["1.1.1.1"];

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
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs'.hyprland.packages.hyprland;
  };

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  qt = {
    enable = true;
  };

  services.clight = {
    enable = true;
    settings = {
      verbose = true;
      dpms.timeouts = [900 300];
      dimmer.timeouts = [870 270];
      screen.disabled = true;
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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    lowLatency.enable = true;
  };

  hardware.graphics.enable = true;

  # battery info & stuff
  services.upower.enable = true;

  # needed for GNOME services outside of GNOME Desktop
  services.dbus.packages = [pkgs.gcr];
  services.udev.packages = with pkgs; [gnome-settings-daemon];

  programs.gamescope = {
    enable = true;
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

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-symbols

      # normal fonts
      jost
      lexend
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
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
  environment.sessionVariables = {
    XDG_CACHE_HOME = "/home/space/.local/cache";
    XDG_CONFIG_HOME = "/home/space/.config";
    XDG_DATA_HOME = "/home/space/.local/share";
    XDG_STATE_HOME = "/home/space/.local/state";
  };
}
