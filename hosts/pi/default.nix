{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pi";

  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # nixpkgs.buildPlatform.system = "x86_64-linux";
  # nixpkgs.hostPlatform.system = "aarch64-linux";

  # boot = {
  #   # Bootloader.
  #   loader = {
  #     systemd-boot.enable = true;
  #     systemd-boot.configurationLimit = 4;
  #     efi.canTouchEfiVariables = true;
  #     # efi.efiSysMountPoint = "/boot/efi";
  #   };

  #   # Setup keyfile
  #   #initrd.secrets = {
  #   #  "/crypto_keyfile.bin" = null;
  #   #};
  # };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "bluetooth"
      "radio_browser"
      "zha"
      "jellyfin"
      "pocketcasts"
      "advantage_air"
      "air_quality"
      "anthropic"
      "caldav"
      "cpuspeed"
      "dwd_weather_warnings"
      "device_tracker"
      "fitbit"
      "google_assistant"
      "nina"
      "notify"
      "google_translate"
      "cast"
      "mqtt"
      "transmission"
      "sonarr"
      "radarr"
      "tailscale"
      "waqi"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {
      };
      "automation ui" = "!include automations.yaml";
    };
  };
  # networking.firewall.allowedTCPPorts = [8123];

  systemd = {
    targets.network-online.wantedBy = pkgs.lib.mkForce []; # Normally ["multi-user.target"]
    services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce []; # Normally ["network-online.target"]
  };

  # hardware.bluetooth.enable = true;
}
