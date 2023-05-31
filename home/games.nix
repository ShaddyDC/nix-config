{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    minigalaxy
    inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin
    inputs.nix-gaming.packages.${pkgs.system}.osu-stable
    inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
    #       inputs.nix-gaming.packages.${pkgs.system}.wine-ge
    gamescope
  ];
}
