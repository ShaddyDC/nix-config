{pkgs, ...}: {
  programs.discocss.enable = true;

  xdg.configFile."discocss/custom.css" = {
    source = pkgs.fetchurl {
      url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
      hash = "sha256-tLI8vVV717UutnesPGGeEedTO6ZMZ5KQu4CiFSWHRiM=";
    };
  };
}
