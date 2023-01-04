let
  spacedesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOgqzPfWz5wPdnfM6PsQ+vsVbuGsfYDeFWphe0U5gw8";

  admins = [ spacedesktop ];
in
{
  "secret1.age".publicKeys = admins;
}
