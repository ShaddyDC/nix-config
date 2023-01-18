{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./mail.nix
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
  home.packages = with pkgs; [
    discord
    steam
    urlscan
    obsidian
    calibre
    elinks
    inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin
    inputs.nix-gaming.packages.${pkgs.system}.osu-stable
    inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
    inputs.nix-gaming.packages.${pkgs.system}.wine-ge
  ];


  programs.zathura.enable = true;
  programs.feh.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "ShaddyDC";
    userEmail = "shaddythefirst@gmail.com";
    difftastic.enable = true;
  };
  programs.lazygit.enable = true;
  programs.bat.enable = true;

  programs.helix.enable = true;

  programs.java.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${pkgs.zellij}/bin/zellij";
        args = [
          "options"
          "--default-shell"
          "nu"
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
    settings = { };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # services.pueue.enable = true;

  # TODO Create directory ~/mnt/gdrive
  systemd.user.services."rclone_gdrive" = {
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
        ${pkgs.rclone}/bin/rclone mount \\
          --config=%h/.config/rclone/rclone.conf \\
          --vfs-cache-mode writes \\
          --vfs-cache-max-size 100M \\
          --log-file /tmp/rclone-%i.log \\
          gdrive: %h/mnt/gdrive \\
      ";
      ExecStop = "${pkgs.rclone}/bin/rclone -u %h/mnt/%i";
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
