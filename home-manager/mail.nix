{ inputs, pkgs, config, ... }: {
  # programs.neomutt.enable = true;
  # programs.mbsync.enable = true;
  # programs.notmuch.enable = true;
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sidebar = {
      enable = true;
    };

    macros = [
      {
        action = "<shell-escape>mbsync -a<enter>";
        key = "O";
        map = [ "index" "pager" ];
      }
    ];
    # extraConfig.general.unsafe-accounts-conf = true;

  };
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  accounts.email.maildirBasePath = "Mail";

  # rage --decrypt -i /etc/ssh/ssh_host_ed25519_key shaddy-mail.age

  accounts.email.accounts =
    # let unsafeMailAddr = file: exec [ "rage" "--decrypt" "-i" "~/.ssh/user" file ];
    let
      unsafeMailAddr = file: builtins.extraBuiltins.unsafeEvalTimeDecryptAsString "${config.home.homeDirectory}/.ssh/id_ed25519" file;
      # let unsafeMailAddr = file: builtins.readFile file; # ANTI PATTERN, BUT FINE FOR MAIL ADDRESS
    in
    {
      "shaddy" = {
        address = unsafeMailAddr ../secrets/shaddy-mail-add.age;
        realName = "Shaddy";
        userName = unsafeMailAddr ../secrets/shaddy-mail-add.age;
        primary = true;
        imap = {
          host = "mail.shaddy.dev";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "mail.shaddy.dev";
          port = 465;
          tls.enable = true;
        };
        folders.inbox = "INBOX";
        folders.drafts = "Drafts";
        folders.sent = "Sent";
        folders.trash = "Trash";
        offlineimap.enable = true;
        neomutt = {
          enable = true;
          extraMailboxes = [ "Junk" ];
        };
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
        };
        msmtp.enable = true;
        passwordCommand = "cat /run/agenix/shaddy-mail";
      };
    };
}
