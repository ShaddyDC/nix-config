{pkgs, ...}:
# nix tooling
{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
    manix
    nix-du
    # self.packages.${pkgs.hostPlatform.system}.repl
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };
}
