{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./config.nix
  ];

  home.packages = with pkgs; [
    jaq
    xorg.xprop
    inputs.hyprland-contrib.packages.${pkgs.hostPlatform.system}.grimblast
  ];

  wayland.windowManager.hyprland = {
    enable = true;
  };

  programs = {
    eww-hyprland = {
      enable = true;
    };
  };

  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
}
