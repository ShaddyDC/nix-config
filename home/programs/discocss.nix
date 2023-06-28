{pkgs, ...}: {
  programs.discocss.enable = true;

  xdg.configFile."discocss/custom.css" = {
    source = pkgs.fetchurl {
      url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
      hash = "sha256-4n2tkJy4jkoMuTQnk0ZNFxm8UPrbKrTLBXVVEAY2Y1s=";
    };
  };
}
