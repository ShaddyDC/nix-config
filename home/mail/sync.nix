{pkgs, ...}: {
  programs = {
    mbsync.enable = true;
    msmtp.enable = true;

    notmuch = {
      enable = true;
      # hooks = {
      #   preNew = "mbsync --all";
      # };
    };
  };

  # services = {
  #   mbsync = {
  #     enable = true;
  #     frequency = "*-*-* *:*0:00";
  #     postExec = "${pkgs.notmuch}/bin/notmuch new";
  #   };
  # };

  # TODO set up imapnotify

  # # mbsync
  # systemd.user.services.mbsync = {
  #   Unit = {
  #     Description = "Runs mbsync every 15 mins";
  #     Wants = "network-online.target";
  #     After = "network-online.target";
  #   };

  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.isync}/bin/mbsync -Va";
  #   };
  # };

  # systemd.user.timers.mbsync = {
  #   Unit = {
  #     Description = "Runs mbsync every 15 mins";
  #   };

  #   Timer = {
  #     OnBootSec = "2m";
  #     OnUnitActiveSec = "15m";
  #     Unit = "mbsync.service";
  #   };

  #   Install = {WantedBy = ["timers.target"];};
  # };
}
