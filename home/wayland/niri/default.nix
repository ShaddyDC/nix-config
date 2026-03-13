{
  pkgs,
  lib,
  config,
  ...
}: let
  sh = cmd: ["sh" "-c" cmd];
in {
  programs.niri = {
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
          natural-scroll = true;
          accel-profile = "flat";
          tap = true;
        };
        focus-follows-mouse.enable = true;
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          {proportion = 0.333;}
          {proportion = 0.5;}
          {proportion = 0.667;}
        ];
        default-column-width = {proportion = 0.5;};
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#cba6f7"; # Catppuccin Mauve
          inactive.color = "#45475a"; # Catppuccin Surface1
        };
        border.enable = false;
      };

      prefer-no-csd = true;

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      spawn-at-startup = [
        {command = ["obsidian"];}
        {command = ["firefox"];}
        {command = [(lib.getExe pkgs.networkmanagerapplet) "--indicator"];}
        {command = [(lib.getExe pkgs.ianny)];}
      ];

      environment = {
        TERMINAL = "kitty";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      window-rules = [
        {
          matches = [
            {app-id = "^(gnome-calculator|org\\.gnome\\.Calculator)$";}
            {app-id = "^blueman-manager$";}
            {app-id = "^pavucontrol$";}
            {app-id = "^nm-connection-editor$";}
            {app-id = "^xdg-desktop-portal$";}
            {app-id = "^zoom$";}
          ];
          open-floating = true;
        }
        {
          matches = [{title = "^Picture-in-Picture$";}];
          open-floating = true;
        }
        {
          matches = [{app-id = "^steam$"; title = "^notificationtoasts";}];
          open-floating = true;
        }
        # KeePassXC browser access request
        {
          matches = [{title = "^KeePassXC - Browser Access Request$";}];
          open-floating = true;
        }
      ];

      binds = with config.lib.niri.actions; let
        sh-action = cmd: spawn (sh cmd);
        ws-binds = builtins.listToAttrs (builtins.concatLists (builtins.genList (
            i: let
              n = i + 1;
              key = toString n;
            in [
              {
                name = "Mod+${key}";
                value.action = focus-workspace n;
              }
              {
                name = "Mod+Shift+${key}";
                value.action = move-column-to-index n;
              }
            ]
          )
          9));
      in
        ws-binds
        // {
          # === Application Launchers ===
          "Mod+T".action = spawn "kitty";
          "Mod+Space".action = sh-action "dms ipc call spotlight toggle";
          "Mod+V".action = sh-action "dms ipc call clipboard toggle";
          "Mod+M".action = sh-action "dms ipc call processlist focusOrToggle";
          "Mod+Comma".action = sh-action "dms ipc call settings focusOrToggle";
          "Mod+N".action = sh-action "dms ipc call notifications toggle";
          "Mod+Shift+N".action = sh-action "dms ipc call notepad toggle";
          "Mod+Y".action = sh-action "dms ipc call dankdash wallpaper";
          "Mod+X".action = sh-action "dms ipc call powermenu toggle";
          "Mod+E".action = spawn "dolphin";
          "Mod+O".action = spawn "wl-ocr";

          # === Security ===
          "Mod+L".action = sh-action "dms ipc call lock lock";
          "Ctrl+Alt+Delete".action = sh-action "dms ipc call processlist focusOrToggle";

          # === Window Management ===
          "Mod+Q".action = close-window;
          "Alt+F4".action = close-window;
          "Mod+Shift+E".action = quit;
          # maximize-column is niri's equivalent of hyprland's fullscreen 1
          "Mod+F".action = maximize-column;
          # fullscreen-window is true fullscreen
          "Mod+Shift+F".action = fullscreen-window;
          # center focused column on screen
          "Mod+C".action = center-column;

          # === Sizing ===
          # cycle through preset column widths (like layoutmsg togglesplit)
          "Mod+R".action = switch-preset-column-width;
          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";
          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Equal".action = set-window-height "+10%";

          # === Focus Navigation ===
          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Up".action = focus-window-up;
          "Mod+Down".action = focus-window-down;

          # === Window/Column Movement ===
          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Right".action = move-column-right;
          "Mod+Shift+Up".action = move-window-up;
          "Mod+Shift+Down".action = move-window-down;

          # === Monitor Navigation ===
          "Mod+Ctrl+Left".action = focus-monitor-left;
          "Mod+Ctrl+Right".action = focus-monitor-right;

          # === Move to Monitor ===
          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

          # === Screenshots ===
          "Print".action = sh-action "dms screenshot";
          "Ctrl+Print".action = sh-action "dms screenshot full";
          "Alt+Print".action = sh-action "dms screenshot window";

          # === Scroll through workspaces ===
          "Mod+WheelScrollDown" = {
            action = focus-workspace-down;
            cooldown-ms = 150;
          };
          "Mod+WheelScrollUp" = {
            action = focus-workspace-up;
            cooldown-ms = 150;
          };

          # === Media Controls (allow-when-inhibited for lock screen) ===
          "XF86AudioPlay" = {
            action = sh-action "dms ipc call mpris playPause";
            allow-when-locked = true;
          };
          "XF86AudioPause" = {
            action = sh-action "dms ipc call mpris playPause";
            allow-when-locked = true;
          };
          "XF86AudioPrev" = {
            action = sh-action "dms ipc call mpris previous";
            allow-when-locked = true;
          };
          "XF86AudioNext" = {
            action = sh-action "dms ipc call mpris next";
            allow-when-locked = true;
          };
          "XF86AudioMute" = {
            action = sh-action "dms ipc call audio mute";
            allow-when-locked = true;
          };
          "XF86AudioMicMute" = {
            action = sh-action "dms ipc call audio micmute";
            allow-when-locked = true;
          };
          "XF86AudioRaiseVolume" = {
            action = sh-action "dms ipc call audio increment 3";
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            action = sh-action "dms ipc call audio decrement 3";
            allow-when-locked = true;
          };
          "Ctrl+XF86AudioRaiseVolume" = {
            action = sh-action "dms ipc call mpris increment 3";
            allow-when-locked = true;
          };
          "Ctrl+XF86AudioLowerVolume" = {
            action = sh-action "dms ipc call mpris decrement 3";
            allow-when-locked = true;
          };
          "XF86MonBrightnessUp" = {
            action = sh-action "dms ipc call brightness increment 5 \"\"";
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            action = sh-action "dms ipc call brightness decrement 5 \"\"";
            allow-when-locked = true;
          };
        };
    };
  };
}
