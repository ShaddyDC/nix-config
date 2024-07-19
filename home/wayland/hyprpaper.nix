{
  inputs',
  default,
  ...
}: {
  services.hyprpaper = {
    enable = true;
    package = inputs'.hyprpaper.packages.default;

    settings = {
      preload = ["${default.wallpaper}"];
      wallpaper = [", ${default.wallpaper}"];
    };
  };
}
