{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration.nix
    ../../nixos/mail.nix
  ];

  networking.hostName = "spacelaptop";

  hardware.bluetooth.enable = true;
  workstation.enable = true;
  services.upower.enable = true;
  programs.dconf.enable = true;
  # needed for GNOME services outside of GNOME Desktop
  services.dbus.packages = [ pkgs.gcr ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  security.polkit.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
