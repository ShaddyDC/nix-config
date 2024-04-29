{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./files
    ./media.nix
    ./discocss.nix
    ./dunst.nix
    ./git.nix
    ./gtk.nix
    ./kitty.nix
    ./media.nix
    ./packages.nix
    ./ssh.nix
    ./vdirsyncer.nix
    ./vscode.nix
    ./xdg.nix
    ./zathura.nix
  ];

  systemd.user.services.kdeconnect = {
    Unit.Description = "KDEConnect Service";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdeconnect}/bin/kdeconnect-indicator";
      TimeoutStopSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  programs = {
    chromium = {
      enable = true;
      commandLineArgs = ["--enable-features=TouchpadOverscrollHistoryNavigation"];
      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
        {id = "bkkmolkhemgaeaeggcmfbghljjjoofoh";}
      ];
    };

    firefox = {
      enable = true;
      profiles.shaddy = {};
      package = pkgs.firefox.override {
        nativeMessagingHosts = [
          pkgs.tridactyl-native
        ];
      };
    };

    # gpg = {
    #   enable = true;
    #   homedir = "${config.xdg.dataHome}/gnupg";
    # };

    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
      settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };

    java.enable = true;

    rofi.enable = true;
  };

  services = {
    caffeine.enable = true;
    batsignal.enable = true;
  };

  programs.eww-hyprland = {
    enable = true;
    package = inputs.eww.packages.${pkgs.hostPlatform.system}.eww;
  };

  programs.alacritty.enable = true;

  stylix.targets.kde.enable = false;
}
