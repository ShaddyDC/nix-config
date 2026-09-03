{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./config.nix
  ];

  home.packages = with pkgs; [
    jaq
    xprop
    grimblast
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # The default flipped to "lua" for stateVersion >= 26.05. Everything in
    # ./config.nix is written as hyprlang strings ("$mod, S, submap, resize",
    # "env = KEY,VALUE", the windowrule list), which the lua backend does not
    # accept as-is, so pin the old backend rather than let the state version
    # decide.
    configType = "hyprlang";
  };

  # Create DMS runtime config directory with empty placeholders
  # These files are written by DMS at runtime (dynamic theming, etc.)
  # but must exist for Hyprland's source directive
  home.activation.createDmsHyprConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.config/hypr/dms"
    for f in colors.conf layout.conf outputs.conf cursor.conf; do
      [ -f "$HOME/.config/hypr/dms/$f" ] || touch "$HOME/.config/hypr/dms/$f"
    done
  '';
}
