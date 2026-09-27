{
  pkgs,
  inputs',
  ...
}: {
  home.packages = with pkgs; [
    # minigalaxy
    # The default PIPEWIRE_LATENCY is 64/44100, which neither matches the
    # 48kHz graph rate set in modules/workstation.nix nor leaves enough
    # headroom -- it crackles. 128/48000 is still low latency, no resampling.
    (inputs'.nix-gaming.packages.osu-lazer-bin.override {pipewire_latency = "128/48000";})
    # inputs'.nix-gaming.packages.osu-stable
    # inputs'.nix-gaming.packages.wine-discord-ipc-bridge
    #       inputs'.nix-gaming.packages..wine-ge
    gamescope
    tetrio-desktop
  ];
}
