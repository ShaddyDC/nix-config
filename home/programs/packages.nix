{
  pkgs,
  inputs',
  self',
  ...
}: {
  home.packages = with pkgs; [
    # office
    libreoffice
    okular
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
    tdesktop
    discord
    webcord

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    gnome.gnome-control-center
    keepassxc
    inputs'.deploy-rs.packages.deploy-rs

    # productivity
    self'.packages.obsidian_oop
    zotero
    anki

    # nix
    nil
    alejandra
  ];
}
