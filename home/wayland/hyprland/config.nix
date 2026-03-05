{
  pkgs,
  inputs',
  lib,
  config,
  ...
}: let
  screenshotarea = "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";

  recordScript = pkgs.writeShellScriptBin "screen-record" ''
    # Default output directory
    OUTPUT_DIR="$HOME/Videos/Recordings"
    mkdir -p "$OUTPUT_DIR"

    # Generate output filename with timestamp
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT_FILE="$OUTPUT_DIR/recording_$TIMESTAMP.mp4"

    # Get the screen area coordinates using slurp
    GEOMETRY=$(${pkgs.slurp}/bin/slurp -d)
    if [ -z "$GEOMETRY" ]; then
        ${pkgs.libnotify}/bin/notify-send "Recording" "Selection cancelled"
        exit 1
    fi

    # Set up trap to handle notifications and clipboard
    trap '${pkgs.libnotify}/bin/notify-send "Recording" "Saved to $OUTPUT_FILE"; ${pkgs.wl-clipboard}/bin/wl-copy < "$OUTPUT_FILE"; exit 0' INT TERM

    # Notify recording start
    ${pkgs.libnotify}/bin/notify-send "Recording" "Started recording selected area (press Ctrl+C to stop)"

    # Start recording with wf-recorder
    ${pkgs.wf-recorder}/bin/wf-recorder -g "$GEOMETRY" -f "$OUTPUT_FILE"

    # These will run after Ctrl+C stops wf-recorder
    ${pkgs.libnotify}/bin/notify-send "Recording" "Saved to $OUTPUT_FILE"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$OUTPUT_FILE"
  '';

  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10);
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    env = [
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_QPA_PLATFORM,wayland"
      "SDL_VIDEODRIVER,wayland"
      "XDG_SESSION_TYPE,wayland"
      "XCURSOR_SIZE,24"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "TERMINAL,kitty"
    ];

    exec-once = [
      "obsidian & firefox"
      "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1"
      "/nix/store/$(ls -la /nix/store | grep 'kwallet-pam' | grep '4096' | awk '{print $9}' | sed -n '$p')/libexec/pam_kwallet_init && ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      "${lib.getExe pkgs.ianny}"
    ];
    input = {
      kb_layout = "de";

      force_no_accel = true;
      natural_scroll = false;
      follow_mouse = 1;
      accel_profile = "flat";

      touchpad = {
        natural_scroll = true;
      };
      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;

      layout = "dwindle";
    };

    decoration = {
      rounding = 12;

      active_opacity = 1.0;
      inactive_opacity = 1.0;

      shadow = {
        enabled = true;
        range = 30;
        render_power = 5;
        offset = "0 5";
        color = "rgba(00000070)";
      };
    };

    permission = [
      # Allow xdph and grim
      "${config.wayland.windowManager.hyprland.portalPackage}/libexec/.xdg-desktop-portal-hyprland-wrapped, screencopy, allow"
      "${lib.getExe pkgs.grim}, screencopy, allow"

      # Optionally allow non-pipewire capturing
      "${lib.getExe pkgs.wl-screenrec}, screencopy, allow"
    ];

    animations = {
      enabled = true;

      animation = [
        "windowsIn, 1, 3, default"
        "windowsOut, 1, 3, default"
        "workspaces, 1, 5, default"
        "windowsMove, 1, 4, default"
        "fade, 1, 3, default"
        "border, 1, 3, default"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
    };

    gesture = [
      "3, horizontal, workspace"
    ];

    misc = {
      disable_autoreload = true;
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
    render.direct_scanout = true;

    monitor = [
      "desc:Hisense Electric Co. Ltd. HISENSE 0x676C626C,preferred,auto,2.5"
    ];

    source = [
      "~/.config/hypr/dms/colors.conf"
      "~/.config/hypr/dms/layout.conf"
      "~/.config/hypr/dms/outputs.conf"
      "~/.config/hypr/dms/cursor.conf"
    ];

    bind =
      [
        # === Application Launchers ===
        "$mod, T, exec, kitty"
        "$mod, SPACE, exec, dms ipc call spotlight toggle"
        "$mod, V, exec, dms ipc call clipboard toggle"
        "$mod, M, exec, dms ipc call processlist focusOrToggle"
        "$mod, comma, exec, dms ipc call settings focusOrToggle"
        "$mod, N, exec, dms ipc call notifications toggle"
        "$mod SHIFT, N, exec, dms ipc call notepad toggle"
        "$mod, Y, exec, dms ipc call dankdash wallpaper"
        "$mod, TAB, exec, dms ipc call hypr toggleOverview"
        "$mod, X, exec, dms ipc call powermenu toggle"
        "$mod, E, exec, dolphin"
        "$mod, O, exec, wl-ocr"

        # === Cheat sheet ===
        "$mod SHIFT, ssharp, exec, dms ipc call keybinds toggle hyprland"

        # === Security ===
        "$mod, L, exec, dms ipc call lock lock"
        "CTRL ALT, Delete, exec, dms ipc call processlist focusOrToggle"

        # === Window Management ===
        "$mod, Q, killactive"
        "ALT, F4, killactive"
        "$mod SHIFT, E, exit"
        "$mod, F, fullscreen, 1"
        "$mod SHIFT, F, fullscreen, 0"
        "$mod SHIFT, T, togglefloating"
        "$mod, G, togglegroup,"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"

        # === Focus Navigation ===
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # === Window Movement ===
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, right, movewindow, r"

        # === Monitor Navigation ===
        "$mod CTRL, left, focusmonitor, l"
        "$mod CTRL, right, focusmonitor, r"

        # === Move to Monitor ===
        "$mod SHIFT CTRL, left, movewindow, mon:l"
        "$mod SHIFT CTRL, right, movewindow, mon:r"

        # === window resize ===
        "$mod, S, submap, resize"

        # === Screenshots ===
        ", Print, exec, dms screenshot"
        "CTRL, Print, exec, dms screenshot full"
        "ALT, Print, exec, dms screenshot window"
        "$mod SHIFT, Print, exec, ${lib.getExe recordScript}"
        "$mod SHIFT, BACKSPACE, exec, pkill -SIGINT wf-recorder"

        # === special workspace ===
        "$mod SHIFT, dead_circumflex, movetoworkspace, special"
        "$mod, dead_circumflex, togglespecialworkspace,"

        # === Scroll through existing workspaces with mod + scroll ===
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # === send focused workspace to left/right monitors ===
        "$mod SHIFT ALT, left, movecurrentworkspacetomonitor, l"
        "$mod SHIFT ALT, right, movecurrentworkspacetomonitor, r"

        # === Sizing ===
        "$mod, R, layoutmsg, togglesplit"
      ]
      ++ workspaces;

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    binde = [
      "$mod, minus, resizeactive, -10% 0"
      "$mod, equal, resizeactive, 10% 0"
      "$mod SHIFT, minus, resizeactive, 0 -10%"
      "$mod SHIFT, equal, resizeactive, 0 10%"
    ];

    bindl = [
      # media controls
      ", XF86AudioPlay, exec, dms ipc call mpris playPause"
      ", XF86AudioPause, exec, dms ipc call mpris playPause"
      ", XF86AudioPrev, exec, dms ipc call mpris previous"
      ", XF86AudioNext, exec, dms ipc call mpris next"

      ", XF86AudioMute, exec, dms ipc call audio mute"
      ", XF86AudioMicMute, exec, dms ipc call audio micmute"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, dms ipc call audio increment 3"
      ", XF86AudioLowerVolume, exec, dms ipc call audio decrement 3"

      ", XF86MonBrightnessUp, exec, dms ipc call brightness increment 5 \"\""
      ", XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5 \"\""

      "CTRL, XF86AudioRaiseVolume, exec, dms ipc call mpris increment 3"
      "CTRL, XF86AudioLowerVolume, exec, dms ipc call mpris decrement 3"
    ];

    layerrule = [
      "animation off, match:namespace ^(quickshell)$"
      "animation off, match:namespace ^dms:.*"
    ];

    windowrule = [
      # DMS / Quickshell
      "tile on, match:class ^(gnome-control-center)$"
      "tile on, match:class ^(pavucontrol)$"
      "tile on, match:class ^(nm-connection-editor)$"
      "rounding 12, match:class ^(org\\.gnome\\.)$"
      "float on, match:class ^(gnome-calculator)$"
      "float on, match:class ^(blueman-manager)$"
      "float on, match:class ^(org\\.gnome\\.Nautilus)$"
      "float on, match:class ^(xdg-desktop-portal)$"
      "border_size 0, match:class ^(kitty)$"
      "no_initial_focus on, match:class ^(steam)$, match:title ^(notificationtoasts)$"
      "pin on, match:class ^(steam)$, match:title ^(notificationtoasts)$"
      "float on, match:class ^(zoom)$"

      # Firefox
      "match:class firefox, workspace 1"
      "match:class obsidian, workspace 2"
      "match:class discord, workspace 5"
      "match:title ^(Firefox — Sharing Indicator)$, float on"
      "match:title ^(Firefox — Sharing Indicator)$, move 0 0"
      "match:title ^(Firefox — Sharing Indicator)$, no_focus on"
      "match:title ^(KeePassXC - Browser Access Request)$, float on"
      "match:title ^(.*is sharing (your screen|a window)\\.)$, workspace special silent"
      "match:title ^(Picture-in-Picture)$, float on"
      "match:title ^(Picture-in-Picture)$, pin on"
    ];
  };
}
