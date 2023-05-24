{pkgs, ...}: let
  imgviewer = pkgs.feh;
in {
  home.packages = with pkgs; [
    urlscan
    ripmime
    elinks
  ];

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
        map = ["index" "pager"];
      }
      {
        action = "<pipe-message> urlscan<Enter>";
        key = "B";
        map = ["pager"];
      }
      {
        action = "<pipe-message> ripmime -i - -d ~/Downloads && rm ~/Downloads/textfile*<Enter>";
        key = "S";
        map = ["pager"];
      }
      {
        action = "<save-message>+Archive<Enter><Enter>";
        key = "n2";
        map = ["index"];
      }
      {
        action = "<save-message>+INBOX<Enter><Enter>";
        key = "n3";
        map = ["index"];
      }
    ];

    binds = [
      {
        action = "sidebar-prev";
        key = "<up>";
        map = ["index" "pager"];
      }
      {
        action = "sidebar-next";
        key = "<down>";
        map = ["index" "pager"];
      }
      {
        action = "sidebar-open";
        key = "<right>";
        map = ["index" "pager"];
      }

      {
        action = "toggle-new";
        key = "n1";
        map = ["index"];
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

  home.file.".config/neomutt/mailcap".text = ''
    text/html; ${pkgs.elinks}/bin/elinks -dump %s; copiousoutput;

    # PDF documents
    application/pdf; ${pkgs.zathura}/bin/zathura %s

    # Images
    image/jpg; ${imgviewer}/bin/feh %s
    image/jpeg; ${imgviewer}/bin/feh %s
    image/pjpeg; ${imgviewer}/bin/feh %s
    image/png; ${imgviewer}/bin/feh %s
    image/gif; ${imgviewer}/bin/feh %s
  '';
}
