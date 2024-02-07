{pkgs, ...}: {
  # notification daemon
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    settings = {
      fullscreen_delay_everything = {fullscreen = "delay";};

      # urgency_critical = {
      #   background = default.xcolors.bg;
      #   foreground = default.xcolors.fg;
      #   frame_color = default.xcolors.red;
      # };
      # urgency_low = {
      #   background = default.xcolors.bg;
      #   foreground = default.xcolors.fg;
      #   frame_color = default.xcolors.blue;
      # };
      # urgency_normal = {
      #   background = default.xcolors.bg;
      #   foreground = default.xcolors.fg;
      #   frame_color = default.xcolors.green;
      # };
    };
  };
}
