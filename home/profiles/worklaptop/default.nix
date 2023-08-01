{pkgs, ...}: {
  imports = [
  ];

  wayland.windowManager.hyprland.xwayland.hidpi = true;

  home.packages = with pkgs; [
    awscli2
  ];
}
