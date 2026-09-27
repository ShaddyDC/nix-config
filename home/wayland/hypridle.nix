{
  pkgs,
  lib,
  config,
  ...
}: let
  lock = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";

  # only lock if nothing is playing audio
  idleLock = pkgs.writeShellScript "idle-lock" ''
    if ! ${lib.getExe' pkgs.pipewire "pw-cli"} i all | ${lib.getExe pkgs.ripgrep} -q running; then
      ${lock}
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
        # NB: deliberately NOT guarded with `pgrep hyprlock ||`. A hyprlock
        # process has been observed outliving its own successful unlock by
        # tens of minutes, and such a guard would then suppress the real
        # locker, leaving the session locked with nothing drawn and no way
        # back in.
        lock_cmd = lib.getExe config.programs.hyprlock.package;
      };

      listener = [
        {
          timeout = 330;
          on-timeout = idleLock.outPath;
        }
      ];
    };
  };
}
