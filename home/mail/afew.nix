{
  pkgs,
  config,
  inputs,
  ...
}: let
  # Import filter rules from secrets folder
  mailFilters = import "${inputs.secrets}/mail-filters.nix";

  # Get all email account names
  accounts = builtins.attrNames config.accounts.email.accounts;

  # Convert filter rules to afew config format
  generateFilterConfig = filters: let
    formatFilter = idx: filter: ''
      [Filter.${toString idx}]
      message = ${filter.message}
      query = ${filter.query}
      tags = ${filter.tags}
    '';
  in
    pkgs.lib.strings.concatStringsSep "\n"
    (pkgs.lib.imap1 formatFilter filters);

  # MailMover rules must be mutually exclusive. If two folders can each claim
  # the same message, it ping-pongs between them forever: every move rewrites
  # the file (rename = true), so mbsync sees a delete + a brand new message and
  # re-uploads it to the server on every sync, which shows up as a new arrival
  # in every other client.
  #
  # Precedence: deleted > spam > archive > inbox. Each query requires the
  # absence of every higher-precedence tag, so a message carrying conflicting
  # tags has exactly one valid destination and comes to rest there.
  qDeleted = "tag:deleted";
  qSpam = "tag:spam AND NOT tag:deleted";
  qArchive = "tag:archive AND NOT tag:deleted AND NOT tag:spam";
  qInbox = "tag:inbox AND NOT tag:deleted AND NOT tag:spam AND NOT tag:archive";

  # Helper functions for folder names
  getArchiveFolder = acc: let
    accountCfg = config.accounts.email.accounts.${acc};
    hasArchives = builtins.elem "Archives" (accountCfg.neomutt.extraMailboxes or []);
  in
    if hasArchives
    then "Archives"
    else "Archive";

  getSpamFolder = acc: let
    accountCfg = config.accounts.email.accounts.${acc};
    hasSpam = builtins.elem "Spam" (accountCfg.neomutt.extraMailboxes or []);
    hasJunk = builtins.elem "Junk" (accountCfg.neomutt.extraMailboxes or []);
  in
    if hasSpam
    then "Spam"
    else if hasJunk
    then "Junk"
    else "Spam";

  # A rule never targets the folder it is defined on, so each generator emits
  # only the destinations a message can actually leave for.
  ruleFor = acc: folder: destinations:
    "${acc}/${folder} = "
    + pkgs.lib.strings.concatStringsSep " "
    (map (d: "'${d.query}':${acc}/${d.folder}") destinations);

  toTrash = acc: {
    query = qDeleted;
    folder = "Trash";
  };
  toSpam = acc: {
    query = qSpam;
    folder = getSpamFolder acc;
  };
  toArchive = acc: {
    query = qArchive;
    folder = getArchiveFolder acc;
  };
  toInbox = acc: {
    query = qInbox;
    folder = "INBOX";
  };

  # Generate INBOX rules (what should leave INBOX)
  generateInboxMappings = accounts:
    pkgs.lib.strings.concatStringsSep "\n"
    (map (acc: ruleFor acc "INBOX" [(toTrash acc) (toSpam acc) (toArchive acc)]) accounts);

  # Generate Archive rules (leave when re-inboxed, spammed or deleted)
  generateArchiveReverseMappings = accounts:
    pkgs.lib.strings.concatStringsSep "\n"
    (map (acc: ruleFor acc (getArchiveFolder acc) [(toTrash acc) (toSpam acc) (toInbox acc)]) accounts);

  # Generate Spam rules (leave when re-inboxed, archived or deleted)
  generateSpamReverseMappings = accounts:
    pkgs.lib.strings.concatStringsSep "\n"
    (map (acc: ruleFor acc (getSpamFolder acc) [(toTrash acc) (toArchive acc) (toInbox acc)]) accounts);

  # Generate Trash rules (leave when the deleted tag is removed again)
  generateTrashMappings = accounts:
    pkgs.lib.strings.concatStringsSep "\n"
    (map (acc: ruleFor acc "Trash" [(toSpam acc) (toArchive acc) (toInbox acc)]) accounts);

  # Generate rules for extraMailboxes (move messages based on tags)
  generateExtraMailboxMappings = accounts: let
    generateForAccount = acc: let
      accountCfg = config.accounts.email.accounts.${acc};
      extraMailboxes = accountCfg.neomutt.extraMailboxes or [];
      # Filter out folders that are already handled (Archives, Spam, Trash, etc.)
      standardFolders = ["Archives" "Archive" "Spam" "Junk" "Trash" "TRASH"];
      nonStandardMailboxes = builtins.filter (folder: !(builtins.elem folder standardFolders)) extraMailboxes;
    in
      # Don't quote the folder path in the option name - quotes are only for the folders list
      map (folder: ruleFor acc folder [(toTrash acc) (toSpam acc) (toArchive acc) (toInbox acc)]) nonStandardMailboxes;
  in
    pkgs.lib.strings.concatStringsSep "\n"
    (pkgs.lib.lists.flatten (map generateForAccount accounts));

  # Quote folder names if they contain spaces (for shlex.split() compatibility)
  quoteFolderIfNeeded = folder:
    if builtins.match ".*[[:space:]].*" folder != null
    then ''"${folder}"''
    else folder;

  # Generate complete folder list (INBOX + Archive + Spam + Trash + extraMailboxes for all accounts)
  generateAllFolders = accounts: let
    inboxFolders = map (acc: quoteFolderIfNeeded "${acc}/INBOX") accounts;
    archiveFolders = map (acc: quoteFolderIfNeeded "${acc}/${getArchiveFolder acc}") accounts;
    spamFolders = map (acc: quoteFolderIfNeeded "${acc}/${getSpamFolder acc}") accounts;
    trashFolders = map (acc: quoteFolderIfNeeded "${acc}/Trash") accounts;

    # Get all extra mailboxes for all accounts
    extraFolders = pkgs.lib.lists.flatten (map (
        acc: let
          accountCfg = config.accounts.email.accounts.${acc};
          extraMailboxes = accountCfg.neomutt.extraMailboxes or [];
        in
          map (folder: quoteFolderIfNeeded "${acc}/${folder}") extraMailboxes
      )
      accounts);

    allFolders = inboxFolders ++ archiveFolders ++ spamFolders ++ trashFolders ++ extraFolders;
  in
    pkgs.lib.strings.concatStringsSep " " allFolders;
