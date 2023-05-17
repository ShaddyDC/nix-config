{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./mail.nix
  ];

  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 4;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    # Setup keyfile
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };
  };

  networking.networkmanager.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    layout = "de";
    xkbVariant = "";


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

  security.pam.services = {
    gdm.enableKwallet = true;
    kdm.enableKwallet = true;
    lightdm.enableKwallet = true;
    sddm.enableKwallet = true;
    slim.enableKwallet = true;

    swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  programs.light.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.hidpi = true;
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  # hardware.pulseaudio.enable =  false; # TODO check
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    lowLatency.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.space = {
    isNormalUser = true;
    description = "space";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = [ ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;  [
    vlc
    mpv
    zathura
    okular

    ripgrep
    youtube-dl
    gcc
    pandoc
    gdb

    inputs.agenix.packages.x86_64-linux.default
    inputs.deploy-rs.packages.${pkgs.system}.deploy-rs
    rage

    direnv
    keepassxc
    chromium

    # Nix languages
    nixpkgs-fmt
    nil

    kwallet-pam
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  age.secrets.vdirsyncer-config = {
    file = ../secrets/vdirsyncer.config.age;
    owner = config.users.users.space.name;
  };

  services.flatpak.enable = true;
  programs.kdeconnect.enable = true;


  fonts.fonts = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
    (nerdfonts.override { fonts = [ "3270" "JetBrainsMono" ]; })
  ];
  #   fonts.fontconfig.defaultFonts = {
  #     monospace = [
  #       "JetBrainsMono"
  #       "IPAGothic"
  #     ];
  #     sansSerif = [
  #       "DejaVu Sans"
  #       "IPAPGothic"
  #     ];
  #     serif = [
  #       "DejaVu Serif"
  #       "IPAPMincho"
  #     ];
  #   };
  #   i18n = {
  #     inputMethod = {
  #       enabled = "fcitx5";
  #       fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  #       fcitx5.addons = with pkgs; [
  #         fcitx5-mozc
  #         fcitx5-gtk
  #       ];
  #     };
  #   };
}
