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
      };

      # spawn-at-startup and window-rule both repeat as top-level nodes, which
      # an attrset cannot express, so they share the ordered `_children` list.
      _children =
        map (command: {spawn-at-startup._args = command;}) [
          ["obsidian"]
          ["firefox"]
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
          (floatingRule [{title = "^Picture-in-Picture$";}])
          (floatingRule [
            {
              app-id = "^steam$";
              title = "^notificationtoasts";
            }
          ])
          # KeePassXC browser access request
          (floatingRule [{title = "^KeePassXC - Browser Access Request$";}])
        ];

      binds = let
        ws-binds = builtins.listToAttrs (builtins.concatLists (builtins.genList (
            i: let
              n = i + 1;
              key = toString n;
            in [
              {
                name = "Mod+${key}";
                value.focus-workspace = n;
              }
              {
                name = "Mod+Shift+${key}";
                value.move-column-to-index = n;
              }
            ]
          )
          9));
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

          # === Sizing ===
          # cycle through preset column widths (like layoutmsg togglesplit)
          "Mod+R".switch-preset-column-width = {};
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

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

          # === Screenshots ===
          "Print" = shBind "dms screenshot";
          "Ctrl+Print" = shBind "dms screenshot full";
          "Alt+Print" = shBind "dms screenshot window";

          # === Scroll through workspaces ===
          "Mod+WheelScrollDown" = {
            _props.cooldown-ms = 150;
            focus-workspace-down = {};
          };
          "Mod+WheelScrollUp" = {
            _props.cooldown-ms = 150;
            focus-workspace-up = {};
          };

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
