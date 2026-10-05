{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.generators) mkLuaInline;

  mod = "SUPER";

  # hl.dsp.window.resize takes pixels, not percentages (see the note in
  # ./default.nix), so the resize binds work in fixed steps.
  resizeStep = 100;

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

  # hl.bind(keys, dispatcher, opts?). The dispatcher is a Lua expression
  # (hl.dsp.*), so it has to be injected raw instead of quoted as a string.
  mkBind = opts: keys: dispatcher: {
    _args = [keys (mkLuaInline dispatcher)] ++ lib.optional (opts != {}) opts;
  };

  bind = mkBind {};
  bindm = mkBind {mouse = true;};
  binde = mkBind {repeating = true;};
  bindl = mkBind {locked = true;};
  bindel = mkBind {
    locked = true;
    repeating = true;
  };

  # toJSON gives us correct escaping for a Lua string literal.
  execCmd = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";
  dms = args: execCmd "dms ${args}";

  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  workspaceBinds = builtins.concatLists (builtins.genList (
      x: let
        n = x + 1;
        key = toString (
          if n == 10
          then 0
          else n
        );
      in [
        (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${toString n} })")
        (bind "${mod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString n} })")
      ]
    )
    10);
in {
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        {_args = ["QT_WAYLAND_DISABLE_WINDOWDECORATION" "1"];}
        # Same fallback as home/wayland: X11 for apps with no wayland backend.
        {_args = ["QT_QPA_PLATFORM" "wayland;x11"];}
        {_args = ["SDL_VIDEODRIVER" "wayland;x11"];}
        {_args = ["XDG_SESSION_TYPE" "wayland"];}
        {_args = ["XCURSOR_SIZE" "24"];}
        {_args = ["ELECTRON_OZONE_PLATFORM_HINT" "auto"];}
        {_args = ["TERMINAL" "kitty"];}
      ];

      config = {
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

        animations.enabled = true;

        dwindle.preserve_split = true;

        misc = {
          # If a lock screen crashes, Hyprland keeps the session locked and
          # refuses a replacement locker unless this is set -- which turns a
          # locker crash into "boot to a TTY" rather than "run the locker
          # again". Weakens the lock slightly for someone with physical
          # access to a machine whose locker just died; worth it on a laptop.
          allow_session_lock_restore = true;

          disable_autoreload = true;
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        render.direct_scanout = true;
      };

      animation = [
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "default";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 4;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
      ];

      permission = [
        # Allow xdph and grim
        {
          binary = "${config.wayland.windowManager.hyprland.portalPackage}/libexec/.xdg-desktop-portal-hyprland-wrapped";
          type = "screencopy";
          mode = "allow";
        }
        {
          binary = lib.getExe pkgs.grim;
          type = "screencopy";
          mode = "allow";
        }

        # Optionally allow non-pipewire capturing
        {
          binary = lib.getExe pkgs.wl-screenrec;
          type = "screencopy";
          mode = "allow";
        }
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      monitor = [
        {
          output = "desc:Hisense Electric Co. Ltd. HISENSE 0x676C626C";
          mode = "preferred";
          position = "auto";
          scale = 2.5;
        }
      ];

      bind =
        [
          # === Application Launchers ===
          (bind "${mod} + T" (execCmd "kitty"))
          (bind "${mod} + SPACE" (dms "ipc call spotlight toggle"))
          (bind "${mod} + V" (dms "ipc call clipboard toggle"))
          (bind "${mod} + M" (dms "ipc call processlist focusOrToggle"))
          (bind "${mod} + comma" (dms "ipc call settings focusOrToggle"))
          (bind "${mod} + N" (dms "ipc call notifications toggle"))
          (bind "${mod} + SHIFT + N" (dms "ipc call notepad toggle"))
          (bind "${mod} + Y" (dms "ipc call dankdash wallpaper"))
          (bind "${mod} + TAB" (dms "ipc call hypr toggleOverview"))
          (bind "${mod} + X" (dms "ipc call powermenu toggle"))
          (bind "${mod} + E" (execCmd "dolphin"))
          (bind "${mod} + O" (execCmd "wl-ocr"))

          # === Cheat sheet ===
          (bind "${mod} + SHIFT + ssharp" (dms "ipc call keybinds toggle hyprland"))

          # === Security ===
          (bind "${mod} + L" (dms "ipc call lock lock"))
          (bind "CTRL + ALT + Delete" (dms "ipc call processlist focusOrToggle"))

          # === Window Management ===
          (bind "${mod} + Q" "hl.dsp.window.close()")
          (bind "ALT + F4" "hl.dsp.window.close()")
          (bind "${mod} + SHIFT + E" "hl.dsp.exit()")
          (bind "${mod} + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
          (bind "${mod} + SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
          (bind "${mod} + SHIFT + T" ''hl.dsp.window.float({ action = "toggle" })'')
          (bind "${mod} + G" "hl.dsp.group.toggle()")
          (bind "${mod} + P" "hl.dsp.window.pseudo()") # dwindle
          (bind "${mod} + J" ''hl.dsp.layout("togglesplit")'')

          # === Focus Navigation ===
          (bind "${mod} + left" ''hl.dsp.focus({ direction = "left" })'')
          (bind "${mod} + right" ''hl.dsp.focus({ direction = "right" })'')
          (bind "${mod} + up" ''hl.dsp.focus({ direction = "up" })'')
          (bind "${mod} + down" ''hl.dsp.focus({ direction = "down" })'')

          # === Window Movement ===
          (bind "${mod} + SHIFT + left" ''hl.dsp.window.move({ direction = "left" })'')
          (bind "${mod} + SHIFT + down" ''hl.dsp.window.move({ direction = "down" })'')
          (bind "${mod} + SHIFT + up" ''hl.dsp.window.move({ direction = "up" })'')
          (bind "${mod} + SHIFT + right" ''hl.dsp.window.move({ direction = "right" })'')

          # === Monitor Navigation ===
          (bind "${mod} + CTRL + left" ''hl.dsp.focus({ monitor = "l" })'')
          (bind "${mod} + CTRL + right" ''hl.dsp.focus({ monitor = "r" })'')

          # === Move to Monitor ===
          (bind "${mod} + SHIFT + CTRL + left" ''hl.dsp.window.move({ monitor = "l" })'')
          (bind "${mod} + SHIFT + CTRL + right" ''hl.dsp.window.move({ monitor = "r" })'')

          # === window resize ===
          (bind "${mod} + S" ''hl.dsp.submap("resize")'')

          # === Screenshots ===
          # https://danklinux.com/docs/dankmaterialshell/cli-screenshot
          (bind "Print" (dms "screenshot"))
          (bind "CTRL + Print" (dms "screenshot full"))
          (bind "ALT + Print" (dms "screenshot window"))
          (bind "${mod} + Print" (dms "screenshot last"))
          (bind "${mod} + SHIFT + Print" (execCmd (lib.getExe recordScript)))
          (bind "${mod} + SHIFT + BACKSPACE" (execCmd "pkill -SIGINT wf-recorder"))

          # === special workspace ===
          (bind "${mod} + SHIFT + dead_circumflex" ''hl.dsp.window.move({ workspace = "special" })'')
          (bind "${mod} + dead_circumflex" "hl.dsp.workspace.toggle_special()")

          # === Scroll through existing workspaces with mod + scroll ===
          (bind "${mod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (bind "${mod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

          # === send focused workspace to left/right monitors ===
          (bind "${mod} + SHIFT + ALT + left" ''hl.dsp.workspace.move({ monitor = "l" })'')
          (bind "${mod} + SHIFT + ALT + right" ''hl.dsp.workspace.move({ monitor = "r" })'')

          # === Sizing ===
          # Cycle the focused split through 1/3, 1/2, 2/3, like niri's Mod+R.
          # dwindle's splitratio only takes a delta and clamps the result to
          # [0.1, 1.9] (1.0 is an even split), so dropping by 2 pins it at 0.1
          # and the second step lands exactly on the preset.
          (bind "${mod} + R" ''
            (function()
              local presets = { 0.667, 1.0, 1.333 }
              local current = {}
              return function()
                local win = hl.get_active_window()
                if not win then return end
                local i = (current[win.address] or 2) % #presets + 1
                current[win.address] = i
                hl.dispatch(hl.dsp.layout("splitratio -2"))
                hl.dispatch(hl.dsp.layout(string.format("splitratio %.3f", presets[i] - 0.1)))
              end
            end)()
          '')

          # === Mouse ===
          (bindm "${mod} + mouse:272" "hl.dsp.window.drag()")
          (bindm "${mod} + mouse:273" "hl.dsp.window.resize()")
          (bindm "${mod} + ALT + mouse:272" "hl.dsp.window.resize()")

          # === Resize the focused window ===
          (binde "${mod} + minus" "hl.dsp.window.resize({ x = -${toString resizeStep}, y = 0, relative = true })")
          (binde "${mod} + equal" "hl.dsp.window.resize({ x = ${toString resizeStep}, y = 0, relative = true })")
          (binde "${mod} + SHIFT + minus" "hl.dsp.window.resize({ x = 0, y = -${toString resizeStep}, relative = true })")
          (binde "${mod} + SHIFT + equal" "hl.dsp.window.resize({ x = 0, y = ${toString resizeStep}, relative = true })")

          # === media controls ===
          (bindl "XF86AudioPlay" (dms "ipc call mpris playPause"))
          (bindl "XF86AudioPause" (dms "ipc call mpris playPause"))
          (bindl "XF86AudioPrev" (dms "ipc call mpris previous"))
          (bindl "XF86AudioNext" (dms "ipc call mpris next"))

          (bindl "XF86AudioMute" (dms "ipc call audio mute"))
          (bindl "XF86AudioMicMute" (dms "ipc call audio micmute"))

          (bindel "XF86AudioRaiseVolume" (dms "ipc call audio increment 3"))
          (bindel "XF86AudioLowerVolume" (dms "ipc call audio decrement 3"))

          (bindel "XF86MonBrightnessUp" (dms ''ipc call brightness increment 5 ""''))
          (bindel "XF86MonBrightnessDown" (dms ''ipc call brightness decrement 5 ""''))

          (bindel "CTRL + XF86AudioRaiseVolume" (dms "ipc call mpris increment 3"))
          (bindel "CTRL + XF86AudioLowerVolume" (dms "ipc call mpris decrement 3"))
        ]
        ++ workspaceBinds;

      layer_rule = [
        {
          name = "no-anim-quickshell";
          match.namespace = "^(quickshell)$";
          animation = "off";
        }
        {
          name = "no-anim-dms";
          match.namespace = "^dms:.*";
          animation = "off";
        }
      ];

      window_rule = [
        # DMS / Quickshell
        {
          name = "tile-gnome-control-center";
          match.class = "^(gnome-control-center)$";
          tile = true;
        }
        {
          name = "tile-pavucontrol";
          match.class = "^(pavucontrol)$";
          tile = true;
        }
        {
          name = "tile-nm-connection-editor";
          match.class = "^(nm-connection-editor)$";
          tile = true;
        }
        {
          name = "rounding-gnome";
          match.class = "^(org\\.gnome\\.)$";
          rounding = 12;
        }
        {
          name = "float-gnome-calculator";
          match.class = "^(gnome-calculator)$";
          float = true;
        }
        {
          name = "float-blueman-manager";
          match.class = "^(blueman-manager)$";
          float = true;
        }
        {
          name = "float-nautilus";
          match.class = "^(org\\.gnome\\.Nautilus)$";
          float = true;
        }
        {
          name = "float-xdg-desktop-portal";
          match.class = "^(xdg-desktop-portal)$";
          float = true;
        }
        {
          name = "no-border-kitty";
          match.class = "^(kitty)$";
          border_size = 0;
        }
        {
          name = "steam-notification-toasts";
          match = {
            class = "^(steam)$";
            title = "^(notificationtoasts)$";
          };
          no_initial_focus = true;
          pin = true;
        }
        {
          name = "float-zoom";
          match.class = "^(zoom)$";
          float = true;
        }

        # Firefox
        {
          name = "firefox-to-ws1";
          match.class = "firefox";
          workspace = 1;
        }
        {
          name = "obsidian-to-ws2";
          match.class = "obsidian";
          workspace = 2;
        }
        {
          name = "discord-to-ws5";
          match.class = "discord";
          workspace = 5;
        }
        {
          name = "firefox-sharing-indicator";
          match.title = "^(Firefox — Sharing Indicator)$";
          float = true;
          move = "0 0";
          no_focus = true;
        }
        {
          name = "float-keepassxc-browser-access";
          match.title = "^(KeePassXC - Browser Access Request)$";
          float = true;
        }
        {
          name = "screen-share-indicator-to-special";
          match.title = "^(.*is sharing (your screen|a window)\\.)$";
          workspace = "special silent";
        }
        {
          name = "picture-in-picture";
          match.title = "^(Picture-in-Picture)$";
          float = true;
          pin = true;
        }
      ];
    };

    # `$mod, S` entered a submap that was never defined, which left the
    # keyboard with no binds until `submap reset`. Give it the same steps as
    # the $mod +/- binds and an escape hatch.
    submaps.resize.settings.bind = [
      (bind "left" "hl.dsp.window.resize({ x = -${toString resizeStep}, y = 0, relative = true })")
      (bind "right" "hl.dsp.window.resize({ x = ${toString resizeStep}, y = 0, relative = true })")
      (bind "up" "hl.dsp.window.resize({ x = 0, y = -${toString resizeStep}, relative = true })")
      (bind "down" "hl.dsp.window.resize({ x = 0, y = ${toString resizeStep}, relative = true })")
      (bind "escape" ''hl.dsp.submap("reset")'')
      (bind "return" ''hl.dsp.submap("reset")'')
    ];
  };
}
