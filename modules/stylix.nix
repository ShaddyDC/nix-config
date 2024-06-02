{
  default,
  pkgs,
  self',
  ...
}: {
  stylix.image = default.wallpaper;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  stylix.fonts = {
    serif = {
      package = pkgs.inter;
      name = "Inter Serif";
    };

    sansSerif = {
      package = pkgs.inter;
      name = "Inter Sans";
    };

    monospace = {
      package = self'.packages.berkeley-mono;
      name = "Berkeley Mono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
