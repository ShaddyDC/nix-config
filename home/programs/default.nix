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
    ./dunst.nix
    ./git.nix
    ./gtk.nix
    ./kitty.nix
    ./media.nix
    ./packages.nix
    ./ssh.nix
    # ./vdirsyncer.nix
    ./vscode.nix
    ./xdg.nix
    ./zathura.nix
  ];

  systemd.user.services.kdeconnect = {
    Unit.Description = "KDEConnect Service";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator";
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

      # The default flipped to "$XDG_CONFIG_HOME/mozilla/firefox" for
      # stateVersion >= 26.05. Moving to it means relocating the existing 4 GB
      # profile by hand (and native messaging hosts do not follow), so stay on
      # the classic path explicitly.
      configPath = ".mozilla/firefox";
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

  programs.alacritty.enable = true;
}
