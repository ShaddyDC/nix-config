{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./config.nix
  ];

  home.packages = with pkgs; [
    jaq
    xprop
    grimblast
  ];

  wayland.windowManager.hyprland = {
    enable = true;
  };

  programs = {
    eww-hyprland = {
      enable = true;
    };
  };
}
