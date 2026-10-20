{
  pkgs,
  inputs',
  self',
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
    # bottles
    streamlink
    ripdrag

    # messaging & communication
    telegram-desktop
    discord
    webcord
    vesktop

    # ai — official Linux build, vendored in pkgs/claude-desktop.nix
    self'.packages.claude-desktop

    # misc
    libnotify
    wineWow64Packages.wayland
    xdg-utils
    gnome-control-center
    keepassxc

    # productivity
    obsidian
    # zotero # bundles Firefox ESR 140, EOL since 2026-10-13; re-enable once it moves on
    anki

    # security
    proton-vpn

    # nix
    nil
    alejandra
  ];
}
