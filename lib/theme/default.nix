{...}: {
  browser = "firefox";

  launcher = "anyrun";

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://pngfreepic.com/wp-content/uploads/2021/02/background-png-freepic-24.png";
    sha256 = "0972wjwcykznxkd6i4p9d61a7b5ddqqrynrlcl36kwvgcyn49g0r";
  };
}
