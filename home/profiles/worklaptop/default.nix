{pkgs, ...}: {
  imports = [
  ];

  home.packages = with pkgs; [
    awscli2
  ];
}
