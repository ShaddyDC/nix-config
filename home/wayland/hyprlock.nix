{theme, ...}: let
  font_family = "Inter";
in {
  programs.hyprlock = {
    enable = true;

    # NOTE: the widget sections are singular (`background`, `image`,
    # `input-field`, `label`). Plural names parse as unknown options, and
    # hyprlock then logs "Proceeding ignoring faulty entries" and locks the
    # session with nothing drawn at all -- a black screen with only a cursor,
    # and no visible way to authenticate. Validate changes with:
    #   hyprlock --display nonexistent -c ~/.config/hypr/hyprlock.conf
    # which parses the config and exits without touching the real session.
    settings = {
      general = {
        hide_cursor = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          color = "rgba(25, 20, 20, 1.0)";
        }
      ];

      image = [
        {
          path = "${theme.wallpaper}";
        }
      ];

      input-field = [
        {
          placeholder_text = ''<span font_family="${font_family}">Password...</span>'';
        }
      ];

      label = [
        {
          text = "$TIME";
          inherit font_family;
          font_size = 50;
        }
      ];
    };
  };
}
