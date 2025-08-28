{pkgs, ...}: {
  programs = {
    mbsync.enable = true;
    msmtp.enable = true;

    notmuch = {
      enable = true;
      hooks = {
        # Run afew after notmuch indexes new mail
        # Check for lock file to avoid conflicts with interactive neomutt usage
        postNew = ''
          LOCK_FILE="/tmp/neomutt.lock"

          # Skip if neomutt is running (check for lock file or process)
          if [ -f "$LOCK_FILE" ] || pgrep -x neomutt > /dev/null 2>&1; then
            echo "Skipping afew - neomutt is active"
            exit 0
          fi

          ${pkgs.afew}/bin/afew --tag --new
          ${pkgs.afew}/bin/afew --move-mails
        '';
      };
    };
  };

  # Automatic mail sync every 15 minutes
  # Comment out this section if you prefer manual sync (mbsync -a)
  services = {
    mbsync = {
      enable = true;
      frequency = "*:0/15";  # Every 15 minutes
      postExec = "${pkgs.notmuch}/bin/notmuch new";
    };
  };

  # Add resource limits to prevent freezing
  systemd.user.services.mbsync = {
    Service = {
      # Run at lowest CPU and I/O priority so it doesn't freeze the desktop
      Nice = 19;
      IOSchedulingClass = "idle";
      # Kill if it takes longer than 5 minutes (stuck network, etc.)
      TimeoutStartSec = 300;
    };
  };

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
