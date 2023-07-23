{pkgs, ...}: {
  programs.discocss.enable = true;

  xdg.configFile."discocss/custom.css" = {
    source = pkgs.fetchurl {
      url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
      hash = "sha256-QmoUPzi4dApswZiGr8Jj2bGaGbiUHpqth+0qxlhMSPA=";
    };
  };
}
