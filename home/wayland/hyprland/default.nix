{
  pkgs,
  lib,
  ...
}: let
  # `exec-once` has no direct equivalent in the Lua config: calling
  # hl.exec_cmd at the top level would re-run on every config reload, so the
  # startup commands hang off the hyprland.start event instead.
  startupCommands = [
    "obsidian & firefox"
    "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1"
    # Hands the login password that pam_kwallet captured at the greeter to
    # ksecretd, which unlocks the wallet (the session's Secret Service).
    "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
    "${lib.getExe pkgs.networkmanagerapplet} --indicator"
    (lib.getExe pkgs.ianny)
  ];

  # DMS rewrites these at runtime (matugen colours, layout, outputs, cursor
  # and window rules). They have to load *after* our own settings so DMS wins.
  dmsFragments = ["colors" "layout" "outputs" "cursor" "windowrules"];
in {
  imports = [
    ./config.nix
  ];

  home.packages = with pkgs; [
    jaq
    xprop
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # DMS 1.6.2 dropped the hyprlang fragments for Hyprland: it now writes
    # dms/{colors,layout,outputs,cursor,windowrules}.lua and looks for
    # ~/.config/hypr/hyprland.lua, so hyprlang no longer gets DMS's output.
    configType = "lua";

    extraConfig = ''
      -- Startup commands (the hyprlang `exec-once` equivalent).
      hl.on("hyprland.start", function()
      ${lib.concatMapStringsSep "\n" (c: "  hl.exec_cmd(${builtins.toJSON c})") startupCommands}
      end)

      -- DMS runtime fragments. require() needs ~/.config/hypr on package.path;
      -- the module only sets that up when extraLuaFiles is used.
      local hyprDir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr"
      package.path = hyprDir .. "/?.lua;" .. hyprDir .. "/?/init.lua;" .. package.path

      for _, fragment in ipairs({${lib.concatMapStringsSep ", " (f: "\"dms.${f}\"") dmsFragments}}) do
        -- A fragment DMS has not written yet is not an error.
        pcall(require, fragment)
      end
    '';
  };

  # Create DMS runtime config directory with empty placeholders
  # These files are written by DMS at runtime (dynamic theming, etc.)
  # but must exist for the require() calls above
  home.activation.createDmsHyprConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.config/hypr/dms"
    for f in ${lib.concatMapStringsSep " " (f: "${f}.lua") dmsFragments}; do
      [ -f "$HOME/.config/hypr/dms/$f" ] || touch "$HOME/.config/hypr/dms/$f"
    done
  '';
}
