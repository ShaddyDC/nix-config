{ inputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # "${inputs.nix-gaming}/modules/pipewireLowLatency.nix"
  ];


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

    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };


    package = pkgs.nixFlakes;
    extraOptions = ''
      plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
    '';
  };


  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
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


  # Configure console keymap
  console.keyMap = "de";



  # # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.space = lib.mkIf config.workstation.enable {
  #   isNormalUser = true;
  #   description = "space";
  #   extraGroups = [ "networkmanager" "wheel" "video" ];
  #   packages = [ ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.command-not-found.enable = true;
  virtualisation.podman.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBrktlT4vqiq+3tzsxEpeeW2+osiDixImgYbbRVm0c+D3Qo8EYwmqqEWnfpGfg41YBzN8x4lALlW69pxBgu2URI8owDIIgI0xQL0NL69RKs32iZLj6qtx5nH5opRkAFTVLDn3WJ/04ytkIl2Ee/C137dOvQpvVfzKOcpBvTJ25owaRtN7tr3F2YHoiEalYiV7xudqiDlyX3n3hIpZQOKIGKS4ZqKZhQwbiY+zdGt+7DSLphyvE5CPdgKb0qSqsWh6y/QOPJjVI4fBJ0CZAdYMA1YjowsNmOnTejmr6n0ZLo1wHUHFddd8cKLT+GyMBR1u9hRCu/122ubYCDwO30/mZ667WbfOOELAjM6HCre4AH0eIiz20HGgBoNS62rzWsJc9+WzSbNXhNNnRqHgGfQwq5Ykr2Le9RI+M2dTm/5r259Jt2pVKUdbahq53Q61qaMP9MZ9Wy02SvW2IkuRZuaDSsFUJFx6x/K2dcbDmS4xH0H+Vdr5ismdpZoP6eiyYB9wa9+ixxye+g6ZwizP0B7VgrsZJCY/JYt/TARPBBv2kgTrhtckNj4Tlxd3XFpgPNEa+z08EKSWSUwZax/Na/+05WfBpcDtk9qDq0Nkx6DUf8xHsPVFV30NTqhxPKGFsh0cq2CuFH4QTMzhFD1eMchoqPCFQFP4wu2+whSRyjB3G5w== id_rsa"
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF3eBu9/qGpIYQCDaE9dv1YHsus+3dJlanQFjNNQwq0 userme@dockerhost"
  ];

  services.tailscale.enable = true;

  networking.firewall = {
    # enable the firewall
    enable = true;

    # # always allow traffic from your Tailscale network
    # trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
