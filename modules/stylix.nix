{
  default,
  pkgs,
  ...
}: {
  stylix.image = default.wallpaper;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  stylix.fonts = let
    nerdfonts = pkgs.nerdfonts.override {fonts = ["3270" "FiraCode" "JetBrainsMono"];};
  in {
    serif = {
      package = pkgs.inter;
      name = "Inter Serif";
    };

    sansSerif = {
      package = pkgs.inter;
      name = "Inter Sans";
    };

    monospace = {
      package = nerdfonts;
      name = "3270 Sans Mono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
