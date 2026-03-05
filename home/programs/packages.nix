{
  pkgs,
  inputs',
  ...
}: {
  home.packages = with pkgs; [
    # office
    libreoffice
    kdePackages.okular
    pandoc
    calibre
    gnucash

    #util
    libqalculate
    kalker
    inputs'.agenix.packages.default
    bottles
    streamlink
    ripdrag

    # messaging & communication
    telegram-desktop
    discord
    webcord
    vesktop

    # misc
    libnotify
    wineWow64Packages.wayland
    xdg-utils
    gnome-control-center
    keepassxc
    inputs'.deploy-rs.packages.deploy-rs

    # productivity
    obsidian
    zotero
    anki

    # security
    protonvpn-gui

    # nix
    nil
    alejandra
  ];
}
