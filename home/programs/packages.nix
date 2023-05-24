{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # office
    libreoffice
    okular
    pandoc
    calibre

    #util
    libqalculate
    kalker
    inputs.highlight-extract.packages.${pkgs.system}.highlight-extract

    # messaging & communication
    tdesktop
    discord
    zoom-us

    # torrents
    transmission-remote-gtk

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    gnome.gnome-control-center
    keepassxc
    inputs.deploy-rs.packages.${pkgs.system}.deploy-rs

    # productivity
    obsidian
    zotero
    anki

    # nix
    nil
    alejandra
  ];
}
