let
  spacedesktop-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6e+0AggPaLNrl7Qurh1yEIHqR+8fVCSyL898zi1vBl";

  spacedesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOgqzPfWz5wPdnfM6PsQ+vsVbuGsfYDeFWphe0U5gw8";

  admins = [ spacedesktop-user ];
in
{
  "shaddy-mail-add.age".publicKeys = [ spacedesktop ] ++ admins;
  "shaddy-mail-pw.age".publicKeys = admins;
}
