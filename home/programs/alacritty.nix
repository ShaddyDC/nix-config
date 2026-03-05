{
  inputs,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zellij}/bin/zellij";
        args = [
          "options"
          "--default-shell"
          "nu"
        ];
      };
    };
  };
}
