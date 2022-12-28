# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "space";
    homeDirectory = "/home/space";
  };

  # Add stuff for your user as you see fit:
  programs.neovim.enable = true;
  # home.packages = with pkgs; [ rclone ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "ShaddyDC";
    userEmail = "shaddythefirst@gmail.com";
    difftastic.enable = true;
  };
  programs.lazygit.enable = true;

  programs.helix.enable = true;

  programs.java.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "/run/current-system/sw/bin/zellij";
        args = [
          "options" "--default-shell" "nu"
        ];
      };
      font.normal.style = "JetBrains Mono";
      font.size = 8;
    };
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };


  programs.starship = {
    enable = true;
    # TODO remove from here and nushell configs when starship 0.12
    enableNushellIntegration = false;
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.pueue.enable = true;

  systemd.user.services."rclone_gdrive.service" = {
    Unit = {
      Description = "Remote FUSE filesystem for cloud storage";
      Wants = "network-online.target";
      After = "network-online.target";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "notify";
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = " \\
        /run/current-system/sw/bin/rclone mount \\
          --config=%h/.config/rclone/rclone.conf \\
          --vfs-cache-mode writes \\
          --vfs-cache-max-size 100M \\
          --log-file /tmp/rclone-%i.log \\
          gdrive: %h/mnt/gdrive \\
      ";
      ExecStop = "/run/current-system/sw/bin/rclone -u %h/mnt/%i";
    };
  };

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "git.rwth-aachen.de" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "devps" = {
      user = "root";
      hostname = "88.198.105.181";
      identityFile = "~/.ssh/id_rsa.pub";
    };

  };

  home.file.".ssh/id_rsa.pub".source = ./id_rsa.pub;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
