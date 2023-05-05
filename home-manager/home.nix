{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./mail.nix
    inputs.fufexan.homeManagerModules.eww-hyprland
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "space";
    homeDirectory = "/home/space";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = { enableTridactylNative = true; };
    };
  };

  # Add stuff for your user as you see fit:
  programs.neovim.enable = true;

  home.packages =
    with pkgs;
    let todoman-git = pkgs.callPackage ../extra-pkgs/todoman.nix { };
    in [
      discord
      obs-studio
      urlscan
      ripmime
      poppler_utils
      obsidian
      calibre
      elinks
      ffmpeg
      vdirsyncer
      todoman-git
      libqalculate
      kalker
      zotero
      zoom-us
      minigalaxy
      inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin
      #       inputs.nix-gaming.packages.${pkgs.system}.osu-stable
      #       inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
      #       inputs.nix-gaming.packages.${pkgs.system}.wine-ge
      gamescope

      anki
      caffeine-ng

      # yubikey-manager-qt

      dunst
      polkit
      kitty
      eww-wayland
      rofi-wayland-unwrapped
      waybar
      networkmanagerapplet
      networkmanager_dmenu

      # screenshot
      grim
      slurp

      # utils
      # ocrScript
      wf-recorder
      wl-clipboard
      wlogout
      wlr-randr
      wofi
      swaybg

      gojq
      jc
      material-icons
      xorg.xprop
      jost
      jaq

      inputs.hyprland-contrib.packages.${pkgs.hostPlatform.system}.grimblast
    ];

  programs.eww-hyprland = {
    enable = true;
  };

  programs.swaylock = {
    enable = true;
  };

  # screen idle
  services.swayidle =
    let
      suspendScript = pkgs.writeShellScript "suspend-script" ''
        ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
        # only suspend if audio isn't running
        if [ $? == 1 ]; then
          ${pkgs.systemd}/bin/systemctl suspend
        fi
      '';
    in
    {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
      ];
      timeouts = [
        {
          timeout = 330;
          command = suspendScript.outPath;
        }
      ];
    };
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];

  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [ wlrobs ];

  wayland.windowManager.hyprland = {
    enable = true;
    recommendedEnvironment = true;
    extraConfig = ''
      $mod = SUPER

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=eDP-1, 1920x1080@60, 0x0, 1.25
      monitor=,preferred,auto,auto


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      exec-once = obsidian & firefox & discord

      env = GDK_SCALE,2
      env = QT_QPA_PLATFORM,wayland
      env = SDL_VIDEODRIVER,wayland
      env = XDG_SESSION_TYPE,wayland
      exec-once xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

      exec-once = dunst
      exec-once =  /nix/store/$(ls -la /nix/store | grep 'kwallet-pam' | grep '4096' | awk '{print $9}' | sed -n '$p')/libexec/pam_kwallet_init && nm-applet --indicator
      exec-once = eww open bar

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,24

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
        kb_layout = de

        force_no_accel = true
        natural_scroll = true
        follow_mouse = 1
        accel_profile = "flat"

        touchpad {
          natural_scroll = true
        }
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5
          gaps_out = 15
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 3
          blur = false
          blur_size = 3
          blur_passes = 1
          blur_new_optimizations = true

          drop_shadow = false
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = true

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = true # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
          preserve_split = true # you probably want this
      }

      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }

      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = true
      }

      misc {
          disable_autoreload = true
      }

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mod, T, exec, kitty
      bind = $mod, Q, killactive,
      bind = $mod SHIFT, E, exit
      bind = $mod ALT, F4, exit
      bind = $mod, L, exec, loginctl lock-session
      bind = $mod, F, fullscreen,
      bind = $mod, E, exec, dolphin
      bind = $mod, V, togglefloating,
      bind = $mod, SPACE, exec, pkill rofi || rofi -show run
      bind = $mod, P, pseudo, # dwindle
      bind = $mod, J, togglesplit, # dwindle

      bind = $mod, G, togglegroup,
      bind = $mod SHIFT, N, changegroupactive, f
      bind = $mod SHIFT, P, changegroupactive, b
      bind = $mod ALT, ,resizeactive,

      # toggle "monocle" (no_gaps_when_only)
      $kw = dwindle:no_gaps_when_only
      bind = $mod, M, exec, hyprctl keyword $kw $(($(hyprctl getoption $kw -j | jaq -r '.int') ^ 1))

      # Move focus with mod + arrow keys
      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d

      # mouse movements
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow
      bindm = $mod ALT, mouse:272, resizewindow

      # window resize
      bind = $mod, S, submap, resize
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      bind = , escape, submap, reset
      submap = reset

      # Switch workspaces with mod + [0-9]
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      # Move active window to a workspace with mod + SHIFT + [0-9]
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mod + scroll
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1



      # media controls
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      bindl = , XF86AudioNext, exec, playerctl next

      # volume
      bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
      binde = , XF86AudioRaiseVolume, exec, /home/space/.config/eww/scripts/volume osd
      bindle = , XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-
      binde = , XF86AudioLowerVolume, exec, /home/space/.config/eww/scripts/volume osd
      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioMute, exec, /home/space/.config/eww/scripts/volume osd
      bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # backlight
      bindle = , XF86MonBrightnessUp, exec, light -A 5
      binde = , XF86MonBrightnessUp, exec, /home/space/.config/eww/scripts/brightness osd
      bindle = , XF86MonBrightnessDown, exec, light -U 5
      binde = , XF86MonBrightnessDown, exec, /home/space/.config/eww/scripts/brightness osd


      # screenshot
      # stop animations while screenshotting; makes black border go away
      $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
      bind = , Print, exec, $screenshotarea
      bind = $mod SHIFT, R, exec, $screenshotarea

      bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
      bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output

      bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
      bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen


      # throw sharing indicators away
      windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
      windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

      # make Firefox PiP window floating and sticky
      windowrulev2 = float, title:^(Picture-in-Picture)$
      windowrulev2 = pin, title:^(Picture-in-Picture)$

      windowrule = workspace 1,^(firefox)$
      windowrule = workspace 2,^(obsidian)$
      windowrule = workspace 5,^(discord)$
    '';

  };

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };


  programs.zathura.enable = true;
  programs.feh.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "ShaddyDC";
    userEmail = "shaddythefirst@gmail.com";
    delta.enable = true;
  };
  programs.lazygit.enable = true;
  programs.bat.enable = true;

  programs.helix.enable = true;

  programs.java.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${inputs.nixpkgs.legacyPackages.${pkgs.system}.zellij}/bin/zellij";
        args = [
          "options"
          "--default-shell"
          "nu"
        ];
      };
      font.normal.style = "JetBrains Mono";
      font.size = 8;
    };
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };

  programs.starship = {
    enable = true;
    settings = { };
  };

  programs.vscode = {
    enable = true;
    extensions = (with pkgs;
      with vscode-extensions; [
        ms-vscode.cpptools
      ]);
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # services.pueue.enable = true;

  # TODO Create directory ~/mnt/gdrive
  systemd.user.services."rclone_gdrive" = {
    Unit = {
      Description = "Remote FUSE filesystem for cloud storage";
      Wants = "network-online.target";
      After = "network-online.target";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "notify";
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = " \\
        ${pkgs.rclone}/bin/rclone mount \\
          --config=%h/.config/rclone/rclone.conf \\
          --vfs-cache-mode writes \\
          --vfs-cache-max-size 100M \\
          --log-file /tmp/rclone-%i.log \\
          gdrive: %h/mnt/gdrive
      ";
      ExecStop = "${pkgs.rclone}/bin/rclone -u %h/mnt/%i";
    };
  };

  # vdirsyncer
  systemd.user.services.vdirsyncer = {
    Unit = {
      Description = "Runs vdirsyncer every 15 mins";
      Wants = "network-online.target";
      After = "network-online.target";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer -c /run/agenix/vdirsyncer-config sync";
    };
  };

  systemd.user.timers.vdirsyncer = {
    Unit = {
      Description = "Runs vdirsyncer every 5 mins";
    };

    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "15m";
      Unit = "vdirsyncer.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

  home.file.".config/todoman/config.py".source = ./todoman.config.py;

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "git.rwth-aachen.de" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "devps" = {
      user = "root";
      hostname = "88.198.105.181";
      identityFile = "~/.ssh/id_rsa.pub";
    };

  };

  home.file.".ssh/id_rsa.pub".source = ./id_rsa.pub;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
