{ pkgs, ... }: {
  home.packages =
    with pkgs;[
      vdirsyncer
    ];
  # systemd.user.services.vdirsyncer = {
  #   Unit = {
  #     Description = "Runs vdirsyncer every 15 mins";
  #     Wants = "network-online.target";
  #     After = "network-online.target";
  #   };

  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer -c /run/agenix/vdirsyncer-config sync";
  #   };
  # };

  # systemd.user.timers.vdirsyncer = {
  #   Unit = {
  #     Description = "Runs vdirsyncer every 5 mins";
  #   };

  #   Timer = {
  #     OnBootSec = "2m";
  #     OnUnitActiveSec = "15m";
  #     Unit = "vdirsyncer.service";
  #   };

  #   Install = { WantedBy = [ "timers.target" ]; };
  # };
}
