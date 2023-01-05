let
  spacedesktop-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6e+0AggPaLNrl7Qurh1yEIHqR+8fVCSyL898zi1vBl";

  spacedesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOgqzPfWz5wPdnfM6PsQ+vsVbuGsfYDeFWphe0U5gw8";

  admins = [ spacedesktop-user ];
  mail = [ spacedesktop ] ++ admins;
in
{
  "mail/shaddy-mail-add.age".publicKeys = mail;
  "mail/shaddy-mail-pw.age".publicKeys = mail;
  "mail/shaddy2-pw.age".publicKeys = mail;
  "mail/private1-ser.age".publicKeys = mail;
  "mail/private1-pw.age".publicKeys = mail;
  "mail/private1-name.age".publicKeys = mail;
  "mail/private1-add.age".publicKeys = mail;
  "mail/private2-pw.age".publicKeys = mail;
  "mail/private2-name.age".publicKeys = mail;
  "mail/private2-add.age".publicKeys = mail;
  "mail/private3-pw.age".publicKeys = mail;
  "mail/private3-name.age".publicKeys = mail;
  "mail/private3-add.age".publicKeys = mail;
  "mail/private4-pw.age".publicKeys = mail;
  "mail/private4-name.age".publicKeys = mail;
  "mail/private4-add.age".publicKeys = mail;
  "mail/private5-pw.age".publicKeys = mail;
  "mail/private5-name.age".publicKeys = mail;
  "mail/private5-add.age".publicKeys = mail;
  "mail/private5-use.age".publicKeys = mail;
  "mail/private6-pw.age".publicKeys = mail;
  "mail/private6-name.age".publicKeys = mail;
  "mail/private6-add.age".publicKeys = mail;
  "mail/private7-pw.age".publicKeys = mail;
  "mail/private7-name.age".publicKeys = mail;
  "mail/private7-add.age".publicKeys = mail;
}
