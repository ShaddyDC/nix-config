{
  pkgs,
  config,
  ...
}: let
  # Import filter rules from secrets folder
  mailFilters = import ../../secrets/mail-filters.nix;

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


  # Generate folder mappings for Archive
  generateArchiveMappings = accounts: let
    # Get the account config to check folder names
    getArchiveFolder = acc: let
      accountCfg = config.accounts.email.accounts.${acc};
      # Some accounts use "Archives", some use "Archive"
      hasArchives = builtins.elem "Archives" (accountCfg.neomutt.extraMailboxes or []);
    in
      if hasArchives then "Archives" else "Archive";

    formatMapping = acc:
      "${acc}/${getArchiveFolder acc} = tag:archive AND folder:\"${acc}/**\"";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Generate folder mappings for Spam/Junk
  generateSpamMappings = accounts: let
    getSpamFolder = acc: let
      accountCfg = config.accounts.email.accounts.${acc};
      # Check if account has Spam or Junk in extraMailboxes
      hasSpam = builtins.elem "Spam" (accountCfg.neomutt.extraMailboxes or []);
      hasJunk = builtins.elem "Junk" (accountCfg.neomutt.extraMailboxes or []);
    in
      if hasSpam
      then "Spam"
      else if hasJunk
      then "Junk"
      else "Spam"; # default

    formatMapping = acc:
      "${acc}/${getSpamFolder acc} = tag:spam AND folder:\"${acc}/**\"";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Helper functions for folder names
  getArchiveFolder = acc: let
    accountCfg = config.accounts.email.accounts.${acc};
    hasArchives = builtins.elem "Archives" (accountCfg.neomutt.extraMailboxes or []);
  in
    if hasArchives then "Archives" else "Archive";

  getSpamFolder = acc: let
    accountCfg = config.accounts.email.accounts.${acc};
    hasSpam = builtins.elem "Spam" (accountCfg.neomutt.extraMailboxes or []);
    hasJunk = builtins.elem "Junk" (accountCfg.neomutt.extraMailboxes or []);
  in
    if hasSpam then "Spam" else if hasJunk then "Junk" else "Spam";

  # Generate INBOX rules (what should leave INBOX)
  generateInboxMappings = accounts: let
    formatMapping = acc:
      "${acc}/INBOX = 'tag:archive':${acc}/${getArchiveFolder acc} 'tag:spam':${acc}/${getSpamFolder acc} 'tag:deleted':${acc}/Trash";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Generate Archive rules (move back to INBOX when inbox tag is added, or to Trash when deleted)
  generateArchiveReverseMappings = accounts: let
    formatMapping = acc:
      "${acc}/${getArchiveFolder acc} = 'tag:inbox':${acc}/INBOX 'tag:deleted':${acc}/Trash";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Generate Spam rules (move back to INBOX when inbox tag is added, or to Trash when deleted)
  generateSpamReverseMappings = accounts: let
    formatMapping = acc:
      "${acc}/${getSpamFolder acc} = 'tag:inbox':${acc}/INBOX 'tag:deleted':${acc}/Trash";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Generate Trash rules (move back to INBOX when inbox tag is added)
  generateTrashMappings = accounts: let
    formatMapping = acc:
      "${acc}/Trash = 'tag:inbox':${acc}/INBOX";
  in
    pkgs.lib.strings.concatStringsSep "\n"
      (map formatMapping accounts);

  # Generate rules for extraMailboxes (move messages based on tags)
  generateExtraMailboxMappings = accounts: let
    formatMapping = acc: folder:
      # Don't quote the folder path in the option name - quotes are only for the folders list
      "${acc}/${folder} = 'tag:inbox':${acc}/INBOX 'tag:archive':${acc}/${getArchiveFolder acc} 'tag:spam':${acc}/${getSpamFolder acc} 'tag:deleted':${acc}/Trash";

    generateForAccount = acc: let
      accountCfg = config.accounts.email.accounts.${acc};
      extraMailboxes = accountCfg.neomutt.extraMailboxes or [];
      # Filter out folders that are already handled (Archives, Spam, Trash, etc.)
      standardFolders = ["Archives" "Archive" "Spam" "Junk" "Trash" "TRASH"];
      nonStandardMailboxes = builtins.filter (folder: !(builtins.elem folder standardFolders)) extraMailboxes;
    in
      map (folder: formatMapping acc folder) nonStandardMailboxes;
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
    extraFolders = pkgs.lib.lists.flatten (map (acc: let
      accountCfg = config.accounts.email.accounts.${acc};
      extraMailboxes = accountCfg.neomutt.extraMailboxes or [];
    in
      map (folder: quoteFolderIfNeeded "${acc}/${folder}") extraMailboxes
    ) accounts);

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
      # Processes all folders, transforms known ones, catchall filter tags the rest
      [FolderNameFilter]
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

      # Catchall: tag everything not spam/archive/sent/deleted as inbox
      [Filter.${toString (builtins.length mailFilters.filters + 1)}]
      message = Catchall for inbox tagging
      query = NOT tag:spam AND NOT tag:archive AND NOT tag:sent AND NOT tag:draft AND NOT tag:deleted
      tags = +inbox

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
