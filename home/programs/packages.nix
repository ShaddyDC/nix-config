{ pkgs
, inputs
, ...
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
  ];
}
