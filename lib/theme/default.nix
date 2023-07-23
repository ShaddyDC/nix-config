{...}: {
  browser = "firefox";

  launcher = "anyrun";

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://images.unsplash.com/photo-1529840882932-55f06ab2c681";
    sha256 = "1xngx610skv1vqzx1c7j2zv5cg3gld3hkcxki8jd30rssjjx98p2";
  };
}
