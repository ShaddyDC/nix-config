{ pkgs, lib, inputs, ... }: {
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
    recommendedEnvironment = true;
  };

  programs = {
    eww-hyprland = {
      enable = true;
    };
    # swaylock = {
    #   enable = true;
    # };
  };

  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
}
