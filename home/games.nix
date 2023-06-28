{
  pkgs,
  inputs',
  ...
}: {
  home.packages = with pkgs; [
    minigalaxy
    inputs'.nix-gaming.packages.osu-lazer-bin
    inputs'.nix-gaming.packages.osu-stable
    inputs'.nix-gaming.packages.wine-discord-ipc-bridge
    #       inputs'.nix-gaming.packages..wine-ge
    gamescope
  ];
}
