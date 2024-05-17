{default, ...}: let
  font_family = "Inter";
in {
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = false;
        grace = 5;
      };

      backgrounds = [
        {
          path = "screenshot";
          blur_passes = 3;
          color = "rgba(25, 20, 20, 1.0)";
        }
      ];

      images = [
        {
          path = "${default.wallpaper}";
        }
      ];

      input-fields = [
        {
          placeholder_text = ''<span font_family="${font_family}">Password...</span>'';
        }
      ];

      labels = [
        {
          text = "$TIME";
          inherit font_family;
          font_size = 50;
        }
      ];
    };
  };
}
