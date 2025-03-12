{...}: {
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    # displayManager.sddm.enable = true;

    # Configure keymap in X11
    xkb.layout = "de";
    xkb.variant = "";
  };
  services.libinput = {
    enable = true;
    # disable mouse acceleration
    mouse.accelProfile = "flat";
    mouse.accelSpeed = "0";
    mouse.middleEmulation = false;
    # touchpad settings
    touchpad.naturalScrolling = true;
  };
}
