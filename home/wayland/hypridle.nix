{
  pkgs,
  lib,
  config,
  ...
}: let
  lock = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";

  # Exit status 0 while any MPRIS player (browser, music player, mpv...) is
  # playing. This used to check for any running pipewire node, but apps like
  # vesktop keep an uncorked stream open for as long as they run, which kept
  # the sink running and suppressed the idle lock indefinitely.
  audioPlaying = "${lib.getExe pkgs.playerctl} -a status 2>/dev/null | ${lib.getExe pkgs.ripgrep} -qx Playing";

  # only lock if nothing is playing media
  idleLock = pkgs.writeShellScript "idle-lock" ''
    if ! ${audioPlaying}; then
      ${lock}
    fi
  '';

  # Suspend only on battery, and not while audio plays. On AC the machine
  # just locks and blanks.
  idleSuspend = pkgs.writeShellScript "idle-suspend" ''
    for bat in /sys/class/power_supply/BAT*/status; do
      [ "$(cat "$bat")" = Discharging ] || exit 0
    done
    if ! ${audioPlaying}; then
      ${lib.getExe' pkgs.systemd "systemctl"} suspend
    fi
  '';

  # hypridle is shared between Hyprland and niri, and only Hyprland has
  # hyprctl. Since 0.56 the dispatcher is Lua, so the old `dpms on` spelling
  # is a syntax error rather than a no-op.
  wakeDisplays = pkgs.writeShellScript "wake-displays" ''
    if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      ${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} \
        dispatch 'hl.dsp.dpms({action = "on"})'
    fi
  '';

  # niri has no hyprctl but its own action; it powers monitors back on by
  # itself at the next input, so it needs no counterpart in wakeDisplays.
  sleepDisplays = pkgs.writeShellScript "sleep-displays" ''
    if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      ${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} \
        dispatch 'hl.dsp.dpms({action = "off"})'
    elif [ -n "''${NIRI_SOCKET:-}" ]; then
      ${lib.getExe config.wayland.windowManager.niri.package} msg action power-off-monitors
    fi
  '';
in {
  # screen idle
  #
  # NOTE: `settings` is freeform hyprlang -- home-manager passes the attribute
  # names through verbatim. They must match hypridle.conf exactly (`general`
  # block, `listener` singular, snake_case/kebab-case keys), otherwise the
  # config parses into nothing and no listener ever fires.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = lock;
        after_sleep_cmd = wakeDisplays.outPath;
        # Lock with DMS, the same locker SUPER+L uses. Having the idle timer
        # reach for hyprlock instead is what let hyprlock's config rot
        # unnoticed until it locked the session with nothing drawn.
        #
        # NB: deliberately NOT guarded with `pgrep <locker> ||`. A hyprlock
        # process was observed outliving its own successful unlock by tens of
        # minutes, and such a guard would then suppress the real locker,
        # leaving the session locked and unreachable short of a TTY.
        lock_cmd = "${lib.getExe' pkgs.dms-shell "dms"} ipc call lock lock";
      };

      listener = [
        {
          timeout = 330;
          on-timeout = idleLock.outPath;
        }
        # Blank the screen shortly after locking. Apps playing video hold an
        # idle inhibitor, so this doesn't fire under a playing video.
        {
          timeout = 360;
          on-timeout = sleepDisplays.outPath;
          on-resume = wakeDisplays.outPath;
        }
        {
          timeout = 900;
          on-timeout = idleSuspend.outPath;
        }
      ];
    };
  };
}
