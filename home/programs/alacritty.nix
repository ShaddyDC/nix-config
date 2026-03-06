{
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${pkgs.zellij}/bin/zellij";
        args = [
          "options"
          "--default-shell"
          "nu"
        ];
      };
    };
  };
}
