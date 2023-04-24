{ inputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    "${inputs.nix-gaming}/modules/pipewireLowLatency.nix"
  ];

  options = {
    workstation.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set up as a workstation";
    };
  };

  config = {
    nixpkgs = {
      # You can add overlays here
      overlays = [
        # If you want to use overlays exported from other flakes:
        # neovim-nightly-overlay.overlays.default

        # Or define it inline, for example:
        # (final: prev: {
        #   hi = final.hello.overrideAttrs (oldAttrs: {
        #     patches = [ ./change-hello-to-hi.patch ];
        #   });
        # })
      ];
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };
    };

    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;


        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      extraOptions = ''
        plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
      '';
    };

    boot = lib.mkIf config.workstation.enable {
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

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    networking.networkmanager.enable = lib.mkIf config.workstation.enable true;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

    i18n.extraLocaleSettings = lib.mkIf config.workstation.enable {
      LC_ALL = "en_GB.UTF-8";
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    services.xserver = lib.mkIf config.workstation.enable {
      # Enable the X11 windowing system.
      enable = true;

      # Enable the KDE Plasma Desktop Environment.
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;

      # Configure keymap in X11
      layout = "de";
      xkbVariant = "";
    };

    programs.hyprland = lib.mkIf config.workstation.enable {
      enable = true;
      xwayland.hidpi = true;
    };

    # Configure console keymap
    console.keyMap = "de";

    # Enable CUPS to print documents.
    services.printing.enable = lib.mkIf config.workstation.enable true;

    # Enable sound with pipewire.
    sound.enable = lib.mkIf config.workstation.enable true;
    hardware.pulseaudio.enable = lib.mkIf config.workstation.enable false;
    security.rtkit.enable = lib.mkIf config.workstation.enable true;
    services.pipewire = lib.mkIf config.workstation.enable {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      lowLatency.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.space = lib.mkIf config.workstation.enable {
      isNormalUser = true;
      description = "space";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = [ ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      neovim
      vim
      wget
      curl
      unzip
      zip
      htop

      rclone
      zellij
      nushell
      alacritty
      python311
      git

      comma

      inputs.devenv.packages.${pkgs.system}.devenv
    ]
    ++ (lib.optionals config.workstation.enable) [
      vlc
      mpv
      zathura
      okular

      ripgrep
      youtube-dl
      gcc
      pandoc
      gdb

      inputs.agenix.packages.x86_64-linux.default
      inputs.deploy-rs.packages.${pkgs.system}.deploy-rs
      rage

      direnv
      keepassxc
      chromium

      # Nix languages
      nixpkgs-fmt
      nil
    ];

    programs.command-not-found.enable = true;
    virtualisation.podman.enable = true;

    programs.steam = lib.mkIf config.workstation.enable {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    };

    age.secrets.vdirsyncer-config = lib.mkIf config.workstation.enable {
      file = ../secrets/vdirsyncer.config.age;
      owner = config.users.users.space.name;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    programs.gnupg.agent = lib.mkIf config.workstation.enable {
      enable = true;
      enableSSHSupport = true;
    };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBrktlT4vqiq+3tzsxEpeeW2+osiDixImgYbbRVm0c+D3Qo8EYwmqqEWnfpGfg41YBzN8x4lALlW69pxBgu2URI8owDIIgI0xQL0NL69RKs32iZLj6qtx5nH5opRkAFTVLDn3WJ/04ytkIl2Ee/C137dOvQpvVfzKOcpBvTJ25owaRtN7tr3F2YHoiEalYiV7xudqiDlyX3n3hIpZQOKIGKS4ZqKZhQwbiY+zdGt+7DSLphyvE5CPdgKb0qSqsWh6y/QOPJjVI4fBJ0CZAdYMA1YjowsNmOnTejmr6n0ZLo1wHUHFddd8cKLT+GyMBR1u9hRCu/122ubYCDwO30/mZ667WbfOOELAjM6HCre4AH0eIiz20HGgBoNS62rzWsJc9+WzSbNXhNNnRqHgGfQwq5Ykr2Le9RI+M2dTm/5r259Jt2pVKUdbahq53Q61qaMP9MZ9Wy02SvW2IkuRZuaDSsFUJFx6x/K2dcbDmS4xH0H+Vdr5ismdpZoP6eiyYB9wa9+ixxye+g6ZwizP0B7VgrsZJCY/JYt/TARPBBv2kgTrhtckNj4Tlxd3XFpgPNEa+z08EKSWSUwZax/Na/+05WfBpcDtk9qDq0Nkx6DUf8xHsPVFV30NTqhxPKGFsh0cq2CuFH4QTMzhFD1eMchoqPCFQFP4wu2+whSRyjB3G5w== id_rsa"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF3eBu9/qGpIYQCDaE9dv1YHsus+3dJlanQFjNNQwq0 userme@dockerhost"
    ];

    services.tailscale.enable = true;

    services.flatpak.enable = lib.mkIf config.workstation.enable true;

    programs.kdeconnect.enable = lib.mkIf config.workstation.enable true;

    networking.firewall = {
      # enable the firewall
      enable = true;

      # # always allow traffic from your Tailscale network
      # trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [ 22 ];
    };


    fonts.fonts = with pkgs; lib.mkIf config.workstation.enable [
      carlito
      dejavu_fonts
      ipafont
      kochi-substitute
      source-code-pro
      ttf_bitstream_vera
      (nerdfonts.override { fonts = [ "3270" "JetBrainsMono" ]; })
    ];
    #   fonts.fontconfig.defaultFonts = {
    #     monospace = [
    #       "JetBrainsMono"
    #       "IPAGothic"
    #     ];
    #     sansSerif = [
    #       "DejaVu Sans"
    #       "IPAPGothic"
    #     ];
    #     serif = [
    #       "DejaVu Serif"
    #       "IPAPMincho"
    #     ];
    #   };
    #   i18n = {
    #     inputMethod = {
    #       enabled = "fcitx5";
    #       fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    #       fcitx5.addons = with pkgs; [
    #         fcitx5-mozc
    #         fcitx5-gtk
    #       ];
    #     };
    #   };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };
}
