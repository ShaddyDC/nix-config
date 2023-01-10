{ inputs, pkgs, config, ... }: {
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sidebar = {
      enable = true;
      width = 35;
      # format = "%D%?F? [%F]?%* %?N?%N/?%S";
      # format = "%D %* [%?N?%N / ?%S]";
    };

    macros = [
      {
        action = "!mbsync -a";
        key = "O";
        map = [ "index" "pager" ];
      }
      {
        action = "<pipe-message> urlscan<Enter>";
        key = "B";
        map = [ "pager" ];
      }
      {
        action = "<save-message>+Archive<Enter><Enter>";
        key = "n2";
        map = [ "index" ];
      }
      {
        action = "<save-message>+INBOX<Enter><Enter>";
        key = "n3";
        map = [ "index" ];
      }
    ];

    binds = [
      {
        action = "sidebar-prev";
        key = "<up>";
        map = [ "index" "pager" ];
      }
      {
        action = "sidebar-next";
        key = "<down>";
        map = [ "index" "pager" ];
      }
      {
        action = "sidebar-open";
        key = "<right>";
        map = [ "index" "pager" ];
      }

      {
        action = "toggle-new";
        key = "n1";
        map = [ "index" ];
      }
    ];

    settings = {
      mailcap_path = "~/.config/neomutt/mailcap";
    };

    extraConfig = ''
      set wait_key = no
      set mbox_type = Maildir
      set delete
      set quit
      set thorough_search
      set mail_check_stats
      color index blue default "~N"
      color index blue default "~O"

      # compose View Options
      set reverse_name                     # reply as whomever it was to
      set include                          # include message in replies
      set forward_quote                    # include message in forwards
      set text_flowed

      # status bar, date format, finding stuff etc.
      set status_chars = " *%A"
      set status_format = "[ Folder: %f ] [%r%m messages%?n? (%n new)?%?d? (%d to delete)?%?t? (%t tagged)? ]%>─%?p?( %p postponed )?"
      set index_format = "[%Z] %?X?A&-? %D  %-20.20F  %s"
      set sort = threads
      set sort_aux = reverse-last-date-received

      # Pager View Options
      set pager_index_lines = 10
      set pager_context = 3
      set pager_stop
      set menu_scroll
      set tilde

      # email headers and attachments
      ignore *
      unignore from: to: cc: bcc: date: subject:
      unhdr_order *
      hdr_order from: to: cc: bcc: date: subject:
      alternative_order text/plain text/enriched text/html
      auto_view text/html
    '';
  };
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  home.file.".config/neomutt/mailcap".text = ''
    text/html; ${pkgs.elinks}/bin/elinks -dump %s; copiousoutput;

    # PDF documents
    application/pdf; ${pkgs.zathura}/bin/zathura %s

    # Images
    image/jpg; ${pkgs.feh}/bin/feh %s
    image/jpeg; ${pkgs.feh}/bin/feh %s
    image/pjpeg; ${pkgs.feh}/bin/feh %s
    image/png; ${pkgs.feh}/bin/feh %s
    image/gif; ${pkgs.feh}/bin/feh %s
  '';

  accounts.email.maildirBasePath = "Mail";

  accounts.email.accounts =
    let
      unsafeMailAddr = file: builtins.extraBuiltins.unsafeEvalTimeDecryptAsString "${config.home.homeDirectory}/.ssh/id_ed25519" file;
      defaultSettings = {
        folders.inbox = "INBOX";
        folders.drafts = "Drafts";
        folders.sent = "Sent";
        folders.trash = "Trash";

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
        };

        msmtp.enable = true;
      };
    in
    {
      "shaddy" = defaultSettings // {
        primary = true;
        realName = "Shaddy";
        address = unsafeMailAddr ../secrets/mail/shaddy-mail-add.age;
        userName = unsafeMailAddr ../secrets/mail/shaddy-mail-add.age;
        imap = {
          host = "mail.shaddy.dev";
          tls.enable = true;
        };
        smtp = {
          host = "mail.shaddy.dev";
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/shaddy-mail-add.age;
          extraMailboxes = [ "Junk" ];
        };
        passwordCommand = "cat /run/agenix/mail-shaddy-pw";
      };

      # I don't want to set up 2fa for this, so I guess I won't be reading it for now
      # "shaddy2" = defaultSettings // {
      #   realName = "Shaddy";
      #   address = "ShaddyTheFirst@gmail.com";
      #   userName = "ShaddyTheFirst@gmail.com";
      #   imap = {
      #     host = "imap.gmail.com";
      #     tls.enable = true;
      #   };
      #   smtp = {
      #     host = "smtp.gmail.com";
      #     tls.enable = true;
      #   };
      #   passwordCommand = "cat /run/agenix/mail-shaddy2-pw";
      # };

      "private1" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private1-name.age;
        address = unsafeMailAddr ../secrets/mail/private1-add.age;
        userName = unsafeMailAddr ../secrets/mail/private1-add.age;
        imap = {
          host = unsafeMailAddr ../secrets/mail/private1-ser.age;
          tls.enable = true;
        };
        smtp = {
          host = unsafeMailAddr ../secrets/mail/private1-ser.age;
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private1-add.age;
          extraMailboxes = [ "Junk" ];
        };
        passwordCommand = "cat /run/agenix/mail-private1-pw";
      };

      "private2" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private2-name.age;
        address = unsafeMailAddr ../secrets/mail/private2-add.age;
        userName = unsafeMailAddr ../secrets/mail/private2-add.age;
        imap = {
          host = "imap.mail.de";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.mail.de";
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private2-add.age;
          extraMailboxes = [ "Archives" "Bulk" "Remember" "Spam" "Unbekannt" ];
        };

        passwordCommand = "cat /run/agenix/mail-private2-pw";
      };

      "private3" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private3-name.age;
        address = unsafeMailAddr ../secrets/mail/private3-add.age;
        userName = unsafeMailAddr ../secrets/mail/private3-add.age;
        imap = {
          host = "imap.web.de";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.web.de";
          port = 587;
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private3-add.age;
          extraMailboxes = [ "Archives" "Spam" "Templates" "Unbekannt" ];
        };

        passwordCommand = "cat /run/agenix/mail-private3-pw";
      };

      "private4" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private4-name.age;
        address = unsafeMailAddr ../secrets/mail/private4-add.age;
        userName = unsafeMailAddr ../secrets/mail/private4-add.age;
        imap = {
          host = "imap.web.de";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.web.de";
          port = 587;
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private4-add.age;
          extraMailboxes = [ "Archives" "Spam" "Unbekannt" ];
        };

        passwordCommand = "cat /run/agenix/mail-private4-pw";
      };

      "private5" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private5-name.age;
        address = unsafeMailAddr ../secrets/mail/private5-add.age;
        userName = unsafeMailAddr ../secrets/mail/private5-use.age;
        imap = {
          host = "imap.de.aol.com";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.de.aol.com";
          tls.enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private5-add.age;
          extraMailboxes = [ ];
        };

        passwordCommand = "cat /run/agenix/mail-private5-pw";
      };

      "private6" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private6-name.age;
        address = unsafeMailAddr ../secrets/mail/private6-add.age;
        userName = unsafeMailAddr ../secrets/mail/private6-add.age;
        imap = {
          host = "imap.gmail.com";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.gmail.com";
          tls.enable = true;
        };
        folders.drafts = "[Gmail]/Drafts";
        folders.sent = "[Gmail]/Sent Mail";
        folders.inbox = "INBOX";
        folders.trash = "Trash";
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private6-add.age;
          extraMailboxes = [ ];
        };
        passwordCommand = "cat /run/agenix/mail-private6-pw";
      };

      "private7" = defaultSettings // {
        realName = unsafeMailAddr ../secrets/mail/private7-name.age;
        address = unsafeMailAddr ../secrets/mail/private7-add.age;
        userName = unsafeMailAddr ../secrets/mail/private7-add.age;
        imap = {
          host = "imap.gmail.com";
          tls.enable = true;
        };
        smtp = {
          host = "smtp.gmail.com";
          tls.enable = true;
        };
        folders.drafts = "[Gmail]/Drafts";
        folders.sent = "[Gmail]/Sent Mail";
        folders.inbox = "INBOX";
        folders.trash = "Trash";
        neomutt = {
          enable = true;
          mailboxName = "-" + unsafeMailAddr ../secrets/mail/private7-add.age;
          extraMailboxes = [ ];
        };
        passwordCommand = "cat /run/agenix/mail-private7-pw";
      };
    };
}
