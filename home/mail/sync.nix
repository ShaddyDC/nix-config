{pkgs, ...}: {
  programs = {
    mbsync.enable = true;
    msmtp.enable = true;

    notmuch = {
      enable = true;

      # Must NOT be the default "unread;inbox". notmuch applies these to every
      # newly indexed file regardless of which folder it landed in, so with
      # "inbox" here a message delivered straight into Spam gets tagged both
      # "inbox" (by notmuch) and "spam" (by afew's FolderNameFilter, which only
      # ever adds tags). That pair makes it match two MailMover rules at once
      # and bounce between INBOX and Spam forever.
      #
      # afew also derives its --new query from this list minus "unread", so
      # "unread;inbox" made "afew --tag --new" re-process the entire inbox on
      # every run instead of just newly arrived mail.
      new.tags = ["new" "unread"];

      hooks = {
        # Run afew after notmuch indexes new mail
        # Check for lock file to avoid conflicts with interactive neomutt usage
        postNew = ''
          LOCK_FILE="/tmp/neomutt.lock"

          # afew --move-mails runs `notmuch new` itself once it has moved a file,
          # which re-enters this hook. Without this guard that recurses for as
          # long as there is anything left to move.
          if [ -n "''${AFEW_POST_NEW:-}" ]; then
            exit 0
          fi
          export AFEW_POST_NEW=1

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
      frequency = "*:0/15"; # Every 15 minutes
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
      # A missed timer fires right on resume, before wifi is back, and fails on
      # DNS. Give NetworkManager a moment, then skip (not fail) while offline.
      ExecCondition = "${pkgs.networkmanager}/bin/nm-online -q -t 30";
    };
  };

  # A dozen rules in mail-filters.nix are age-based ("archive/delete once older
  # than 14 days"). Those can never match when the message first arrives, so
  # they only fire on a re-scan of already-known mail. Sweep the database daily.
  #
  # Safe to run over everything: the catchall filter is scoped to tag:new, so a
  # full pass cannot re-add "inbox" to mail that was already classified.
  # AFEW_POST_NEW short-circuits the notmuch postNew hook, which afew would
  # otherwise re-enter through its own `notmuch new` call.
  systemd.user.services.afew-retag = {
    Unit.Description = "Re-apply afew filters to older mail (age-based rules)";
    Service = {
      Type = "oneshot";
      Environment = [
        "AFEW_POST_NEW=1"
        # afew falls back to ~/.notmuch-config when this is unset, which does
        # not exist - home-manager writes the XDG path. notmuch sets this
        # itself when it runs hooks, but a standalone unit has to pass it.
        "NOTMUCH_CONFIG=%h/.config/notmuch/default/config"
      ];
      ExecStart = [
        "${pkgs.afew}/bin/afew --tag --all"
        "${pkgs.afew}/bin/afew --move-mails"
      ];
      Nice = 19;
      IOSchedulingClass = "idle";
      TimeoutStartSec = 1800;
    };
  };

  systemd.user.timers.afew-retag = {
    Unit.Description = "Daily afew re-tag so age-based filter rules can fire";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    Install.WantedBy = ["timers.target"];
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
