{
  default,
  ...
}: {
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = ["${default.wallpaper}"];
      wallpaper = [", ${default.wallpaper}"];
    };
  };
}
