{inputs, ...}: {
  programs.zathura = {
    enable = true;
    options = {
      font = "Lexend 12";
      selection-notification = true;

      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      pages-per-row = "1";
      scroll-page-aware = "true";
      scroll-full-overlap = "0.01";
      scroll-step = "100";
      zoom-min = "10";
    };

    extraConfig = "include catppuccin-mocha";
  };

  xdg.configFile."zathura/catppuccin-mocha".source = "${inputs.zathura-style}/src/catppuccin-mocha";
}
