{
  pkgs,
  lib,
  ...
}: let
  sh = cmd: ["sh" "-c" cmd];

  # In the KDL the module generates, a bind is a node named after the key
  # combo whose child node is the action, and `_props` holds node properties
  # such as cooldown-ms or allow-when-locked.
  shBind = cmd: {spawn = sh cmd;};
  whenLocked = bind: bind // {_props.allow-when-locked = true;};

  # window-rule takes repeated `match` children, so it has to go through
  # `_children` rather than a plain list.
  floatingRule = matches: {
    window-rule._children =
      map (m: {match._props = m;}) matches
      ++ [{open-floating = true;}];
  };
in {
  wayland.windowManager.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb.layout = "de";
          repeat-delay = 600;
          repeat-rate = 25;
          track-layout = "global";
        };
        mouse = {
          accel-profile = "flat";
          accel-speed = 0.0;
        };
        touchpad = {
          natural-scroll = {};
          accel-profile = "flat";
          tap = {};
        };
        focus-follows-mouse = {};
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths._children = [
          {proportion = 0.333;}
          {proportion = 0.5;}
          {proportion = 0.667;}
        ];
        default-column-width.proportion = 0.5;
        # Colours come from the DMS include below.
        focus-ring.width = 2;
        border.off = {};
      };

      prefer-no-csd = {};

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      environment = {
        TERMINAL = "kitty";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        # Same as the Hyprland env block: home.sessionVariables only reaches
        # shells that source hm-session-vars.sh, and the session isn't one.
        QT_QPA_PLATFORM = "wayland;x11";
        SDL_VIDEODRIVER = "wayland;x11";
        XCURSOR_SIZE = "24";
      };

      # spawn-at-startup and window-rule both repeat as top-level nodes, which
      # an attrset cannot express, so they share the ordered `_children` list.
      _children =
        map (command: {spawn-at-startup._args = command;}) [
          ["obsidian"]
          ["firefox"]
          # Hands the login password that pam_kwallet captured at the greeter
          # to ksecretd, which unlocks the wallet (the session's Secret Service).
          ["${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"]
          [(lib.getExe pkgs.networkmanagerapplet) "--indicator"]
          [(lib.getExe pkgs.ianny)]
        ]
        ++ [
          # DMS writes its theme colours here at runtime. Optional, because
          # the file does not exist before DMS first runs, nor in the
          # sandbox where checkConfig validates this config.
          {
            include = {
              _props.optional = true;
              _args = ["dms/colors.kdl"];
            };
          }
          (floatingRule [
            {app-id = "^(gnome-calculator|org\\.gnome\\.Calculator)$";}
            {app-id = "^blueman-manager$";}
            {app-id = "^pavucontrol$";}
            {app-id = "^nm-connection-editor$";}
            {app-id = "^xdg-desktop-portal$";}
            {app-id = "^zoom$";}
          ])
          # Rounded corners, matching Hyprland's rounding.
          {
            window-rule = {
              geometry-corner-radius = 12;
              clip-to-geometry = true;
            };
          }
          (floatingRule [
            {title = "^Picture-in-Picture$";}
            {title = "^Firefox — Sharing Indicator$";}
          ])
          {
            window-rule._children = [
              {
                match._props = {
                  app-id = "^steam$";
                  title = "^notificationtoasts";
                };
              }
              {open-floating = true;}
              {open-focused = false;}
            ];
          }
          # KeePassXC browser access request
          (floatingRule [{title = "^KeePassXC - Browser Access Request$";}])
        ];

      binds = let
        ws-binds = builtins.listToAttrs (builtins.concatLists (builtins.genList (
            i: let
              n = i + 1;
              key = toString (
                if n == 10
                then 0
                else n
              );
            in [
              {
                name = "Mod+${key}";
                value.focus-workspace = n;
              }
              {
                name = "Mod+Shift+${key}";
                value.move-column-to-workspace = n;
              }
            ]
          )
          10));
      in
        ws-binds
        // {
          # === Application Launchers ===
          "Mod+T".spawn = "kitty";
          "Mod+Space" = shBind "dms ipc call spotlight toggle";
          "Mod+V" = shBind "dms ipc call clipboard toggle";
          "Mod+M" = shBind "dms ipc call processlist focusOrToggle";
          "Mod+Comma" = shBind "dms ipc call settings focusOrToggle";
          "Mod+N" = shBind "dms ipc call notifications toggle";
          "Mod+Shift+N" = shBind "dms ipc call notepad toggle";
          "Mod+Y" = shBind "dms ipc call dankdash wallpaper";
          "Mod+X" = shBind "dms ipc call powermenu toggle";
          "Mod+E".spawn = "dolphin";
          "Mod+O".spawn = "wl-ocr";
          "Mod+Tab".toggle-overview = {};

          # === Cheat sheet ===
          # ssharp is the ?-key on a German layout, like Hyprland's bind.
          "Mod+Shift+ssharp".show-hotkey-overlay = {};

          # === Security ===
          "Mod+L" = shBind "dms ipc call lock lock";
          "Ctrl+Alt+Delete" = shBind "dms ipc call processlist focusOrToggle";

          # === Window Management ===
          "Mod+Q".close-window = {};
          "Alt+F4".close-window = {};
          "Mod+Shift+E".quit = {};
          # maximize-column is niri's equivalent of hyprland's fullscreen 1
          "Mod+F".maximize-column = {};
          # fullscreen-window is true fullscreen
          "Mod+Shift+F".fullscreen-window = {};
          # center focused column on screen
          "Mod+C".center-column = {};
          "Mod+Shift+T".toggle-window-floating = {};
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};
          # tabbed columns are the closest thing to hyprland's groups
          "Mod+W".toggle-column-tabbed-display = {};
          # let a VM or remote desktop grab every key; Mod+Escape again to undo
          "Mod+Escape" = {
            _props.allow-inhibiting = false;
            toggle-keyboard-shortcuts-inhibit = {};
          };

          # === Columns ===
          # Pull the neighbouring window into this column, or push the
          # focused one out of it.
          "Mod+Alt+Left".consume-or-expel-window-left = {};
          "Mod+Alt+Right".consume-or-expel-window-right = {};

          # === Sizing ===
          # cycle through preset column widths (like layoutmsg togglesplit)
          "Mod+R".switch-preset-column-width = {};
          "Mod+Shift+R".switch-preset-window-height = {};
          "Mod+Ctrl+F".expand-column-to-available-width = {};
          # niri matches the unshifted keysym, and = is Shift+0 on a German
          # layout, so the grow binds sit on the + key instead.
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Plus".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Plus".set-window-height = "+10%";

          # === Focus Navigation ===
          "Mod+Left".focus-column-left = {};
          "Mod+Right".focus-column-right = {};
          "Mod+Up".focus-window-up = {};
          "Mod+Down".focus-window-down = {};

          # === Window/Column Movement ===
          "Mod+Shift+Left".move-column-left = {};
          "Mod+Shift+Right".move-column-right = {};
          "Mod+Shift+Up".move-window-up = {};
          "Mod+Shift+Down".move-window-down = {};

          # === Monitor Navigation ===
          "Mod+Ctrl+Left".focus-monitor-left = {};
          "Mod+Ctrl+Right".focus-monitor-right = {};

          # === Move to Monitor ===
          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
          "Mod+Shift+Alt+Left".move-workspace-to-monitor-left = {};
          "Mod+Shift+Alt+Right".move-workspace-to-monitor-right = {};

          # === Workspaces ===
          "Mod+Page_Down".focus-workspace-down = {};
          "Mod+Page_Up".focus-workspace-up = {};
          "Mod+Ctrl+Down".move-column-to-workspace-down = {};
          "Mod+Ctrl+Up".move-column-to-workspace-up = {};
          "Mod+Shift+Page_Down".move-workspace-down = {};
          "Mod+Shift+Page_Up".move-workspace-up = {};

          # === Screenshots ===
          "Print" = shBind "dms screenshot";
          "Ctrl+Print" = shBind "dms screenshot full";
          "Alt+Print" = shBind "dms screenshot window";
          "Mod+Print" = shBind "dms screenshot last";

          # === Scroll through workspaces ===
          "Mod+WheelScrollDown" = {
            _props.cooldown-ms = 150;
            focus-workspace-down = {};
          };
          "Mod+WheelScrollUp" = {
            _props.cooldown-ms = 150;
            focus-workspace-up = {};
          };
          "Mod+WheelScrollRight".focus-column-right = {};
          "Mod+WheelScrollLeft".focus-column-left = {};
          "Mod+Shift+WheelScrollDown".focus-column-right = {};
          "Mod+Shift+WheelScrollUp".focus-column-left = {};

          # === Media Controls (allow-when-locked for lock screen) ===
          "XF86AudioPlay" = whenLocked (shBind "dms ipc call mpris playPause");
          "XF86AudioPause" = whenLocked (shBind "dms ipc call mpris playPause");
          "XF86AudioPrev" = whenLocked (shBind "dms ipc call mpris previous");
          "XF86AudioNext" = whenLocked (shBind "dms ipc call mpris next");
          "XF86AudioMute" = whenLocked (shBind "dms ipc call audio mute");
          "XF86AudioMicMute" = whenLocked (shBind "dms ipc call audio micmute");
          "XF86AudioRaiseVolume" = whenLocked (shBind "dms ipc call audio increment 3");
          "XF86AudioLowerVolume" = whenLocked (shBind "dms ipc call audio decrement 3");
          "Ctrl+XF86AudioRaiseVolume" = whenLocked (shBind "dms ipc call mpris increment 3");
          "Ctrl+XF86AudioLowerVolume" = whenLocked (shBind "dms ipc call mpris decrement 3");
          "XF86MonBrightnessUp" = whenLocked (shBind "dms ipc call brightness increment 5 \"\"");
          "XF86MonBrightnessDown" = whenLocked (shBind "dms ipc call brightness decrement 5 \"\"");
        };
    };
  };
}
