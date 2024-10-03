{pkgs, ...}: let
  defaultKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBrktlT4vqiq+3tzsxEpeeW2+osiDixImgYbbRVm0c+D3Qo8EYwmqqEWnfpGfg41YBzN8x4lALlW69pxBgu2URI8owDIIgI0xQL0NL69RKs32iZLj6qtx5nH5opRkAFTVLDn3WJ/04ytkIl2Ee/C137dOvQpvVfzKOcpBvTJ25owaRtN7tr3F2YHoiEalYiV7xudqiDlyX3n3hIpZQOKIGKS4ZqKZhQwbiY+zdGt+7DSLphyvE5CPdgKb0qSqsWh6y/QOPJjVI4fBJ0CZAdYMA1YjowsNmOnTejmr6n0ZLo1wHUHFddd8cKLT+GyMBR1u9hRCu/122ubYCDwO30/mZ667WbfOOELAjM6HCre4AH0eIiz20HGgBoNS62rzWsJc9+WzSbNXhNNnRqHgGfQwq5Ykr2Le9RI+M2dTm/5r259Jt2pVKUdbahq53Q61qaMP9MZ9Wy02SvW2IkuRZuaDSsFUJFx6x/K2dcbDmS4xH0H+Vdr5ismdpZoP6eiyYB9wa9+ixxye+g6ZwizP0B7VgrsZJCY/JYt/TARPBBv2kgTrhtckNj4Tlxd3XFpgPNEa+z08EKSWSUwZax/Na/+05WfBpcDtk9qDq0Nkx6DUf8xHsPVFV30NTqhxPKGFsh0cq2CuFH4QTMzhFD1eMchoqPCFQFP4wu2+whSRyjB3G5w== id_rsa";
  # homeserverKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF3eBu9/qGpIYQCDaE9dv1YHsus+3dJlanQFjNNQwq0 userme@dockerhost";
  workLaptopKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEAV3cjJeQmfvad7Cyh9h8UoSGu98z2D6Cv5M9X65nc space@nixos";
  termiusKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGP3QhWoHYdByhRE/vDYP0Xv7KX4uGdvtnwS09ymnsVF";
  frameworkKey = " ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESUb8bTFKNUebogL10sjPmmpIa2vubrtnPfuiwvmh0s space@nixos";
in {
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n = {
    # Select internationalisation properties.
    defaultLocale = "en_GB.UTF-8";
    # supportedLocales = ["en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8"];

    extraLocaleSettings = {
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
  };

  # Configure console keymap
  console.keyMap = "de";

  networking = {
    # required to connect to Tailscale exit nodes
    firewall.checkReversePath = "loose";

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = true;
    };
  };

  programs = {
    less.enable = true;
  };

  virtualisation.podman.enable = true;

  services = {
    fail2ban.enable = true;

    openssh = {
      enable = true;
    };

    # DNS resolver
    resolved.enable = true;

    # inter-machine VPN
    tailscale.enable = true;
  };

  # services.smartd.enable = true;

  # # Don't wait for network startup
  # # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
  # systemd = {
  #   targets.network-online.wantedBy = pkgs.lib.mkForce []; # Normally ["multi-user.target"]
  #   services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce []; # Normally ["network-online.target"]
  # };

  # don't ask for password for wheel group
  security.sudo.wheelNeedsPassword = false;

  users.users.space = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = ["input" "libvirtd" "networkmanager" "video" "wheel"];

    openssh.authorizedKeys.keys = [defaultKey workLaptopKey termiusKey frameworkKey];
  };

  users.users.root.openssh.authorizedKeys.keys = [defaultKey workLaptopKey frameworkKey];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
