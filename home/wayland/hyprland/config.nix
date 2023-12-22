{
  pkgs,
  inputs',
  lib,
  ...
}: let
  monocle = "dwindle:no_gaps_when_only";
  screenshotarea = "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";

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
      gaps_out = 15;
      border_size = 2;
      col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      col.inactive_border = "rgba(595959aa)";

      layout = "dwindle";
    };

    decoration = {
      rounding = 3;

      drop_shadow = false;
      shadow_range = 4;
      shadow_render_power = 3;
      col.shadow = "rgba(1a1a1aee)";
    };

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
      new_is_master = true;
    };

    gestures = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = true;
    };

    misc = {
      disuble_autoreload = true;
      force_default_wallpaper = 0;
    };

    binds =
      [
        "$mod, T, exec, kitty"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit"
        "ALT, F4, killactive"
        "$mod, Escape, exec, wlogout -p layer-shell"
        "$mod, L, exec, loginctl lock-session"
        "$mod, O, exec, wl-ocr"
        "$mod, F, fullscreen,"
        "$mod, E, exec, dolphin"
        "$mod, V, togglefloating,"
        "$mod, SPACE, exec, pkill anyrun || ${inputs'.anyrun.packages.anyrun}/bin/anyrun"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, G, togglegroup,"
        "$mod SHIFT, N, changegroupactive, f"
        "$mod SHIFT, P, changegroupactive, b"
        "$mod ALT, ,resizeactive,"

        # toggle "monocle" (no_gaps_when_only)
        "$mod, M, exec, hyprctl keyword ${monocle} $(($(hyprctl getoption ${monocle} -j | ${lib.getExe pkgs.jaq} -r '.int') ^ 1))"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"

        # window resize
        "$mod, S, submap, resize"

        # screenshot
        # stop animations while screenshotting; makes black border go away
        # $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
        ", Print, exec, ${screenshotarea}"
        "$mod SHIFT, R, exec, ${screenshotarea}"

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
      ]
      ++ workspaces;

    bindl = [
      # media controls
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"

      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindle = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l "
      1.0
      " @DEFAULT_AUDIO_SINK@ 6%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume -l "
      1.0
      " @DEFAULT_AUDIO_SINK@ 6%-"

      ", XF86MonBrightnessUp, exec, brillo -q -u 300000 -A 5"
      ", XF86MonBrightnessDown, exec, brillo -q -u 300000 -U 5"
    ];

    windowrule = [
      # throw sharing indicators away
      "float, title:^(Firefox — Sharing Indicator)$"
      "move 0 0, title:^(Firefox — Sharing Indicator)$"
      "nofocus, title:^(Firefox — Sharing Indicator)$"

      "float, title:^(KeePassXC - Browser Access Request)$"
      "workspace 1,^(firefox)$"
      "workspace 2,^(obsidian)$"
      "workspace 5,^(discord)$"
    ];

    windowrulev2 = [
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
