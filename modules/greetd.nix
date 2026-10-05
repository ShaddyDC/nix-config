{...}: {
  services.displayManager.regreet.enable = true;

  # Unlock the keyrings with the login password. kwallet's ksecretd is the
  # session's Secret Service; its pam_kwallet_init runs at Hyprland startup.
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.greetd.kwallet.enable = true;
}