in {
  programs.afew = {
    enable = true;
    extraConfig = ''
      # Global settings for afew mail filtering

      # Folder-to-tag synchronization
      # Maps maildir folders to tags - handles moves from other devices
      #
      # maildir_separator must be "/" - afew defaults to "." and our account
      # directories contain dots, so the default split "rasmus.piorr@web.de/Spam"
      # into the junk tags "rasmus", "piorr@web" and "de/Spam" instead of "Spam".
      # folder_explicit_list keeps the account directory itself from becoming a tag.
      [FolderNameFilter]
      maildir_separator = /
      folder_explicit_list = Spam Junk Bulk Trash Archive Archives Drafts Sent
      folder_transforms = Spam:spam Junk:spam Trash:deleted Bulk:spam Archive:archive Archives:archive Drafts:draft Sent:sent
      folder_blacklist =

      # Spam filter - learns from your spam folder
      [SpamFilter]
      spam_tag = spam

      # Archive sent mails automatically
      [ArchiveSentMailsFilter]
      sent_tag = sent

      # Classify mailing list emails
      [ListMailsFilter]

      # Custom user-defined filters (from secrets/mail-filters.nix)
      ${generateFilterConfig mailFilters.filters}

      # Catchall: tag everything not spam/archive/sent/deleted as inbox.
      # This is the only thing allowed to grant "inbox" - see new.tags in sync.nix,
      # which must stay "new;unread" so that notmuch does not stamp "inbox" onto
      # mail that was delivered straight into a Spam folder.
      [Filter.${toString (builtins.length mailFilters.filters + 1)}]
      message = Catchall for inbox tagging
      query = tag:new AND NOT tag:spam AND NOT tag:archive AND NOT tag:sent AND NOT tag:draft AND NOT tag:deleted
      tags = +inbox;-new

      # Enforce a single state tag, using the same precedence as the MailMover
      # rules below (deleted > spam > archive > inbox).
      #
      # FolderNameFilter only ever adds tags, so a message moved into Spam or
      # Trash on another device gains "spam"/"deleted" while keeping the tag it
      # already had. That pair used to satisfy two MailMover rules at once and
      # bounce the message between folders forever. Collapsing it here keeps the
      # physical folder authoritative, which is what a move on another device
      # means, and leaves exactly one rule able to match.
      [Filter.${toString (builtins.length mailFilters.filters + 2)}]
      message = Deleted wins over every other state tag
      query = tag:deleted AND (tag:inbox OR tag:spam OR tag:archive)
      tags = -inbox;-spam;-archive

      [Filter.${toString (builtins.length mailFilters.filters + 3)}]
      message = Spam wins over archive and inbox
      query = tag:spam AND (tag:inbox OR tag:archive)
      tags = -inbox;-archive

      [Filter.${toString (builtins.length mailFilters.filters + 4)}]
      message = Archive wins over inbox
      query = tag:archive AND tag:inbox
      tags = -inbox

      # Drop the transient "new" marker last, once every filter above has had a
      # chance to see it.
      [Filter.${toString (builtins.length mailFilters.filters + 5)}]
      message = Clear the transient new tag
      query = tag:new
      tags = -new

      # Folder mapping - move emails to folders based on tags
      # This syncs tags to physical folders across machines
      # Automatically generated for all configured accounts
      [MailMover]
      folders = ${generateAllFolders accounts}
      rename = true

      # INBOX rules (auto-generated for each account)
      # Defines what should LEAVE INBOX and where it should go
      ${generateInboxMappings accounts}

      # Archive rules (auto-generated for each account)
      # Move back to INBOX when inbox tag is added
      ${generateArchiveReverseMappings accounts}

      # Spam rules (auto-generated for each account)
      # Move back to INBOX when inbox tag is added
      ${generateSpamReverseMappings accounts}

      # Trash rules (auto-generated for each account)
      # Move back to INBOX when inbox tag is added
      ${generateTrashMappings accounts}

      # Extra mailbox rules (auto-generated for each account)
      # Move messages from extra folders based on tags
      ${generateExtraMailboxMappings accounts}
    '';
  };
}
