{pkgs, ...}: {
  services.xserver = {
    enable = true;
    # displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    xkb.layout = "de";
    xkb.variant = "";

    libinput = {
      enable = true;
      # disable mouse acceleration
      mouse.accelProfile = "flat";
      mouse.accelSpeed = "0";
      mouse.middleEmulation = false;
      # touchpad settings
      touchpad.naturalScrolling = true;
    };
  };
  programs.chromium.plasmaBrowserIntegrationPackage = pkgs.libsForQt5.plasma-browser-integration;
}
