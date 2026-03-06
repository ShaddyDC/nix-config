{
  theme,
  ...
}: {
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = ["${theme.wallpaper}"];
      wallpaper = [", ${theme.wallpaper}"];
    };
  };
}
