{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    # ./mail.nix
  ];

  # programs.atuin = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   enableNushellIntegration = true;
  # };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
