{lib, ...}: rec {
  browser = "firefox";

  launcher = "anyrun";

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://images.unsplash.com/photo-1529840882932-55f06ab2c681";
    sha256 = "1rdkal6ry2g9i2i6aisg5j0a234m2sz1xyj3h8mdkmq981q90y5k";
  };
}
