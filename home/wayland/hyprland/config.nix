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
    ];

    exec-once = [
      "obsidian & firefox"
      "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1"
      "/nix/store/$(ls -la /nix/store | grep 'kwallet-pam' | grep '4096' | awk '{print $9}' | sed -n '$p')/libexec/pam_kwallet_init && ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      "eww open bar"
      "eww open osd"
      "${pkgs.avizo}/bin/avizo-service"
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
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5;
      gaps_out = 5;
      border_size = 1;

      layout = "dwindle";
    };

    decoration = {
      rounding = 3;
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

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = true; # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
      preserve_split = true; # you probably want this
    };

    master = {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      # new_is_master = true;
    };

    gesture = [
      "3, horizontal, workspace"
    ];

    misc = {
      disable_autoreload = true;
      force_default_wallpaper = 0;
    };
    render.direct_scanout = true;

    monitor = [
      "desc:Hisense Electric Co. Ltd. HISENSE 0x676C626C,preferred,auto,2.5"
    ];

    bind =
      [
        "$mod, T, exec, kitty"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit"
        "ALT, F4, killactive"
        "$mod, Escape, exec, wlogout -p layer-shell"
        "$mod, L, exec, ${lib.getExe config.programs.hyprlock.package}"
        "$mod, O, exec, wl-ocr"
        "$mod, F, fullscreen,"
        "$mod, E, exec, dolphin"
        "$mod, V, togglefloating,"
        "$mod, SPACE, exec, pkill walker || ${lib.getExe pkgs.walker}"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, G, togglegroup,"
        "$mod SHIFT, N, changegroupactive, f"
        "$mod SHIFT, P, changegroupactive, b"
        "$mod ALT, ,resizeactive,"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # window resize
        "$mod, S, submap, resize"

        # screenshot
        # stop animations while screenshotting; makes black border go away
        # $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
        ", Print, exec, ${screenshotarea}"
        "$mod SHIFT, Print, exec, ${lib.getExe recordScript}"
        "$mod SHIFT, BACKSPACE, exec, pkill -SIGINT wf-recorder"

        "CTRL, Print, exec, grimblast --notify --cursor copysave output"
        "$mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output"

        "ALT, Print, exec, grimblast --notify --cursor copysave screen"
        "$mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen"

        # special workspace
        "$mod SHIFT, dead_circumflex, movetoworkspace, special"
        "$mod, dead_circumflex, togglespecialworkspace,"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # send focused workspace to left/right monitors
        "$mod SHIFT ALT, left, movecurrentworkspacetomonitor, l"
        "$mod SHIFT ALT, right, movecurrentworkspacetomonitor, r"
      ]
      ++ workspaces;

    bindm = [
      # mouse movements
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    bindl = [
      # media controls
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"

      ", XF86AudioMute, exec, ${pkgs.avizo}/bin/volumectl toggle-mute"
      ", XF86AudioMicMute, exec, ${pkgs.avizo}/bin/volumectl -m toggle-mute"
    ];

    bindle = [
      ", XF86AudioRaiseVolume, exec, ${pkgs.avizo}/bin/volumectl -u up"
      ", XF86AudioLowerVolume, exec, ${pkgs.avizo}/bin/volumectl -u down"

      ", XF86MonBrightnessUp, exec, ${pkgs.avizo}/bin/lightctl up"
      ", XF86MonBrightnessDown, exec, ${pkgs.avizo}/bin/lightctl down"
    ];

    windowrule = [
      # throw sharing indicators away
      "float, title:^(Firefox — Sharing Indicator)$"
      "move 0 0, title:^(Firefox — Sharing Indicator)$"
      "nofocus, title:^(Firefox — Sharing Indicator)$"

      "float, title:^(KeePassXC - Browser Access Request)$"
      "workspace 1,class:firefox"
      "workspace 2,class:obsidian"
      "workspace 5,class:discord"

      "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

      # make Firefox PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"
    ];
  };
  # # volume
  # binde = , XF86AudioRaiseVolume, exec, ${scriptDir}/volume osd
  # binde = , XF86AudioLowerVolume, exec, ${scriptDir}/volume osd
  # bind = , XF86AudioMute, exec, ${scriptDir}/volume osd

  # # backlight
  # binde = , XF86MonBrightnessUp, exec, ${scriptDir}/brightness osd
  # binde = , XF86MonBrightnessDown, exec, ${scriptDir}/brightness osd
}
